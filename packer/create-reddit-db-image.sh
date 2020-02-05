#!/bin/bash
set -e
packer validate -var-file=variables.json db.json
packer build -var-file=variables.json db.json
