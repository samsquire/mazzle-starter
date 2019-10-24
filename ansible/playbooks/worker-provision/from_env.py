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
        }
    }
    print(json.dumps(data, indent=True, sort_keys=True))
        
        
if args.host:
    data = {
        "ansible_ssh_private_key_file": "/home/sam/.ssh/vvv-sam-n550jv"
    }
    print(json.dumps(data, indent=True, sort_keys=True))