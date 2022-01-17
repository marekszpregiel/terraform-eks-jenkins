pipeline {
   parameters {
       choice(name: 'action', choices: 'create\ndestroy\ndeploy\nshow', description: 'Create/update/destroy the eks cluster or deploy new version of pod and service in k8s.')
       string(name: 'cluster', defaultValue : 'eks-cluster', description: "EKS cluster name.")
   }
  
  agent any
  tools {
      terraform 'terraform'
  } 
  stages {
    stage('checkout') {
        steps {
            git branch: 'main',
                credentialsId: 'GITHUB_Credentials',
                url: 'https://github.com/marekszpregiel/terraform-eks-jenkins'
        }
    }
    stage('Setup') {
        steps {
            script {
                currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + " " + params.cluster
                plan = params.cluster + '.plan'
            }
        }
    }
    stage('Set Terraform path') {
        steps {
            sh 'terraform version'
        }
    }
    stage('TF Plan') {
      when {
          expression { params.action == 'create' }
      }    
        steps {
            script {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_Credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh """
                    PATH=$PATH:$HOME/bin
                    terraform init
                    terraform workspace new ${params.cluster} || true
                    terraform workspace select ${params.cluster}
                    terraform plan -out=${plan}
                """
                }
        }
      }
    }
    stage('TF Apply') {
      when {
        expression { params.action == 'create' }
      }    
      steps {
          script {
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_Credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                  if (fileExists('$HOME/.kube')) {
                      echo '.kube Directory Exists'
                  } else {
                      sh 'mkdir -p $HOME/.kube'
                  }
                  sh """
                      PATH=$PATH:$HOME/bin
                      terraform apply -auto-approve ${plan}
                      terraform output kubectl_config > $HOME/.kube/config
                      sed -i '/EOT/d' $HOME/.kube/config
                      sed -i '/^\$/d' $HOME/.kube/config
                      chown \$(id -u):\$(id -g) $HOME/.kube/config
                      kubectl get nodes
                  """
              }
          }
      }
    }
    stage('TF Destroy') {
      when {
          expression { params.action == 'destroy' }
      }
      steps {
          script {
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_Credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                  sh """
                      PATH=$PATH:$HOME/bin
                      kubectl get deployment | grep deer && (kubectl delete -f deer-deployment.yml)
                      kubectl get service | grep deer && (kubectl delete -f deer-service-loadbalancer.yml)
                      terraform workspace select ${params.cluster}
                      terraform destroy -auto-approve
                      rm -rf /root/.kube/*
                  """
              }
          }
      }
    }
    stage('K8S Deploy') {
      when {
        expression { params.action == 'deploy' }
      }
      steps {
          script {
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_Credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                  sh """
                      PATH=$PATH:$HOME/bin
                      kubectl apply -f k8s/deer-deployment.yml
                      kubectl apply -f k8s/deer-service-loadbalancer.yml
                  """
              }
          }
      }
    }
    stage('K8S Show') {
      when {
        expression { params.action == 'show' }
      }
      steps {
          script {
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_Credentials', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                  sh """
                      PATH=$PATH:$HOME/bin
                      kubectl get service/deer-service-loadbalancer | awk {'print \$1" " \$2 " " \$4 " " \$5'} | column -t
                      kubectl get nodes
                      kubectl get all
                      kubectl get pods -o wide
                  """
              }
          }
      }
    }
  }
}

