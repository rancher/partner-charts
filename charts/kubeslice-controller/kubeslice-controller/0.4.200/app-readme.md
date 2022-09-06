# Kubeslice Controller

## Introduction

The KubeSlice Controller orchestrates the creation and management of slices on worker clusters.
The KubeSlice Controller components and the worker cluster components can coexist on a cluster. Hence, the cluster running the KubeSlice controller can also be used as a worker cluster.

The user is required to register themselves to receive a token that is required to install the KubeSlice Controller and Worker Operator.

Instructions for registration will be provided during the installation steps.

## Chart Details

This chart installs the following:

- KubeSlice Controller specific ClusterResourceDefinition (CRD)
- ClusterRole, ServiceAccount and ClusterRoleBinding for KubeSlice Controller
- A role and RoleBinding for KubeSlice Controller Leader Election
- KubeSlice Controller workload
- Kubernetes Dashboard
- KubeSlice Controller API Gateway
- KubeSlice Manager
- Kubeslice dashboard for user interactions.

📖 For step-by-step instructions, go to [documentation](https://docs.avesha.io/documentation/enterprise/0.1.0/deployment-partners/deploying-kubeslice-on-rancher/).

This chart will install our enterprise edition of KubeSlice. 

🟠 Note: KubeSlice is an opensource project. We encourage you to use, connect with the community, and contribute to the [opensource edition of KubeSlice](https://github.com/kubeslice). 
