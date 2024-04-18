#!/bin/bash
clear
echo "Install required packages"
sudo apt install awscli python3 python3-pip jq -y -q
python3 -m pip install -r requirements.txt --break-system-packages

echo "Configuring awscli (s3)"
mkdir ~/.aws/
touch ~/.aws/credentials
touch ~/.aws/config

printf "
[default]
aws_access_key_id = $(cat config.json | jq -r .config.s3.access_key)
aws_secret_access_key = $(cat config.json | jq -r .config.s3.secret_key)
" > ~/.aws/credentials
printf "
[plugins]
endpoint = awscli_plugin_endpoint

[profile default]
region = $(cat config.json | jq -r .config.s3.region | tr '[:upper:]' '[:lower:]')
s3 =
  endpoint_url = $(cat config.json | jq -r .config.s3.endpoint)
  signature_version = s3v4
s3api =
  endpoint_url = $(cat config.json | jq -r .config.s3.endpoint)
" > ~/.aws/config

echo "Done !"
