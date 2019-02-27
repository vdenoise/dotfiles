#!/bin/bash
export TF_VAR_digitalocean_token="ccc001bafa9f6ddf32c8b6ebaab769e39a5a9899bdd71e5d2482020dd7bbd2b5" 
export TF_VAR_digitalocean_ssh_fingerprint="ef:c2:72:18:48:73:44:4c:5f:6e:a7:57:ec:0a:5b:d6"  	
export TF_VAR_digitalocean_pub_key="~/.ssh/ipad_rsa.pub" 
export TF_VAR_digitalocean_private_key="~/.ssh/ipad_rsa.pub" 


terraform init
terraform plan
terraform apply -auto-approve
