---
# Whether this project is subject to the CRA at all (Article 2).
# Machine check: if false, all other compliance checks are skipped.
# Justification must be provided in the markdown body below.
cra_applicable: true

# CRA product class as defined in Annex III / Annex IV.
# Machine check: if class is 2, additional certification evidence is required
# and the checker will look for a third-party audit document.
# Allowed values: default, important-1, important-2, critical
class: default

# Support period in months (Article 13(4)).
# Must be commensurate with the expected use of the product.
# Machine check: assert value is a positive integer.
support_period_months: 60
---

# Product Classification and General Description

## Annex VII — General Description of the Product

> 1. a general description of the product with digital elements, including:
>   (a) its intended purpose;
>   (b) versions of software affecting compliance with essential cybersecurity requirements;
>   (c) where the product with digital elements is a hardware product, photographs or 
>       illustrations showing external features, marking and internal layout;
>   (d) user information and instructions as set out in Annex II;

**Question: What is this product and what is its intended purpose?** `[maintainer]`

DevGuard is a software supply chain security platform. It aggregates vulnerability scan results, manages SBOMs and provenance attestations, tracks vulnerability lifecycle state, and provides compliance reporting for development teams. It integrates with CI/CD pipelines to collect security findings and with Git providers (GitHub, GitLab). It stores security-sensitive data (CVE findings, OAuth integration tokens, scan results) and is deployed as an operator-managed Kubernetes application.

**Question: What are the essential characteristics of the product (key features, primary functions)?** `[maintainer]`

The product spans multiple components deployed together via this Helm chart:

- **devguard** — the backend API (Go)
- **devguard-web** — the frontend (Next.js)
- **devguard-scanner** — the CLI scanning tool (Go)
- **devguard-action** — the GitHub Actions integration
- **devguard-ci-component** — the GitLab CI component

Key features include: SCA, SAST, container scanning, and secret detection; SBOM generation and distribution in CycloneDX format; provenance attestation and cosign-based artefact signing; vulnerability lifecycle management with audit trails; CSAF and VEX document generation; role-based access control with organisation-scoped data isolation.

**Question: What versions of software or firmware are covered by this documentation?** `[maintainer]`

This documentation covers the DevGuard Helm chart and all components it deploys, starting from the Helm chart version in which this compliance documentation was introduced. Each component is released independently but versioned together in this Helm chart. The specific container image versions deployed by a given Helm chart release are pinned in `values.yaml`. This documentation is reviewed and updated with each major or security-relevant release.

---

## Annex III / IV — Product Class

> Classification: Default/ Important Product (Class I/II) (Annex III)/ Critical Product (Annex IV)

> Annex III examples: identity management software, browsers, password managers, VPNs, SIEM, network monitoring tools, microcontrollers, routers, switches, smart home assistants.
>
> Annex IV: Hardware Devices with Security Boxes; Smart meter gateways within smart metering systems as defined in Article 2, point (23) of Directive (EU) 2019/944 of the European Parliament and of the Council (1) and other devices for advanced security purposes, including for secure cryptoprocessing; Smartcards or similar devices, including secure elements

**Question: Does this product fall under Annex III (Important Product, Class I/II) or Annex IV (Critical Product)? Provide justification.** `[manufacturer]`

DevGuard is classified as a **default class** product. It does not fall under Annex III or Annex IV.

**Annex III (Important Product) exclusion**: DevGuard is not identity management software, a browser, password manager, VPN, network management or configuration tool, SIEM system, boot manager, PKI software, or any other category listed in Annex III. While it processes security-relevant data, it does not itself perform network monitoring/traffic management, manage digital identities or credentials, or function as a firewall, IDS/IPS, or endpoint protection system.

**Annex IV (Critical Product) exclusion**: DevGuard is not a hardware security module, smartcard, secure element, smart meter gateway, or any hardware device with security functions.

DevGuard is a developer-facing tool for aggregating and managing vulnerability findings. It does not control access to networks, manage cryptographic keys on behalf of users, or operate as security infrastructure that other systems depend on for their security properties. The default conformity assessment procedure applies.

---

## Article 13(3) — Support Period

> 3. The cybersecurity risk assessment shall be documented and updated as appropriate during a support period to be determined in accordance with paragraph 8 of this Article. [...]

**Question: What is the declared support period for this product, and how was it determined to be commensurate with the product's expected use?** `[manufacturer]`

The declared support period is **60 months** (5 years). DevGuard is infrastructure software deployed in enterprise environments where long-term stability and security maintenance are expected. A 5-year support period aligns with typical enterprise software lifecycle expectations. Security updates are provided on an ongoing basis for the latest release. Only the latest release is actively supported; operators are expected to upgrade to receive security fixes.

**Question: What is the process for communicating end-of-support to users?** `[manufacturer]`

This question must be answered by the operator/manufacturer deploying DevGuard. The open-source project communicates support status and end-of-life notices via GitHub releases and the project's public documentation.
