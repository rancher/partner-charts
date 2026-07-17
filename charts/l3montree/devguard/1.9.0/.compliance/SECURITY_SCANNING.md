---
# All scanning evidence entries.
# Protocols:
#   https:// → HTTP GET → assert 200
#   oci://   → cosign verify-attestation --key <cosign_public_key_url> --type <predicate_type> <ref>
# predicate_type determines what is checked:
#   https://www.schemastore.org/schemas/json/sarif-2.1.0.json
#     → parse as SARIF, assert no findings with level: error
#   https://cyclonedx.org/vex
#     → parse as CycloneDX VEX, assert all vulnerabilities have an exploitability statement
# Optional fields:
#   cosign_public_key_url  — required for oci:// entries
#   predicate_type         — required for oci:// entries
evidences:
  # SAST — SARIF attested on each container image
  - url: oci://ghcr.io/l3montree-dev/devguard:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://www.schemastore.org/schemas/json/sarif-2.1.0.json
  - url: oci://ghcr.io/l3montree-dev/devguard-web:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://www.schemastore.org/schemas/json/sarif-2.1.0.json
  - url: oci://ghcr.io/l3montree-dev/devguard/scanner:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://www.schemastore.org/schemas/json/sarif-2.1.0.json
  # VEX — exploitability statements attested on each container image
  - url: oci://ghcr.io/l3montree-dev/devguard:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://cyclonedx.org/vex
  - url: oci://ghcr.io/l3montree-dev/devguard-web:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://cyclonedx.org/vex
  - url: oci://ghcr.io/l3montree-dev/devguard/scanner:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://cyclonedx.org/vex
---

# Security Scanning

## Annex I, Part I(2)(a) — No Known Exploitable Vulnerabilities at Release

> (a) be made available on the market without known exploitable vulnerabilities;

**Question: What scanning tools are used to detect known vulnerabilities in dependencies (SCA) and source code (SAST) before release?** `[maintainer]`

DevGuard uses its own scanning capabilities via the `devguard-action` reusable GitHub Actions workflow, which orchestrates the `devguard-scanner` CLI:

- **SAST**: `devguard-scanner sast` executes semgrep against Go and TypeScript code, producing SARIF output. Triggered on every push.
- **SCA**: `devguard-scanner sca` uses Trivy to scan Go modules and Node.js packages to create a SBOM and scan it with DevGuard for CVEs. Triggered on every push.
- **Secret detection**: `devguard-scanner secret-scanning` executes gitleaks, producing SARIF output. A baseline file (`leaks-baseline.json`) exists for false positive suppression.
- **Container scanning**: Built container images are scanned with Trivy to create a SBOM and scan it with DevGuard for CVEs.
- **Linting**: `golangci-lint` with `staticcheck` and `unused` rules runs as a dedicated CI job on every push.

**Question: Is scanning integrated into the CI/CD pipeline so that every build is checked before release?** `[maintainer]`

Yes. All scanning runs automatically on every push via the `devguard-action` workflows. Results are uploaded to DevGuard at https://main.devguard.org/l3montree-cybersecurity/projects/devguard/assets/devguard.


**Question: What is the policy for blocking a release when vulnerabilities are found?** `[maintainer]`

The pipeline is configured with two blocking thresholds: `fail-on-risk: high` and `fail-on-cvss: high` (CVSS >= 7.0).

**Question: How are false positives documented and justified? (Link to VEX document in the evidence field above)** `[maintainer]`

False positives and accepted risks are managed through DevGuard's vulnerability lifecycle management:

- Findings can be marked as "false positive" with a mandatory justification text and user attribution, recorded as `VulnEvent` audit records
- VEX (Vulnerability Exploitability eXchange) documents are generated in CycloneDX format and attested as OCI referrers on container images (see evidence entries above)
- Gitleaks false positives are suppressed via a checked-in `leaks-baseline.json` baseline file
- Automated VEX rules can be configured to apply recurring decisions across releases

---

## Annex I, Part II(3) — Regular Security Testing and Reviews

> (3) apply effective and regular tests and reviews of the security of the product with digital elements;

**Question: How frequently is security scanning performed? (e.g., on every commit, nightly, per release)** `[maintainer]`

Scanning runs on every push to any branch via the `devguard-action` workflows.

**Question: Beyond automated scanning, are manual security reviews or penetration tests conducted? If so, at what cadence?** `[maintainer]`

All code changes require a reviewed pull request with at least one approving review before merge. No systematic penetration testing is conducted at a defined cadence.

**Question: What is the process for acting on findings from security reviews or penetration tests?** `[maintainer]`

Findings from automated scanning are triaged through DevGuard's vulnerability lifecycle: each finding is assessed, classified (accepted, false positive, mitigated, or fixed), and tracked with user attribution and justification. Findings rated high or above block the pipeline and must be resolved before merge. Findings from code review are addressed in the PR before approval. Results for the DevGuard project itself are visible at https://main.devguard.org/l3montree-cybersecurity/projects/devguard/assets/devguard.
