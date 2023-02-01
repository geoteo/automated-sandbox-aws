#!/bin/bash

#installing prerequisites
echo "installing prerequisites..."
sudo apt-get update && apt install -y curl unzip

#installing the aws cli v2
echo "downloading aws cli v2..."
curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
echo "installing aws cli v2..."
unzip awscliv2.zip
sudo ./aws/install

#clean up by removing the zip file
rm awscliv2.zip

#default output path for the AWS CLI Version 2
echo "export PATH=/usr/local/bin:$PATH" >>~/.bashrc

#refresh the bash profile
source ~/.bashrc
echo "AWS CLI Version 2 installed successfully"
