---
# Encryption evidence entries.
# Protocols:
#   file://  → assert path exists in repo; scan content for encryption markers
#   https:// → HTTP GET → assert 200
#   oci://   → cosign verify-attestation --key <cosign_public_key_url> --type <predicate_type> <ref>
#
# file:// entries are scanned based on inferred type:
#   TLS config (ingress.yaml, nginx.conf, etc.)
#     → scan for min TLS version markers (TLSv1.2, ssl_protocols, minProtocolVersion)
#     → flag if TLS < 1.2 is found
#   At-rest config (rds.tf, statefulset.yaml, etc.)
#     → scan for encryption indicators (storage_encrypted, kms_key_id, encrypt: true)
#     → flag if no encryption marker is found
evidences:
  - url: file://templates/devguard/ingress.yaml
  - url: file://templates/devguard-web/ingress.yaml
  - url: file://templates/postgresql/postgresql-statefulset.yaml
  - url: https://github.com/l3montree-dev/devguard-helm-chart/blob/main/templates/devguard/ingress.yaml
  - url: https://github.com/l3montree-dev/devguard-helm-chart/blob/main/templates/devguard-web/ingress.yaml
  - url: https://github.com/l3montree-dev/devguard-helm-chart/blob/main/templates/postgresql/postgresql-statefulset.yaml
---

# Encryption and Data Integrity

## Annex I, Part I(2)(e) — Data Confidentiality

> (e) protect the confidentiality of stored, transmitted or otherwise processed data, personal or other, such as by
> encrypting relevant data at rest or in transit by state of the art mechanisms, and by using other technical means;

**Question: What categories of data does this product transmit over the network?** `[maintainer]`

- Vulnerability scan results (SARIF, CycloneDX) from scanners and CI/CD pipelines to the API
- SBOM and provenance attestation data
- User authentication credentials and session tokens (handled by Ory Kratos)
- API responses containing vulnerability findings, risk scores, and compliance reports
- OAuth tokens for Git provider integrations (GitHub, GitLab)

**Question: What encryption mechanisms does the product implement or enforce for data in transit? (e.g., minimum TLS version, cipher suite configuration, certificate validation)** `[maintainer]`

All external communication between clients and the DevGuard API and web frontend is encrypted via TLS, terminated at the Kubernetes Ingress level. The Helm chart provides Ingress resource templates that support TLS configuration; operators must supply a valid TLS certificate (e.g. via cert-manager). The Helm chart does not enforce a minimum TLS version or cipher suite — this is the responsibility of the operator's ingress controller configuration.

Scanner-to-API communication is additionally protected by HTTP Message Signing (RFC 9421) with ECDSA P-256, providing authentication and integrity on top of the TLS channel.

> **Known gap**: Operators should deploy a service mesh (e.g. Linkerd, Istio) for internal mTLS, or ensure the database is only reachable within a private network segment.

**Question: What encryption capabilities does the product itself provide for data at rest? (e.g., application-level field encryption, encrypted configuration storage, key management interfaces)** `[maintainer]`

DevGuard does not handle password storage directly. User authentication is delegated to Ory Kratos, which stores password hashes using its own configurable hashing algorithm. DevGuard application code never sees or stores plaintext passwords.

Personal Access Tokens are not stored as secrets. The client generates an ECDSA P-256 key pair locally; only the public key is sent to the server. The server stores the public key and a SHA-256 fingerprint — no token secret exists on the server side.

CSAF advisory documents are signed with OpenPGP keys. The private key and passphrase must be provided by the operator as a Kubernetes Secret.

> **Known gap**: OAuth integration tokens for Git providers (GitHub, GitLab) are stored as plaintext strings in the PostgreSQL database. No application-level encryption is applied. Encrypting these tokens at rest at the application layer is on the roadmap. Operators must enable storage-level encryption (e.g. encrypted volumes) to mitigate this.

**Question: What encryption mechanisms are used for data at rest in the production deployment? (e.g., database encryption, volume encryption, key management)** `[manufacturer]`

