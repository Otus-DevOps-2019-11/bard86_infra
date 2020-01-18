# bard86_infra
bard86 Infra repository
  
## Connect to someinternalhost through bastion host  
`ssh -i ~/.ssh/appuser -J appuser@35.228.188.53 appuser@10.166.0.3`

## Connect to someinternalhost through bastion host using alias  
add to `~/.ssh/config`:  

```console
Host bastion
HostName 35.228.188.53
IdentityFile ~/.ssh/appuser
User appuser
```

```console
Host someinternalhost
HostName 10.166.0.3
IdentityFile ~/.ssh/appuser
Port 22
User appuser
ProxyCommand ssh -q -W %h:%p bastion
```

use command `ssh someinternalhost` to connect  
  
## Install VPN server & and connect by openVPN  
install vpn server executing script `vpn/setupvpn.sh`  
use `vpn/cloud-bastion.ovpn` configuration file for openVPN connect  
  
IP for test:  
  
bastion_IP = 35.228.188.53  
someinternalhost_IP = 10.166.0.3  
  
## Test app deploy  
create bucket for store startup script `gsutil mb gs://otus-devops-denis-barsukov-bucket/`  
copy startup_script.s to bucket `gsutil cp .\startup_script.sh gs://otus-devops-denis-barsukov-bucket/`  
  
Firewall rules:  
```console
gcloud compute firewall-rules create default-puma-server\
  --allow tcp:9292 \
  --target-tags=puma-server
```
  
Instance:  
```console
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=f1-micro \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=gs://otus-devops-denis-barsukov-bucket/startup_script.sh
```
  
Startup script output is written to the following log file `/var/log/syslog`  
Test url: http://35.228.226.232:9292/  
  
testapp_IP = 35.228.226.232  
testapp_port = 9292  

## Packer

create Application Default Credentials (ADC): `gcloud auth application-default login`  
create Packer template `packer\ubuntu16.json`  
validate configuration file: `packer validate ubuntu16.json`   
build image: `packer build ubuntu16.json`  
extract sensitive variables to file `variables.json`, use it with build parameter `-var-file=variables.json`  
use `"source_image_family": "reddit-base"` to bake image with deployed app, we used `packer\files\puma.service` to start puma service by systemd  
to create VM run script:  
```console
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family=reddit-full \
  --machine-type=f1-micro \
  --tags=puma-server \
  --restart-on-failure
```

## Terraform-1
  
load balancer, pool and health check were described in `lb.tf`  
load balancer IP address added to `output.tf`   
zone, private_key_path and number of instances were added to `variables.tf`  
extract new variables from `main.tf` to `terraform.tfvars`  
`terraform.tfvars.example` was updated
ssh keys were added to project metadata

> **Warning:** Be careful, don't overwrite values, that were added manually

## Terraform-2

exclude load balancer from infrastructure (move `lb.tf` to `terraform/files`)
change app instance count to 1 
import firewall ssh rule to state file  
create application external ip address resource  
create compute engine image for app instance  
create compute engine image for db instance  
create modules: app, db, vpc  
create stage&prod envs  
add storage bucket (using `SweetOps/storage-bucket/google` module)  
add remote backend based on gcs (described in `backend.tf`)  
add provisioners to app module to deploy app automatically (optional, depends on `app_deploy_enabled` variable value)  

## Ansible-1

install Python 2.7.17, pip 19.3.1, ansible 2.8.4  
up stage infrastructure, test ssh connection
create ansible inventory file  
test connection with ansible ping module `ansible appserver -i ./inventory -m ping`  
create `ansible.cfg` with default settings, remove excess information from invetory file 
add groups to ansible inventory file  
switch to new inventory file format (ini -> yaml) `https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html`  
check that the components for application are available (`check_components_availability.sh` which using `shell` and `service` modules)  
add clone repo script, clone repo playbook (`ansible-playbook clone.yml`)  
>difference: changed=1
  
change inventory source to `./dynamic_inventory.py` script  
change inventory source to `./inventory.json`  

## Ansible-2
 - disable app auto deploy (terraform/stage/terraform.tfvars), delete mongo db provisioners(packer/db.json)  
 - create new db image with mongod default config `$ ./packer/create-reddit-db-image.sh`  
 - up infrastructure `$ cd ./terraform/stage/ && terraform apply`   
 - create template for mongod `./ansible/templates/mongod.conf.j2`  
 - create template for db connection `./ansible/templates/db_config.j2`  

 - create playbook `./ansible/reddit_app.yml`  
 - check playbook for db instance: `$ ansible-playbook reddit_app.yml --check --limit db --tags db-tag`  
 - run playbook for db instance: `$ ansible-playbook reddit_app.yml --limit db --tags db-tag`  
 - check playbook for app instance: `$ ansible-playbook reddit_app.yml --check --limit app --tags app-tag`  
 - run playbook for app instance: `$ ansible-playbook reddit_app.yml --limit app --tags app-tag`  
 - check playbook for app deploy: `$ ansible-playbook reddit_app.yml --check --limit app --tags deploy-tag`  
 - run playbook for app deploy: `$ ansible-playbook reddit_app.yml --limit app --tags deploy-tag` 
 
 - create playbook2 with multiple scenarios `./ansible/reddit_app2.yml`  
 - check playbook2 for db instance: `$ ansible-playbook reddit_app2.yml --check --tags db-tag`  
 - run playbook2 for db instance: `$ ansible-playbook reddit_app2.yml --tags db-tags`  
 - check playbook2 for app instance: `$ ansible-playbook reddit_app2.yml --check --tags app-tag`  
 - run playbook2 for app instance: `$ ansible-playbook reddit_app2.yml --tags app-tag`  
 - check playbook2 for app deploy: `$ ansible-playbook reddit_app2.yml --check --tags deploy-tag`  
 - run playbook2 for app deploy: `$ ansible-playbook reddit_app2.yml --tags deploy-tag`  

 - print list of avalible inventory plugins `$ ansible-doc -t inventory -l`  
 - add inventory plugin `gcp_compute` (https://docs.ansible.com/ansible/latest/plugins/inventory/gcp_compute.html)  
 - create gcp_compute plugin config `./ansible/gcp_compute.yml`
 - create service account key `~/.gsutil/key.json` (https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-gcloud)
 - test gcp_compute plugin `$ ansible-inventory -i gcp_compute.yml --graph`
 - modify `ansible.cfg` and playbooks to use inventory data  

 - add playbooks for packer: `./ansible/packer_app.json` and `./ansible/packer_db.json`  
 - integrate ansible with packer `./packer/app.json` and `./packer/db.json`  
 - create new db & app images  
 - up infrastructure `$ cd ./terraform/stage/ && terraform apply`
 - run `$ ansible-playbook site.yml` to depoly infrastructure and app  
