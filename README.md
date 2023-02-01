AWS CLI v2 Installation
=======================

This guide will show how to install AWS CLI v2 on a Linux environment.

Prerequisites
-------------

Before you get started, make sure your machine has:

*   `curl`
*   `unzip`

Installation
------------

Follow the steps below to install AWS CLI v2:

1.  Download AWS CLI v2 package:  
    `curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"`
2.  Unzip the package:  
    `unzip awscliv2.zip`
3.  Install the package:  
    `./aws/install`

Verifying Your Installation
---------------------------

Once the installation is complete, you can check the AWS CLI version by running the following command:  
`aws --version`

Conclusion
----------

After following the steps above, AWS CLI v2 is sucessfully installed on your machine. Enjoy using and managing your AWS resources using the AWS CLI!


# Uninstall Script for AWS CLI v2

Uninstall Prerequisites
-----------------------

echo "Uninstalling prerequisites..."  
aptget remove -y curl unzip

Uninstall AWS CLI v2
--------------------

echo "Uninstalling AWS CLI v2..."  
./aws/uninstall  
rm -rf awscliv2.zip aws/

echo "AWS CLI v2 has been successfully uninstalled!"