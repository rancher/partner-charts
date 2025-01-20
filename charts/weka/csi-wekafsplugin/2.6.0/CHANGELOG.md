<!-- Release notes generated using configuration in .github/release.yaml at main -->

## What's Changed
### New features
* feat(CSI-300): add arm64 support by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/379* 
* feat(CSI-312): add topology awareness by providing accessibleTopology in PV creation by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/426
* feat(CSI-313): add configuration for skipping out-of-band volume garbage collection by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/427
### Improvements
* feat(CSI-310): drop container_name mount option from volume context by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/408
* feat(CSI-311): add CSI driver version used for provisioning a PV into volumeContext by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/409
* feat(CSI-308): add support for ReadWriteOncePod, ReadOnlyOncePod by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/399
* feat(CSI-309): migrate from Alpine to RedHat UBI9 base image by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/400
### Bug fixes
* refactor(CSI-305): change mount Map logic for WEKAFS to align with NFS and support same fs name on SCMC by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/383
* chore(deps): improve the way of locar to delete multi-depth directories by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/422
* fix(CSI-306): compatibility for sync_on_close not logged by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/395
### Miscellaneous
* chore(deps): add LICENSE to UBI /licenses by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/418
* chore(deps): update golang dependencies as of 2024-12-09 by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/410
* chore(deps): update helm/kind-action action to v1.12.0 by @renovate in https://github.com/weka/csi-wekafs/pull/414
* chore(deps): update registry.access.redhat.com/ubi9/ubi to v9.5-1736404036 by @renovate in https://github.com/weka/csi-wekafs/pull/421
* fix(deps): update golang.org/x/exp digest to 7588d65 by @renovate in https://github.com/weka/csi-wekafs/pull/407
* fix(deps): update module google.golang.org/grpc to v1.69.4 by @renovate in https://github.com/weka/csi-wekafs/pull/406
* fix(deps): update module google.golang.org/protobuf to v1.36.2 by @renovate in https://github.com/weka/csi-wekafs/pull/415
* chore(deps): add labels to CSI Docker image by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/425
* chore(deps): update go dependencies as of 2025-01-19 by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/429


