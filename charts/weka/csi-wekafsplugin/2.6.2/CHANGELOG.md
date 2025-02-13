<!-- Release notes generated using configuration in .github/release.yaml at main -->

## What's Changed
This version resolves issues that could occur during accessing CSI-published volumes on SELinux-enabled nodes.
Since the issue is related to switching to RedHat Universal Base Image (UBI9), the interim solution is to revert switching to UBI.
In the following versions, a better solution will be incorporated and the plugin will be again based on UBI9 image.

### Improvements
* refactor(CSI-272): move NFS client registration to APIClient startup rather than on each mount by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/436
* refactor(CSI-318): add configurable wait for filesystem / snapshot deletion by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/437
### Bug Fixes
* fix(CSI-322): revert CSI-309 migrate from Alpine to RedHat UBI9 base image by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/448
* fix(CSI-320): print raw entry in log when endpoint address fails to be parsed" by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/443
* fix(CSI-323): when snapshot of directory backed volumes is prohibited, incorrect error message is shown stating volume is legacy by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/449
### Miscellaneous
* chore(deps): optimize CSI sanity speed during CI by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/438


