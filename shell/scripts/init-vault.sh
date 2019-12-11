#!/usr/bin/env python3
import json, sys, os
import subprocess
from subprocess import Popen, PIPE, run

environment = os.environ["ENVIRONMENT"]
bastion_ip = os.environ["bastion_public"]
vault_ip = os.environ["vault_private_ip"]
args = ["ssh",
  "-o",
  "StrictHostKeyChecking=no",
  "-o",
  "UserKnownHostsFile=/dev/null",
  "-o",
  "ProxyCommand ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p -i ~/.ssh/vvv-sam-n550jv ubuntu@{}".format(bastion_ip),
  "ubuntu@{}".format(vault_ip),
  "-i",
  "~/.ssh/vvv-sam-n550jv",
  "VAULT_ADDR=https://vault.{}.devops-pipeline.com:8200".format(environment),
  "VAULT_CACERT=/data/vault/ca/root.cer",
  "vault init"]

unseal_cert = run(args, stdout=PIPE)
unseal_result = unseal_cert.stdout.decode('utf-8')
sys.stderr.write(unseal_result)
print(json.dumps({"secrets": {"unseal_result": unseal_result}}))
sys.exit(unseal_cert.returncode)
