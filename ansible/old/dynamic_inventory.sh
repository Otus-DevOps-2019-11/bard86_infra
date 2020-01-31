#!/bin/bash
set -e

cd ../terraform/stage && terraform output > /tmp/terraform_output

app_external_ip=`grep app_external_ip /tmp/terraform_output | awk '{print $3}'`
db_external_ip=`grep db_external_ip /tmp/terraform_output | awk '{print $3}'`

if [ "$1" == "--list" ] ; then
cat<<EOT
{
  "app": {
    "hosts": ["$app_external_ip"]
  },
  "db": {
    "hosts": ["$db_external_ip"]
  }
}
EOT
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
else
  echo "{ }"
fi
