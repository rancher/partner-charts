# DevGuard Helm Chart

This repository contains the Helm chart for deploying DevGuard, a security and vulnerability management platform, on Kubernetes clusters.

Get started by following the installation instructions in the [DevGuard documentation](https://devguard.org/how-to-guides/administration/deploy-with-helm).

You can find the default configuration values in the `values.yaml` file. Customize these values as needed for your deployment.

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
  validationFailureAction: Enforce  # or Audit
```

The policy enforces three rules on all Pods in the namespace:

| Rule | Image | Verification |
|---|---|---|
| `verify-devguard-images` | `ghcr.io/l3montree-dev/devguard*` | Cosign signature + SLSA provenance attestation |
| `verify-kratos-image` | `oryd/kratos*` | Cosign signature |
| `verify-otel-collector-image` | `otel/opentelemetry-collector-contrib*` | Keyless signature (GitHub Actions OIDC) |

### SLSA provenance checks

For DevGuard images, the policy additionally verifies the SLSA provenance attestation and checks that:

- The builder ID is `devguard.org`
- The image was built from `https://github.com/l3montree-dev/devguard`
- The commit was authored by a known maintainer

### Testing

See [`tests/kyverno/README.md`](tests/kyverno/README.md) for instructions on running the policy tests locally.