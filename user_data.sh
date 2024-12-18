#!/bin/bash
sudo apt-add-repository ppa:ansible/ansible
sudo apt update -y
sudo apt install jq sshpass openjdk-17-jdk ansible awscli -y
sudo ansible-galaxy collection install community.docker
sudo ufw allow 80
sudo ufw allow 443
echo "ubuntu:ubuntu" | sudo chpasswd
sudo sed -i -e 's/Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/g' /etc/ssh/sshd_config
sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh