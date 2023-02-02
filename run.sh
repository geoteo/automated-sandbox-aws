#!/bin/bash

# Define Variables
CLUSTER_NAME=sandbox-eks
REGION=us-east-1
PROFILE=default

# Check if AWS CLI is Installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI is not installed. Please install it before running this script."
    exit 1
fi

# Check if eksctl is Installed
if ! command -v eksctl &> /dev/null
then
    echo "eksctl is not installed."
    echo Installing eksctl

    # confirm if curl, unzip and git are installed
    if ! [ -x "$(command -v curl)" ]; 
    then 
        echo 'Error: curl is not installed.' 
        echo 'Install curl, unzip and git and try again.' 
        exit 1 
    fi

if ! [ -x "$(command -v unzip)" ]; then 
  echo 'Error: unzip is not installed.' 
  echo 'Install curl, unzip and git and try again.' 
  exit 1 
fi

if ! [ -x "$(command -v git)" ]; then 
  echo 'Error: git is not installed.' 
  echo 'Install curl, unzip and git and try again.' 
  exit 1 
fi

#install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

echo "eksctl has been installed successfully"
fi

aws ec2 create-key-pair --key-name eksKeyPair --query 'KeyMaterial' --output text > eksKeyPair.pem

# Create EKS Cluster
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $PROFILE \
  --node-type=t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --with-oidc \
  --ssh-access \
  --ssh-public-key eksKeyPair


# Apply Kubernetes Manifest Resources
echo "Please provide your deployment configuration in a file named deployment.yaml and your service configuration in a file named service.yaml, then run the following commands to apply them:"
echo "kubectl apply -f deployment.yaml"
echo "kubectl apply -f service.yaml"

# Verify Deployment and Service are Running
echo "To verify that your deployment and service are running, run the following commands:"
echo "kubectl get pods"
echo "kubectl get svc"

kubectl get nodes -o wide

kubectl get pods --all-namespaces -o wide

kubectl apply -f https://k8s.io/examples/controllers/nginx-deployment.yaml

kubectl get pods

# creating the webshell application in EKS 
# eksctl create deployment --name webshell --container image=bwsw/webshell:latest --cluster $CLUSTER_NAME

# configuring the ELB target group
# aws elbv2 create-target-group --name <name-of-target-group> --port 80 --protocol HTTP --target-type 'instance' 
