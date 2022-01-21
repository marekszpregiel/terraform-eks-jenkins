# EKS Getting Started with Jenkins and terraform

The repo you are looking at gives you the opportunity to create your very own EKS cluster in AWS using Jenkins pipeline.

## First configuration
**1.** During the first configuration, you must remember to add AWS Credentails to Jenkins.
You can do it this way: 
![alt text](https://github.com/marekszpregiel/terraform-eks-jenkins/blob/main/images/aws_credentials.jpg?raw=true)

**Fields:**  
ID: AWS_Credentials  
Access Key ID: \<you own Access Key>  
Secret Access Key: \<Your own Secret Access Key>  

These are the same values as required for "aws configure".  
![alt text](https://github.com/marekszpregiel/terraform-eks-jenkins/blob/main/images/aws_configure.jpg?raw=true)
  
More information on how to get them you can find at the link below.  
[AWS Quickstart](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

**2.** Next you must create "New Project".  
Set the name of your project and choose option "Pipeline". Click "OK"  
![alt text](https://github.com/marekszpregiel/terraform-eks-jenkins/blob/main/images/new_job_1.jpg?raw=true)

Then select an option **"This project is parametrized"**  
![alt text](https://github.com/marekszpregiel/terraform-eks-jenkins/blob/main/images/new_job_2.jpg?raw=true)

and for the **"Pipeline"** section complete the fields as below.  
**Definition:** Pipeline script from SCM  
**SCM:** Git  
**Repository URL:** https://github.com/marekszpregiel/terraform-eks-jenkins.git  
**Credentials:** -none-  
**Branch Specifier (blank for 'any'):** */main  
**Repository browser:** (Auto)  
**Script Path:** Jenkinsfile  

![alt text](https://github.com/marekszpregiel/terraform-eks-jenkins/blob/main/images/new_job_3.jpg?raw=true)


**3.** Now all that's left to do is run the task. 

![alt text](https://github.com/marekszpregiel/terraform-eks-jenkins/blob/main/images/jenkins_stage_view.jpg?raw=true)
