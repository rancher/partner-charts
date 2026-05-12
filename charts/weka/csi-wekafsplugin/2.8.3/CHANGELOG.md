<!-- Release notes generated using configuration in .github/release.yaml at main -->

## What's Changed
### Bug Fixes
* fix: remove semconv schema attributes from otel trace provider by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/662
* fix: update OCP SecurityContextConstraints to allow emptyDir volume type by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/661
* fix: propagate unmount func errors, fix decRef order, isolate mount paths by CSI role by @kristina-solovyova in https://github.com/weka/csi-wekafs/pull/659
* fix: prevent liveness probe from hanging on unresponsive WekaFS, propagate context (CSI-412) by @kristina-solovyova in https://github.com/weka/csi-wekafs/pull/660
* fix: mount selinux filesystem in node server daemonset to correctly manage labels in UBI image by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/676
### Miscellaneous
* chore: trigger sanity workflow on ready_for_review events by @kristina-solovyova in https://github.com/weka/csi-wekafs/pull/663
* docs: add OCP namespace pod-security label instructions, regenerate readme by @kristina-solovyova in https://github.com/weka/csi-wekafs/pull/675


