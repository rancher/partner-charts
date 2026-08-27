# NetScaler IPAM Controller

[NetScaler IPAM Controller](https://docs.netscaler.com/en-us/netscaler-k8s-ingress-controller/configure/ipam-for-ingress.html) can automatically allocate an IP address to an Ingress or Service. Once the IPAM controller is deployed, it allocates IP address to services of type LoadBalancer or an Ingress from predefined IP address ranges. The NetScaler ingress controller configures the IP address allocated to the service as virtual IP (VIP) in NetScaler MPX or VPX.

This chart bootstraps standalone NetScaler IPAM Controller which can be used for IP Address management in NetScaler MPX or VPX.
