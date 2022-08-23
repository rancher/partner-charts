# Slice Operator

## Introduction

The Slice Operator, also known as Worker operator is a Kubernetes Operator component that manages the life-cycle of the KubeSlice related Custom Resource Definition (CRDs).

User is required to have already installed the kubeslice controller before installing the worker. The token created during the registration process of kubeslice controller must be used to install the kubeslice worker.

The Slice Operator performs the following functions:

- Interacts with the KubeSlice controller to receive slice configuration updates.
- Reconciliation of slice resources in the cluster KubeSlice Controller.
- Creation of slice components required for Slice VPN Gateway connectivity and Service Discovery.
- Auto insertion and deletion of slice components to accommodate topology changes.
- Lifecycle management of slices, slice configurations, slice status, and slice telemetry.
- Lifecycle management of network policies and monitoring of configuration drift to generate slice events and alerts.
- Management of the association of slices with namespaces
- Interaction with the KubeSlice Controller to:

  - Facilitate network policy and service discovery across the slice.
  - Import/export Istio services to/from the other clusters attached to the slice.
  - Implement Role-Based Access Control (RBAC) for managing the slice components.
  

📖 For step-by-step instructions, go to [documentation](https://docs.avesha.io/documentation/enterprise/0.1.0/deployment-partners/deploying-kubeslice-on-rancher/).

This chart will install our enterprise edition of KubeSlice. 

🟠 Note: KubeSlice is an opensource project. We encourage you to use, connect with the community, and contribute to the [opensource edition of KubeSlice](https://github.com/kubeslice). 
