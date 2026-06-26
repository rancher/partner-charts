---
# General security assurance evidence entries.
# Protocols:
#   file://  → assert path exists in repo
#   https:// → HTTP GET → assert 200
evidences: []
  # - url: https://docs.example.com/security-assurance
---

# General Security Assurance

## Annex I, Part I(1) — Appropriate Level of Cybersecurity

> (1) Products with digital elements shall be designed, developed and produced in such a way that they ensure an appropriate
> level of cybersecurity based on the risks.

**Question: How does the product's design and development process ensure the level of cybersecurity is appropriate to the identified risks? Which specific design decisions were made in response to the risk assessment?** `[maintainer]`

The threat model (see [THREAT_MODEL.md](.compliance/THREAT_MODEL.md)) is the primary artefact linking identified risks to concrete design decisions. Each identified threat maps to an architectural mitigation:

- **Layered authentication**: External API requests are authenticated via three mechanisms depending on context: Ory Kratos session cookies for interactive users, HTTP Message Signing (RFC 9421) with ECDSA P-256 for scanner integrations, and pre-shared admin tokens for administrative access. Scanner submissions are additionally integrity-protected via `Content-Digest` headers.
- **Organisation-scoped data isolation**: Enforced at the application layer through Casbin RBAC with domain-scoped policies. Every API request is evaluated against the caller's organisation membership before data access.
- **Signed artefacts**: Container images are cosign-signed. Release workflows generate provenance attestations via the `devguard-action` pipeline.
- **Minimal container images**: Production images use minimal base images and run as non-root user.

**Question: How is the level of cybersecurity maintained throughout production and delivery — not only during design and development? (e.g., secure build pipelines, release signing, deployment hardening)** `[maintainer]`

Security is enforced in the CI/CD pipeline and deployment configuration through automated tooling:

- **Linting**: `golangci-lint` with `staticcheck` and `unused` rules runs on every push
- **SCA**: Dependency and container scanning via `devguard-action` on every push, configured to fail on high-severity CVEs (`fail-on-cvss: high`)
- **Image signing**: Container images are signed with cosign; provenance attestations are generated per release
- **Kyverno admission policies**: The Helm chart ships Kyverno policies that verify cosign signatures on container images at deploy time
- **Code review**: Protected main branch requires at least one approving review before merge
- **Dependency pinning**: CI dependencies are pinned by SHA digest, not mutable tags

**Question: How does the manufacturer demonstrate holistic compliance with the essential cybersecurity requirements (a)–(m) of Part I for their specific product deployment?** `[manufacturer]`

The manufacturer (maintainer) provides the compliance documentation in this `.compliance/` directory covering the product's built-in security properties. The operator is responsible for demonstrating that deployment-specific controls (TLS configuration, at-rest encryption, network segmentation, access management) meet the requirements for their environment.
