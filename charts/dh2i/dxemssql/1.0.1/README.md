# DxEnterprise for Microsoft SQL AG

This chart deploys a SQL Server availability group managed by DxEnterprise clustering technology. 

## Prerequisites

- A secret on your Kubernetes cluster that contains SQL Server credentials (`MSSQL_SA_PASSWORD`) and your DxEnterprise cluster password (`DX_PASSKEY`)
- A DxEnterprise license key with availability group management features and tunnels enabled
- Optional: DxAdmin installed on a Windows machine. Installation instructions for DxAdmin can be found in [DH2i documentation](https://support.dh2i.com/docs/v22.0/guides/dxenterprise/installation/dxadmin-qsg)

Instructions for creating this chart using Rancher can be found in the [DxEnterprise Rancher guide](https://support.dh2i.com/docs/v22.0/guides/dxenterprise/containers/kubernetes/mssql-ag-rancher#install-the-helm-chart), and additional DxEnterprise Kubernetes documentation can be found [here](https://support.dh2i.com/docs/v22.0/category/guides/dxenterprise/containers/kubernetes/).
