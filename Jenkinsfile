pipeline {
    
    parameters {
        choice choices: ['Apply', 'Destroy', 'Ansible'], description: 'Terraform step to run', name: 'tfstep'
    }
    
    agent {
        label 'agent2'
    }
    
    tools {
        terraform 'terraform-jenkins-linux'
        ansible 'ansible-jenkins-linux'
    }
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
    }
    
    stages {

        stage('Checkout') {
            when {
                expression { params.tfstep == 'Apply' || params.tfstep == 'Ansible' }
            }
            
            steps {
                git branch: 'main', url: 'https://github.com/yahasop/capstone-project.git'
            }
        }
        
        stage('Initialization') {
            
            when {
                expression { params.tfstep == 'Apply' }
            }
            
            steps {
                sh 'terraform init'
            }
        }

        stage('Provisioning') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
        
        stage('Get Instances IP') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            
            steps {
                sh 'terraform output -json | jq -r \'.["instances-ip"].value[0][]\' > instances-ip.txt'
                sh 'cat instances-ip.txt'
            }
        }
        
        stage('Destroying') {
            when {
                expression { params.tfstep == 'Destroy' }
            }
            
            steps {
                sh 'terraform destroy --auto-approve'
            }
        }
        
        stage('Running Ansible (Preparation)') {
            when {
                expression { params.tfstep == 'Ansible' }
            }

            steps {
                sh 'chmod u+x create-inv.sh'
                sh 'sudo ./create-inv.sh'
                sh 'ansible --version'
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