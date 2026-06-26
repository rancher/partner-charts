## Render Kyverno policies

Run from the repo root to generate the policy file used by the tests:

```sh
helm template devguard . --set kyvernoPolicy.enabled=true | \
  grep -A 10000 'apiVersion: kyverno.io/v1' > tests/kyverno/policies/kyverno-policy.yaml
```

## Run tests

```sh
kyverno test tests/kyverno
```

The test verifies that the `verify-devguard-images` rule correctly validates image signatures and SLSA provenance attestations for `ghcr.io/l3montree-dev/devguard` images.

The pod resource in `resources/pod-devguard.yaml` must reference the image by digest (`image:tag@sha256:...`) — Kyverno requires a pinned digest for `verifyImages` rules to work during testing.