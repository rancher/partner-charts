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

Connectors fall into two groups with different opt-in semantics:

**Always-on connectors** — enabled by default server-side. Set `disabled: true` to turn
one off, or set any sub-field to override its server default:

| Block | Connector |
|---|---|
| `grpc` | gRPC interface |
| `rest` | REST/WebSocket interface (also fronts the HTTP-family connectors below) |
| `api` | API / dashboard interface |
| `http` | Shared HTTP server + CORS policy for the HTTP-family connectors |
| `mcp` | Model Context Protocol (shares the REST port) |
| `agents` | Agents / A2A (shares the REST port) |
| `ce` | CloudEvents (shares the REST port) |

> The `mcp`, `agents`, and `ce` connectors share the REST HTTP port. Their external
> exposure is governed by the `rest.expose` / `rest.nodePort` settings — keep `rest`
> enabled to reach them.

**Opt-in connectors** — disabled by default server-side (no ports opened unless you
explicitly opt in). Set `enabled: true` to activate a connector and open its port(s).
Omitting the block entirely, or setting `enabled: false`, keeps the connector off:

| Block | Connector | Ports |
|---|---|---|
| `mqtt` | MQTT | 1883 (mqtt), 8883 (mqtt-tls), 8083 (mqtt-ws) |
| `amqp` | AMQP 0.9.1 (RabbitMQ dialect) | 5672 (amqp), 5671 (amqp-tls) — shared with amqp10 |
| `amqp10` | AMQP 1.0 | 5672 (amqp), 5671 (amqp-tls) — shared with amqp |
| `stomp` | STOMP | 61613 (stomp), 61614 (stomp-tls) |
| `aws` | AWS SQS/SNS | 4566 (aws-http) |
| `gcp` | Google Cloud Pub/Sub | 8085 (gcp-grpc, gRPC-only) |

> The `amqp` and `amqp10` connectors share a single Kubernetes Service on ports 5672/5671.
> The Service is kept as long as at least one of the two dialects is enabled.

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

### v2.8.x → v2.9.0 — Wire-protocol connectors are now opt-in (BREAKING)

**Lockstep requirement:** chart v2.9.0 must be installed together with the kubemq-crds
v2.13.0 chart, the kubemq-operator v1.19.0 (or the kubemq-controller chart at its matching
version), and the KubeMQ server image v3.0.0-b7+. **Do not upgrade charts alone** — the
operator and server binary must move in lockstep.

**What changed:** The six wire-protocol connectors (MQTT, AMQP 0-9-1, AMQP 1.0, STOMP,
AWS, GCP Pub/Sub) are **disabled by default** in the server binary starting from v3. The
CRD field for these connectors changed from `disabled: bool` to `enabled: *bool`. Any
existing `KubemqCluster` CR block that tunes a connector without setting `enabled` will
resolve **off** after the upgrade.

**Migration — add `enabled: true` to each connector you need:**

```yaml
spec:
  mqtt:
    enabled: true   # was: disabled: false (or omitted)
  amqp:
    enabled: true
  amqp10:
    enabled: true
  stomp:
    enabled: true
  aws:
    enabled: true
  gcp:
    enabled: true
```

See the full upgrade guide at:
[dev-center/content/docs/getting-started/installation/upgrade-v2-to-v3.mdx](https://github.com/kubemq-io/dev-center/blob/master/content/docs/getting-started/installation/upgrade-v2-to-v3.mdx)

**No customer-facing publish** until all repositories are green and the user gate is
satisfied. Lockstep: server flip must not be merged to a release branch until the k8s-lib
tag + operator vendor (the `enabled` re-enable path) land.

## Uninstalling the charts

To uninstall/delete kubemq-cluster use the following command:

```console
$ helm uninstall -n kubemq kubemq-cluster
```
The commands remove all the Kubernetes components associated with the chart.

If you want to keep the history use `--keep-history` flag.
