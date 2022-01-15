pipeline {
   parameters {
       choice(name: 'action', choices: 'create\ndestroy', description: 'Create/update or destroy the eks cluster.')
       string(name: 'cluster', defaultValue : 'demo', description: "EKS cluster name;eg demo creates cluster named eks-demo.")
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
                currentBuild.displayName = "#" + env.BUILD_NUMBER + " " + params.action + " eks-" + params.cluster
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
                      terraform apply -auto-approve ${plan}
                      terraform output kubectl_config > $HOME/.kube/config
                      chown $(id -u):$(id -g) $HOME/.kube/config
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
                      terraform workspace select ${params.cluster}
                      terraform destroy -auto-approve
                  """
              }
          }
      }
    }
  }
}

