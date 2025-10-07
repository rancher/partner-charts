# NetScaler Kubernetes Gateway Controller

[NetScaler Kubernetes Gateway Controller](https://docs.netscaler.com/en-us/netscaler-kubernetes-gateway-controller.html) translates Gateway API objects into NetScaler configurations. NetScaler Kubernetes Gateway continuously monitors the Kubernetes API server for changes in the gateway API resources. The NetScaler Kubernetes Gateway is a separate deployment from the NetScaler Ingress Controller. If both Ingress and Gateway API functionalities are needed, both the NetScaler Ingress Controller and the NetScaler Kubernetes Gateway must be deployed.

This chart bootstraps standalone NetScaler Kubernetes Gateway Controller which can be used to configure NetScaler MPX or VPX.
