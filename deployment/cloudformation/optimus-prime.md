# 1. Create a VPC in AWS with two availability zones

aws ec2 create-vpc --cidr-block 10.0.0.0/16

# 2. Create two public subnets in different availability zones

aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.1.0/24 --availability-zone <Availability-Zone1>

aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.2.0/24 --availability-zone <Availability-Zone2>

# 3. Create two private subnets in different availability zones

aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.3.0/24 --availability-zone <Availability-Zone1>

aws ec2 create-subnet --vpc-id <vpc-id> --cidr-block 10.0.4.0/24 --availability-zone <Availability-Zone2>

# 4. Create an internet gateway

aws ec2 create-internet-gateway

# 5. Attach the internet gateway to the VPC

aws ec2 attach-internet-gateway --vpc-id <vpc-id> --internet-gateway-id <internet-gateway-id>

# 6. Create a NAT gateway for each availability zone

aws ec2 create-nat-gateway --subnet-id <subnet-id> --allocation-id <allocation-id>

# 7. Create a route table for the public subnets and add a route to the internet gateway

aws ec2 create-route-table --vpc-id <vpc-id>

aws ec2 create-route --route-table-id <route-table-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <internet-gateway-id>

# 8. Create a route table for the private subnets and add a route to the NAT gateway

aws ec2 create-route-table --vpc-id <vpc-id>

aws ec2 create-route --route-table-id <route-table-id> --destination-cidr-block 0.0.0.0/0 --gateway-id <nat-gateway-id>

# 9. Associate the public and private subnets with their respective route tables

aws ec2 associate-route-table --subnet-id <subnet-id> --route-table-id <route-table-id> 

# 10. Create an IAM role for the EKS cluster

aws iam create-role --role-name AmazonEKS-EKSCluster-Role --assume-role-policy-document file://iam-eks-role.json

# 11. Create an IAM policy for the EKS cluster

aws iam create-policy --policy-name AmazonEKS-EKSCluster-Policy --policy-document file://iam-eks-policy.json

# 12. Attach the IAM policy to the IAM role

aws iam attach-role-policy --role-name AmazonEKS-EKSCluster-Role --policy-arn <policy-arn>

# 13. Create the EKS cluster

aws eks create-cluster --name <cluster-name> --role-arn <role-arn> --resources-vpc-config subnetIds=<public-subnet1-id>,<public-subnet2-id>,<private-subnet1-id>,<private-subnet2-id>

# 14. Configure your kubectl to use the EKS cluster

aws eks update-kubeconfig --name <cluster-name>

# 15. Create a Kubernetes deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: <image-name>
        ports:
        - containerPort: 80

# 16. Create a Kubernetes service

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: hello-world
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: <node-port>



//Create a custom VPC with a private, public, and database subnet

AWS CloudFormation Template:

{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "VPC": {
      "Type": "AWS::EC2::VPC",
      "Properties": {
        "CidrBlock": "10.0.0.0/16"
      }
    },
    "PublicSubnet": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "VpcId": {
          "Ref": "VPC"
        },
        "CidrBlock": "10.0.0.0/24",
        "AvailabilityZone": "us-west-2a"
      }
    },
    "PrivateSubnet": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "VpcId": {
          "Ref": "VPC"
        },
        "CidrBlock": "10.0.1.0/24",
        "AvailabilityZone": "us-west-2a"
      }
    },
    "DatabaseSubnet": {
      "Type": "AWS::EC2::Subnet",
      "Properties": {
        "VpcId": {
          "Ref": "VPC"
        },
        "CidrBlock": "10.0.2.0/24",
        "AvailabilityZone": "us-west-2a"
      }
    }
  }
}

//Create an Amazon Elastic Kubernetes (EKS) cluster

AWS CloudFormation Template:

{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Resources": {
        "EKSCluster": {
            "Type": "AWS::EKS::Cluster",
            "Properties": {
                "Name": "My-EKS",
                "ResourcesVpcConfig": {
                    "SubnetIds": [
                        { "Ref": "PublicSubnet" },
                        { "Ref": "PrivateSubnet" },
                        { "Ref": "DatabaseSubnet" }
                    ],
                    "SecurityGroupIds": [
                      { "Ref": "MySecurityGroup" }
                    ],
                    "ClusterSecurityGroupId": {
                      "Ref": "MySecurityGroup"
                    }
                }
            }
        },
    }
}

//Create IAM roles and security groups for used for the Amazon EKS Cluster

AWS CloudFormation Template:

{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Resources": {
        "EKSCNA access role": {
            "Type": "AWS::IAM::Role",
            "Properties": {
                "AssumeRolePolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Sid": "",
                            "Effect": "Allow",
                            "Principal": {
                                "Service": "eks.amazonaws.com"
                            },
                            "Action": "sts:AssumeRole"
                        }
                    ]
                },
                "ManagedPolicyArns": [
                    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
                ], 
            }
        },
        "EKSCNB access role": {
            "Type": "AWS::IAM::Role",
            "Properties": {
                "AssumeRolePolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Sid": "",
                            "Effect": "Allow",
                            "Principal": {
                                "Service": "eks.amazonaws.com"
                            },
                            "Action": "sts:AssumeRole"
                        }
                    ]
                },
                "ManagedPolicyArns": [
                    "arn:aws:iam::aws:policy/AmazonEKSCNBPolicy"
                ],
            }
        },
        "MySecurityGroup": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
                "GroupDescription": "Security Group for EKS Cluster",
                "VpcId": {
                    "Ref": "VPC"
                },
                "SecurityGroupIngress": [
                    {
                        "IpProtocol": "-1",
                        "FromPort": "0",
                        "ToPort": "65535",
                        "CidrIp": "192.168.0.0/16"
                    }
                ],
                "SecurityGroupEgress": [
                    {
                        "IpProtocol": "-1",
                        "FromPort": "0",
                        "ToPort": "65535",
                        "CidrIp": "0.0.0.0/0"
                    }
                ]
            }
        }
    }
}

//Create Kubernetes manifest resources such as a deployment and a service

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-container
          image: my-container-image

---

apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
    # Label the port with a 'name':
    # line that is descriptive,
    # like 'http'
    - name: http
      port: 8080
      targetPort: 8080
  type: NodePort
