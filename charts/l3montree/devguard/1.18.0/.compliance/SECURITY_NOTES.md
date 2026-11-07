---
# Public security documentation entries.
# Machine check: HTTP GET url → assert 200,
# assert content-type is text/html or application/pdf.
evidences:
  - url: https://docs.devguard.org
  - url: https://docs.devguard.org/self-hosting
---

# Security Notes and User Information

## Annex II — Information and Instructions to the User

> At minimum, the product with digital elements shall be accompanied by:
> 
> 1. the name, registered trade name or registered trademark of the manufacturer, and the
>   postal address, the email address
>   or other digital contact as well as, where available, the website at which the
>   manufacturer can be contacted;
> 
> 2. the single point of contact where information about vulnerabilities of the product
>   with digital elements can be reported and received, and where the manufacturer’s 
>   policy on coordinated vulnerability disclosure can be found;
> 
> 3. name and type and any additional information enabling the unique identification
>   of the product with digital elements;
> 
> 4. the intended purpose of the product with digital elements, including the security
>   environment provided by the manufacturer, as well as the product’s essential 
>   functionalities and information about the security properties;
> 
> 5. any known or foreseeable circumstance, related to the use of the product with
>   digital elements in accordance with its intended purpose or under conditions of
>   reasonably foreseeable misuse, which may lead to significant cybersecurity risks;
> 
> 6. where applicable, the internet address at which the EU declaration of conformity can be accessed;
> 
> 7. the type of technical security support offered by the manufacturer and the end-date of
>   the support period during which users can expect vulnerabilities to be handled and to
>   receive security updates;
>
> 8. detailed instructions or an internet address referring to such detailed instructions
>   and information on:
>     (a) the necessary measures during initial commissioning and throughout the lifetime 
>     of the product with digital elements to ensure its secure use;
>     (b) how changes to the product with digital elements can affect the security of data;
>     (c) how security-relevant updates can be installed;
>     (d) the secure decommissioning of the product with digital elements, including
>     information on how user data can be securely removed;
>     (e) how the default setting enabling the automatic installation of security updates,
>     as required by Part I, point (2)(c), of Annex I, can be turned off;
>     (f) where the product with digital elements is intended for integration into other
>     products with digital elements, the information necessary for the integrator to 
>     comply with the essential cybersecurity requirements set out in Annex I and the
>     documentation requirements set out in Annex VII.
>
> 9. If the manufacturer decides to make available the software bill of materials to the user,
>   information on where the software bill of materials can be accessed.

**Question: Is user-facing security documentation publicly available (website, README, docs)? Provide the URL.** `[maintainer]`

Documentation is available at https://docs.devguard.org. Self-hosting documentation specifically at https://docs.devguard.org/self-hosting.

**Question: Does the documentation explain the intended purpose and any known cybersecurity risks users should be aware of?** `[maintainer]`

DevGuard is designed for self-hosting via Helm chart in Kubernetes environments. Key operator responsibilities and cybersecurity considerations:

- **TLS certificates**: Operators must provide a valid TLS certificate (e.g. via cert-manager). The Helm chart does not enforce a minimum TLS version or cipher suite — this is the operator's ingress controller responsibility. The API and frontend must not be exposed over plain HTTP.
- **Internal database connections**: Communication between the API/Kratos and PostgreSQL uses `sslmode=disable` by default. Operators should deploy a service mesh or ensure the database is only reachable within a private network segment.
- **Secret management**: All credentials (database passwords, Kratos secrets, cosign keys) are generated as random 32-character strings on first install if not pre-provided. No default passwords exist in the chart.
- **Network policies**: Enabled by default (`networkPolicy.enabled: true`). Restricts inbound pod-to-pod traffic (e.g. PostgreSQL only accepts connections from API and Kratos pods).
- **OAuth token storage**: Integration tokens for Git providers (GitHub, GitLab) are stored as plaintext in the database. Operators must enable storage-level encryption (encrypted volumes) to protect these at rest.
- **Updates**: Operators should subscribe to GitHub release notifications. See [UPDATE_POLICY.md](.compliance/UPDATE_POLICY.md) for update mechanisms and SLAs.

**Question: Does the documentation provide instructions for secure installation, initial configuration, and ongoing operation?** `[maintainer]`

The self-hosting documentation at https://docs.devguard.org/self-hosting covers:

