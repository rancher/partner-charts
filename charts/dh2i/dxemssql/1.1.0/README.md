## DxEnterprise for Microsoft SQL AG

Helm chart for DH2i's DxEnterprise  with SQL Server Availability Groups

DxEnterprise (DxE) Smart High Availability Clustering software 
dramatically reduces the complexity of configuring and managing highly 
available SQL Server AGs. DxEnterprise makes AGs highly available within 
containers without relying on WSFC or any other cumbersome and 
restrictive cluster orchestration technologies. Additionally, DxE 
provides advanced fault detection and failover automation to minimize 
outages for SQL Server databases, helping customers achieve 
nearest-to-zero total downtime. DxEnterprise AGs enable cross-network 
failover without opening external ports or having to utilize virtual 
private networks (VPNs), enabling simplified cross-network, cross-zone, 
and cross-region clusters.

- SDP-enhanced highly available SQL Server Availability Groups
- Realtime health detection and automatic failover
- Discreet and secure networking across AG nodes in separate sites, 
  regions, or clouds - without a VPN
- Management simplicity and minimal complexity

## Chart Information

This chart deploys a SQL Server Availability Group managed by 
DxEnterprise clustering technology.

## Prerequisites 

- A DxEnterprise license key with Availability Group management features 
  and tunnels enabled -- [Request a free developer license](https://dh2i.com/dxoperator-sql-server-operator-for-kubernetes/)
- Persistent volumes, for storing the SQL Server data
- A secret on your Kubernetes cluster that contains SQL Server 
  credentials (`MSSQL_SA_PASSWORD`), your DxEnterprise cluster password 
  (`DX_PASSKEY`), your DxEnterprise license key (`DX_LICENSE`), and
  optionally your one-time passkey (`DX_OTPK`)
- Optional: DxAdmin installed on a Windows machine. Installation 
  instructions for DxAdmin can be found in [DH2i documentation](https://support.dh2i.com/docs/v22.0/guides/dxenterprise/installation/dxadmin-qsg)

## Additional Information

- To install using the Helm CLI: [Install DxE + SQL Server Helm Chart](https://support.dh2i.com/docs/v23.0/guides/dxenterprise/containers/kubernetes/mssql-ag-helm)
- Instructions for installing this chart using Rancher can be found in the [DxEnterprise Rancher guide](https://support.dh2i.com/docs/v23.0/guides/dxenterprise/containers/kubernetes/mssql-ag-rancher#install-the-helm-chart), and additional DxEnterprise Kubernetes documentation can be found [here](https://support.dh2i.com/docs/v22.0/guides/dxenterprise/containers/kubernetes)
- Before creating an Availability Group, reference SQL Server's [quorum considerations](https://support.dh2i.com/docs/v23.0/kbs/sql_server/availability_groups/quorum-considerations-for-sql-server-availability-groups) when determining the quantity of replicas to deploy
