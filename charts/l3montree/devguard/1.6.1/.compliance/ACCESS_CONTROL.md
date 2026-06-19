---
# Access control configuration evidence entries.
# Protocols:
#   file://  → assert path exists in repo; scan for security anti-patterns:
#               - world-readable secrets, overly permissive RBAC roles
#               - missing authentication on exposed endpoints
#   https:// → HTTP GET → assert 200 (links to auth architecture docs, OIDC config)
evidences:
  - url: https://docs.devguard.org/explanations/architecture/security-model
  - url: https://docs.devguard.org/explanations/architecture/authentication-flow
---

# Access Control and Data Minimisation

## Annex I, Part I(2)(d) — Authentication and Access Management

> (2) (d) ensure protection from unauthorised access by appropriate control mechanisms, including but not limited to authentication, identity or access management systems, and report on possible unauthorised access;

**Question: What authentication mechanisms does the product implement or support? (e.g., password-based, MFA, OAuth 2.0, OpenID Connect, certificate-based, API keys)** `[maintainer]`

DevGuard delegates interactive user authentication to **Ory Kratos** (`v25.x.y-distroless`, image digest-pinned) and implements a separate signature-based mechanism for programmatic access:

- **Password-based authentication** — Enabled by default. Kratos hashes passwords with bcrypt at its compiled-in default cost. Sessions are cookie-based (`ory_kratos_session`). Privileged operations (password change, account settings) require re-authentication if the session is older than 15 minutes (`privileged_session_max_age: 15m`). Login and registration flows expire after 10 minutes.
- **Passkeys** — Enabled by default. Provides phishing-resistant passwordless authentication. The relying party ID is derived from the deployment's root domain; origins are restricted to the configured ingress host and protocol.
- **WebAuthn** — Needs to be enabled by operators. When enabled, configured for passwordless mode (not MFA).
- **TOTP** — Needs to be enabled by operators. When enabled, issues codes under the `devguard` issuer.
- **OAuth 2.0 / OpenID Connect** — Operators can configure GitHub and/or GitLab as identity providers. OIDC client secrets are injected via Kubernetes Secrets (referenced by `existingClientSecretName`), never stored in the Helm values. The OIDC claim mapper (Jsonnet) only maps an email to the identity if the provider marks it as verified — unverified emails are silently dropped to prevent account enumeration via OIDC.
- **Email verification** — enabled after sign-up via code-based flow. Recovery uses the same code-based mechanism.
- **Personal Access Tokens (PAT)** — for programmatic API access. DevGuard stores only the ECDSA P-256 **public key** (hex-encoded) and its **SHA-256 fingerprint** - no secret is ever persisted server-side. Clients sign each HTTP request using their private key per RFC 9421 (HTTP Message Signatures). The server looks up the token by the `X-Fingerprint` header, reconstructs the ECDSA public key, and verifies the `Signature` against the signed components (`@method`, `content-digest`). This design eliminates bearer-token theft as an attack vector — a database compromise does not yield usable credentials.

**Question: What access control model does the product implement? (e.g., RBAC, ABAC, ACL)** `[maintainer]`

DevGuard implements **domain-scoped Role-Based Access Control (RBAC)** using Casbin with a PostgreSQL policy adapter. Every access decision evaluates the subject, the domain (organisation), the object, and the action.

**Resource hierarchy:**

```
Organisation → Project → Asset
```

**Roles** (per hierarchy level): `owner`, `admin`, `member`, `guest`, `unknown`.

Role assignments are encoded as structured strings (e.g., `user::<uuid>|role::admin`, `project::<id>|role::member`) and scoped to a domain (`domain::<orgId>`). Roles cascade downward — an organisation-level `admin` inherits access to all projects and assets within that organisation. A `project::<id>|role::member` assignment restricts access to that project's assets only.

**Actions:** `create`, `read`, `update`, `delete` — enforced per object type (`project`, `asset`, `user`, `organization`).

**Policy enforcement** is implemented as Echo middleware. Three middleware functions enforce RBAC at each hierarchy level: `OrganizationAccessControlMiddleware`, `ProjectAccessControlFactory`, and `AssetAccessControlFactory`. Each middleware extracts the session, resolves the target resource from the request path, and calls Casbin's `Enforce()`. Denied requests return HTTP 404 for read operations (to avoid leaking resource existence) and HTTP 403 for write operations.

