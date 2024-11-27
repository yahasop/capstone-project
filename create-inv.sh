#!/bin/bash

LINES=()

while IFS= read -ra line; do
        LINES+=("$line")
done < instances-ip.txt

FIRST=${LINES[0]}
SECOND=${LINES[1]}

cat <<EOF > ./ansible/hosts
[appserver]
appserver1 ansible_host=$FIRST ansible_ssh_user=ubuntu

[nexuserver]
nexuserver1 ansible_host=$SECOND ansible_ssh_user=ubuntu
EOF

cat <<EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
EOF