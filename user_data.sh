#!/bin/bash
HOSTNAME=$(hostname) #Sets the variable to be used in the static page
sudo apt update -y
# Installs all neccesary tools
# - apache2 to install Apache's server to host a simple static page
# - jq to use it to process the terraform output's json
# - sshpass to enable password non-interactive authentication when connecting through ssh
# - openjdk-17-jdk is neccesary to be able to use the instance as jenkins agent
# - awscli to process some commands to fetch information about AWS resources
sudo apt install apache2 jq sshpass openjdk-17-jdk awscli -y
sudo rm /var/www/html/index.html #After apache is installed, this removes the default page
#This creates a simple static page and replaces as the Apache default page. Contains info about the host machine
echo "<html><head><title>Terraform Practice</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Host is: <br>$HOSTNAME</br> and IP is: <br>$(curl -4 -s ifconfig.me)</br></span></span></p></body></html>" | sudo tee /var/www/html/index.html
sudo systemctl enable apache2 #Enables and stars the Apache server service
sudo systemctl start apache2
sudo ufw allow 80 #This enables both 80, 443 and 8080 ports on instance's firewall to allow requests
sudo ufw allow 443
sudo ufw allow 8080
sudo ufw allow 9000
echo "ubuntu:ubuntu" | sudo chpasswd #This allow to update the user and password of the instance
#These next sed commands change some lines to allow password authentication when connecting through SSh to the instance.
sudo sed -i -e 's/Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/g' /etc/ssh/sshd_config
sudo sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart ssh #This is neccesary to apply the changes on the sshd_config file
#curl -fsSL https://get.docker.com -o get-docker.sh
#sh get-docker.sh
#sudo usermod -aG docker $USER
#newgrp docker
