resource "aws_eks_cluster" "cluster" {
  name     = "sandbox"
  role_arn = aws_iam_role.cluster_role.arn
  vpc_config {
    subnet_ids         = aws_subnet.public.*.id
    security_group_ids = [aws_security_group.eks.id]
  }
}

resource "aws_iam_role" "cluster_role" {
  name = "eks-sandbox"
  assume_role_policy = <<-EOF
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
}

resource "aws_iam_policy" "cluster_policy" {
  name = "eks-sandbox"
  path = "/"
  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = aws_iam_policy.cluster_policy.arn
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "eks-sandbox-vpc"
  }
}

resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.vpc.id
  availability_zone = lookup(var.aws_azs, count.index)
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  tags = {
    Name = "eks-sandbox-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = 2
  vpc_id            = aws_vpc.vpc.id
  availability_zone = lookup(var.aws_azs, count.index)
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 12, count.index)
  tags = {
    Name = "eks-sandbox-subnet-private-${count.index}"
  }
}

resource "aws_security_group" "eks" {
  name        = "eks-sandbox"
  description = "allow ssh"
  vpc_id      = aws_vpc.vpc.id
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
  tags = {
    Name = "eks-sandbox"
    Security_group = "eks"
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.id
}

resource "kubernetes_manifest" "deployment" {
  manifest = <<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: webshell
  name:  webshell
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webshell
  template:
    metadata:
      labels:
        app:  webshell
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
            value: "0.0.0.0/0,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,fc00::/7"
          name: webshell
          ports:
            - containerPort: 80
          command:
            - "/opt/shellinabox.init"
          args:
            - "bin/sh"
            - "-c"
            - "#(nop) "
            - "ENTRYPOINT [\"/opt/shellinabox.init\"]"
          resources: {}
EOF
  kubeconfig = data.aws_eks_cluster_auth.cluster.raw_config
}

resource "kubernetes_manifest" "service" {
   
  manifest = <<-EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app: webshell
  name: webshell
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: webshell
  type: NodePort
EOF
  kubeconfig = data.aws_eks_cluster_auth.cluster.raw_config
}
