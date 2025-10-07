pipeline {

    //Makes the pipeline able to run with parameters in order to select stages to build depending on parameter selection
    parameters {
        choice choices: ['Apply', 'Destroy'], description: 'Terraform step to run', name: 'tfstep'
    }
    
    //Makes this pipeline to run only on this specific agent
    agent {
        label 'built-in' //The buil-in node (where Jenkins is installed) is labeled as built-in to enforce this pipeline runs only into the local machine
    }
    
    //Selection of tools to be used
    tools {
        terraform 'terraform-jenkins-linux' //Uses the terraform installer for mac as this pipeline runs on a local MacOS environment (tool needs to be configured)
    }
    
    //Environnment variables for this particular pipeline
    environment {
        //Fetchs the credentials configured in the Jenkins credentials manager
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    
    stages {

        //SCM checkout on repo's agent branch. If param Apply is selected, this stage will be built
        stage('Checkout') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            steps {
                git branch: 'agent', url: 'https://github.com/yahasop/capstone-project.git'
            }
        }
        
        //Performs a terraform init to download provider plugins and configurations
        stage('Initialization') {
            when {
                expression { params.tfstep == 'Apply' }
            }        
            steps {
                sh 'terraform init'
            }
        }

        //This auto-approves the terraform apply to provision the agent
        stage('Provisioning') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            steps {
                sh 'terraform apply --auto-approve' //The auto-approve skips the interactive approval
            }
        }
        
        //This stage outputs into the console the provisioned instance's IP
        stage('Get Instance IP') {
            when {
                expression { params.tfstep == 'Apply' }
            }
            steps {
                sh 'terraform output' //Output the instance IP to be used in the Jenkins node configuration
            }
        }
        
        //If param Destroy is selected, this stage runs, destroying the resources.
        stage('Destroying') {
            when {
                expression { params.tfstep == 'Destroy' }
            }
            steps {
                sh 'terraform destroy --auto-approve' //The auto-approve skips the interactive approval
            }
        }
    }
}