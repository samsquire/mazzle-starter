#!/bin/bash

# sudo sed -i 's@deb http://eu-west-2.ec2.archive.ubuntu.com/ubuntu/@deb http://${mirror_url}/ubuntu@g' /etc/apt/sources.list

sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y unzip
sudo apt-get install -y zip
sudo apt-get install -y python3
sudo apt-get install -y python2.7
sudo apt-get install -y jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

pushd /tmp

curl -s https://releases.hashicorp.com/vault/0.8.1/vault_0.8.1_linux_amd64.zip -O

unzip vault_0.8.1_linux_amd64.zip
sudo mv vault /usr/local/bin


curl https://releases.hashicorp.com/consul/1.6.2/consul_1.6.2_linux_amd64.zip -O
unzip consul_1.6.2_linux_amd64.zip
sudo mv consul /usr/local/bin

curl https://releases.hashicorp.com/nomad/0.10.2/nomad_0.10.2_linux_amd64.zip -O
unzip nomad_0.10.2_linux_amd64.zip
sudo mv nomad /usr/local/bin

cat <<EOF | sudo bash
cat <<EOI >> /etc/apt/sources.list.d/repository.list
deb [trusted=yes] http://${mirror_url}/ubuntu amd64/
EOI
EOF
