# terraform-handson

A static website is hosted with my resume using terraform.

Provider file contains which provide we are using aling with acccess key *"PLEASE add ACCESS KEY PASSWORD"*

Output file shows the value of S3 bucket name and it's endpoint url

main file create a S# bucket and then provide ACL to make public all objects in that bucket , upload index.html and resume.pdf

srv folder contains index.html, error.html and pic for resume creation the html are genrated using chatgpt. 

To run this project you need to have Terraform installed in your system. You can download from here https://www.terraform.
To run this project you need to install Terraform : https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/getting-start

## Requirements:
1. AWS account  
2. Terraform installed in your local system  

## Steps to run this project 
Step 1 : Clone or download this repository into your local machine.
bash
$ git clone https://github.com/forkumargaurav/terraform-handson.git

Step 2 : Navigate to "provider.tf" file and add access key

Step 3 : Navigate to "main.tf" file and change S3 bucket name

Step 4 : terraform init

Step 5 : terraform plan

Step 6 : terraform apply -auto-approve

**To destroy all resources use terraform  destroy -auto-approve**


