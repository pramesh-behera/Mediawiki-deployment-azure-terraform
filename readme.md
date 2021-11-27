# MediaWiki Deployment in Azure using Terraform

This project describes the steps for deploying MediaWiki using Terraform in RHEL 8 virtual machine in Azure . Please follow below steps for the complete deployment.

- ## About the repository :

  This repository contain below files.

  - main.sh - This file provides terraform code for deployment of virtual machine and provisioning the resources in Azure cloud.
  - automate.sh - This is a shell script, that performs all the activities starting from installing required packages to publish the service.
  - apache-config.conf - This is the config file to setup the apache server.

- ## Prerequisites :
  - You should have Microsoft Azure account.
  - Download Terraform application into your system and define the path in system environment variables.
  - Download AzureCLI and install in your system.
  - Login by executing this command "az login" in cmd or powershell.
- ## Steps to follow :
  - Clone the repository into your local system.
  - Open cmd or powershell and change the directory to the cloned repository.
  - run command -- "terraform init"
  - run command -- "terraform plan"
  - run command -- "terraform apply"

### Mediawiki is now deplyed in your azure virtual machine. You can check by opening "http://\<publicip>/mediawiki/" in your browser and follow the mentioned step to set up the wiki.

### You can edit the automate.sh file to provide your own database credentials also you can refer to this <a href="https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Red_Hat_Linux">mediawiki</a> link for more details.
### Note: You can use this command "terraform output -raw tls_private_key" in cmd or powershell to get the private ssh key for login in to Azure virtual machine.
