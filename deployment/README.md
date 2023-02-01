To create a programmatic IAM user and attach the AmazonEKSCluster policy to the user, you can use the following CLI command:

`aws iam create-user --user-name <USER_NAME> --tags Key=Name,Value=amazon-eks-cluster-user`

`aws iam attach-user-policy --user-name <USER_NAME> --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy`

You can create an access key and secret access key for the user using the same following command:

`aws iam create-access-key --user-name <USER_NAME>`

To configure the AWS\_ACCESS\_KEY\_ID and AWS\_SECRET\_ACCESS\_KEY environment variables, you can use the following commands:

`export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>`

`export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>`

You can install eksctl in your environment by running the following command:

`curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp`

`sudo mv /tmp/eksctl /usr/local/bin`

You can run the eksctl create cluster command and enter any other information requested by eksctl using the following command:

`eksctl create cluster --name <CLUSTER_NAME> --region <REGION> --node-type <INSTANCE_TYPE> --nodes <NUMBER_OF_NODES> --ssh-access --ssh-public-key <PATH_TO_SSH_KEY>`