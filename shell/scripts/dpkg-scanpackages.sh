#!/usr/bin/env python3
import json, sys, os
import subprocess
from subprocess import Popen, PIPE, run

bastion_ip = os.environ["bastion_public"]
repository_ip = os.environ["repository_private_ip"]
key_name = os.environ["key_name"]
args = ["ssh",
  "-o",
  "StrictHostKeyChecking=no",
  "-o",
  "ProxyCommand ssh -o StrictHostKeyChecking=no -W %h:%p -i ~/.ssh/{} ubuntu@{}".format(key_name, bastion_ip),
  "ubuntu@{}".format(repository_ip),
  "-i",
  "~/.ssh/{}".format(key_name),
  "bash", "-c",
  "cd /var/www/ubuntu/ ; sudo mkdir /var/www/ubuntu/amd64 ; sudo dpkg-scanpackages -m . > ~/Packages ; sudo cp ~/Packages /var/www/ubuntu/amd64/"]

scanpackages = run(args, stdout=PIPE)
scanpackages_output = scanpackages.stdout.decode('utf-8')
sys.stderr.write(scanpackages_output)
print(json.dumps({}))
sys.exit(scanpackages.returncode)
