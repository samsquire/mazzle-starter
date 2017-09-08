#!/usr/bin/env python
import json, sys, os
import subprocess
from subprocess import Popen, PIPE, run

bastion_ip = os.environ["bastion_public"]
vault_ip = os.environ["vault_private_ip"]
args = ["ssh",
  "-o",
  "ProxyCommand ssh -W %h:%p -i ~/.ssh/vvv-sam-n550jv ubuntu@{}".format(bastion_ip),
  "ubuntu@{}".format(vault_ip),
  "-i",
  "~/.ssh/vvv-sam-n550jv",
  "cat",
  "/data/vault/ca/root.cer"]

cat_cert = run(args, stdout=PIPE) 
root_certificate = cat_cert.stdout.decode('utf-8')
print(json.dumps({"root_certificate": root_certificate}))
sys.exit(cat_cert.returncode)

