## What's Changed

### Bug Fixes
* fix: make "-option" mount overrides actually remove the option by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/818 [(more details)](#pr-818)

### Documentation
* docs: explain sync_on_close, and correct the order mount options are applied in by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/820 [(more details)](#pr-820)

---
<details>
<summary><b>PR Details</b></summary>

### <a name="pr-818"></a>PR #818 - fix: make "-option" mount overrides actually remove the option
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/818

> ### TL;DR
> `-sync_on_close` in a PVC or pod annotation now actually removes the option, and a Weka version that cannot accept an option no longer gets it anyway.
> 
> ### What changed?
> - A `-option` mount override is recorded as an exclusion, so it survives the driver defaults being merged in afterwards; a later `+option` still puts it back
> - `sync_on_close` is now dropped from the options actually mounted with on clusters below Weka v4.2, instead of being pruned and then re-added by the defaults
> - `ro` and `container_name` are still refused when supplied as custom mount options, and are now also refused when supplied through an annotation override
> - The documented order of application was wrong about when the defaults apply; corrected
> 
> ### How to test?
> 1. Set `allowMountOptionOverrides: true` and annotate a PVC with `weka.io/mount-options-override: -sync_on_close`
> 2. Create a pod using that PVC
> 3. On the node, run `mount | grep wekafs` — the options should no longer contain `sync_on_close`
> 4. Change the annotation to `-sync_on_close,+sync_on_close` and remount — it should be present again
> 5. Attach a volume read-only and check the mount still carries `ro`
> 
> ### Why make this change?
> Removing an option only worked if it came from the StorageClass. Anything the driver adds by default — `sync_on_close`, `writecache` — was silently put back after the override ran, so the annotation appeared to be ignored with nothing in the log to explain it. The same gap meant a cluster too old for `sync_on_close` was still mounted with it.
> 
> <!-- CURSOR_SUMMARY -->
> ---
> 
> > [!NOTE]
> > **Medium Risk**
> > Changes what mount flags actually reach the kernel for published volumes, including readonly and cluster-version gating, though logic is heavily tested and scoped to option assembly.
> >
> > **Overview**
> > **`-option` overrides (PVC/pod annotations) now stick** by recording removals in `excludeOptions` via new `ExcludeOption` / `UnexcludeOption`, instead of only deleting from the volume’s option set. That matters because node defaults are merged **under** volume options at `MountUnderlyingFS`, which previously reintroduced options like `sync_on_close` and `writecache` after an override.
> >
> > Override parsing uses **`ExcludeOption` for `-opt`** and **`UnexcludeOption` before adds** so `-opt,+opt` and valued options behave correctly; readonly attachment uses `ExcludeOption("rw")` when adding `ro`.
> >
> > **Pruning is split and re-timed:** cluster-capability drops (e.g. `sync_on_close` on old Weka) run on the **fully merged** options at mount time; user-forbidden options (`ro`, `container_name`) are stripped only on user/annotation layers, with an extra prune in `NodePublishVolume` after overrides so annotations cannot bypass those rules.
> >
> > Documentation in `constants.go` updates the mount-option application order; broad unit tests cover exclusion, defaults merge, and the full cache-option pipeline.
> >
> > <sup>Reviewed by [Cursor Bugbot](https://cursor.com/bugbot) for commit 2833fec02cf2264f0fd1b8309104b8fb32a83e52. Bugbot is set up for automated code reviews on this repo. Configure [here](https://www.cursor.com/dashboard/bugbot).</sup>
> <!-- /CURSOR_SUMMARY -->

### <a name="pr-820"></a>PR #820 - docs: explain sync_on_close, and correct the order mount options are applied in
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/820

> ### TL;DR
> 
> Documents why `sync_on_close` is a default mount option, what you lose by removing it, and the fact that it can only be removed per-PVC or per-Pod.
> 
> ### What changed?
> 
> - A new section in the usage guide explaining `sync_on_close`: the silent data truncation it prevents, why Kubernetes makes that failure worse than it is elsewhere, and the two conditions under which removing it is reasonable.
> - `sync_on_close` added to the list of common mount options.
> - Corrected the documented order in which mount options are applied. The node defaults were listed as applied second; they are actually merged underneath everything else, which is what makes `-option` removals in an annotation take effect.
> - A worked example of removing `sync_on_close`, in both the PVC and Pod forms, plus a runnable `examples/mount_options/sync-on-close-override.yaml`. `sync_on_close` was not mentioned in the examples README at all; it now is.
> - Documentation only. No behaviour changes.
> 
> ### How to test?
> 
> Read `docs/usage.md`, section "The `sync_on_close` option". To confirm the documented rule that it cannot be removed from a StorageClass: set `sync_on_close` in a StorageClass and check a resulting mount with `mount | grep wekafs` — it is unaffected either way. Then apply `examples/mount_options/sync-on-close-override.yaml` and run `kubectl exec csi-app-sync-on-close-override -- mount -t wekafs` — `sync_on_close` is absent on `/scratch` and present on `/results`.
> 
> ### Why make this change?
> 
> Nothing recorded why `sync_on_close` is enabled by default, so it read like an ordinary performance tunable that could be traded away. It is not. Without it, a write can succeed while the filesystem or the volume quota is already full, the out-of-space error arrives out of band, and the application is never told its data was truncated. In Kubernetes one exhausted filesystem affects every directory- and snapshot-backed volume on it at once, and the exhaustion warning usually reaches storage administrators rather than the people running the workloads. Operators need that written down before they decide to override it.
> 
> <!-- CURSOR_SUMMARY -->
> ---
> 
> > [!NOTE]
> > **Low Risk**
> > Markdown and example YAML only; no changes to CSI mount logic or runtime configuration.
> >
> > **Overview**
> > This PR is **documentation only**—no driver behavior changes.
> >
> > **`docs/usage.md`** adds a dedicated section on **`sync_on_close`**: why the CSI driver enables it by default (synchronous flush at `close()` so full-filesystem/quota write failures surface to the app instead of silent truncation), why that risk is worse in Kubernetes, and that removal is supported **only** via PVC or Pod override annotations—not StorageClass. It also **corrects mount-option precedence**: node defaults are merged *underneath* StorageClass, PVC, Pod, and read-only settings so `-option` removals still win after defaults apply; the worked example now ends with `sync_on_close` on the final mount. A new practical example covers PVC- vs pod-regex-level removal for scratch vs durable volumes.
> >
> > **Examples**: `examples/mount_options/sync-on-close-override.yaml` is new; `examples/mount_options/README.md` documents the option, the warning, and a workflow to verify with `mount -t wekafs`.
> >
> > <sup>Reviewed by [Cursor Bugbot](https://cursor.com/bugbot) for commit 650a12593dec4de3affc1844a5a216e6b3f9c07c. Bugbot is set up for automated code reviews on this repo. Configure [here](https://www.cursor.com/dashboard/bugbot).</sup>
> <!-- /CURSOR_SUMMARY -->

</details>
