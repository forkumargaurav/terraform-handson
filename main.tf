terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAW3MD77LQBTEYWWWG"
  secret_key = "enter the secret_key"
}


resource "aws_instance" "webserver" {
  ami           = "ami-007020fd9c84e18c7"
  instance_type = "t3.micro"

  tags = {
    Name = "server"
  }
}