## What's Changed

### New Features
* feat: implement external volume health monitoring via WEKA REST API by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/708 [(more details)](#pr-708)

### Improvements
* feat: add TTL-based filesystem name cache to API client by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/717 [(more details)](#pr-717)
* feat: add paginated API response support for quota fetching by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/715 [(more details)](#pr-715)

### Bug Fixes
* fix: accept the TenantAdmin API role for CSI operations by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/751 [(more details)](#pr-751)
* fix: correct NFS sync/async option translation in AsNfs mount option conversion by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/719 [(more details)](#pr-719)
* fix: make ApiClient safe for concurrent use, and fix what review found by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/718 [(more details)](#pr-718)
* fix: invalidate filesystem cache before deletion to prevent stale UID snapshot listing by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/714 [(more details)](#pr-714)
* fix: default semaphore weight to 1 for ops absent from maxConcurrencyPerOp by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/713 [(more details)](#pr-713)
* fix: replace Mutex with RWMutex in ApiStore to prevent concurrent map access races by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/712 [(more details)](#pr-712)
* fix: optimize gc resource consumption and support tenants with same filesystem name  by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/710 [(more details)](#pr-710)

### Documentation
* ci: adopt the v2 workflows and the new sanity harness by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/750 [(more details)](#pr-750)

### Miscellaneous
* fix(ci): write artifacthub changes as a string, and stop committing scratch by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/753 [(more details)](#pr-753)
* fix(ci): draft the release notes for the right branch, bounded by the last tag by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/752 [(more details)](#pr-752)

---
## PR Details

### <a name="pr-753"></a>PR #753 - fix(ci): write artifacthub changes as a string, and stop committing scratch
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/753

> ### TL;DR
> Fixes the release job, which produced an unloadable Helm chart and so never published v2.9.0.
> 
> ### What changed?
> - The `artifacthub.io/changes` chart annotation is written as text, and left out entirely when there is nothing to record
> - The release commit now includes only the files the release rewrites, instead of everything left lying in the build workspace
> - Removed a stray build scratch file that had been committed to the repository
> 
> ### How to test?
> 1. Run the release workflow.
> 2. Confirm it completes, and that a version tag, a GitHub release and a published Helm chart all appear.
> 3. Run `helm show chart charts/csi-wekafsplugin` and confirm it loads.
> 
> ### Why make this change?
> The release job wrote a list where Helm requires text, which made `Chart.yaml` impossible to load. Chart publishing failed on it, and that single failure also cost the version tag and the GitHub release, so v2.9.0 never went out even though the release commit had already landed. Nothing changes for anyone running the driver.

### <a name="pr-752"></a>PR #752 - fix(ci): draft the release notes for the right branch, bounded by the last tag
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/752

> ### TL;DR
> Release note drafts now cover only the release being cut, instead of repeating work that already shipped.
> 
> ### What changed?
> - The draft job lists only pull requests merged since the newest tag reachable from the branch being released
> - Removed a 30-item cap that silently dropped the oldest pull requests of a cycle
> - The release branch now defaults to `main`, and a push drafts notes for the branch that was pushed
> 
> ### How to test?
> 1. Run the `draft-v2` workflow against `main`.
> 2. Open the draft release it creates.
> 3. Confirm it lists only pull requests merged after the previous release tag — for `main` today, that is 15.
> 
> ### Why make this change?
> The job asked for merged pull requests with no cut-off date at all, so it returned whichever 30 had merged most recently regardless of the release they belonged to. The v2.9.0 draft consequently repeated work released in 2.8.4 through 2.8.9, and would have started losing genuine 2.9.0 entries off the bottom once more than 30 pull requests merged in the cycle. Nothing changes for anyone running the driver.

### <a name="pr-751"></a>PR #751 - fix: accept the TenantAdmin API role for CSI operations
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/751

> ### TL;DR
> Fixed a bug that made the driver unusable for customers whose storage API user has the TenantAdmin role.
> 
> ### What changed?
> - The driver now accepts the `TenantAdmin` role for its storage API user, alongside the already-supported `CSI`, `ClusterAdmin`, and `OrgAdmin` roles
> 
> ### How to test?
> 1. Configure the driver's storage API credentials with a user that has the `TenantAdmin` role
> 2. Create a PVC
> 3. Confirm the volume provisions successfully instead of failing with a permissions error
> 
> ### Why make this change?
> TenantAdmin grants full administrative control within its organization — the same scope OrgAdmin has — but it was missing from the driver's accepted-role list, blocking those customers entirely.

### <a name="pr-750"></a>PR #750 - ci: adopt the v2 workflows and the new sanity harness
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/750

> ### TL;DR
> No user-visible change — a faster internal build and test pipeline for developers.
> 
> ### What changed?
> - Adopted a faster continuous integration pipeline for building and testing the driver
> - Fixed a gap where automated storage tests never ran on pull requests opened as drafts
> 
> ### How to test?
> 1. Not applicable to users of the driver
> 2. Nothing changes in how the driver runs, is built, or is deployed
> 
> ### Why make this change?
> The previous pipeline was slow, and a trigger gap meant draft pull requests silently skipped storage test coverage, letting issues slip through unnoticed.

### <a name="pr-719"></a>PR #719 - fix: correct NFS sync/async option translation in AsNfs mount option conversion
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/719

> ### TL;DR
> Fixed an NFS mount bug that could apply the opposite write-caching behavior to what was requested.
> 
> ### What changed?
> - Corrected the `coherent` and `force_direct` NFS mount options so they now correctly set synchronous ("sync") writes instead of buffered ("async") writes
> 
> ### How to test?
> 1. Mount a volume over NFS using the `coherent` or `force_direct` mount option
> 2. Check the effective mount options on the client (for example, via `mount` or `/proc/mounts`)
> 3. Confirm `sync` is applied instead of `async`
> 
> ### Why make this change?
> The incorrect translation caused writes to be buffered instead of written through immediately, silently weakening the durability guarantee these options are meant to provide.

### <a name="pr-718"></a>PR #718 - fix: make ApiClient safe for concurrent use, and fix what review found
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/718

> ### TL;DR
> Fixed bugs that could crash the driver, or make it misjudge storage cluster features, when many volume operations ran at once.
> 
> ### What changed?
> - Made the driver's storage API client safe for many volume operations running at once
> - Fixed a partly-failed login being treated as successful, which left the driver with wrong assumptions about cluster capabilities for up to an hour (refusing valid volumes, skipping quota enforcement, or rejecting valid organizations)
> 
> ### How to test?
> Only reliably shown by automated tests, since the failures depend on timing under concurrent load:
> 1. Run the automated concurrency test suite added in this change
> 2. It reproduces the crashes and wrong behavior on the old code, and passes cleanly after the fix
> 
> ### Why make this change?
> Under concurrent load — normal in production, since Kubernetes creates and deletes many volumes in parallel — the driver could crash or silently run on wrong assumptions, causing hard-to-diagnose failures.

### <a name="pr-717"></a>PR #717 - feat: add TTL-based filesystem name cache to API client
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/717

> ### TL;DR
> Filesystem lookups are now cached briefly, cutting repeated calls to the storage system.
> 
> ### What changed?
> - Filesystem lookups reuse a recent result for a short time instead of querying the storage system every time.
> - Operations that need guaranteed fresh data are unaffected and always fetch live data.
> 
> ### How to test?
> 1. This is an internal performance optimization, verified by automated tests included in this change.
> 2. Operators may notice fewer repeated filesystem lookup calls to the storage cluster when the same filesystems are used repeatedly.
> 
> ### Why make this change?
> Workloads that resolve many filesystems in quick succession were generating a burst of repeated, identical requests to the storage cluster.

### <a name="pr-715"></a>PR #715 - feat: add paginated API response support for quota fetching
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/715

> ### TL;DR
> Quota lists are no longer silently truncated when a filesystem has more quotas than fit in one page of results.
> 
> ### What changed?
> - The API client now follows the storage system's pagination and combines all pages into the full result.
> - Hardened handling for older clusters without pagination support, and for empty or malformed pages.
> 
> ### How to test?
> 1. Query quotas on a filesystem with more quota entries than fit in a single page.
> 2. Verify the full list is returned, not just the first page.
> 3. Also covered extensively by automated tests.
> 
> ### Why make this change?
> The client wasn't following the "next page" pointer the storage system returns for long lists, so any sufficiently long list - most noticeably quotas - was silently incomplete.

### <a name="pr-714"></a>PR #714 - fix: invalidate filesystem cache before deletion to prevent stale UID snapshot listing
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/714

> ### TL;DR
> Deleting a filesystem could use stale cached data, letting deletion proceed even if the filesystem still had snapshots.
> 
> ### What changed?
> - The snapshot check performed before deleting a filesystem now always reads current data instead of a cached copy.
> - The cached record for a filesystem is cleared immediately once its deletion begins.
> 
> ### How to test?
> 1. This depends on an internal timing window that isn't practical to reproduce manually.
> 2. Covered by automated tests added in this change.
> 
> ### Why make this change?
> A cache used to avoid extra lookups wasn't cleared at the right time, so a delete could occasionally act on outdated filesystem information.

### <a name="pr-713"></a>PR #713 - fix: default semaphore weight to 1 for ops absent from maxConcurrencyPerOp
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/713

> ### TL;DR
> Operations without an explicit concurrency limit were being blocked entirely instead of allowed to run.
> 
> ### What changed?
> - Operations missing a configured concurrency limit now default to allowing 1 at a time, instead of 0.
> - Operations explicitly configured with a limit of 0 still remain blocked, as intended.
> 
> ### How to test?
> 1. Deploy the CSI driver.
> 2. Trigger an operation that has no explicit concurrency limit configured.
> 3. Verify it completes normally instead of hanging until it times out.
> 
> ### Why make this change?
> An operation without a configured limit defaulted to a concurrency of zero, which can never be acquired, so it would hang until its request timed out rather than running or failing clearly.

### <a name="pr-712"></a>PR #712 - fix: replace Mutex with RWMutex in ApiStore to prevent concurrent map access races
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/712

> ### TL;DR
> Fixes a bug that could crash the CSI controller under concurrent use
> 
> ### What changed?
> - Fixed unsafe concurrent access to the driver's internal cache of Weka cluster connections
> - Prevents a crash when many requests need cluster credentials at the same time
> 
> ### How to test?
> 1. Covered by automated concurrency tests included in this change
> 2. Before the fix, the symptom was occasional controller pod restarts under heavy simultaneous volume operations; this should no longer occur
> 
> ### Why make this change?
> The controller could crash outright when multiple requests needing storage-cluster credentials were handled at the same time — more likely at scale or with many simultaneous volume operations.

### <a name="pr-710"></a>PR #710 - fix: optimize gc resource consumption and support tenants with same filesystem name 
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/710

> ### TL;DR
> Fixes deleted-volume cleanup colliding across tenants sharing a filesystem name
> 
> ### What changed?
> - Cleanup of deleted volumes is now tracked per tenant, not just by filesystem name
> - Fixes trash left behind indefinitely when two tenants both use a name like `default`
> - Upgraded the deletion tool, lowering cleanup CPU/time cost
> 
> ### How to test?
> 1. Create identically-named filesystems under two different tenants
> 2. Provision and delete volumes on each
> 3. Confirm both tenants' deleted data is fully cleaned up, without one blocking the other
> 
> ### Why make this change?
> A tenant's deleted volume data could previously be left behind indefinitely if another tenant used the same filesystem name — a real risk in shared, multi-tenant clusters.

### <a name="pr-708"></a>PR #708 - feat: implement external volume health monitoring via WEKA REST API
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/708

> ### TL;DR
> Kubernetes can now detect and report when a volume's storage becomes unhealthy
> 
> ### What changed?
> - Periodic health checks for each volume against the Weka cluster
> - Unhealthy volumes surface as abnormal conditions on the PVC
> - Reports actual used capacity alongside health status
> - On by default, checks every 5 minutes; requires Weka 4.3+
> 
> ### How to test?
> 1. Deploy the CSI driver and create a PVC
> 2. Remove the volume's backing filesystem on the Weka cluster
> 3. Run `kubectl describe pvc <name>` and confirm an abnormal condition appears within 5 minutes
> 
> ### Why make this change?
> Previously Kubernetes couldn't tell if a volume's storage was still intact; problems went unnoticed until an application failed. This gives ongoing visibility into real volume health.
