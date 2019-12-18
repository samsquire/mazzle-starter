#!/bin/bash

# sudo sed -i 's@deb http://eu-west-2.ec2.archive.ubuntu.com/ubuntu/@deb http://${mirror_url}/ubuntu@g' /etc/apt/sources.list

cat <<EOF | sudo bash
cat <<EOI >> /etc/apt/sources.list.d/repository.list
deb [trusted=yes] http://${mirror_url}/ubuntu amd64/
EOI
EOF


sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y unzip
sudo apt-get install -y zip
sudo apt-get install -y python3
sudo apt-get install -y python2.7
sudo apt-get install -y jq
sudo apt-get install -y awscli

pushd /tmp

curl -s https://releases.hashicorp.com/vault/0.8.1/vault_0.8.1_linux_amd64.zip -O

unzip vault_0.8.1_linux_amd64.zip

sudo mv vault /usr/local/bin
