#!/bin/bash

# IP=$1

# Update the system
#sudo apt-get update -y
sudo apt update
sudo add-apt-repository ppa:ansible/ansible-2.10
sudo apt install ansible -y

# Install software-properties-common
#sudo apt-get install software-properties-common -y

# Add Ansible's repository
#sudo add-apt-repository --yes --update ppa:ansible/ansible

# Install Ansible
#sudo apt-get install ansible -y

#dpkg -L ansible

# Configure inventory file
# echo "[webservers]" > inventory
# #IP=$(curl -s ifconfig.me)
# echo $IP >> inventory

# echo IP ADDRESS ID $IP

# Download the Ansible playbook
# Replace the URL with the location of your Ansible playbook
wget https://github.com/rahul7thube/AzureApp/raw/main/ansible-playbooks/configure-webserver.yml
wget https://github.com/rahul7thube/AzureApp/raw/main/ansible-playbooks/index.php
wget https://github.com/rahul7thube/AzureApp/raw/main/ansible-playbooks/migration.sql
wget https://github.com/rahul7thube/AzureApp/raw/main/ansible-playbooks/postgresql-ansible.yml

export PATH=/usr/bin:$PATH
# Run the Ansible playbook
ansible-playbook postgresql-ansible.yml
ansible-playbook configure-webserver.yml

# Optional: Add any additional commands or scripts here
