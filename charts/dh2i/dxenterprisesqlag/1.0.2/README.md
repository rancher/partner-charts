# DxOperator - DxE & SQL Server AG

This chart deploys a SQL Server Availability group in Kubernetes managed by DxOperator, DH2i's custom operator. DxOperator can create new availability groups in Kubernetes, or join existing availability groups that are managed using DxEnterprise.

## Prerequisites

- DxOperator installed and running in your Kubernetes cluster.
- A DxEnterprise license key with availability group management, tunnels, and (optionally) NAT features.

## Additional Information

Instructions for creating this chart using Helm can be found in the [DxOperator Helm Guide](https://support.dh2i.com/dxoperator/v1.0.67.0/guides/dxesqlag-helm).

Before creating an availability group, reference SQL Server's [quorum considerations](https://support.dh2i.com/docs/v23.0/kbs/sql_server/availability_groups/quorum-considerations-for-sql-server-availability-groups) when determining the quantity of replicas to deploy.
