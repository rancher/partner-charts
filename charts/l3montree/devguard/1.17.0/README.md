# DevGuard Helm Chart

This repository contains the Helm chart for deploying DevGuard, a security and vulnerability management platform, on Kubernetes clusters.

Get started by following the installation instructions in the [DevGuard documentation](https://devguard.org/how-to-guides/administration/deploy-with-helm).

```bash
helm repo add devguard https://l3montree-dev.github.io/devguard-helm-chart
helm repo update
helm install devguard devguard/devguard
```

The chart is also available as an OCI artifact: `oci://ghcr.io/l3montree-dev/devguard-helm-chart/devguard`. See [DISTRIBUTION.md](DISTRIBUTION.md) for details.

You can find the default configuration values in the `values.yaml` file. Customize these values as needed for your deployment.

## Supported Versions

DevGuard is tested on Rancher-supported Kubernetes distributions and is supported by L3montree GmbH on the following configurations:

| DevGuard Chart | Distribution          | Distribution   | Kubernetes | Status |
| -------------- | --------------------- | -------------- | ---------- | ------ |
| > 1.9.x        | Rancher (>= 2.14)     | K3s (>= v1.35) | >= v1.35   | Tested |
| > 1.9.x        | Talos Linux (>= 1.11) | K8s (>= 1.33)  | >= v1.33   | Tested |

The chart declares `kubeVersion: >=1.21-0` and is expected to work on other Rancher-supported distributions (e.g. RKE2, EKS) and recent Kubernetes versions, but the configurations listed above are the ones we have validated and actively support.

### Prerequisites

- **Storage**: DevGuard's PostgreSQL requires a `PersistentVolumeClaim`. Your cluster must provide a StorageClass — either a default one, or set `postgresql.pvc.storageClassName` explicitly. Note that some distributions (e.g. RKE2, or Rancher's local cluster) do not ship a default StorageClass; the [local-path-provisioner](https://github.com/rancher/local-path-provisioner) is a simple option for single-node setups.
- **Ingress**: An ingress controller must be available if `api.ingress.enabled` / `web.ingress.enabled` are used (default: enabled).

## External PostgreSQL

Set `postgresql.enabled=false` to skip the bundled StatefulSet, Service, PVC and init job and point the API, Kratos and the Kratos cleanup job at a database you operate:

```yaml
postgresql:
  enabled: false
  external:
    host: postgres.example.internal
    port: 5432
    sslMode: disable
  useExistingSecret: true
  useExistingKratosDatabaseSecret: true
```

The chart does not bootstrap an external server. Prepare it beforehand — PostgreSQL 16 or newer:

```sql
CREATE ROLE devguard LOGIN PASSWORD '<devguard-password>';
CREATE DATABASE devguard OWNER devguard;
\c devguard
CREATE EXTENSION IF NOT EXISTS semver;

CREATE ROLE kratos LOGIN PASSWORD '<kratos-password>';
CREATE DATABASE kratos OWNER kratos;
\c kratos
GRANT USAGE, CREATE ON SCHEMA public TO kratos;
```

- The [pg_semver](https://github.com/theory/pg-semver) extension is required. It is not part of a stock `postgres` image.
- Kratos runs its own migrations, so the `kratos` role needs `USAGE` and `CREATE` on its `public` schema.
- For credentials keep the existing secret contract: `db-secret` key `postgres-password` (devguard role) and `kratos-db-secret` key `password` (kratos role). With `useExistingSecret` / `useExistingKratosDatabaseSecret` set to `true` — the usual choice under Argo CD, where the Helm `lookup` function is unavailable — create both secrets yourself.
- `external.sslMode` applies to the Kratos connections only. The DevGuard API always connects with `sslmode=disable` - terminate TLS in the network path (e.g. a sidecar or service mesh) if your database requires it.
- `postgresql.enabled=false` also drops the PostgreSQL ServiceMonitor, Grafana dashboard and the `devguard-postgresql-ingress` NetworkPolicy.

## Image Configuration

For `api.image`, `web.image`, and `postgresql.image`, the chart supports both:

- Full image string (for example `ghcr.io/l3montree-dev/devguard:0.13.0` or `ghcr.io/l3montree-dev/devguard@sha256:...`)
- Object format with `repository`, `tag`, optional `digest`, and `pullPolicy`

When `digest` is set in object format, it is preferred over `tag` and rendered as `repository@digest`.

## PDF Report Generation

`api.pdfGenerationApi` is the URL of the external service that renders SBOM and vulnerability report PDFs - expects this [service](https://gitlab.opencode.de/open-code/document-writing-tools/document-writing-ci-components/-/blob/v3/scripts/Dockerfile.api). It is empty by default, so no report data leaves the cluster. With it unset, `GET …/sbom.pdf/` and `GET …/vulnerability-report.pdf/` return HTTP 500; every other API route is unaffected. Set it to use a rendering service:

```yaml
api:
  pdfGenerationApi: https://example.com/pdf
```

## Public API URL

`INSTANCE_DOMAIN` — the URL the instance advertises to itself and to CI clients — is derived from `api.ingress.host` and `api.ingress.tls` regardless of `api.ingress.enabled`, mirroring how `FRONTEND_URL` is derived from `web.ingress.host`. Set both when the API is published by something other than the chart's Ingress (Gateway API `HTTPRoute`, OpenShift `Route`, a service mesh) and leave `api.ingress.enabled=false` so no Ingress object is created.

## Kyverno Policy

The chart includes an optional [Kyverno](https://kyverno.io) policy for supply chain security. Enable it with:

```yaml
kyvernoPolicy:
  enabled: true
  validationFailureAction: Enforce # or Audit
```

The policy enforces three rules on all Pods in the namespace:

| Rule                          | Image                                   | Verification                                   |
| ----------------------------- | --------------------------------------- | ---------------------------------------------- |
| `verify-devguard-images`      | `ghcr.io/l3montree-dev/devguard*`       | Cosign signature + SLSA provenance attestation |
| `verify-kratos-image`         | `oryd/kratos*`                          | Cosign signature                               |
| `verify-otel-collector-image` | `otel/opentelemetry-collector-contrib*` | Keyless signature (GitHub Actions OIDC)        |

### SLSA provenance checks

For DevGuard images, the policy additionally verifies the SLSA provenance attestation and checks that:

- The builder ID is `devguard.org`
- The image was built from `https://github.com/l3montree-dev/devguard`
- The commit was authored by a known maintainer

### Testing

See [`tests/kyverno/README.md`](tests/kyverno/README.md) for instructions on running the policy tests locally.

### Architecture / Docs

- [Architecture](ARCHITECTURE.md)
