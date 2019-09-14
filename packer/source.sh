#!/bin/bash

# sudo sed -i 's@deb http://eu-west-2.ec2.archive.ubuntu.com/ubuntu/@deb http://${mirror_url}/ubuntu@g' /etc/apt/sources.list
sudo apt-get update
sleep 10
sudo apt-get upgrade
sudo apt install -y unzip
sudo apt-get install -y python3
sudo apt-get install -y python2.7

pushd /tmp

curl -s https://releases.hashicorp.com/vault/0.8.1/vault_0.8.1_linux_amd64.zip -O

unzip vault_0.8.1_linux_amd64.zip

sudo mv vault /usr/local/bin
