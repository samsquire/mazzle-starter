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
        "repository": {
            "hosts": os.environ["repository_private_ip"].split(" "),
            "children": [],
            "vars": {}
        }
    }
    print(json.dumps(data, indent=True, sort_keys=True))


if args.host:
    data = {
        "ansible_ssh_private_key_file": "/home/ubuntu/.ssh/{}".format("id_ssh_rsa")
    }
    print(json.dumps(data, indent=True, sort_keys=True))
