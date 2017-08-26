#!/usr/bin/env bash

echo "Installing serf and ansible"

sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install serf awscli ansible -y

mkdir /tmp/ansible
echo "Downloading ansible playbook"
aws s3 cp s3://vvv-laptop-backup-content/trains-ansible.tar.xz /tmp/ansible/trains-ansible.tar.xz --region eu-west-2

cd /tmp/ansible

echo "Extracting ansible playbook"
tar --extract -v -f trains-ansible.tar.xz 

echo "Running ansible"
sudo ansible-playbook -i hosts playbook.yml -vvv

exit 0

