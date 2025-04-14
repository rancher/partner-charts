# CloudCasa Kubernetes Agent

[CloudCasa](https://cloudcasa.io) - Leader in Kubernetes Data Protection and Application Resiliency

# Introduction

CloudCasa is a data protection, disaster recovery, migration, and replication service for Kubernetes and cloud-native applications. Configuration is quick and easy, and basic service is free.

CloudCasa provides two types of backup services for Kubernetes: 
* **CloudCasa Pro** provides centralized backup services for large, complex, multi-cluster, multi-cloud, and hybrid cloud environments. It includes multi-cloud account integration, managed backup storage, and advanced cross-cloud recovery. It also provides protection for VMs running under SUSE Virtualization and other KubeVirt-based systems.
* **CloudCasa Velero Management** provides centralized management and monitoring, guided recovery, and commercial support for existing Velero backup installations.

Whether you are managing existing Velero installations or using the advanced Pro features, with CloudCasa you don't need to be a storage or data protection expert to back up and restore your Kubernetes clusters.

This Helm chart installs and configures the CloudCasa agent on a Kubernetes cluster.
See the CloudCasa [Getting Started Guide](https://docs.cloudcasa.io/help/guide-kubernetes-backup.html) for more information.

Note that a [CloudCasa Rancher Extension](https://docs.cloudcasa.io/help/rancher.html) is also available that allows SUSE Rancher and Rancher Prime users to perform common CloudCasa functions through the Rancher UI.

## Prerequisites

1. Kubernetes 1.20+
2. Rancher configured to manage your cluster

## Rancher Installation (Apps & Marketplace)

1. Log in to https://home.cloudcasa.io and add your Kubernetes cluster under the Clusters tab. Note the returned cluster ID.
2. Go to Apps & Marketplace in the Rancher UI. In the Chart section, check the Partners checkbox and click on the CloudCasa chart.
3. Provide a Name (e.g. CloudCasa) and optional description.
4. In the CloudCasa Configuration section, provide the Cluster ID obtained above.
5. Click on the Install button to complete installation of the agent.

To perform an upgrade, click on Upgrade version. 

*CloudCasa is a trademark of Catalogic Software Inc.*
