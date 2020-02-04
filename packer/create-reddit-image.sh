#!/bin/bash
set -e
packer validate -var-file=variables.json ubuntu16.json
packer build -var-file=variables.json ubuntu16.json
