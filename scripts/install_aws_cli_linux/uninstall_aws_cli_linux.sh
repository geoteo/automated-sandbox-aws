#!/bin/bash

# Uninstall Prerequisites
echo "Uninstalling prerequisites..."  
aptget remove -y curl unzip

# Uninstall AWS CLI v2

echo "Uninstalling AWS CLI v2..."  
./aws/uninstall  
rm -rf awscliv2.zip aws/

echo "AWS CLI v2 has been successfully uninstalled!"