**Policy synchronisation:** Casbin policies are cached in-memory and synchronised across replicas via a PostgreSQL-backed PubSub broker (`casbin_watcher.go`). Policy changes (role grants/revocations) propagate to all API instances without restart.

**External entity provider RBAC:** For organisations linked to GitHub or GitLab, DevGuard can delegate permission checks to the external provider's API. The `ExternalEntityProviderRBAC` wrapper queries the provider to determine the user's role in the linked repository/group and maps it to the internal role hierarchy. This allows repository collaborators to access DevGuard without explicit role assignment.

**Question: How is the principle of least privilege enforced in the product's own internal architecture (e.g., service accounts, internal components)?** `[maintainer]`

- **PAT scope restriction:** Each personal access token carries a whitespace-separated scope string. Allowed scopes are `scan` and `manage`. A token issued with `scan` scope cannot modify project settings or read project metadata. Scope enforcement is checked in the `NeededScope` middleware before the request reaches any handler.
- **Tenant isolation:** All data queries are scoped to the authenticated user's organisation. The Casbin domain parameter (`domain::<orgId>`) ensures that policy evaluation never crosses organisation boundaries. There is no global query path that bypasses domain scoping.
- **Default-deny posture:** Organisations, projects, and assets default to `is_public=false`. Public access requires an explicit opt-in per resource. Unauthenticated requests to private resources receive HTTP 404 (not 401/403) to prevent resource enumeration.
- **Kubernetes network policies:** Six `NetworkPolicy` resources restrict pod-to-pod communication: PostgreSQL accepts connections only from the API and Kratos pods; the Kratos admin port (4434) is accessible only from the API pod; the Kratos public port (4433) is accessible from the API and web pods; the web and API pods accept ingress only from the ingress controller namespace. All policies use pod-selector and namespace-selector labels.
- **Container hardening:** All app containers (API, Kratos, web) run as non-root, drop all Linux capabilities, enforce read-only root filesystems, apply SELinux labels, and use the `RuntimeDefault` seccomp profile. Privilege escalation is explicitly disabled.

**Question: What protections does the product implement against authentication attacks? (e.g., brute-force protection, rate limiting, account lockout)** `[maintainer]`

- **Password brute-force mitigation:** Kratos enforces its built-in rate limiting on login flows. Login flows have a 10-minute lifespan — abandoned or stalled attempts expire automatically. The Helm chart does not override Kratos's default account-lockout thresholds, so the compiled-in defaults of the deployed Kratos version apply.
- **PAT authentication is not brute-forceable:** PATs use ECDSA P-256 request signing. Compromise requires possession of the private key. A request with a known fingerprint but an invalid signature returns HTTP 401; the fingerprint alone is not sufficient for authentication.
- **Rate limiting:** DevGuard does not implement application-level rate limiting. Rate limiting is expected to be enforced at the infrastructure layer (ingress controller, reverse proxy, or WAF). Operators must configure this externally.
- **Flow expiration:** Login and registration flows expire after 10 minutes. This limits the window for CSRF or session-fixation attacks targeting authentication flows.

**Question: How are authentication credentials (passwords, tokens, keys, certificates) managed in the production deployment — storage, rotation, revocation?** `[manufacturer]`

**Password storage:** Delegated entirely to Ory Kratos. Passwords are hashed with bcrypt at the Kratos-default cost factor. Password hashes are stored in the Kratos-managed PostgreSQL database. DevGuard's application code never handles raw passwords.

**Kratos secrets (session signing, cookie encryption, cipher):** The Helm chart generates three 32-character random secrets on first install (`secretsDefault`, `secretsCookie`, `secretsCipher`) and stores them in a Kubernetes `Secret` named `kratos`. On subsequent upgrades, the chart uses `lookup` to preserve existing secrets. These are injected into the Kratos container as environment variables (`SECRETS_DEFAULT`, `SECRETS_COOKIE`, `SECRETS_CIPHER`), never written to ConfigMaps or disk. Rotation requires manually updating the Kubernetes Secret and restarting the Kratos pod; Kratos supports secret rotation by accepting an ordered list of secrets (newest first).

**Database credentials:** The Helm chart generates random 32-character passwords for the PostgreSQL `postgres` user, the application user, and the replication user on first install, stored in a Kubernetes `Secret` named per the release. The Kratos database password is stored in a separate `kratos-db-secret`. Both are preserved across upgrades via `lookup`. Connection strings are assembled at runtime via environment variable interpolation (`postgres://kratos:$(DB_PASSWORD)@postgresql:5432/kratos`).

