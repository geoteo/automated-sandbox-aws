#!/bin/bash

# get kubectl download URL
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

# make the download executable
chmod +x ./kubectl

# move the executable to system directory
sudo mv ./kubectl /usr/local/bin/kubectl

# check the version of the installed kubectl
kubectl version --client