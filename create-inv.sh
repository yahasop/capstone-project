#!/bin/bash

LINES=()

while IFS= read -ra line; do
        LINES+=("$line")
done < instances-ip.txt

FIRST=${LINES[0]}
SECOND=${LINES[1]}

cat <<EOF > ./ansible/hosts
[appserver]
appserver ansible_host=$FIRST ansible_ssh_user=ubuntu #ansible_password=ubuntu

[nexuserver]
nexuserver ansible_host=$SECOND ansible_ssh_user=ubuntu #ansible_password=ubuntu
EOF