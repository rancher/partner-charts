# kubemq-cluster

`kubemq-cluster` is the Helm chart that installs the KubeMQ Cluster.

## Installing

For example:
```console
$ helm repo add kubemq-charts  https://kubemq-io.github.io/charts
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster
```

## Using Private Container Registries

KubeMQ Cluster supports pulling images from private container registries. To use private registries:

1. **Create a registry secret:**

```console
$ kubectl create secret docker-registry my-registry-secret \
  --docker-server=my-private-registry.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com \
  --namespace=kubemq
```

2. **Install the cluster with the registry secret:**

```console
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster \
  --set key={your-license-key} \
  --set imagePullSecrets[0].name=my-registry-secret
```

3. **Using values file:**

Create a `values.yaml` file:
```yaml
key: your-license-key
imagePullSecrets:
  - name: my-registry-secret
```

Then install:
```console
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster -f values.yaml
```

## Configuration

This chart is a thin passthrough over the `KubemqCluster` custom resource. Every key you
set under the chart's values (except `key`, `license`, and `imagePullSecrets`, which are
handled specially) is rendered verbatim into `spec:` of the generated `KubemqCluster` — so
**any `KubemqCluster.spec.*` field is a Helm value of the same name**. The full, annotated
catalog of supported values lives in
[`values_example.yaml`](values_example.yaml); the authoritative field reference is
[`docs/10-configuration-reference.md`](https://github.com/kubemq-io/kubemq-server/blob/master/docs/10-configuration-reference.md)
in the KubeMQ server repo, and the validating schema is the
[`KubemqCluster` CRD](../kubemq-crds/templates/kubemqclusters.core.k8s.kubemq.io.crd.yaml).

> **Passthrough pinning caveat:** because every value is rendered straight into `spec:`,
> putting an *active* (uncommented) value in your `values.yaml` **pins** that field on the
> CR. The server default for that field then no longer applies — the chart value wins, even
> across upgrades. Keep your `values.yaml` minimal (license + only the fields you truly need
> to override) and leave everything else commented so the server defaults stay in effect.
> Use `values_example.yaml` as a reference for what *can* be set, not as a file to copy
> wholesale.

### Connector blocks

Each connector is enabled by default server-side; set `disabled: true` to turn one off, or
set any sub-field to override its server default:

| Block | Connector |
|---|---|
| `grpc` | gRPC interface |
| `rest` | REST/WebSocket interface (also fronts the HTTP-family connectors below) |
| `api` | API / dashboard interface |
| `http` | Shared HTTP server + CORS policy for the HTTP-family connectors |
| `mqtt` | MQTT |
| `amqp` | AMQP 0.9.1 (RabbitMQ dialect) |
| `amqp10` | AMQP 1.0 |
| `stomp` | STOMP |
| `aws` | AWS SQS/SNS |
| `gcp` | Google Cloud Pub/Sub |
| `mcp` | Model Context Protocol (shares the REST port) |
| `agents` | Agents / A2A (shares the REST port) |
| `ce` | CloudEvents (shares the REST port) |

> The `mcp`, `agents`, and `ce` connectors share the REST HTTP port. Their external
> exposure is governed by the `rest.expose` / `rest.nodePort` settings — keep `rest`
> enabled to reach them.

### Core blocks

| Block | Purpose |
|---|---|
| `store` | Persistent store settings |
| `queue` | Queue defaults |
| `authentication` | Authentication (JWT / OIDC) |
| `authorization` | Authorization policy |
| `routing` | Channel routing rules |
| `tls` | TLS material |
| `telemetry` | OpenTelemetry traces/metrics export |
| `audit` | Audit log retention |
| `log` | Log level |
| `notification` | System notifications |
| `health` | Health-probe timing |

## Upgrading the charts

Please refer to the release notes of each version of the helm charts.
These can be found [here](https://github.com/kubemq/helm-charts/releases).

## Uninstalling the charts

To uninstall/delete kubemq-cluster use the following command:

```console
$ helm uninstall -n kubemq kubemq-cluster
```
The commands remove all the Kubernetes components associated with the chart.

If you want to keep the history use `--keep-history` flag.
