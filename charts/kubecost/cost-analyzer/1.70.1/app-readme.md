# Kubecost
[Kubecost](https://kubecost.com/) is an open-source Kubernetes cost monitoring solution.

Kubecost gives teams visibility into current and historical Kubernetes spend and resource allocation. These models  provide cost transparency in Kubernetes environments that support multiple applications, teams, departments, etc.

To see more on the functionality of the full Kubecost product, please visit the [features page](https://kubecost.com/#features) on our website.

Here is a summary of features enabled by this cost model:

- Real-time cost allocation by Kubernetes service, deployment, namespace, label, statefulset, daemonset, pod, and container
- Dynamic asset pricing enabled by integrations with AWS, Azure, and GCP billing APIs 
- Supports on-prem k8s clusters with custom pricing sheets
- Allocation for in-cluster resources like CPU, GPU, memory, and persistent volumes.
- Allocation for AWS & GCP out-of-cluster resources like RDS instances and S3 buckets with key (optional)
- Easily export pricing data to Prometheus with /metrics endpoint ([learn more](PROMETHEUS.md))
- Free and open source distribution (Apache2 license)

## Requirements
- Kubernetes 1.8+
- kube-state-metrics
- Grafana
- Prometheus
- Node Exporter
