#!/bin/bash
ansible appserver -m command -a uptime
ansible dbserver -m command -a uptime
