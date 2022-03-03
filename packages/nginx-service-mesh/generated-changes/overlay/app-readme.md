# NGINX Service Mesh

[NGINX Service Mesh](https://docs.nginx.com/nginx-service-mesh/) is a fully integrated lightweight service mesh that leverages a data plane powered by NGINX Plus to manage container traffic in Kubernetes environments.

NGINX Service Mesh is supported in Rancher 2.5+ when deploying from the Apps and Marketplace. NGINX Service Mesh is not currently supported on k3s.

## Enabling telemetry

Telemetry can only be enabled by editing the configuration YAML directly in the Rancher UI. When installing NGINX Service Mesh, select the `Edit YAML` option. To enable telemetry, set the `tracing` object to `{}` and fill out the `telemetry` object.
The telemetry object expects a `samplerRatio`, and the `host` and `port` of your OTLP gRPC collector.
For example:

```yaml
tracing: {}
telemetry:
  samplerRatio: 0.01
  exporters:
    otlp:
      host: "my-otlp-collector-host"
      port: 4317
```
