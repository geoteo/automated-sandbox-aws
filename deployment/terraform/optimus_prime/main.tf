# Create VPC, subnets and egress-only igw
resource "aws_vpc" "kubernetes" {
  cidr_block           = "10.10.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "kubernetes_egw" {
  vpc_id = aws_vpc.kubernetes.id
}

resource "aws_egress_only_internet_gateway" "kubernetes_egress" {
  vpc_id = aws_vpc.kubernetes.id
}

resource "aws_subnet" "kubernetes" {
  vpc_id            = aws_vpc.kubernetes.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = "us-east-1a"
}

# Create the EKS cluster
resource "aws_eks_cluster" "kubernetes" {
  name    = "kube-cluster"
  vpc_config {
    subnet_ids = [aws_subnet.kubernetes.id]

    security_group_ids = [aws_security_group.kube_sg.id]
  }
}

# Create a security group for the EKS cluster
resource "aws_security_group" "kube_sg" {
  name        = "kube_sg"
  description = "Allow traffic related to K8s"
  vpc_id      = aws_vpc.kubernetes.id

  ingress {
    from_port   = 0  
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the IAM role for EKS
resource "aws_iam_role" "kubernetes_cluster" {
  name = "kubernetes_cluster"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

# Create the IAM binding for the new EKS Worker node group
resource "aws_iam_role_policy_attachment" "node_group_attachment" {
  role       = aws_iam_role.kubernetes_cluster.name
  policy_arn = aws_iam_policy.node_group_policy.arn
}

# Create a IAM policy for the Worker node groups
resource "aws_iam_policy" "node_group_policy" {
  name        = "node_group_policy"
  description = "Allow EKS worker node access to APIs"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "autoscaling:Describe*",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create the Worker node group
resource "aws_eks_node_group" "kubernetes" {
  cluster_name    = aws_eks_cluster.kubernetes.name
  node_role_arn   = aws_iam_role.kubernetes_cluster.arn
  subnet_ids      = [aws_subnet.kubernetes.id]
  disksize        = 100
  instance_type   = "t2.medium"
  desired_size    = 2
  max_size        = 3
  min_size        = 2
}

# Create the Kubernetes Deployment and Service
resource "kubernetes_deployment" "test-deployment" {
  metadata {
    name = "test-deployment"
  }
  spec {
    selector {
      match_labels = {
        app = "test-deployment"
      }
    }
    template {
      metadata {
        labels = {
          app = "test-deployment"
        }
      }
      spec {
        container {
          image = "test-deployment:latest"
          name  = "test-deployment"
        }
      }
    }
  }
}

resource "kubernetes_service" "test-service" {
  metadata {
    name = "test-service"
  }
  spec {
    selector = {
      app = "test-deployment"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
