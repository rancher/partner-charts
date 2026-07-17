---
# SBOM artifact entries.
# Protocols:
#   https:// → HTTP GET → assert 200, parse as valid CycloneDX or SPDX JSON
#   oci://   → cosign verify-attestation --key <cosign_public_key_url> --type <predicate_type> <ref>
# Optional fields per entry:
#   cosign_public_key_url  — required for oci:// entries; used to verify the attestation signature
#   predicate_type         — required for oci:// entries; e.g. https://cyclonedx.org/bom
evidences:
  - url: https://github.com/l3montree-dev/devguard/releases/latest
  - url: oci://ghcr.io/l3montree-dev/devguard:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://cyclonedx.org/bom
  - url: oci://ghcr.io/l3montree-dev/devguard-web:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://cyclonedx.org/bom
  - url: oci://ghcr.io/l3montree-dev/devguard/scanner:latest
    cosign_public_key_url: https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub
    predicate_type: https://cyclonedx.org/bom
---

# Software Bill of Materials (SBOM)

## Annex I, Part II(1) — SBOM and Component Inventory

> (1) identify and document vulnerabilities and components contained in products with digital elements, including by
> drawing up a software bill of materials in a commonly used and machine-readable format covering at the very least the
> top-level dependencies of the products;

**Question: What format is the SBOM provided in? (CycloneDX ECMA-424 or SPDX ISO/IEC 5962:2021 are the accepted machine-readable formats)** `[maintainer]`

SBOMs are provided in **CycloneDX JSON** format. They are generated using Trivy.

**Question: Does the SBOM cover at minimum all top-level dependencies? Does it also cover transitive dependencies?** `[maintainer]`

SBOMs cover all direct and transitive dependencies, their versions, and known licenses. Trivy resolves the full dependency tree from Go modules (`go.sum`), npm lockfiles (`package-lock.json`), and OS package managers in container images.

**Question: At what point in the build process is the SBOM generated (e.g., per commit, per release)?** `[maintainer]`

SBOMs are generated per release. Container image SBOMs are generated and attested as part of the CI release workflow.

**Question: How is the SBOM kept up to date as dependencies change?** `[maintainer]`

A new SBOM is generated with each release. Since SBOMs are embedded as OCI referrers on container images, pulling a specific image version always yields the corresponding SBOM.

**Question: Where is the SBOM published or made available to users and market surveillance authorities upon request?** `[maintainer]`

- **Container image SBOMs** are embedded as OCI referrers using cosign attestations, allowing any consumer to verify the SBOM directly from the registry.
- **Binary SBOMs** are attached to GitHub releases.
- All attestations are signed with the project's cosign key and verifiable using the public key at `https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub`.

**Question: How are vulnerabilities in third-party components and dependencies continuously monitored after release (not only at build time)?** `[maintainer]`

DevGuard monitors its own components using its own scanning capabilities. The vulnerability database is rebuilt every 6 hours. Each rebuild fetches the latest data from all upstream sources (see below) and recalculates vulnerability status for all tracked components. Dependency tree changes are tracked across releases.

**Question: What vulnerability databases are used as the source of truth? (e.g., NVD, OSV, GitHub Advisory Database, CISA KEV)** `[maintainer]`

**Vulnerability databases**:
- **OSV** (Open Source Vulnerabilities) — primary vulnerability source
- **CISA KEV** (Known Exploited Vulnerabilities) — identifies actively exploited CVEs
- **OSSF Malicious Packages** — detects known-malicious packages in dependency trees

**Enrichment sources** (scoring, classification, exploit intelligence):
- **EPSS** (Exploit Prediction Scoring System) — probabilistic exploit likelihood scores
- **CWE** (Common Weakness Enumeration) — weakness classification
- **ExploitDB** — known public exploits, fetched from GitLab
- **GitHub PoC database** (nomi-sec/PoC-in-GitHub) — proof-of-concept exploit references
