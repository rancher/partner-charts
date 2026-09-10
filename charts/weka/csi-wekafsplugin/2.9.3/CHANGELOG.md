## What's Changed

### Bug Fixes
* fix(CSI-353): take the actual SELinux state rather than the desired one by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/733 [(more details)](#pr-733)

---
<details>
<summary><b>PR Details</b></summary>

### <a name="pr-733"></a>PR #733 - fix(CSI-353): take the actual SELinux state rather than the desired one
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/733

> ### TL;DR
> On nodes that do not run SELinux, Weka mounts are no longer given an SELinux context (CSI-353).
> 
> ### What changed?
> - SELinux is detected from the node kernel's live state, not from a configuration file the plugin image carries its own copy of
> - Permissive nodes now count as SELinux-enabled
> - OpenShift and `selinuxSupport: enforced` are unchanged
> 
> ### How to test?
> 1. Deploy with the default `selinuxSupport: off` on nodes without SELinux
> 2. Create a PVC and attach it to a pod
> 3. On that node, run `mount | grep wekafs` — the options no longer contain `fscontext=` (`context=` for NFS)
> 4. Repeat with `selinuxSupport: enforced` on an SELinux node — the context is still applied
> 
> ### Why make this change?
> The plugin image ships its own SELinux configuration saying enforcing, so wherever the host's copy was not mounted over it the driver labelled every mount as if SELinux were on. Nothing failed, since a kernel without SELinux discards a context it cannot apply — but the mounts were labelled wrong from the start.

</details>
