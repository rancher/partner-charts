---
# Evidence entries proving secure coding practices.
# Protocols:
#   https:// → HTTP GET → assert 200
#   oci://   → cosign verify-attestation --key <cosign_public_key_url> --type <predicate_type> <ref>
# predicate_type determines validation:
#   https://www.schemastore.org/schemas/json/sarif-2.1.0.json
#     → SAST: parse as SARIF, assert no findings with level: error
#   https://slsa.dev/provenance/v1
#     → Build provenance: validate against SLSA provenance schema
#   https://gitlab.opencode.de/open-code/badgebackend/source-provenance-attestation-service/-/raw/main/schema/source-provenance-schema-1.0.0.json
#     → Source provenance: validate against openCode source provenance schema
evidences:
  # SAST reports (SARIF attested on each container image)
  - url: oci://ghcr.io/l3montree-dev/devguard:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://www.schemastore.org/schemas/json/sarif-2.1.0.json
  - url: oci://ghcr.io/l3montree-dev/devguard-web:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://www.schemastore.org/schemas/json/sarif-2.1.0.json
  - url: oci://ghcr.io/l3montree-dev/devguard/scanner:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://www.schemastore.org/schemas/json/sarif-2.1.0.json
  # Provenance attestations
  - url: oci://ghcr.io/l3montree-dev/devguard:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://slsa.dev/provenance/v1
  - url: oci://ghcr.io/l3montree-dev/devguard-web:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://slsa.dev/provenance/v1
  - url: oci://ghcr.io/l3montree-dev/devguard/scanner:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://slsa.dev/provenance/v1
---

# Secure Coding Standard and Exploitation Mitigation

## Annex I, Part I(2)(k) — Exploitation Mitigation Mechanisms

> (k) be designed, developed and produced to reduce the impact of an incident using appropriate exploitation mitigation
> mechanisms and techniques;

**Question: What language-level or platform-level exploitation mitigation mechanisms does the product benefit from or enable? (e.g., memory-safe language runtime, position-independent executables, stack protection, type safety, bounds checking)** `[maintainer]`

- Go production binaries are compiled with `CGO_ENABLED=0` (pure Go, no C dependencies)
- Build flags: `-trimpath` for improved reproducibility, version metadata injected via `-ldflags`
- Go's runtime provides built-in bounds checking, garbage collection, and goroutine stack management, mitigating buffer overflows and use-after-free vulnerabilities
- All containers run with hardened security contexts: `runAsNonRoot: true`, `readOnlyRootFilesystem: true`, `allowPrivilegeEscalation: false`, all capabilities dropped, seccomp profile set to `RuntimeDefault`

**Question: What memory-safe languages or safe coding practices are used to prevent classes of vulnerabilities such as buffer overflows, use-after-free, or integer overflows?** `[maintainer]`

- The backend API and scanner are written in **Go**, a memory-safe language with built-in bounds checking and garbage collection
- The frontend is written in **TypeScript** (Next.js)
- Neither component uses manual memory management

**Question: What secure coding standard or guidelines does the project follow? (e.g., OWASP Top 10, CERT C/C++, SEI CERT, CWE Top 25)** `[maintainer]`

The project follows **OWASP Top 10** and **CWE Top 25** as reference guidelines for secure coding. Adherence is enforced through the following concrete, verifiable properties:

1. All code changes go through a reviewed pull request — the main branch is protected and requires at least one approving review
2. `golangci-lint` with `staticcheck` and `unused` rules runs on every push
3. Dependency and container scanning via `devguard-action` on every push, configured to fail on high-severity CVEs (`fail-on-cvss: high`)

**Question: How is adherence to the secure coding standard enforced? (e.g., SAST in CI/CD, code review checklist, automated linting)** `[maintainer]`

- **Linting**: `golangci-lint` with `staticcheck` and `unused` rules on every push
- **SCA**: Dependency and container scanning via `devguard-action` on every push, failing on high-severity CVEs
- **Code review**: Protected main branch requires at least one approving review before merge
- **Dependency pinning**: CI actions pinned by SHA digest; Go dependencies tracked in `go.sum`, Node.js in `package-lock.json`

See known gaps above regarding semgrep, gitleaks, and gosec.

**Question: What containment mechanisms are in place to reduce the blast radius if a component is compromised? (e.g., sandboxing, process isolation, seccomp profiles, namespace separation, privilege dropping after initialisation)** `[maintainer]`

All containers are deployed with hardened Kubernetes security contexts:

- `runAsNonRoot: true` — prevents running as root (enforced on API, web, Kratos, PostgreSQL)
- `readOnlyRootFilesystem: true` — prevents filesystem writes outside mounted volumes
- `allowPrivilegeEscalation: false` — blocks privilege escalation via setuid/setgid
- `capabilities: { drop: ["ALL"] }` — drops all Linux capabilities
- `seccompProfile: { type: RuntimeDefault }` — applies the container runtime's default seccomp filter

NetworkPolicies (enabled by default) restrict pod-to-pod communication: PostgreSQL only accepts connections from the API and Kratos; Kratos admin port is reachable only from the API. See [RESILIENCE.md](.compliance/RESILIENCE.md) for details.

Container images use minimal base images and run as non-root user (UID 53111).

**Question: What build provenance and supply chain integrity measures are in place to prevent tampering of the build pipeline? (e.g., SLSA level, hermetic builds, signed artefacts)** `[maintainer]`

- All release artefacts (binaries and container images) are signed with cosign
- Every release includes a SLSA-compatible provenance attestation linking the artefact to the exact source commit and CI pipeline run
- All GitHub Actions and container images in CI are pinned to SHA digests, not mutable tags
- Go dependencies are tracked in `go.sum`, Node.js dependencies are locked via `package-lock.json`
- Signatures are verifiable using the project's public cosign key at `https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub`
- The Helm chart ships optional Kyverno admission policies that verify cosign signatures on container images at deploy time
