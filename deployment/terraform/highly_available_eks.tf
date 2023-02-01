resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_role.arn 

  vpc_config {
    security_group_ids = [aws_security_group.eks_security_group.id]
    subnet_ids         = [
      aws_subnet.eks_subnet_a.id,
      aws_subnet.eks_subnet_b.id, 
      aws_subnet.eks_subnet_c.id
    ]
  }

  # NOTE: Amazon EKS clusters require at least two subnets per Availability Zone
  # Refer to the documentation for all available configuration options
  # https://www.terraform.io/docs/providers/aws/r/eks_cluster.html
  private_cluster_config {
    enable_endpoint_private_access = true
    enable_static_private_ips     = true
  }
}

resource "aws_iam_role" "eks_role" {
  name               = "aws_eks_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

// Create security group for EKS
resource "aws_security_group" "eks_security_group" {
  name        = "eks_cluster_sg"
  description = "Allow EKS cluster to access the internet"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    # Allow outbound Internet access
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allowed sources for inbound traffic
  # To define multiple sources use multiple resources
  # E.g. With an Network Load Balancer add ingress block like this
  # ingress {
  #     from_port       = 4443
  #     to_port         = 4443
  #     protocol        = "tcp"
  #     cidr_blocks     = [aws_lb.lb.vpc_zone_identifier]
  #     security_groups = [aws_security_group.master.id]
  # }
}

// Create subnets for EKS cluster
resource "aws_subnet" "eks_subnet_a" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.region_namea
  tags = {
    Name = "eks-subnet-a"
  }
}

resource "aws_subnet" "eks_subnet_b" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.region_nameb
  tags = {
    Name = "eks-subnet-b"
  }
}

resource "aws_subnet" "eks_subnet_c" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.region_namec
  tags = {
    Name = "eks-subnet-c"
  }
}
