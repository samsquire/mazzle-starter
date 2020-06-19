#!/usr/bin/env python3
from argparse import ArgumentParser
import json
import os

parser = ArgumentParser()
parser.add_argument("--list", action="store_true")
parser.add_argument("--host", nargs="+")

args = parser.parse_args()

if args.list:
    data = {
        "cluster": {
            "hosts": os.environ["cluster"].split(" "),
            "vars": {},
            "children": []
        }
    }
    print(json.dumps(data, indent=True, sort_keys=True))


if args.host:
    data = {
        "ansible_ssh_private_key_file": "{}/{}".format(os.environ["key_path"], os.environ["key_name"]),
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o \"ProxyCommand ssh -W %h:%p -i {}/{} ubuntu@{} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\"".format(
            os.environ["key_path"], os.environ["key_name"], os.environ["bastion_public"])
    }
    print(json.dumps(data, indent=True, sort_keys=True))
