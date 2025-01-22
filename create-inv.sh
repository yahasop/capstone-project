#!/bin/bash

LINES=() #Variable initialization

#While loop. It reads the instances-ip file lines and appends to LINES variable
while IFS= read -ra line; do
        LINES+=("$line")
done < instances-ip.txt

#Saves indexed values of LINES variable into another variables
FIRST=${LINES[0]} 
SECOND=${LINES[1]}

#Using a here document to create the hosts Ansible file
cat <<EOF > ./ansible/hosts
[appserver]
appserver1 ansible_host=$FIRST ansible_ssh_user=ubuntu
appserver2 ansible_host=$SECOND ansible_ssh_user=ubuntu

[agent]
jenkins-agent ansible_connection=local ansible_ssh_user=ubuntu

EOF

#Using a here document to create the Ansble configurations file
cat <<EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
EOF