**OIDC client secrets:** Referenced by `existingClientSecretName` in the Helm values — operators must pre-create these Kubernetes Secrets. The Helm chart never stores OIDC secrets in `values.yaml`.

**PAT revocation:** Users can revoke their own tokens. Revocation deletes the public key and fingerprint from the database, immediately invalidating all future requests signed with the corresponding private key. There is currently no automatic PAT expiration; tokens remain valid until explicitly revoked.

**OAuth tokens for Git providers:** Access and refresh tokens from GitHub/GitLab are stored in the application database. Refresh tokens are rotated automatically when the access token expires. See [ENCRYPTION.md](./ENCRYPTION.md) for the current encryption status of these tokens at rest.

**Question: How does the manufacturer's deployment configure the identity provider or SSO integration?** `[manufacturer]`

OIDC-based SSO is configured in the Helm chart's `values.yaml` under `kratos.oidc`. The operator sets `oidc.enabled: true` and provides one or more provider entries specifying the `provider` type (`github` or `gitlab`), the `clientId`, an optional `issuerUrl` (required for self-hosted GitLab), and a reference to a pre-existing Kubernetes Secret containing the client secret (`existingClientSecretName`). Requested OAuth scopes are configurable per provider.

At deployment time, the Helm chart renders these values into the Kratos ConfigMap and injects the client secrets as environment variables from the referenced Kubernetes Secrets. Kratos handles the OIDC redirect flow, token exchange, and identity mapping. The Jsonnet claim mapper extracts the user's email (only if provider-verified), display name (with fallback chain: `name` → `preferred_username` → `login` → `username` → `nickname` → `sub`), and auto-accepts terms of service for OIDC-provisioned accounts.

See also: https://docs.devguard.org/how-to-guides/administration/restricting-access/


**Question: How does the product detect and report possible unauthorised access to the user or operator? (e.g., failed login alerts, anomalous access notifications, audit log entries)** `[maintainer]`

DevGuard provides structured log output that operators can feed into their monitoring and alerting infrastructure:

- **RBAC denials:** Every access control denial is logged via `slog` with structured fields: user ID, target object, requested action, and (where applicable) the asset or project slug. Organisation-level denials log at `Error` level; project- and asset-level denials log at `Warn` level. Example: `slog.Warn("access denied in ProjectAccess", "user", user, "object", obj, "action", act, "projectSlug", projectSlug)`.
- **PAT authentication failures:** A request carrying a fingerprint (`X-Fingerprint` header) that does not match any stored token returns HTTP 401 and logs a warning. A request with a valid fingerprint but an invalid signature triggers a `monitoring.Alert()` call (integrated with error tracking, e.g. GlitchTip/Sentry) in addition to the structured log entry — this indicates a potential private key compromise or replay attempt.
- **Session failures:** Failed Kratos cookie validation is logged at `Warn` level with the error detail. The request proceeds as unauthenticated (`NoSession`), and downstream RBAC enforcement determines whether access is granted (public resources) or denied.
- **Request logging:** All HTTP requests (except `/health`) are logged with method, URL, status code, and duration. This allows operators to detect anomalous patterns (e.g., spikes in 401/403 responses) via log aggregation.
- **Distributed tracing:** OpenTelemetry trace IDs are injected into every request via `X-Trace-ID` header, enabling end-to-end correlation of authentication and authorisation events across the Kratos and DevGuard API components.

DevGuard does not currently implement in-product alerting or user-facing notifications for suspicious access. Operators are expected to configure alerting rules in their log aggregation / SIEM infrastructure (see [LOGGING.md](./LOGGING.md)).

---

## Annex I, Part I(2)(g) — Data Minimisation

> (g) process only data, personal or other, that are adequate, relevant and limited to what is necessary in relation to the
> intended purpose of the product with digital elements (data minimisation);

**Question: What categories of data does this product collect or process by design?** `[maintainer]`

