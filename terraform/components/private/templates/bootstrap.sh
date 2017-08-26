#!/bin/bash

sed -i 's@deb http://eu-west-2.ec2.archive.ubuntu.com/ubuntu/@deb http://${mirror_url}/ubuntu@g' /etc/apt/sources.list 

