#!/bin/bash
ansible app -m shell -a 'ruby -v; bundler -v'
ansible db -m service -a name=mongod

