pipeline {
    parameters {
        choice choices: ['Apply', 'Destroy'], description: 'Terraform step to run', name: 'tfstep'
    }
    
    agent {
        label 'built-in'
    }
    
    tools {
        terraform 'terraform-jenkins-mac'
    }
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    
    stages {

        stage('Checkout') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            steps {
                git branch: 'agent', url: 'https://github.com/yahasop/capstone-project.git'
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
        
        stage('Get Instance IP') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            steps {
                sh 'terraform output'
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
    }
}