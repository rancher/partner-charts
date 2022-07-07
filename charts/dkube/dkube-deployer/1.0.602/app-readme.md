# Dkube

[DKube](https://dkube.io/) is an MLOps product based on best of Kubeflow and MLFlow. It is optimized for implementation on-prem or in the cloud. You get the flexibility and innovation of open source ref architectures like Kubeflow and MLFlow as a supported product.

With DKube you can prepare your data including feature engineering, train AI models, optimize, tune and publish AI models and be able to deploy/serve those models.  Kubeflow pipelines, KF Serving, MLFlow experiment tracking and comparison are all provided while allowing you to track the model and data versioning for reproducibility, audits and governance.

## Installation

### Requirements
The following is the minimum configuration required to deploy DKube on a Rancher cluster
- The minimal configuration for each of the worker nodes is as follows:
  - 16 cores
  - 64 GB RAM
  - 300 GB storage for Root Volume
- The worker nodes could be brought up with any of the following OS distributions
  - Ubuntu 20.04
  - CentOS / RHEL 7.9
  - Amazon Linux 2 for installations on AWS
- Storage
  - The recommended storage option for DKube meta-data and user ML resources is an external NFS server with a min of 1TB storage available.
  - For evaluation purposes, one of the worker nodes can be configured as the storage option. In this case the recommended size of storage on the worker node is 1 TB and a minimum size of 400 GB.
- Dkube requires a Kubernetes version of 1.20.
- Dkube images registry details are required for installation. Please send a mail to support@dkube.io for the details.
- The following sections in the installation guide needs to be followed to prepare Rancher cluster for Dkube installation.
  - [Getting the Dkube Files](https://dkube.io/install/install3_x/Install-Getting-Started.html#getting-the-dkube-files)
  - [Setting up the Rancher Cluster](https://dkube.io/install/install3_x/Install-Rancher.html#setting-up-the-rancher-cluster)
  - [Preparing the Rancher Cluster](https://dkube.io/install/install3_x/Install-Rancher.html#preparing-the-rancher-cluster).
  - [Node Setup](https://dkube.io/install/install3_x/Install-Rancher.html#node-setup). This is optional for a non-GPU cluster.

For more information on installation, refer to the [Dkube Installation Guide](https://dkube.io/install/install3_x/Install-Advanced.html).
