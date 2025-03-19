<!-- Release notes generated using configuration in .github/release.yaml at main -->
## What's Changed
This release provides stability fixes and minor improvements
### Bug Fixes
* fix(CSI-355): if user of role CSI cannot resolvePath via API, switch to mount by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/493
* fix(CSI-357): server default mount options take precedence over custom ones by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/495
### Improvements
* feat(CSI-356): avoid failback to xattr upon quota set error by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/494 
### Known limitations
* Due to current limitation of WEKA software, publishing snapshot-backed volumes via NFS transport is not supported and could result in stale file handle error when trying to access the volume contents from within the pod.
This limitation applies to both new snapshot-backed volumes and to any volumes that were cloned from existing PersistentVolume or Snapshot.