- Helm-based Kubernetes deployment (production)
- Docker Compose setup (evaluation/development only — explicitly marked as not for production use)
- Secret management and ingress configuration
- Authentication setup (Ory Kratos, OIDC providers)
- SMTP configuration for email notifications
- Database maintenance including backup (`pg_dump`) and restore procedures
- Upgrade procedures with rollback instructions

**Question: Does the manufacturer's product documentation inform end users of the support period and how to receive security updates?** `[manufacturer]`

The support period is declared as 60 months (see [PRODUCT_CLASS.md](.compliance/PRODUCT_CLASS.md)). Security updates are distributed via cosign-signed container images on ghcr.io and GitHub releases. Update mechanisms, notification channels, and severity-based SLAs are documented in [UPDATE_POLICY.md](.compliance/UPDATE_POLICY.md). Only the latest release is actively supported.

**Question: Does the documentation include or reference the vulnerability reporting contact address?** `[steward / maintainer]`

The `SECURITY.md` file in the devguard repository documents the coordinated vulnerability disclosure (CVD) process:

- **Reporting channels**: GitHub Private Vulnerability Reporting or email to `developer@l3montree.com` (PGP-encrypted submissions supported)
- **Response target**: Security patches within one week where possible
- **Disclosure**: Public disclosure after the vulnerability is fixed
- **Canonical security contact**: https://l3montree.com/.well-known/security.txt

**Question: Are security advisory messages provided to end users when security updates are released? In what format and via what channel?** `[manufacturer]`

Security advisories are published via GitHub Security Advisories on the devguard repository. Release notes accompanying each GitHub release describe security-relevant changes. The DevGuard admin dashboard indicates when a new release is available. Operators can subscribe to GitHub release notifications or use GitOps tools (FluxCD, ArgoCD) for automated update detection.

---

## Annex II — Checklist of Required Information Items

> The following items are required by Annex II. Each must be verifiable in the published documentation.

| Annex II item | Status | Where addressed |
|---|---|---|
| 1. Manufacturer name, postal address, email, website | Covered | L3montree GmbH & DevGuard Contributors, Markt 3, 53111 Bonn, Germany, community@devguard.org, https://devguard.org |
| 2. Vulnerability reporting contact and CVD policy | Covered | `SECURITY.md` in devguard repo; `developer@l3montree.com`; https://l3montree.com/.well-known/security.txt |
| 3. Product name, type, unique identification | Covered | [PRODUCT_CLASS.md](.compliance/PRODUCT_CLASS.md) — Helm chart name + component list |
| 4. Intended purpose and security properties | Covered | [PRODUCT_CLASS.md](.compliance/PRODUCT_CLASS.md) and https://docs.devguard.org |
| 5. Known cybersecurity risks | Covered | Operator responsibilities above, [THREAT_MODEL.md](.compliance/THREAT_MODEL.md), and known gaps documented across compliance files |
| 6. URL to EU declaration of conformity | WIP | Must be provided once the declaration is drawn up. See [CONFORMITY.md](.compliance/CONFORMITY.md) |
| 7. Support period and security update information | Covered | 60 months declared in [PRODUCT_CLASS.md](.compliance/PRODUCT_CLASS.md); update SLAs in [UPDATE_POLICY.md](.compliance/UPDATE_POLICY.md) |
| 8(a). Secure installation and operation instructions | Covered | https://docs.devguard.org/self-hosting |
| 8(b). How changes affect data security | Partially covered | Upgrade guide at https://docs.devguard.org/how-to-guides/administration/upgrade-devguard |
| 8(c). How to install security updates | Covered | [UPDATE_POLICY.md](.compliance/UPDATE_POLICY.md) and upgrade guide |
| 8(d). Secure decommissioning and data removal | Covered | [DATA_REMOVAL.md](.compliance/DATA_REMOVAL.md) — organisation deletion, cascading deletes, PVC handling, backup cleanup |
| 8(e). How to turn off automatic security updates | Covered | Vulnerability database auto-update can be disabled via `DISABLE_VULNDB_UPDATE=true` env var. Application updates are manual (Helm upgrade) by default. |
| 8(f). Integration information for integrators | Covered | Scanner CLI, GitHub Action, and GitLab CI component documented at https://docs.devguard.org; API documented for integration |
| 9. Where to access the SBOM | Covered | [SBOM.md](.compliance/SBOM.md) — cosign attestations on container images (OCI referrers) and `*.sbom.json` on GitHub releases |