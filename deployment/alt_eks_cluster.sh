#!/bin/bash

#install prerequisites

sudo apt-get update
sudo apt-get install -y python3 python3-pip
sudo pip3 install awscli eksctl

#configure aws credentials
aws configure

#create an EKS cluster
eksctl create cluster --name=bwsw-webshell --version=1.13 --region=eu-central-1

#deploy webshell
kubectl apply -f https://raw.githubusercontent.com/bwsw/webshell/master/bwsw-webshell.yaml

#expose service
kubectl expose deployment bwsw-webshell --type=LoadBalancer --name=bwsw-webshell-service

#verify
echo "Visit http://$(kubectl get services bwsw-webshell-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') to access the webshell"
Hit [S/s] to save the file or [R/r] to retry [Q/q] to quit: R
#!/bin/bash

# Setup EKS Cluster

# Create Cluster Variables
REGION=<region>
CLUSTERNAME=<clustername>
NETWORK_CIDR=10.0.0.0/16
SUBNET_CIDR_1=10.0.0.0/24
SUBNET_CIDR_2=10.0.1.0/24
SUBNET_CIDR_3=10.0.2.0/24
NODE_RG=nodegroup-<region>

# Update/Upgrade Ubuntu
sudo apt-get update
sudo apt-get upgrade -y

# Install AWS CLI and configure
sudo apt-get install -y awscli
aws configure

# Create EKS Cluster
aws eks create-cluster --name $CLUSTERNAME --region $REGION --zones $REGION-1a,$REGION-1b,$REGION-1c

# Create an AWS IAM Role
aws iam create-role --role-name EKSNode --assume-role-policy-document file://node-role.json

# Create the EKS VPC
aws ec2 create-vpc --cidr-block $NETWORK_CIDR
VPC_ID=$(aws ec2 describe-vpcs --filter "Name=cidr,Values=$NETWORK_CIDR" --query 'Vpcs[0].{VpcId:VpcId}' | grep VpcId | tr -d '"')

# Create EKS Subnets
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR_1
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR_2
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR_3

# Set cluster endpoints and logging
aws eks update-cluster-config --name $CLUSTERNAME --region $REGION --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}' --endpoint-private-access --endpoint-public-access --no-enable-helm-tiller

# Add Capacity for EKS Nodegroup
aws ec2 create-security-group --group-name $NODE_RG --description "Security Group for EKS Nodes"
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filter "Name=group-name,Values=$NODE_RG" | grep GroupId | tr -d '"')
aws eks create-nodegroup --cluster-name $CLUSTERNAME --node-role arn:aws:iam::$AWS_ACCOUNT_ID:role/$NODE_GROUP --scaling-config minSize=3,maxSize=3,desiredSize=3 --subnets $SUBNET_CIDR_1 $SUBNET_CIDR_2 $SUBNET_CIDR_3 --security-groups $SECURITY_GROUP_ID

# Wait for cluster to be Ready
while ! [[ $(aws eks describe-cluster --name $CLUSTERNAME --region $REGION | grep -i  "active") ]]; do
    echo "Cluster is still not ready. Waiting..."
    sleep 10
done

# Deploy BWSW WebShell
KUBECONFIG=$(aws eks --region $REGION update-kubeconfig --name $CLUSTERNAME)
kubectl apply -f ./web_shell_deployment.yaml

# Export WebShell URL for Access
WebShellURL=$(kubectl get svc web-shell -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
echo "Your WebShell is accessible at: $WebShellURL"