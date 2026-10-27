---
# URL to the EU Declaration of Conformity document (PDF or HTML).
# Machine check: HTTP GET → assert 200; assert content-type is application/pdf or text/html.
# Status: Draft (not yet published).
declaration_of_conformity_url: ""

# List of harmonised standards, European cybersecurity certification schemes,
# or other technical specifications applied to demonstrate conformity with Annex I.
# Machine check: values are validated against a known list of CRA-relevant standards.
standards_applied: []
---

# Conformity Assessment and Declaration of Conformity

## Annex VII — Harmonised Standards and Technical Specifications

> 5. a list of the harmonised standards applied in full or in part the references of which have been published in the Official Journal of the European Union, common specifications as set out in Article 27 of this Regulation or European
> cybersecurity certification schemes adopted pursuant to Regulation (EU) 2019/881 pursuant to Article 27(8) of this Regulation, and, where those harmonised standards, common specifications or European cybersecurity certification
> schemes have not been applied, descriptions of the solutions adopted to meet the essential cybersecurity requirements set out in Parts I and II of Annex I, including a list of other relevant technical specifications applied. In the event of partly
> applied harmonised standards, common specifications or European cybersecurity certification schemes, the technical documentation shall specify the parts which have been applied;

**Question: Which harmonised European standards or common specifications are applied to demonstrate conformity with Annex I? (List in the frontmatter above.)** `[manufacturer]`

DevGuard demonstrates conformity with Annex I (essential cybersecurity requirements) through alignment with the following standards:

**ISO/IEC 27001:2022 / ISO/IEC 27002:2022** — Information Security Management Systems (ISMS). These standards define security control objectives and implementation guidance. DevGuard's security architecture (detailed in ACCESS_CONTROL.md, ENCRYPTION.md, LOGGING.md, and SECURITY.md) implements controls from the ISO 27002 catalogue, including access control, cryptography, operational security and communications security (A.12). Certification audit is currently in progress.

**OWASP Best Practices** — Application Security Standard. DevGuard's development pipeline integrates automated security testing such as SAST (static application security testing) to detect and mitigate vulnerabilities (e.g. injection). Security code review is performed on pull requests.

**CycloneDX specifications** — Software Bill of Materials standards. DevGuard generates SBOMs in CycloneDX format and distributes them alongside built artefacts, enabling users to document and manage component inventories as required by Annex I Part I(2)(c).

**Question: Where standards are only partially applied, which clauses are used and which are not applicable?** `[manufacturer]`

...

**Question: For requirements not covered by any harmonised standard, what alternative technical specifications or internal processes are relied upon?** `[manufacturer]`

For Annex I requirements not addressed by ISO 27001/27002 certification, DevGuard relies on supplementary technical specifications and best practices:

- **Secure Coding & Development Lifecycle:** OWASP Secure Coding Practices Cheat Sheet. DevGuard development enforces code review on all changes, integrates SAST (static analysis) on container images, and attests build provenance via SLSA format. 
- **Cryptography:** BSI TR-02102-1 (Cryptographic Mechanisms: Recommendations and Key Lengths). DevGuard uses ECDSA P-256 for PAT signing and bcrypt for password hashing. See ENCRYPTION.md.
- **Vulnerability Management & Disclosure:** Vulnerability Disclosure and Vulnerability Handling Processes. DevGuard maintains a coordinated vulnerability disclosure (CVD) policy with defined timelines and embargo periods.
- **Supply Chain Security:** SLSA (Supply-chain Levels for Software Artifacts) framework. DevGuard publishes provenance attestations for released container images.

---

## Annex VII — EU Declaration of Conformity

> Article 28 EU declaration of conformity; Annex V
>
> The EU declaration of conformity referred to in Article 28, shall contain all of the following information:
> 1. Name and type and any additional information enabling the unique identification of the 
>   product with digital elements
> 2. Name and address of the manufacturer or its authorised representative
> 3. A statement that the EU declaration of conformity is issued under the sole
>   responsibility of the provider
> 4. Object of the declaration (identification of the product with digital
>   elements allowing traceability, which may include a photograph, where appropriate)
> 5. A statement that the object of the declaration described above is in
>   conformity with the relevant Union harmonisation legislation
> 6. References to any relevant harmonised standards used or any other
>   common specification or cybersecurity certification in relation to which conformity is declared
> 7. Where applicable, the name and number of the notified body, a description
>   of the conformity assessment procedure performed and identification of the certificate issued
> 8. Additional information:
>   Signed for and on behalf of:
>   (place and date of issue):
>   (name, function) (signature):

**Question: Has an EU Declaration of Conformity been drawn up per Annex V? Provide the URL in the frontmatter above.** `[manufacturer]`

An EU Declaration of Conformity (DoC) is currently in draft form and has not yet been published. The DoC will be published at a URL to be announced in the frontmatter above.

**Question: Does the Declaration of Conformity include: the manufacturer's name and address, the product name and version, a reference to this technical documentation, the applicable conformity assessment procedure followed, a list of standards applied, the date of issue, and the authorised signatory?** `[manufacturer]`

The draft EU Declaration of Conformity will include all required elements.
Upon publication, the DoC will be digitally signed and made available at the URL specified in the frontmatter.

**Question: What conformity assessment procedure was followed? (Article 32(1) internal control for default; Article 32(2) for Important Class I; Article 32(3) third-party assessment for Important Class II and Critical)** `[manufacturer]`

DevGuard is classified as default class (not important, not critical) and therefore follows the **internal control procedure** (Article 32(1)).

**Conformity Assessment Procedure:**

1. **Technical Documentation Preparation** — This comprehensive technical documentation has been prepared covering all essential requirements.

2. **Internal Control and Verification** — Ongoing process:
   - Code review on all pull requests
   - SAST scanning integrated into CI/CD pipeline with attestation
   - Dependency scanning and SBOM generation on every release
   - Automated security testing
   - Container image scanning for vulnerabilities
   - Network policy validation in Kubernetes deployments
   - Periodic security self-assessment and threat model review

3. **Standards Alignment Assessment** — Conformity with ISO/IEC 27001:2022/27002:2022 controls is being verified through:
   - Third-party ISO 27001 certification audit (planned)

4. **Ongoing Monitoring** — Per Article 28(3):
   - Changes to essential requirements are tracked in the documentation (GitHub commit history)
   - New vulnerabilities in dependencies trigger automatic reassessment via SBOM and security scanning

**Question: Is the Declaration of Conformity kept up to date as the product changes, as required by Article 28(3)?** `[manufacturer]`

**Conformity Update and Version Management Process (Article 28(3)):**

The EU Declaration of Conformity will be maintained and updated in accordance with Article 28(3) (i.e., "the EU declaration of conformity shall be updated where modifications are made to the product").

**Triggers for DoC Update:**

1. **Major Version Releases** — Any update to the Helm chart major version (e.g., v1.0 → v2.0) requires DoC review and update.
2. **Security-Critical Changes** — Changes to authentication, authorization, encryption, or vulnerability handling trigger immediate DoC review.
3. **Dependency Updates with Security Impact** — Updates to Ory Kratos, PostgreSQL, or other security-critical components trigger reassessment.

**Technical Documentation Updates:**

Changes to the technical documentation in `.compliance/` are tracked via Git commits. The Git history provides an audit trail of all conformity assessment changes. Each commit references the Helm chart version and explains the assessment change.