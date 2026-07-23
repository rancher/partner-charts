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

## Supplying the license from a Secret (optional)

By default the license is a literal value (`--set key=…` or `key:` in values), which Helm
stores in its release data and which lands in the `KubemqCluster` object — readable via
`helm get values` / `kubectl get kubemqcluster -o yaml`. To keep the raw token out of both,
create a Secret first and reference it instead:

```console
$ kubectl create secret generic my-kubemq-license -n kubemq --from-literal=key=<your-license-key>
$ helm install --create-namespace -n kubemq kubemq-cluster kubemq-charts/kubemq-cluster \
  --set keySecretRef=my-kubemq-license
```

The operator resolves the value from the Secret at reconcile time. `keySecretKey` overrides the
data key (default `key`); `licenseSecretRef`/`licenseSecretKey` do the same for license data
(default key `license`). A ref and its literal are **mutually exclusive** — set only one. This
is the recommended path for GitOps, where the manifest lives in git and the Secret is managed
separately (sealed-secrets, external-secrets, Vault). Requires the operator image that supports
these fields (v3 `:next`).

## Configuration

This chart is a thin passthrough over the `KubemqCluster` custom resource. Every key you
set under the chart's values (except `key`, `license`, and `imagePullSecrets`, which are
handled specially) is rendered verbatim into `spec:` of the generated `KubemqCluster` — so
**any `KubemqCluster.spec.*` field is a Helm value of the same name**.
[`values_example.yaml`](values_example.yaml) is a small set of **copy-and-adapt starter
recipes** (plain cluster, the connector one-liner, external Kafka, `expose`, the
`env`/`envFromSecrets` overlay, and the Docker single-node recipes) — not an exhaustive
list. The **full field catalog** (every field, its default, and the matching env var) is
[`docs/10-configuration-reference.md`](https://github.com/kubemq-io/kubemq-server/blob/master/docs/10-configuration-reference.md)
in the KubeMQ server repo, and the validating schema is the
[`KubemqCluster` CRD](../kubemq-crds/templates/kubemqclusters.core.k8s.kubemq.io.crd.yaml).

> **Passthrough pinning caveat:** because every value is rendered straight into `spec:`,
> putting an *active* (uncommented) value in your `values.yaml` **pins** that field on the
> CR. The server default for that field then no longer applies — the chart value wins, even
> across upgrades. Keep your `values.yaml` minimal (license + only the fields you truly need
> to override) and leave everything else commented so the server defaults stay in effect.
> Treat `values_example.yaml` as **starter recipes** to copy-and-adapt one at a time, and
> [`docs/10-configuration-reference.md`](https://github.com/kubemq-io/kubemq-server/blob/master/docs/10-configuration-reference.md)
> as the full catalog of what *can* be set.

### LEAN-CRD escape hatch (`spec.env` / `spec.envFromSecrets`)

The CRD types only the **day-1** surface of each connector (enable, port(s),
advertised endpoint, `expose`, credentials ref). Every other current or future server
tunable is reachable from the CR **without a CRD/operator/chart upgrade** through two
overlay fields:

- **`spec.env`** — a `map[string]string` of server env keys → values. It is applied
  **last-wins** over all typed emits, keys are **uppercased**, empty values are **dropped**
  (you cannot unset a key this way), and changing it **rolls the pods**. Example:

  ```yaml
  env:
    CONNECTORS_KAFKA_FETCH_MAX_BYTES: "10485760"
    CONNECTORS_KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: "3000"
  ```

  Operator-owned identity keys are **rejected** with a `ReconcileError` (no env change,
  pods untouched): `STORE_ENGINE`, `CLUSTER_ENABLE`, `CLUSTER_NAME`, `CLUSTER_ROUTES`,
  `API_BIND_ADDRESS`, `CHECKSUM`, `POD_NAME`, and any `CLUSTER_REPLICATION_*` key. Use the
  typed fields (`store.engine`, replicas, etc.) for those. **`spec.env` is not for
  secrets.**

- **`spec.envFromSecrets`** — a list of existing Secret names whose keys are injected as
  container env (`envFrom`). Secret **values never transit the operator**; standard
  Kubernetes `envFrom` precedence applies; secret-**content** changes do **not** roll the
  pods (roll them yourself if you rotate in place). This is the credentials path.

  ```yaml
  envFromSecrets:
    - my-kafka-credentials
    - my-tls-passwords
  ```

### Connector blocks

Connectors fall into two groups with different opt-in semantics:

**Always-on connectors** — enabled by default server-side. Set `disabled: true` to turn
one off, or set any sub-field to override its server default:

| Block | Connector |
|---|---|
| `grpc` | gRPC interface |
| `rest` | REST/WebSocket interface (also fronts the HTTP-family connectors below) |
| `api` | API / dashboard interface (incl. `api.auth` — opt-in dashboard authentication) |
| `http` | Shared HTTP server + CORS policy for the HTTP-family connectors |
| `mcp` | Model Context Protocol (shares the REST port) |
| `agents` | Agents / A2A (shares the REST port) |
| `ce` | CloudEvents (shares the REST port) |

> The `mcp`, `agents`, and `ce` connectors share the REST HTTP port. Their external
> exposure is governed by the `rest.expose` / `rest.nodePort` settings — keep `rest`
> enabled to reach them.

> **API authentication (`api.auth`)** — opt-in authentication for the management API and
> dashboard (port 8080), off by default. Set `api.auth.enable: true` and provide a seed
> admin: either reference an existing Secret via `api.auth.adminSecretRef` (key
> `api.auth.adminSecretKey`, default `admin-password`), or omit it and the operator
> generates a `<release>-api-admin` Secret once and retains it across upgrades. When
> enabled, `api.allowOrigins` must be a concrete list (no `"*"` wildcard). See
> [`docs/10-configuration-reference.md`](https://github.com/kubemq-io/kubemq-server/blob/master/docs/10-configuration-reference.md)
> for the full `api.auth` field set.

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
| `kafka` | Kafka | 9092 (kafka), 9093 (kafka-tls) |

> The `amqp` and `amqp10` connectors share a single Kubernetes Service on ports 5672/5671.
> The Service is kept as long as at least one of the two dialects is enabled.

> The `kafka` connector requires **kubemq-server v3.1+** (the Kafka drop-in connector was
> integrated into the default server build starting with v3.1; earlier server images do not
> recognize the `CONNECTORS_KAFKA_*` env vars).

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
These can be found [here](https://github.com/kubemq-io/charts/releases).

### Upgrading CRDs (read this first)

**The PRIMARY way to upgrade a CRD is `kubectl apply -f <canonical>`** — Helm **never
upgrades CRDs** that ship in a chart's `crds/` directory (Helm installs them once on first
install and leaves them untouched on every subsequent `helm upgrade`). Apply the canonical
CRD directly:

```console
$ kubectl apply -f https://raw.githubusercontent.com/.../kubemqclusters.core.k8s.kubemq.io.crd.yaml
```

The `kubemq-crds` chart path is for **fresh installs / chart-managed CRDs**. Adopting an
already-installed CRD into the `kubemq-crds` chart requires Helm adoption annotations;
without them, chart adoption fails. When a release note (below) says "upgrade CRDs", it
means run the `kubectl apply` above — not `helm upgrade`.

### Zero-config coherence — engine auto-select, `spec.env`/`expose`, write-back

This release makes `kafka.enabled: true` a one-flag story (auto-selected `next` engine on a
fresh cluster, defaulted in-cluster advertised host), adds the `spec.env` /
`spec.envFromSecrets` overlay and per-connector `expose`, and records the established engine
in a CR annotation with best-effort spec write-back.

**Upgrade order: CRDs + operator as ONE step → server images → charts.** The
CRD-upgraded / operator-old window is transient, not a resting state. Read these
release notes before upgrading:

1. **Old operator strips new fields.** Do not add `spec.env`/`spec.envFromSecrets`/`expose`/
   `nodePort` (or rely on engine write-back) until the operator is upgraded — the old
   operator permanently strips unknown new fields from the CR on its first reconcile
   (full-object update on the finalizer path); re-apply the fields after the operator
   upgrade to restore them.

2. **Operator rollback is not engine-safe.** Pin `spec.store.engine: next` explicitly
   BEFORE rolling back the operator; clustered next CRs crashloop under the old operator
   (peers elided). The `core.k8s.kubemq.io/established-engine` annotation survives the old
   operator (untyped metadata), so re-upgrade re-derives the engine correctly.

3. **Explicit-legacy CRs get one checksum roll.** A CR with `spec.store.engine: legacy`
   explicitly set now emits `STORE_ENGINE=legacy` (previously elided). This changes the
   ConfigMap checksum once, causing a single rolling restart on the first reconcile after
   upgrade. Auto-selected and unset CRs are unaffected.

4. **Write-back arms the replicas freeze.** A successful engine write-back inserts
   `engine: next` into formerly-unset CRs, which retroactively arms the existing CEL
   replicas-freeze rule — replica changes on kafka / auto-next clusters now reject at
   admission. Scale next-engine clusters per the next-engine scaling docs, not by editing
   `replicas`.

### v2.8.x → v2.9.0 — Wire-protocol connectors are now opt-in (BREAKING)

**Lockstep requirement:** chart v2.9.0 must be installed together with the kubemq-crds
v2.13.0 chart, the kubemq-operator v1.19.0 (or the kubemq-controller chart at its matching
version), and the KubeMQ server image v3.0.0+. **Do not upgrade charts alone** — the
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
