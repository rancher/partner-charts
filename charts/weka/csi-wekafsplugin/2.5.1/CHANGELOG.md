<!-- Release notes generated using configuration in .github/release.yaml at main -->

## What's Changed
### Improvements
* feat(CSI-295): add affinity for controller and separated nodeSelector for controller and node by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/377
* feat(CSI-302): convert controller StatefulSet to Deployment by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/381
* feat(CSI-303): add livenessProbe to attacher sidecar by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/382
### Bug Fixes
* fix(CSI-294): caCertificate, NfsTargetIps, localContainerName are not hashed in API client by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/371
* fix(CSI-292): parse NFS version 3.0 to correctly pass it to mountoption by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/372
* fix(CSI-297): nfsTargetIps override is handled incorreclty when empty by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/374
* fix(CSI-296): node registration fails after switch transport from NFS to Wekafs due to label conflict by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/375
* feat(CSI-301): bump locar to version 0.4.2 by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/380
### Miscellaneous
* docs: fix the example of static provisioning of directory-backed volume by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/370
* chore(deps): update actions/checkout digest to 11bd719 by @renovate in https://github.com/weka/csi-wekafs/pull/352
* fix(deps): update kubernetes packages to v0.31.2 by @renovate in https://github.com/weka/csi-wekafs/pull/376
* chore(deps): update registry.k8s.io/kubernetes/kubectl to v1.31.2 by @renovate in https://github.com/weka/csi-wekafs/pull/373
* fix(deps): update golang.org/x/exp digest to f66d83c by @renovate in https://github.com/weka/csi-wekafs/pull/349
* fix(deps): update module github.com/prometheus/client_golang to v1.20.5 by @renovate in https://github.com/weka/csi-wekafs/pull/369

### Known limitations
* Due to current limitation of WEKA software, publishing snapshot-backed volumes via NFS transport is not supported and could result in `stale file handle` error when trying to access the volume contents from within the pod. 
  This limitation applies to both new snapshot-backed volumes and to any volumes that were cloned from existing PersistentVolume or Snapshot.

