#!/bin/bash
sudo apt update -y
sudo apt install openjdk-17-jdk -y
sudo apt install jq sshpass -y
sudo ufw allow 80
sudo ufw allow 443
echo "ubuntu:ubuntu" | sudo chpasswd
sudo sed -i -e 's/Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/g' /etc/ssh/sshd_config
sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh