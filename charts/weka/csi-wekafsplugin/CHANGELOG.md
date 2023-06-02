<!-- Release notes generated using configuration in .github/release.yaml at master -->
## What's Changed
Weka CSI Plugin v2.0.0 has a comprehensive set of improvenents and new functionality:
* Support of different backings for CSI volumes (filesystem, writable snapshot, directory)
* CSI snapshot and volume cloning support
* `fsGroup` support
* Custom mount options per storageClass
* Redundant CSI controllers
* Restructuring of CI and release workflows

> **NOTE:** some of the functionality provided by Weka CSI Plugin 2.0.0 requires Weka software of version 4.2 or higher. Please refer to [documentation](README.md) for additional information

> **NOTE:** To better understand the different types of volume backings and their implications, refer to documentation.

### New features
* feat: Support of new volumes from content source by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/11
* feat: Support Mount options by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/18
* feat: Add fsGroup support on CSI driver by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/20
* feat: Support different backing types for CSI volumes by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/69
* feat: official support for multiple controller server replicas by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/47
 
### Improvements
* feat: configurable log format (colorized human-readable logs or JSON structured logs) by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/26
* feat: OpenTelemetry tracing support by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/26
* feat: support of mutually exclusive mount options by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/54
* feat: Add concurrency limitation for multiple requests by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/56
* refactor: concurrency improvements by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/68

### Bug Fixes
* fix: Correctly calculate capacity for FS-based volume expansion (fixu… by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/15
* refactor: do not recover lost mounts and shorten default mountOptions by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/21
* fix: plugin might crash when trying to create dir-based volume on non… by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/29
* fix: CSI-47 Snapshot volumes run out of space after filling FS space by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/35
* fix: WEKAPP-298226 volumes published with ReadOnlyMany were writable by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/36
* fix: initial filesystem capacity conversion to bytes is invalid by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/38
* fix: loozen snapshot id validation for static provisioning by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/41
* fix: re-enable writecache by default by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/51
* fix: make sure op is written correctly for each function by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/67

### Miscellaneous
* style: add more logging to initial FS resize by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/37
* Add Helm linting and install test by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/13
* Push updated docs to main branch straight after PR merge by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/19
* docs: modify helm docs templates by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/22
* chore: add S3 chart upload GH task by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/23
* chore: auto increase version on feat git commit by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/24
* feat: Bump versions of packages by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/25
* chore: change docker build via native buildx GH action by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/27
* ci: add csi-sanity action to PRs by @dontbreakit in https://github.com/weka/csi-wekafs/pull/30
* ci: add release action by @dontbreakit in https://github.com/weka/csi-wekafs/pull/34
* docs: Improve documentation on mount options and different volume types by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/39
* chore: Bump CSI sidecar images to latest version by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/42
* docs: fix capacityEnforcement comment inside storageClass examples by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/46
* Add notifications to slack by @dontbreakit in https://github.com/weka/csi-wekafs/pull/53
* docs: Improve release.yaml to include additional PR labels by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/70

## Upgrade Implications
In order to support `fsGroup` functionality, the CSIDriver manifest had to be modified. Since this type of Kubernetes objects is defined as immutable, upgrading Helm release with the new version might fail.
Hence, when upgrading from version below 2.0.0, a complete uninstall and reinstall of Helm release is required. 
> NOTE: it is not required to remove any Secrets, storageClass definitions, PersistentVolumes or PersistentVolumeClaims.

## Deprecation Notice
Support of legacy volumes without API binding will be removed in next major release of Weka CSI Plugin. New features rely on API connectivity to Weka cluster and will not be supported on API unbound volumes. Please make sure to migrate all existing volumes to API based scheme prior to next version upgrade. 

