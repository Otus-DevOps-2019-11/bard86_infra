#!/bin/bash
ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'

#second try
ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'
