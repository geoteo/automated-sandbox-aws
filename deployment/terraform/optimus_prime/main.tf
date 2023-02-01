provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "webshell-vpc"
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = "webshell-eks-cluster"
  subnets      = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "iam" {
  source = "terraform-aws-modules/iam/aws"

  name = "webshell-iam"

  create_role = true
  create_instance_profiles = true

  policies = [
    {
      name = "webshell-policy"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "eks:DescribeCluster",
              "eks:ListClusters",
              "eks:ListTagsForResource",
            ]
            Effect = "Allow"
            Resource = "*"
          },
        ]
      })
    },
  ]
}

locals {
  deployment_manifest = <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: webshell
  name: webshell
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webshell
  template:
    metadata:
      labels:
        app: webshell
    spec:
      containers:
      - image: bwsw/webshell
        env:
        - name: PATH
          value: "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        - name: SSH_PORT
          value: "22"
        - name: USERNAME
          value: "student"
        - name: DEFAULT_IP
          value: "0.0.0.0"
        - name: INACTIVITY_INTERVAL
          value: "600"
        - name: ALLOWED_NETWORKS
          value: "0.0.0.0/0,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,fc00::
