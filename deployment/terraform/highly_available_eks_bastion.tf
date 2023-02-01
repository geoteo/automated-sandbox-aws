//Terraform for Highly Available EKS and Bastion Host in EC2

//Provider Block
provider "aws" {
  region = "${var.region}"
}

//VPC Block
resource "aws_vpc" "main_vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "k8s_vpc_${var.name}"
  }
}

//Internet Gateway Block
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main_vpc.id}"
}

//Public Subnet
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${var.public_subnet}"
  map_public_ip_on_launch = true
  availability_zone = "${var.availability_zone}"

}

//Nat Gateway Block
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.ngw_eip.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

//EIP for Nat Gateway
resource "aws_eip" "ngw_eip" {
  vpc = true
}

//Route Table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

//Associate the Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

//Security Groups
resource "aws_security_group" "private_secgrp" {
  name        = "private_secgrp_${var.name}"
  description = "Security group of private subnet"
  vpc_id      = "${aws_vpc.main_vpc.id}"
}

//EKS related Blocks
resource "aws_eks_cluster" "main_cluster" {
name     = "eksCluster-${var.name}"
role_arn = "${var.master_role_arn}"

// Workers Groups
vpc_config {
  security_group_ids = "${aws_security_group.private_secgrp.id}"
  subnet_ids         = "${var.subnet_id}"
}

// Additional Blocks for Highly Available

//Additional Masters
subnet_ids = ["${aws_subnet.public.id}"]

//Autoscaling Configuration
auto_scaling_groups = [
  {
    name            = "eksCluster-autoscaling-group"
    min_size        = 2
    max_size        = 5
    launch_template = {
        id = "${aws_launch_template.template.id}"
        version = "${aws_launch_template.template.latest_version}"
    }
  },
]

// Launch Template
resource "aws_launch_template" "template" {
  name              = "eksCluster-launch-template"
  image_id          = "${var.image_id}"
  instance_type     = "${var.instance_type}"
  key_name          = "${var.key_name}"
  associate_public_ip_address = true

}

// Bastion Host, EC2 Block
resource "aws_instance" "bastion" {
  ami             = "${var.image_id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  count           = 1
  subnet_id       = "${aws_subnet.public.id}"

  security_groups = ["${aws_security_group.private_secgrp.id}"]

  //User Data for the Bastion Host
  user_data = <<-EOF
#! /bin/bash
yum install -y aws-cli
aws eks --region ${var.region} update-kubeconfig --name eksCluster-${var.name}
EOF

}

output "cluster_endpoint" {
    value = "${aws_eks_cluster.main_cluster.endpoint}"
}
