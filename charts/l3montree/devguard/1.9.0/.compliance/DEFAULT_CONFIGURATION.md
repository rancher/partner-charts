---
# Default configuration evidence entries.
# Protocols:
#   file://  → assert path exists in repo; scan for security anti-patterns:
#               - hardcoded secrets or default passwords (e.g. password: admin)
#               - privileged container flags (privileged: true, allowPrivilegeEscalation: true)
#               - missing read-only root filesystem
#               - world-readable secret mounts
#   oci://   → inspect image for default credentials or insecure entrypoints
#   https:// → source reference (Dockerfile, chart source) — HTTP GET → assert 200
evidences:
  - url: file://values.yaml
  - url: file://templates/networkpolicy.yaml
  - url: file://templates/kyverno-policy.yaml
  - url: oci://ghcr.io/l3montree-dev/devguard
  - url: oci://ghcr.io/l3montree-dev/devguard-web
  - url: oci://ghcr.io/l3montree-dev/devguard/postgresql
  - url: https://github.com/l3montree-dev/devguard-helm-chart/blob/main/values.yaml
  - url: https://github.com/l3montree-dev/devguard-helm-chart/blob/main/templates/networkpolicy.yaml
  - url: https://github.com/l3montree-dev/devguard-helm-chart/blob/main/templates/kyverno-policy.yaml
  - url: https://github.com/l3montree-dev/devguard/blob/main/Dockerfile
  - url: https://github.com/l3montree-dev/devguard-web/blob/main/Dockerfile
  - url: https://github.com/l3montree-dev/devguard/blob/main/postgresql/Dockerfile
---

# Default Configuration

## Annex I, Part I(2)(b) — Secure by Default Configuration

> (b) be made available on the market with a secure by default configuration, unless otherwise agreed between
> manufacturer and business user in relation to a tailor-made product with digital elements, including the 
> possibility to reset the product to its original state;

**Question: What is the out-of-the-box security configuration of this product? Which security features are active by default without requiring user action?** `[maintainer]`

The DevGuard Helm chart ships with secure defaults:

- **No hardcoded secrets**: Database passwords, SMTP credentials, CSAF keys, and OAuth client secrets are all provided via Kubernetes Secrets (required before deployment). The chart generates cryptographically random database passwords on first install if not pre-created.
- **Network policies enabled**: `NetworkPolicy` resources are provided. Six policies restrict pod-to-pod traffic to necessary paths only (database, Kratos public/admin, web/API ingress).
- **Non-root execution**: All app containers run as non-root users. 
- **Minimal Images**: DevGuard API, Kratos and Web use minimal distroless images.
- **Authentication required by default**: All API endpoints (`/api/v1/*`) and web UI pages require authentication (Kratos session or PAT signature). Public access is explicit per-resource (`is_public=true` in the database). Unauthenticated requests to private resources receive HTTP 404 (not 401).

**Question: Are there any security-relevant features that are disabled by default? If so, what is the justification?** `[maintainer]`

**Disabled by default (with justification):**

- **WebAuthn** — not a core auth mechanism. Operators can enable it for passwordless authentication. Requires careful RP ID and origin configuration.
- **TOTP MFA** — optional. Operators who require MFA should enable this in Kratos config.
- **OIDC federation** — requires operator configuration of GitHub/GitLab OAuth apps and client secrets. Default is local password/passkey authentication.
- **Kyverno policy enforcement** — requires Kyverno control plane to be pre-installed in the cluster. When enabled, policies enforce signature and commiter validation.
- **OpenTelemetry span export** — optional observability. Requires OTLP collector endpoint configuration.
- **Prometheus Operator integration** — optional. For clusters with Prometheus Operator, can auto-create ServiceMonitor resources.

**Not configured by default (no impact on security):**

- **Service-to-service mTLS**: Internal communication (API ↔ database, API ↔ Kratos) relies on network policies, not TLS. For encrypted internal traffic, operators should use a service mesh (Linkerd, Istio).

**Question: Does the product ship with any default credentials (passwords, API keys, certificates)? If yes, how is the user forced to change them before use?** `[maintainer]`

**No default credentials shipped.** All secrets must be created before deployment:

- **Database passwords**: Generated via `randAlphaNum(32)` on first install (if not pre-created). Stored in Kubernetes `Secret` objects (`db-secret`, `kratos-db-secret`).
- **Kratos secrets** (cookie, cipher): Generated via `randAlphaNum(32)` per secret on first install (if not pre-created). Stored in `Secret` named `kratos`.
- **OIDC client secrets**: Must be pre-created as Kubernetes `Secret`.
- **SMTP credentials**: Must be pre-created as Kubernetes `Secret`.
- **CSAF signing keys**: Must be pre-created with GPG private key, public key, passphrase, and fingerprint.
- **GitHub/GitLab credentials**: Must be pre-created.

**Question: How can the product be reset to its original secure default state? What is the reset mechanism?** `[maintainer]`

**Kubernetes state reset**: `helm upgrade` with default `values.yaml` restores the original configuration. All deployments, services, network policies, and ConfigMaps revert to defaults.

**Database reset**: Manual intervention required:
1. Drop the `devguard` database: `DROP DATABASE devguard;`
2. Drop the `kratos` database: `DROP DATABASE kratos;`
3. Redeploy: `helm upgrade` or `helm install` triggers fresh schema migrations

**Complete clean reset**:
```bash
helm uninstall devguard -n devguard
kubectl delete secret -n devguard --all
kubectl delete pvc -n devguard --all  # WARNING: deletes database volumes
helm install devguard ./devguard-helmchart-oc -n devguard
```

**Question: What hardening steps are applied to the default shipped configuration? (e.g., minimal exposed ports, non-root execution, restrictive file permissions, disabled debug endpoints)** `[maintainer]`

**Container hardening:**
- **Non-root execution**: All containers run as non-root users.
- **Minimal base images**: All app images run on minimal images. There is no shell, package manager, or unnecessary tools inside.
- **Read-only root filesystem**: All containers have `readOnlyRootFilesystem: true`. Temporary write mounts (`/tmp`, `/var/run`) are explicit.
- **Privilege restriction**: All containers have `allowPrivilegeEscalation: false`, `privileged: false`. Linux capabilities dropped entirely (`drop: [ALL]`).
- **Seccomp**: All containers use `seccompProfile: type: RuntimeDefault` (blocks dangerous syscalls).
- **SELinux labels**: Applied where supported.

**Network hardening:**
- **Minimal exposed ports**: API on 8080, Web on 3000, Kratos public on 4433, admin on 4434 (internal only). All routed via Kubernetes `Ingress` with TLS termination.
- **Network policies**: `NetworkPolicy` resources restrict all traffic except explicitly allowed paths. PostgreSQL only from API/Kratos pods. Kratos admin only from API pod.
- **Service-to-service no TLS by default**: Internal communication (API → PostgreSQL, API → Kratos) is unencrypted (relies on network policies and K8s SDN isolation). Operators can add service mesh mTLS (Linkerd, Istio).

**Authentication & access:**
- **Default-deny**: All endpoints require authentication. Public access must be explicitly opted in per resource.
- **Audit logging**: All access (allowed and denied) is logged. Failed auth attempts are logged at `Warn` level.
