---
# Update policy evidence entries.
# Protocols:
#   https:// → HTTP GET → assert 200 (links to release feed, changelog, update documentation)
evidences: 
  - url: https://github.com/l3montree-dev/devguard/releases.atom
  - url: https://docs.devguard.org/how-to-guides/administration/upgrade-devguard
---

# Security Update Policy

## Annex I, Part I(2)(c) — Security Update Mechanisms

> Part I(2) (c) ensure that vulnerabilities can be addressed through security updates, including, where applicable, through automatic security updates that are installed within an appropriate timeframe enabled as a default setting, with a clear and easy-to-use opt-out mechanism, through the notification of available updates to users, and the option to temporarily postpone them;

**Question: What mechanism does the project use to publish security updates? (e.g., versioned releases on a package registry, container image tags, signed binaries)** `[maintainer]`

Security updates are published via:

- **GitHub releases** with versioned tags, changelogs, and attached binary artefacts
- **Container image tags** on GitHub Container Registry (ghcr.io) — the `:latest` tag always receives the latest security patches
- All release artefacts are signed with cosign and accompanied by SLSA provenance attestations

**Question: Does the product support or enable automatic updates for end users? If not, what is the justification?** `[maintainer]`

The CRA requires automatic security updates enabled as a default setting with an opt-out mechanism. DevGuard addresses this through:

*Application updates*: DevGuard is deployed via Helm chart in Kubernetes environments where operators manage their own update cadence. Automatic application updates are not enabled by default because server-side infrastructure software requires operator-controlled change management — uncoordinated restarts can cause service disruption. Operators can enable automatic updates using GitOps tools (FluxCD, ArgoCD image update automation) or dependency update tools (Renovate, Dependabot).

Operators can temporarily postpone any update by pinning a specific container image tag in `values.yaml`.

**Question: How can users opt out of automatic security updates? Describe the mechanism.** `[maintainer]`

Application updates are manual by default (Helm upgrade). Operators who have enabled automatic updates via GitOps tools can opt out by disabling the image update automation in their GitOps configuration, or by pinning a specific image tag in `values.yaml`.

The vulnerability database auto-update (which runs inside the application every 6 hours) can be disabled by setting the environment variable `DISABLE_VULNDB_UPDATE=true`.

**Question: Can users temporarily postpone the installation of security updates? If so, how?** `[maintainer]`

Yes. Operators can postpone application updates by pinning a specific container image tag and Helm chart version in `values.yaml` rather than tracking `:latest`. Vulnerability database updates can be postponed by setting `DISABLE_VULNDB_UPDATE=true`. There is no enforced update deadline — operators have full control over their update cadence.

**Question: How does the manufacturer notify their end users when a security update is available?** `[manufacturer]`

The DevGuard instance admin dashboard indicates when new releases are available. Users can additionally subscribe to GitHub release notifications via the repository's watch settings or the Atom feed at https://github.com/l3montree-dev/devguard/releases.atom.

---

## Annex I, Part II(7) — Secure Update Distribution

> (7) provide for mechanisms to securely distribute updates for products with digital elements to ensure that vulnerabilities
> are fixed or mitigated in a timely manner and, where applicable for security updates, in an automatic manner;

**Question: How are released update artefacts cryptographically signed to prevent tampering? (e.g., GPG-signed packages, cosign-signed container images, SLSA provenance)** `[maintainer]`

- All container images are signed with **cosign** (Sigstore)
- Every release includes a **SLSA-compatible provenance attestation** linking the artefact to the exact source commit and CI pipeline run
- Signatures are verifiable using the project's public cosign key at `https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub`

**Question: How can users verify the authenticity and integrity of an update before applying it?** `[maintainer]`

Users can verify container image signatures using cosign:

```bash
cosign verify --key https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub ghcr.io/l3montree-dev/devguard:latest
```

Provenance attestations can be verified similarly:

```bash
cosign verify-attestation --key https://raw.githubusercontent.com/l3montree-dev/devguard/main/cosign.pub --type https://slsa.dev/provenance/v1 ghcr.io/l3montree-dev/devguard:latest
```

**Question: What is the process the manufacturer uses to deploy updates to their production environment after the upstream project releases a fix?** `[manufacturer]`

This question must be answered by the operator. The recommended update process is:

1. Verify the new container image signature using `cosign verify`
2. Review the release notes and security advisory (if applicable)
3. Update the image tags in `values.yaml` or allow GitOps automation to detect the new image
4. Run `helm upgrade` to deploy the update
5. Verify the deployment via health endpoints and Kubernetes pod status

The upgrade procedure with rollback instructions is documented at https://docs.devguard.org/how-to-guides/administration/upgrade-devguard.

---

## Annex I, Part II(8) — Free and Timely Security Update Dissemination

> (8) ensure that, where security updates are available to address identified security issues, they are disseminated without
> delay and, unless otherwise agreed between a manufacturer and a business user in relation to a tailor-made product with
> digital elements, free of charge, accompanied by advisory messages providing users with the relevant information,
> including on potential action to be taken.

**Question: Are security updates published by this project free of charge?** `[steward / maintainer]`

Yes. All security updates are published free of charge open source via GitHub releases and the public container registry.

**Question: What is the project's target time between a fix being ready and a release being publicly available?** `[steward / maintainer]`

The `:latest` container image tag is updated immediately when a fix is merged to main. For versioned releases, the target aligns with the severity-based SLAs defined in [VULNERABILITY_HANDLING_CVD.md](.compliance/VULNERABILITY_HANDLING_CVD.md). The publicly committed timeline in `SECURITY.md` is "within a week if possible."

Where technically feasible, security-only patch releases are published separately from feature releases. Only the latest release is actively supported - operators on older versions must upgrade to receive fixes.

**Question: Are the manufacturer's security updates to their end users provided free of charge within the declared support period?** `[manufacturer]`

Yes. DevGuard is open source (AGPL-3.0). All security updates are published free of charge via GitHub releases and the public container registry (ghcr.io) throughout the declared support period.

**Question: Are the manufacturer's update notifications accompanied by advisory messages describing the vulnerability, its severity, and the action users should take?** `[manufacturer]`

Security updates are accompanied by GitHub Security Advisories that include: CVE identifier (where assigned), affected version ranges, CVSS score, impact description, and remediation instructions. Release notes describe all changes including security fixes. CSAF advisory documents are generated for machine-readable distribution. See [VULNERABILITY_HANDLING_CVD.md](.compliance/VULNERABILITY_HANDLING_CVD.md) for the full advisory publication process.
