#!/bin/bash
HOSTNAME=$(hostname)
sudo apt update -y
sudo apt install apache2 sshpass openjdk-17-jdk awscli -y
sudo rm /var/www/html/index.html
echo "<html><head><title>Terraform Practice</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Host is: <br>$HOSTNAME</br> and IP is: <br>$(curl -4 -s ifconfig.me)</br></span></span></p></body></html>" | sudo tee /var/www/html/index.html
sudo systemctl enable apache2
sudo systemctl start apache2
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3306
sudo ufw allow 8080
sudo ufw allow 8081
sudo ufw allow 8082
echo "ubuntu:ubuntu" | sudo chpasswd
sudo sed -i -e 's/Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/g' /etc/ssh/sshd_config
sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh