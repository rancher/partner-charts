<!-- Release notes generated using configuration in .github/release.yaml at main -->

## What's Changed
### Improvements
* feat(CSI-376): improve lookup of local containers to rely on driver interface before REST API by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/551
### Bug Fixes
* fix(CSI-375): deletion of volume may be stuck if its contents were already trashed by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/550
* fix(CSI-377): node labels are cleaned up upon startup / termination even if labels managed externally by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/553
* fix(CSI-373): cannot mmap() on weka CSI volumes with SELinux enforced by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/554
### Miscellaneous
* chore(deps): update sidecars as of 2025-07-27 by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/556


