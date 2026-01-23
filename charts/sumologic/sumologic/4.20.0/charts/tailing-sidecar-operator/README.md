# Tailing Sidecar Operator

![Project Status](https://img.shields.io/badge/status-alpha-important?style=for-the-badge)

[Tailing Sidecar Operator](../../operator/README.md) makes it easy to add
[streaming sidecar containers](https://kubernetes.io/docs/concepts/cluster-administration/logging/#streaming-sidecar-container)
to pods in your cluster by adding annotations on the pods.

## Prerequisites

Before installing this chart, ensure the following prerequisites are satisfied in your cluster:

- [admission webhooks](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#prerequisites)
  are enabled

## Installing

Having satisfied the [Prerequisites](#prerequisites), run the following to add Helm repository:

```sh
helm repo add tailing-sidecar https://sumologic.github.io/tailing-sidecar
helm repo update
```

and install Helm chart:

```sh
helm upgrade --install tailing-sidecar tailing-sidecar/tailing-sidecar-operator \
  -n tailing-sidecar-system \
  --create-namespace
```

## Uninstalling

```sh
helm uninstall tailing-sidecar-operator
```

## Configuration

See [values.yaml](./values.yaml) file for the available configuration options.

### Using `cert-manager` to manage operator's certificates

By default, TLS certificates for the Tailing Sidecar Operator's API webhook
are created using Helm's functions `genCA` and `genSignedCert`.
The generated certificate is valid for 365 days after issuing, i.e. after chart installation.

If you have [cert-manager](https://cert-manager.io/) installed in your cluster,
you can make the chart use it for certificate management by setting the property `certManager.enabled` to `true`.

### Overriding Tailing Sidecar configuration

In order to override tailing sidecar configuration, the following properties may be used:

```yaml
sidecar:
  config:
    mountPath: /etc/otel  #for version>=0.19 .0 or  /fluent-bit/etc/ for version <=0.18.1
    content: #  applicable for version <=0.18.1
      file-1.conf: |
        content of file-1.conf
      file-2.conf: |
        content of file-2.conf
```

The above configuration is going to create `file-1.conf` and `file-2.conf` in `/fluent-bit/etc/` directory.

**All existing content of `/fluent-bit/etc/` directory will be replaced with the `sidecar.config.content`.**