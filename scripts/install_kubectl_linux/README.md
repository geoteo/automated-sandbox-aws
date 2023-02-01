Installation Script for Kubectl
===============================

This installation script can be used to easily download, make executable and move Kubectl to a system.

Prerequisites
-------------

You must have curl installed on your system to use this script.

Usage
-----

1.  Download Kubectl: `curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s [https://storage.googleapis.com/kubernetes-release/release/stable.txt\`/bin/linux/amd64/kubectl\`](https://storage.googleapis.com/kubernetes-release/release/stable.txt%60/bin/linux/amd64/kubectl%60)
2.  Make the downloaded Kubectl executable: `chmod +x ./kubectl`
3.  Move the executable to system directory: `sudo mv ./kubectl /usr/local/bin/kubectl`
4.  Check the version of the installed kubectl: `kubectl version --client`

Enjoy using Kubectl!
