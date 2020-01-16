#!/usr/bin/env python

'''
Example custom dynamic inventory script for Ansible, in Python.
https://www.jeffgeerling.com/blog/creating-custom-dynamic-inventories-ansible
'''

import os
import sys
import argparse

try:
    import json
except ImportError:
    import simplejson as json

class ExampleInventory(object):

    def __init__(self):
        self.inventory = {}
        self.read_cli_args()

        # Called with `--list`.
        if self.args.list:
            self.inventory = self.example_inventory()
        # Called with `--host [hostname]`.
        elif self.args.host:
            # Not implemented, since we return _meta info `--list`.
            self.inventory = self.empty_inventory()
        # If no groups or vars are present, return an empty inventory.
        else:
            self.inventory = self.empty_inventory()

        print json.dumps(self.inventory);

    # Example inventory for testing.
    def example_inventory(self):
        return {
            'app': {
                'hosts': ['35.228.135.225'],
                'vars': {
                    'ansible_ssh_user': 'appuser',
                    'ansible_ssh_private_key_file':'~/.ssh/appuser',
                    'example_variable': 'value1'
                }
            },
            'db': {
                'hosts': ['35.228.228.227'],
                'vars': {
                    'ansible_ssh_user': 'appuser',
                    'ansible_ssh_private_key_file':'~/.ssh/appuser',
                    'example_variable': 'value2'
                }
            },			
            '_meta': {
                'hostvars': {
                    '35.228.135.225': {
                        'host_specific_var': 'foo'
                    },
                    '35.228.228.227': {
                        'host_specific_var': 'bar'
                    }
                }
            }
        }

    # Empty inventory for testing.
    def empty_inventory(self):
        return {'_meta': {'hostvars': {}}}

    # Read the command line args passed to the script.
    def read_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action = 'store_true')
        parser.add_argument('--host', action = 'store')
        self.args = parser.parse_args()

# Get the inventory.
ExampleInventory()
