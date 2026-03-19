# DxOperator

DxOperator is DH2i’s Kubernetes operator for deploying and managing SQL Server Availability Groups with DxEnterprise. It watches the `DxSqlAg` custom resource and continuously reconciles the Kubernetes resources and DxEnterprise configuration needed to run a SQL Server AG in Kubernetes.

Install this chart first to add the operator and its CRDs to your cluster. After DxOperator is running, you can create and manage SQL Server Availability Groups by deploying the `dxsqlag` chart or by applying `DxSqlAg` manifests directly.