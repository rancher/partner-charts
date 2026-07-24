---
# Data removal evidence entries.
# Protocols:
#   https:// → HTTP GET → assert 200 (links to decommissioning documentation)
evidences: []
  # - url: https://docs.devguard.org/how-to-guides/administration/decommissioning
---

# Secure Data Removal

## Annex I, Part I(2)(m) — Secure Data Removal

> (m) provide the possibility for users to securely and easily remove on a permanent basis all data and settings and, where
> such data can be transferred to other products or systems, ensure that this is done in a secure manner.

**Question: Can users permanently remove all their data and settings from the product?** `[maintainer]`

Organisation owners can delete their organisation. This deletes associated data:
- Projects and nested projects
- Assets and asset versions
- Vulnerability findings and audit events
- SBOMs, artifacts, and provenance attestations
- PATs (personal access tokens) and OAuth tokens
- Webhooks, integrations, and VEX rules

Deletion is enforced at the database level via `OnDelete:CASCADE` constraints. All child records are deleted.

**Question: Is the data removal mechanism easy to use and does it ensure permanent deletion?** `[maintainer]`

**Ease of use:** Organisation deletion is one-click from the web UI (requires organisation owner role). Deletion is immediate and irreversible.

**Permanent deletion:** Data is hard-deleted from the database (not soft-deleted). Once deleted, rows are unreachable via the API or database queries. **Storage-level deletion** depends on the Kubernetes storage driver:
- If storage class uses `reclaimPolicy: Delete`, volumes are destroyed
- If using `Retain`, volumes persist and must be manually deleted

**Question: Where data can be transferred to other products or systems, is secure export supported?** `[maintainer]`

Export formats:
- **SBOMs**: CycloneDX JSON/XML
- **Vulnerabilities**: CycloneDX VEX JSON/XML
- **Audit logs**: JSON via API
- **Reports**: PDF, CSV, JSON

All exports are protected by the same authentication and RBAC as the API.

**Question: How does the manufacturer ensure secure data removal in their deployment, including backups and replicas?** `[manufacturer]`

**PostgreSQL backups:** Backups must be deleted separately per the operators's backup retention policy:
- Delete backup snapshots from the backup storage system (e.g., S3, Google Cloud Storage)
- Verify deletion in the backup system's audit log

**Kubernetes Secrets:** API tokens and OAuth credentials are stored as `Secret` objects. Deletion of the DevGuard namespace cascades to all `Secret` objects; external Secrets (pre-created outside the Helm release) must be cleaned up manually.

**PersistentVolumeClaims:** PostgreSQL data volumes must be deleted. Ensure the storage class's `reclaimPolicy` is set to `Delete` (not `Retain`) to prevent orphaned volumes.

**Encryption keys:** Database encryption keys (if any) are stored in the database. When the database is dropped, keys are destroyed with it. If keys are external (e.g., HSM, Vault), they must be revoked separately.
