pipeline {
    
    //Makes the pipeline able to run with parameters in order to select stages to build depending on parameter selection
    parameters {
        choice choices: ['Apply', 'Destroy', 'Ansible'], description: 'Terraform step to run', name: 'tfstep'
    }
    
    //Makes this pipeline to run only on this specific agent
    agent {
        label 'agent2'
    }
    
    //Selection of tools to be used
    tools {
        terraform 'terraform-jenkins-linux' //Uses the terraform installer for linux (tool needs to be configured)
    }
    
    //Environnment variables for this particular pipeline
    environment {
        //Fetchs the credentials configured in the Jenkins credentials manager
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1" //Allows to set the default AWS region if in the TF config file is not declared
    }
    
    stages {
        
        //SCM checkout. If params Apply or Ansible are selected, this stage will be built
        stage('Checkout') {
            when {
                expression { params.tfstep == 'Apply' || params.tfstep == 'Ansible' }
            }
            
            steps {
                git branch: 'main', url: 'https://github.com/yahasop/capstone-project.git'
            }
        }
        
        //Performs a terraform init to download provider plugins and configurations
        //Also a terraform fmt to format the TF configuration to a canoncial style
        stage('Init/Format') {
            
            when {
                expression { params.tfstep == 'Apply' }
            }
            
            steps {
                sh 'terraform init'
                sh 'terraform fmt'
            }
        }

        //This outputs the plan (resources to be deployed) into a file
        //Then the apply is done reading that file
        stage('Plan/Provisioning') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            
            steps {
                sh 'terraform plan -out tf-plan'
                sh 'terraform apply tf-plan' //No approval is needed when applying the plan from a file
            }
        }
        
        //To use the created instances after the apply, public IP's are needed
        //The terraform output with the jq tool transform the output into just the needed IP's
        //Then redirects them into a file, later to be used in next stages
        stage('GetInstancesIP') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            
            steps {
                sh 'terraform output -json | jq -r \'.["instances-ip"].value[0][]\' > instances-ip.txt'
            }
        }
        
        //This step will only be performed when the Destroy parameter is selected. Destroys all the infrastructure
        stage('Destroying') {
            when {
                expression { params.tfstep == 'Destroy' }
            }
            
            steps {
                sh 'terraform destroy --auto-approve'
            }
        }
        
        //The next steps are conditioned to the Ansible parameter
        //This runs some steps to prepare the ansible main playbooy runs
        stage('Running Ansible (Preparation)') {
            when {
                expression { params.tfstep == 'Ansible' }
            }

            steps {
                sh 'chmod u+x create-inv.sh' //Makes the script executable
                sh 'sudo ./create-inv.sh' //Executes the script with sudo permissions
                sh 'sshpass -p ubuntu ansible-playbook -i ./ansible/hosts ./ansible/add-sudoers.yml -u ubuntu -k'
            }
        }

        stage('Running Ansible (Installing Docker)') {
            when {
                expression { params.tfstep == 'Ansible' }
            }

            steps {
                sh 'ansible-playbook -i ./ansible/hosts ./ansible/main.yml'
            }
        }
    }
}