| Data category                                      | Purpose                                  | Justification                                                                                                                                              |
|----------------------------------------------------|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Vulnerability findings (CVEs, CVSS, EPSS)          | Core function: vulnerability management  | Required for the product's intended purpose                                                                                                                |
| SBOMs and component inventories                    | Core function: supply chain transparency | Required for dependency tracking and CRA compliance                                                                                                        |
| Provenance attestations                            | Core function: supply chain integrity    | Required for artefact verification                                                                                                                         |
| API token public keys and SHA-256 fingerprints     | Authentication                           | Required for programmatic access. Only the public key and its fingerprint are stored — no shared secret. A database leak does not yield usable credentials. |
| User accounts (email, name)                        | Authentication and attribution           | Required for user management and audit trails                                                                                                              |
| OAuth tokens for Git providers                     | Repository integration                   | Required to read repository metadata and verify permissions. **Note**: currently stored unencrypted in the database (see [ENCRYPTION.md](./ENCRYPTION.md)) |
| Audit trail events                                 | Compliance and accountability            | Required for CRA vulnerability handling evidence                                                                                                           |


**Question: For each data category: is it necessary for the product's intended purpose? What is the technical justification for collecting it?** `[maintainer]`

Each data category in the table above maps directly to a core product function. No category exists for convenience, analytics, or monetisation:

- **Vulnerability findings, SBOMs, provenance attestations** are the product's raison d'être — without them, there is no vulnerability management or supply chain transparency to provide.
- **User accounts (email, name)** are the minimum identity traits required by Kratos for authentication and session management. The identity schema (`identity.schema.json`) enforces `additionalProperties: false`, so no extra traits can be stored.
- **API token public keys** are required to verify ECDSA request signatures. Only the public half is stored; this is the minimum data needed for asymmetric signature verification.
- **OAuth tokens** are required to access repository metadata (e.g., listing collaborators, reading commit SHAs) on behalf of the user. Without them, the GitHub/GitLab integration cannot function.
- **Audit trail events** are required for CRA-mandated vulnerability handling evidence and to support operator investigations of security incidents.

DevGuard does not collect telemetry, usage analytics, advertising identifiers, or any data not listed above. There is no "phone home" mechanism.

**Question: What additional data does the manufacturer's product collect or process beyond what the upstream component handles by default?** `[manufacturer]`

This depends on the manufacturer's deployment configuration. Potential additional data sources include:

- **OIDC identity claims** — if SSO is enabled, the OIDC provider may supply additional claims (e.g., group memberships, profile pictures). The DevGuard Jsonnet mapper explicitly extracts only `email` (if verified), `name` (with fallback chain), and `confirmedTerms`. All other claims are discarded. However, Kratos may store the raw OIDC token payload in its credentials table.
- **Error tracking payloads** — if `errorTracking.dsn` is configured, unhandled errors (including request context) may be sent to the configured error tracking service (e.g., GlitchTip/Sentry).
- **Prometheus metrics** — if the metrics endpoint (`/api/v1/metrics`) is scraped, request counts, latencies, and Go runtime metrics are collected by the operator's monitoring stack.
- **OpenTelemetry traces** — if OTLP export is enabled, distributed traces containing request paths, durations, and trace IDs are exported to the configured collector.

Manufacturers should review their deployment's `values.yaml` to determine which of these optional data flows are active.

**Question: What data retention periods are configured in the deployment, and how is data deleted when no longer necessary?** `[manufacturer]`

**Data deletion mechanisms:**

- **Soft deletes:** All core entities (organisations, projects, assets, asset versions) use GORM soft deletes (`deleted_at` timestamp). Deleting a resource marks it as deleted but retains the row. Cascade constraints (`OnDelete:CASCADE`) propagate deletion to child entities (e.g., deleting a project soft-deletes all its assets and their versions, vulnerability findings, SBOMs, and associated artefacts).
- **Vulnerability event deduplication:** A database migration (`20260117090614_cleanup.up.sql`) removes consecutive duplicate `rawRiskAssessmentUpdated` events and collapses redundant `detected` events per vulnerability to the most recent occurrence.
- **Orphaned table cleanup:** The CLI command `devguard cleanup` removes temporary vulnerability-database tables older than 24 hours that were left behind by interrupted import operations.
- **No automated hard-delete or retention-period enforcement** is currently implemented. Soft-deleted records remain in the database indefinitely. Operators who require GDPR-compliant data erasure or time-bounded retention must implement purge jobs externally (e.g., periodic SQL `DELETE WHERE deleted_at < NOW() - interval`).
- **Account deletion:** The deployment supports an `accountDeletionMail` configuration for user-initiated account deletion requests, but the specific erasure workflow is deployment-dependent.

Manufacturers should define and enforce data retention periods appropriate to their regulatory context and document the configured purge schedule.
