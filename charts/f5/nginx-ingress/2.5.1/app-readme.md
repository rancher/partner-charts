# NGINX Ingress Controller

The [NGINX Ingress Controller](https://github.com/nginxinc/kubernetes-ingress) for Kubernetes provides an enterprise‑grade implementation of an Ingress controller for NGINX and NGINX Plus for Kubernetes applications.

The Ingress controller is an application that runs in a cluster and configures an HTTP load balancer according to Ingress resources. The load balancer can be a software load balancer running in the cluster or a hardware or cloud load balancer running externally. Different load balancers require different Ingress controller implementations.

In the case of NGINX, the Ingress controller is deployed in a pod along with the load balancer.

NGINX Ingress controller works with both NGINX and NGINX Plus and supports the standard Ingress features - content-based routing and TLS/SSL termination.

Additionally, several NGINX and NGINX Plus features are available as extensions to the Ingress resource via annotations and the ConfigMap resource. In addition to HTTP, NGINX Ingress controller supports load balancing Websocket, gRPC, TCP and UDP applications. See ConfigMap and Annotations docs to learn more about the supported features and customization options.

As an alternative to the Ingress, NGINX Ingress controller supports the VirtualServer and VirtualServerRoute resources. They enable use cases not supported with the Ingress resource, such as traffic splitting and advanced content-based routing.

TCP, UDP and TLS Passthrough load balancing is also supported.  
