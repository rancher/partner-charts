# NetScaler CPX with NetScaler Gateway Controller Running as Sidecar

In a [Kubernetes](https://kubernetes.io/) or [OpenShift](https://www.openshift.com) cluster, you can deploy [NetScaler CPX](https://docs.netscaler.com/en-us/cpx.html) with NetScaler gateway controller as a [sidecar](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/). The NetScaler CPX instance is used for load balancing the North-South traffic to the microservices in your cluster. And, the sidecar NetScaler gateway controller configures the NetScaler CPX.

This chart bootstraps deployment of NetScaler CPX with NetScaler Gateway Controller as sidecar.
