#!/bin/bash
set -e
packer validate -var-file=variables.json app.json
packer build -var-file=variables.json app.json
