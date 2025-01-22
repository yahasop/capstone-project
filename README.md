# Capstone Project - Infrastructure

Standalone repository to deploy some resources to test, build and deploy a sample Java application.

## Introduction

The purpose of this project is to demonstrate the use of several tools and also to integrate them and make them working together. This project tries to automatize almost all the flow from provisioning the resources to build the architecture the application will run on, to the automated testing, building and deployment of the application implementing always newer versions of it.
Some of the tools that are being integrated in this project are:
* Jenkins
* Terraform
* AWS (but not attached strictly to it)
* Ansible
* Docker
* Git
* Scripting (Bash/Python)
* Linux

## Getting Started

This repo covers the first part of the project which is the provision of the resources to build the infrastructure where the application will be deployed

### Dependencies

The main tool that is used for this repo is Jenkins along with Terraform and Ansible. A Jenkins instance needs to be installed as a standalone application or within a container. The Jenkinsfile, and even the Terraforn and Ansible configuration files, have strict configurations attached to a particular stack, but being able to easily changed to adapt to other specific stack. This repo depends of some manual configurations that needs to be done within the UI.

### Jenkins Manual Configurations

#### Plugins
Dashboard > Manage Jenkins > Plugins > Available Plugins
* Terraform
* Ansible
* AWS Credentials
* Maven Integration
* Github Integration
* Paramaterized Trigger
* Pipeline Stage View
* Warnings

#### Credentials
Dashboard > Manage Jenkins > Credentials > System > Global Credentials > Add Credentials
* AWS Access Key ID
    * Kind: Secret text
    * Scope: Global
    * Secret: A valid account AWS Access Key ID
    * ID: AWS_ACCESS_KEY_ID
    * Description: Optional
* AWS Secret Access Key
    * Kind: Secret text
    * Scope: Global
    * Secret: A valid account AWS Secret Access Key
    * ID: AWS_SECRET_ACCESS_KEY
    * Description: Optional
* Credentials for VM's
    * Kind: Username with password
    * Scope: Global
    * Username: ubuntu
    * Password: ubuntu
    * ID: ubuntuCreds
    * Description: Optional
* Token fo GH Access
    * Kind: Secret text
    * Scope: Global
    * Secret: GitHub Access Token
    * ID: Github token to access this repo
    * Description: Optional

#### Tools
Dashboard > Manage Jenkins > Tools (Need to install the plugins first)
* Ansible as 'ansible-jenkins-linux' with tool home: /home/ubuntu/jenkins/tools and installed automatically with shell commands:
    ```
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt update -y
    sudo apt install ansible -y
    ```
* Terraform installed automatically with bintray.com 
    * 'terraform-jenkins-linux' with version linux amd64 
    * 'terraform-jenkins-mac' with version darwin amd64
* Maven as 'maven-jenkins' and installed from Apache, version 3.9.9

#### Nodes
Dashboard > Manage Jenkins > Nodes > New Node
* Builtin node
    * Number of executors: 2
    * Labels: built-in
    * Usage: Only builds jobs with label expressions matching this node
* Node 'agent2'
    * Name: agent2
    * Number of executors: 2
    * Remote root directory: /home/ubuntu/jenkins
    * Labels: agent2
    * Usage: As much as possible
    * Launch method: Launch agents via SSH
    * Host: `JenkinsAgentVM_PUBLICIP` (Provided after provision-agent pipeline is build)
    * Credentials: ubuntuCreds
    * Host Key Verification Strategy: Non verifying Verification Strategy (not recommended)
    * Availability: Keep this agent online as much as possible

#### Pipelines
Dashboard > New Item > Pipeline
* To provision Jenkins agent. Name: provision-agent
    * Definition: Pipeline script from SCM
    * Repository URL: This repo URL
    * Credentials: none
    * Branches to build: */agent
    * Script path: Jenkinsfile
* To provision all the resources to deploy the application. Name: provision-infrastructure
    * Definition: Pipeline script from SCM
    * Repository URL: This repo URL
    * Credentials: none
    * Branches to build: */main
    * Script path: Jenkinsfile

## Executing pipelines
The intention of this project is to automate almost everything that can be automatized. In this scenario only one manual step needs to be performed.
When the first pipeline is build, the console output will provide us the IP address of the Jenkins Agent. This IP needs to be put on the node configuration for 'agent2' in the host field
Some other semi-manual steps are the ones within the pipelines. These pipelines are parameterized and depending on which option is selected, it'll run specific steps.
* The povision-agent pipeline have two parameters:
    * Apply: Runs all the necessary steps until the resources are provisioned
    * Destroy: Runs a deprovisioning of the infrastructure based on the Terraform state
* The provision-infrastructure pipeline have three parameters
    * Apply: Runs all the necessary steps until the resources are provisioned
    * Destroy: Runs a deprovisioning of the infrastructure based on the Terraform state
    * Ansible: Runs the Ansible playbooks once the resources are provisioned


# Architecture

<img width="1042" alt="Architecture Diagram" src="./ArchitectureDiagram.png">

<img width="1042" alt="Project Diagram" src="./ProjectDiagram.png">
