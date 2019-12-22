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
        "workers": {
            "hosts": os.environ["workers"].split(" "),
            "vars": {},
            "children": []
        },
        "web": {
            "hosts": os.environ["web_private_dns"].split(" "),
            "vars": {},
            "children": []
        }
    }
    print(json.dumps(data, indent=True, sort_keys=True))


if args.host:
    data = {
        "ansible_ssh_private_key_file": "/home/sam/.ssh/{}".format(os.environ["key_name"]),
        "ansible_ssh_common_args": "-o StrictHostKeyChecking=no -o \"ProxyCommand ssh -W %h:%p -i /home/sam/.ssh/{} ubuntu@{} -o StrictHostKeyChecking=no\"".format(os.environ["key_name"], os.environ["bastion_public"]) 
    }
    print(json.dumps(data, indent=True, sort_keys=True))
