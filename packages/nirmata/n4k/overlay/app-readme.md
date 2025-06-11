Kyverno-N4K is an enterprise distribution of Kyverno by Nirmata, a Kubernetes-native policy engine that enables users to validate, mutate, and generate configurations using familiar YAML syntax.

This chart includes:
- Core Kyverno engine
- Custom Resource Definitions (CRDs)
- Optional Grafana dashboards for policy observability
- Optional reports server for storing policy reports

## Features
- Admission control via validation/mutation policies
- Background policy enforcement
- Policy report generation and aggregation
- Policy compliance visibility with Grafana
- Integration with PostgreSQL or external DB

## Prerequisites
- Kubernetes 1.22+
- Optional: Grafana instance for dashboards
- Optional: PostgreSQL instance for external report storage

> N4K is maintained by Nirmata and is compatible with Rancher-supported distributions (RKE2, K3s, EKS).

For documentation and usage examples, visit: [https://docs.nirmata.io/docs/n4k/](https://docs.nirmata.io/docs/n4k/)

