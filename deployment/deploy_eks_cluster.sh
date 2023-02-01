#!/bin/bash

# Install pre-requisite packages
apt-get update
apt-get -y install awscli eksctl aws-iam-authenticator

# Create the EKS cluster
eksctl create cluster --name bwsw-webshell --version 1.24 --nodes 3

# Create a Security Group for web access
aws ec2 create-security-group --group-name bwsw-webshell-sg --description "Security Group for bwsw-webshell nodes"

# Configure the Security Group for web access
aws ec2 authorize-security-group-ingress --group-name bwsw-webshell-sg --protocol tcp --port 80 --cidr 0.0.0.0/0

# Deploy the bwsw webshell
eksctl create nodegroup --cluster bwsw-webshell --node-ami auto --node-type t2.micro --node-labels="role=webshell" --nodes 3 --name bwsw-webshell-nodes

# Get the bwsw webshell installed and running
kubectl create deployment bwsw-webshell --image bwsw/webshell

# Expose the webshell service
kubectl expose deployment bwsw-webshell --type=LoadBalancer --name=bwsw-webshell-svc --port=80

# Check the status of the cluster and webshell
kubectl get nodes
kubectl get deployments
kubectl get services