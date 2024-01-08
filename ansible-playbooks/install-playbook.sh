#!/bin/bash

IP=$1

# Update the system
#sudo apt-get update -y
sudo apt-get update
sudo apt-get install -y ansible

# Install software-properties-common
#sudo apt-get install software-properties-common -y

# Add Ansible's repository
#sudo add-apt-repository --yes --update ppa:ansible/ansible

# Install Ansible
#sudo apt-get install ansible -y

#dpkg -L ansible

# Configure inventory file
echo "[webservers]" > inventory
#IP=$(curl -s ifconfig.me)
echo $IP >> inventory

echo IP ADDRESS ID $IP

# Download the Ansible playbook
# Replace the URL with the location of your Ansible playbook
wget https://github.com/rahul7thube/AzureApp/raw/main/ansible-playbooks/configure-webserver.yml
export PATH=/usr/bin:$PATH
# Run the Ansible playbook
ansible-playbook -i inventory configure-webserver.yml

# Optional: Add any additional commands or scripts here
