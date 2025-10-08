#!/bin/bash
sudo apt-add-repository ppa:ansible/ansible #Adding the Ansible repository to install it in the agent
sudo apt update -y
# Installs all neccesary tools
# - jq to use it to process the terraform output's json
# - sshpass to enable password non-interactive authentication when connecting through ssh
# - openjdk-17-jdk is neccesary to be able to use the instance as jenkins agent
# - ansible to use ansible to make configurations and to deploy the application
# - awscli to process some commands to fetch information about AWS resources
sudo apt install jq sshpass openjdk-17-jdk ansible awscli -y
sudo ansible-galaxy collection install community.docker #Installing the Docker Ansible module
sudo ufw allow 80 #This enables both 80 and 443 ports on instance's firewall to allow requests
sudo ufw allow 443
echo "ubuntu:ubuntu" | sudo chpasswd #This allow to update the user and password of the instance
#These next sed commands change some lines to allow password authentication when connecting through SSh to the instance.
sudo sed -i -e 's/Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/g' /etc/ssh/sshd_config
sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh #This is neccesary to apply the changes on the sshd_config file
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker
