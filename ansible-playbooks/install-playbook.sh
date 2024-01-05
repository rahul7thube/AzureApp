#!/bin/bash

# Update the system
sudo apt-get update -y

# Install software-properties-common
sudo apt-get install software-properties-common -y

# Add Ansible's repository
sudo add-apt-repository --yes --update ppa:ansible/ansible

# Install Ansible
sudo apt-get install ansible -y

# Download the Ansible playbook
# Replace the URL with the location of your Ansible playbook
wget https://example.com/my_ansible_playbook.yml

# Run the Ansible playbook
ansible-playbook my_ansible_playbook.yml

# Optional: Add any additional commands or scripts here
