#!/bin/bash

# sudo sed -i 's@deb http://eu-west-2.ec2.archive.ubuntu.com/ubuntu/@deb http://${mirror_url}/ubuntu@g' /etc/apt/sources.list
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y unzip
sudo apt install -y zip
sudo apt-get install -y python3
sudo apt-get install -y python2.7
sudo apt install -y jq
sudo apt install -y awscli

pushd /tmp

curl -s https://releases.hashicorp.com/vault/0.8.1/vault_0.8.1_linux_amd64.zip -O

unzip vault_0.8.1_linux_amd64.zip

sudo mv vault /usr/local/bin