The Helm chart and application code provide no at-rest encryption for the PostgreSQL database. The product does not configure database-level encryption or volume encryption. All at-rest encryption is the operator's responsibility.

Operators must ensure:
- Encrypted storage volumes for the PostgreSQL PersistentVolume
- Appropriate key management for the encryption keys backing those volumes
- Encrypted storage for Kubernetes Secrets if the cluster does not use an encrypted etcd backend

**Question: Are the cryptographic algorithms and key lengths used considered state-of-the-art?** `[maintainer]`

Yes. The cryptographic algorithms used by DevGuard are:

- **ECDSA P-256** (256-bit key) for HTTP Message Signing (RFC 9421) and Personal Access Tokens
- **SHA-256** for content digests and key fingerprint derivation
- **Cosign (Sigstore)** for container image and artefact signing — uses ECDSA or Ed25519

All choices are consistent with BSI TR-02102-1 recommendations for algorithms and minimum key length.

---

## Annex I, Part I(2)(f) — Data Integrity

> (f) protect the integrity of stored, transmitted or otherwise processed data, personal or other, commands, programs
> and configuration against any manipulation or modification not authorised by the user, and report on corruptions;

**Question: What mechanisms does the product implement to protect integrity of data in transit? (e.g., TLS MAC, HMAC, digital signatures)** `[maintainer]`

- TLS provides integrity protection for all external communication
- Scanner-to-API communication uses HTTP Message Signing (RFC 9421) with ECDSA P-256 signatures and `Content-Digest` headers, ensuring scan results originate from an authorised source and have not been modified in transit

**Question: What mechanisms does the product implement to protect integrity of stored data and configuration against unauthorised modification?** `[maintainer]`

- Role-based access control (Casbin) enforces that only authorised users can modify data; policies are evaluated on every API request
- Organisation-scoped data isolation prevents cross-tenant access at the query level
- Vulnerability audit events require elevated user privileges to modify
- All deployment configuration is declarative via Helm values and Kubernetes resources, subject to Kubernetes RBAC
- PostgreSQL provides transactional integrity and WAL-based crash recovery

**Question: What mechanisms does the product implement to ensure that commands it receives or executes have not been manipulated? (e.g., authenticated and integrity-protected API channels, message authentication codes, request signing)** `[maintainer]`

- All API requests from external clients are received over TLS, which provides channel integrity
- Scanner submissions are authenticated and integrity-protected via HTTP Message Signing (RFC 9421) with ECDSA P-256: the server verifies the `Signature` and `Content-Digest` headers against the registered public key before processing any scan data
- Interactive user requests are authenticated via Ory Kratos session cookies (HMAC-signed)
- Administrative API access requires a pre-shared admin token (`X-Admin-Token` header), transmitted only over the TLS channel
- The API does not execute arbitrary commands; it processes structured JSON payloads validated against expected schemas


**Question: What mechanisms protect the integrity of software updates and program code against tampering? (e.g., code signing, SLSA provenance, cosign)** `[maintainer]`

- All container images and release artefacts are signed with cosign
- Every release includes a SLSA-compatible provenance attestation linking the artefact to the exact source commit and CI pipeline run
- Dependencies in CI are pinned by SHA digest, not mutable tags
- Signatures are verifiable using the project's public cosign key

**Question: How does the product detect and report data corruption to the user or operator?** `[maintainer]`

- Cosign signature verification at image pull time rejects tampered container images; optionally enforced cluster-wide via Kyverno admission policies (shipped in the Helm chart)
- The `Content-Digest` header in HTTP Message Signed requests detects in-transit corruption of scan submissions — the server rejects requests where the digest does not match the body
- PostgreSQL provides built-in data integrity checks (WAL, page checksums if enabled by operator)
- The API health endpoint (`/api/v1/health`) validates database connectivity and service readiness

> **Limitation**: DevGuard does not implement application-level integrity monitoring of stored data (e.g. row-level checksums or tamper-evident logging). Detection of silent data corruption in the database relies entirely on PostgreSQL's built-in mechanisms.

