#!/bin/bash
apt-get install -y awscli jq curl
sudo systemctl enable volume.service
service volume start



