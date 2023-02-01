# aiac get a bash script to deploy a 3 node EKS cluster thats running bwsw webshell and is accessible by the web

#!/bin/bash

#install prerequisites

sudo apt-get update
sudo apt-get install -y python3 python3-pip
# sudo pip3 install awscli eksctl

#configure aws credentials
aws configure

#create an EKS cluster
eksctl create cluster --name=dt-aws-sandbox --version=1.24 --region=us-east-1 --nodegroup-name dt-aws-sandbox-workers --node-type t3.xlarge --nodes 3 --nodes-min 1 --nodes-max 4 --managed

#deploy webshell
kubectl apply -f ./webshell.yaml

#expose service
kubectl expose deployment bwsw-webshell --type=LoadBalancer --name=bwsw-webshell-service

#verify
echo "Visit http://$(kubectl get services bwsw-webshell-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') to access the webshell"