# DxSqlAg

DxSqlAg is the Helm chart for creating a single SQL Server Availability Group in Kubernetes with DH2i DxOperator and DxEnterprise. It installs a `DxSqlAg` custom resource, lets the operator create and manage the required StatefulSets, Services, and cluster configuration for the AG.

Install this chart after DxOperator v2 is already installed. Configure the chart values for your secrets, replica layout, storage, and SQL Server settings, then deploy it to create and operate a SQL Server AG through a declarative Kubernetes workflow.