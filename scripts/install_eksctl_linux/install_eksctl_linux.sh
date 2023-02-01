#!/bin/bash

echo Installing eksctl

# confirm if curl, unzip and git are installed
if ! [ -x "$(command -v curl)" ]; then 
  echo 'Error: curl is not installed.' 
  echo 'Install curl, unzip and git and try again.' 
  exit 1 
fi

if ! [ -x "$(command -v unzip)" ]; then 
  echo 'Error: unzip is not installed.' 
  echo 'Install curl, unzip and git and try again.' 
  exit 1 
fi

if ! [ -x "$(command -v git)" ]; then 
  echo 'Error: git is not installed.' 
  echo 'Install curl, unzip and git and try again.' 
  exit 1 
fi

#install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

echo "eksctl has been installed successfully"