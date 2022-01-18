// Define variables
def tmpVariable = "eks-cluster"

//Pipeline
pipeline {
   parameters {
       choice(name: 'action', choices: 'create\ndestroy\ndeploy\nshow', description: 'Create/update/destroy the eks cluster.\nDeploy new version of deployment and service in k8s.\nShow information from k8s.')
   }
  
  agent any
  tools {
      terraform 'terraform'
  } 
  stages {
    stage('Checkout') {
        steps {
            git branch: 'main',
                credentialsId: 'GITHUB_Credentials',
                url: 'https://github.com/marekszpregiel/terraform-eks-jenkins'
        }
    }
    stage('Setup') {
        steps {
            script {
                currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + " " + tmpVariable
                plan = tmpVariable + '.plan'
            }
        }
    }
    stage('Get Terraform version') {
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
                    terraform init
                    terraform workspace new ${tmpVariable} || true
                    terraform workspace select ${tmpVariable}
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
                      terraform apply -auto-approve ${plan}
                      terraform output kubectl_config > $HOME/.kube/config
                      sed -i '/EOT/d' $HOME/.kube/config
                      sed -i '/^\$/d' $HOME/.kube/config
                      chown \$(id -u):\$(id -g) $HOME/.kube/config
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
                      kubectl get deployment | grep deer && (kubectl delete -f k8s/deer-deployment.yml)
                      kubectl get service | grep deer && (kubectl delete -f k8s/deer-service-loadbalancer.yml)
                      sleep 30
                      terraform workspace select ${tmpVariable}
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
                      kubectl get service/deer-service-loadbalancer | awk {'print \$4'} || echo 'Service deer-service-loadbalancer is not active'
                      kubectl get nodes
                      kubectl get all --all-namespaces
                      kubectl get pods -o wide --all-namespaces
                  """
              }
          }
      }
    }
  }
}

