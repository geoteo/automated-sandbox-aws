# Installing eksctl

This readme will guide you through the steps necessary to install eksctl on your local system.

Prerequisites
-------------

Before installing eksctl you will need to make sure that the following applications are installed:

*   [curl](https://curl.haxx.se/)
*   [unzip](https://infozip.sourceforge.io/)
*   [git](https://git-scm.com/)

Installation
------------

Follow the steps below to install eksctl on your system:

1.  Download the eksctl binary:

```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
```

2.  Move the binary to `/usr/local/bin`

```
sudo mv /tmp/eksctl /usr/local/bin
```

You should now have eksctl installed on your system. You can confirm that this is the case by running the command `eksctl version`.
