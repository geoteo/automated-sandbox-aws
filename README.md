Deployment of a High-Availability EKS Cluster with a WebShell using IAC Solutions
=================================================================================

This GitHub repository contains the necessary code and configurations to deploy a highly-available Amazon Elastic Container Service for Kubernetes (EKS) cluster in AWS, as well as a WebShell, using various Infrastructure as Code (IAC) solutions. The repository is intended to assist Sales Engineers in quickly accessing a sandboxed EKS environment to showcase the speed and ease of deploying the Dynatrace Operator onto any Kubernetes cluster.


Technologies Used
-----------------

-   AWS CloudFormation
-   Terraform
-   GitHub Actions with Slack Notifications
-   Pulumi
-   Custom Bash Scripts

Prerequisites
-------------

-   An AWS account
-   AWS CLI installed and configured
-   Terraform CLI installed
-   Pulumi CLI installed
-   Basic knowledge of AWS, Terraform, Pulumi, and GitHub Actions

Code Overview
-------------

The repository contains the following directories:

-   `cloudformation`: contains the AWS CloudFormation templates for deploying the EKS cluster
-   `terraform`: contains the Terraform code for deploying the EKS cluster and WebShell
-   `pulumi`: contains the Pulumi code for deploying the EKS cluster
-   `github_actions`: contains the GitHub Actions workflow for deploying the EKS cluster using Terraform and sending Slack notifications
-   `bash_scripts`: contains custom bash scripts for automating the deployment process

Deployment Steps
----------------

1.  Clone the repository

`$ git clone https://github.com/[YOUR_USERNAME]/[REPO_NAME].git`

1.  Navigate to the appropriate directory based on the IAC solution you wish to use (e.g. `terraform`)

`$ cd terraform`

1.  Run the appropriate deployment command based on the IAC solution you are using

-   Terraform:

`$ terraform init
$ terraform apply`

-   Pulumi:

`$ pulumi up`

-   AWS CloudFormation:

`$ aws cloudformation create-stack --stack-name [STACK_NAME] --template-body file://[TEMPLATE_FILE]`

-   GitHub Actions: Commit and push the changes to your repository to trigger the GitHub Actions workflow.

WebShell Access
---------------

After deploying the EKS cluster and WebShell, you can access the WebShell via the public IP or DNS of any of the worker nodes. The default credentials are:

-   username: `student`
-   password: `student`

Clean Up
--------

To clean up the resources created during the deployment process, run the appropriate command based on the IAC solution you used:

-   Terraform:

`$ terraform destroy`

-   Pulumi:

`$ pulumi destroy`

-   AWS CloudFormation:

`$ aws cloudformation delete-stack --stack-name [STACK_NAME]`

Conclusion
----------

By using the code and configurations in this repository, Sales Engineers can quickly deploy a highly-available EKS cluster in AWS along with a WebShell, reducing the amount of time it takes to showcase the speed and ease of deploying the Dynatrace Operator onto any Kubernetes cluster.
