# DevGuard Helm Chart

This repository contains the Helm chart for deploying DevGuard, a security and vulnerability management platform, on Kubernetes clusters.

Get started by following the installation instructions in the [DevGuard documentation](https://devguard.org/how-to-guides/administration/deploy-with-helm).

You can find the default configuration values in the `values.yaml` file. Customize these values as needed for your deployment.

## Supported Versions

DevGuard is tested on Rancher-supported Kubernetes distributions and is supported by L3montree GmbH on the following configurations:

| DevGuard Chart | Distribution          | Distribution   | Kubernetes | Status |
| -------------- | --------------------- | -------------- | ---------- | ------ |
| 1.8.x          | Rancher (>= 2.14)     | K3s (>= v1.35) | >= v1.35   | Tested |
| 1.8.x          | Talos Linux (>= 1.11) | K8s (>= 1.33)  | >= v1.33   | Tested |

The chart declares `kubeVersion: >=1.21-0` and is expected to work on other Rancher-supported distributions (e.g. RKE2, EKS) and recent Kubernetes versions, but the configurations listed above are the ones we have validated and actively support.

### Prerequisites

- **Storage**: DevGuard's PostgreSQL requires a `PersistentVolumeClaim`. Your cluster must provide a StorageClass — either a default one, or set `postgresql.pvc.storageClassName` explicitly. Note that some distributions (e.g. RKE2, or Rancher's local cluster) do not ship a default StorageClass; the [local-path-provisioner](https://github.com/rancher/local-path-provisioner) is a simple option for single-node setups.
- **Ingress**: An ingress controller must be available if `api.ingress.enabled` / `web.ingress.enabled` are used (default: enabled).

## Image Configuration

For `api.image`, `web.image`, and `postgresql.image`, the chart supports both:

- Full image string (for example `ghcr.io/l3montree-dev/devguard:0.13.0` or `ghcr.io/l3montree-dev/devguard@sha256:...`)
- Object format with `repository`, `tag`, optional `digest`, and `pullPolicy`

When `digest` is set in object format, it is preferred over `tag` and rendered as `repository@digest`.

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
