#!/bin/bash

LINES=()

while IFS= read -ra line; do
        LINES+=("$line")
done < instances-ip.txt

FIRST=${LINES[0]}
SECOND=${LINES[1]}
#THIRD=$(curl -4 ifconfig.me)

cat <<EOF > ./ansible/hosts
[appserver]
appserver1 ansible_host=$FIRST ansible_ssh_user=ubuntu
appserver2 ansible_host=$SECOND ansible_ssh_user=ubuntu

[agent]
jenkins-agent ansible_connection=local

EOF

cat <<EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
EOF