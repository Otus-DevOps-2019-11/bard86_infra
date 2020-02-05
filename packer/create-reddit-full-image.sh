#!/bin/bash
set -e
packer validate -var-file=variables.json immutable.json
packer build -var-file=variables.json -var "source_image_family=reddit-base" immutable.json
