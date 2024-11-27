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
* Nexus

## Getting Started

### Dependencies

The main tool that is used for this project is Jenkins. A Jenkins instance needs to be installed as a standalone application or within a container. The Jenkinsfile, and even the Terraforn and Ansible configuration files, have strict configurations attached to a particular stack, but being able to easily changed to adapt to other specific stack. Mainly, this repo depends of some manual configurations that needs to be done within the UI.

### Jenkins Manual Configurations

* Plugins
    * Terraform
    * Ansible
    * Paramaterized Trigger
    * Pipeline Stage View

* Credentials
    * AWS_ACCESS_KEY_ID as Secret Text kind
    * AWS_SECRET_ACCESS_KEY as Secret Text kind
    * ubuntu: VM's user and password as Username with Password kind (The same as shows in the user_data.sh)

* Tools
    * Ansible as 'ansible-jenkins-linux' with tool home: /home/ubuntu/jenkins/tools and installed automatically with shell commands:
        * sudo apt-add-repository ppa:ansible/ansible
        * sudo apt update -y
        * sudo apt install ansible -y
    * Terraform installed automatically with bintray.com 
        * 'terraform-jenkins-linux' with version linux amd64 
        * 'terraform-jenkins-mac' with version darwin amd64
    * Maven as 'maven-jenkins' and installed from Apache, version 3.9.9

* Nodes
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
        * Host: Jenkins-Agent VM IP
        * Credentials: ubuntu
        * Host Key Verification Strategy: Non verifying Verification Strategy (not recommended)
        * Availability: Keep this agent online as much as possible


### Executing program

* How to run the program
* Step-by-step bullets
```
code blocks for commands
```

## Help

Any advise for common problems or issues.
```
command to run if program contains helper info
```

## Authors

Contributors names and contact info

ex. Dominique Pizzie  
ex. [@DomPizzie](https://twitter.com/dompizzie)

## Version History

* 0.2
    * Various bug fixes and optimizations
    * See [commit change]() or See [release history]()
* 0.1
    * Initial Release

## License

This project is licensed under the [NAME HERE] License - see the LICENSE.md file for details

## Acknowledgments

Inspiration, code snippets, etc.
* [awesome-readme](https://github.com/matiassingers/awesome-readme)
* [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)
* [dbader](https://github.com/dbader/readme-template)
* [zenorocha](https://gist.github.com/zenorocha/4526327)
* [fvcproductions](https://gist.github.com/fvcproductions/1bfc2d4aecb01a834b46)