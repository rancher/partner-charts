## What's Changed

### Improvements
* feat: allow a separate priorityClassName for controller and node components by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/778 [(more details)](#pr-778)

### Bug Fixes
* fix(chart): use the configured logLevel for the csi-snapshotter sidecar by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/779 [(more details)](#pr-779)
* fix: give every container port a name unique within its pod by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/792 [(more details)](#pr-792)
* fix: stop the driver panicking when it cannot determine volume encryption by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/793 [(more details)](#pr-793)
* docs: show a Source Code link on the chart page by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/794 [(more details)](#pr-794)

---
<details>
<summary><b>PR Details</b></summary>

### <a name="pr-778"></a>PR #778 - feat: allow a separate priorityClassName for controller and node components
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/778

> ### TL;DR
> The controller and the node pods can now be given different priority classes.
> 
> ### What changed?
> - New chart values `controller.priorityClassName` and `node.priorityClassName`.
> - Either one overrides the existing global `priorityClassName` for its own pods. Left unset, both inherit it, so nothing changes for an existing installation.
> 
> ### How to test?
> 1. Install with `--set controller.priorityClassName=system-cluster-critical --set node.priorityClassName=system-node-critical`.
> 2. Confirm `kubectl get deploy,ds -n csi-wekafs -o custom-columns=NAME:.metadata.name,PC:.spec.template.spec.priorityClassName` shows the two different classes.
> 3. Install with only the global `priorityClassName` set and confirm both components still use it.
> 
> ### Why make this change?
> Requested in issue #691. A controller Deployment and a node DaemonSet have different scheduling requirements — the usual pairing is `system-cluster-critical` for the controller and `system-node-critical` for the node — and a single global value could only ever express one of them. Setting a per-component value replaces the global one rather than being combined with it, since a priority class is a single name.

### <a name="pr-779"></a>PR #779 - fix(chart): use the configured logLevel for the csi-snapshotter sidecar
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/779

> ### TL;DR
> `logLevel` now applies to the snapshotter sidecar too, instead of it always logging at level 5.
> 
> ### What changed?
> - The `csi-snapshotter` container's verbosity came from a value written into the template rather than from `logLevel`. It now follows `logLevel` like every other container.
> - No change at the default: the hardcoded value and the default are both 5.
> 
> ### How to test?
> 1. Install with `--set logLevel=2`.
> 2. Run `kubectl get deploy <release>-controller -o yaml` and confirm the `csi-snapshotter` container is started with `--v=2`.
> 3. Confirm its logs are correspondingly quieter.
> 
> ### Why make this change?
> Reported in issue #687. Turning `logLevel` down quieted every container except the snapshotter, which kept logging at 5 — and on a busy controller that was most of the remaining log volume. While fixing it we checked every other container in both charts; this was the only one whose log level was not configurable.

### <a name="pr-792"></a>PR #792 - fix: give every container port a name unique within its pod
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/792

> ### TL;DR
> 
> Fixes duplicate container port names in the node and controller pods, which could send metrics scrapes to the wrong sidecar.
> 
> ### What changed?
> 
> - In the node DaemonSet, the two ports both named `healthz` are now `ns-healthz` (9899, node driver) and `reg-healthz` (9809, registrar).
> - In the controller Deployment, the attacher metrics port is renamed from `pr-metrics` to `at-metrics`. The provisioner keeps `pr-metrics`.
> - The liveness probes that referenced these ports by name were updated to match.
> 
> No ports, values or defaults change — only names.
> 
> ### How to test?
> 
> 1. Install or upgrade the chart with `metrics.enabled=true`.
> 2. Run `kubectl get pod <node-pod> -o jsonpath='{.spec.containers[*].ports[*].name}'` and confirm `ns-healthz` and `reg-healthz` appear instead of `healthz` twice.
> 3. Do the same for a controller pod and confirm `at-metrics` and `pr-metrics` are distinct.
> 4. Confirm both pods stay healthy — the liveness probes resolve the renamed ports.
> 
> ### Why make this change?
> 
> A port name must be unique across a whole pod, not just within one container. Two pods reused a name, so anything resolving a port by name — a Service `targetPort`, a `PodMonitor` port selector — would get whichever one the cluster happened to keep. Metrics could be scraped from the wrong sidecar, or missed. Nothing in the chart selects by these names today, which is why it went unnoticed, but it makes the ports unsafe to reference.
> 
> Original fix by @assafgi in #682, reworked with the shorter names already used in the 3.0 branch so a second set of names does not follow behind it.

### <a name="pr-793"></a>PR #793 - fix: stop the driver panicking when it cannot determine volume encryption
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/793

> ### TL;DR
> 
> Fixes a crash: the driver could panic when checking whether a volume is encrypted, taking the process down.
> 
> ### What changed?
> 
> - Checking encryption on a filesystem-backed volume with no API credentials bound now returns a clear error instead of crashing.
> - The error says the encryption state could not be determined, and includes the underlying reason when there is one.
> - Volume creation that needs this answer fails with an `Internal` error rather than continuing.
> 
> ### How to test?
> 
> 1. Create a volume backed by a whole filesystem whose storage class has no API secret attached.
> 2. Perform an operation that touches encryption on it — for example creating a volume from it.
> 3. Confirm the driver reports an error and keeps running, rather than the controller pod restarting.
> 
> Automated coverage is included: the new test reproduces the crash against the unfixed code.
> 
> ### Why make this change?
> 
> The check ended by reading a value that was not always set. For a filesystem-backed volume with no API client, the driver has no way to ask the cluster whether the volume is encrypted, so nothing filled that value in and reading it crashed the process.
> 
> Reporting an error is the safe answer rather than assuming "not encrypted". Callers use this to decide whether to apply encryption, so a volume whose state could not be read would otherwise be treated as one that had been read and found unencrypted.
> 
> Found by @kristina-solovyova in #692.

### <a name="pr-794"></a>PR #794 - docs: show a Source Code link on the chart page
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/794

> ### TL;DR
> 
> The chart page now shows a **Source Code** link, pointing at the tag the chart was built from.
> 
> ### What changed?
> 
> - The chart README and the ArtifactHub listing render a `## Source Code` section, taken from the `sources` entry already in `Chart.yaml`.
> - Fixed the source URL recorded by PR-built charts, which contained the literal text `$CHART_VERSION` instead of the version number. Released charts were not affected.
> 
> ### How to test?
> 
> 1. Open `charts/csi-wekafsplugin/README.md` and confirm a **Source Code** section appears under **Maintainers**, with a link ending in the chart version.
> 2. On a PR build, run `helm show chart <chart>` and confirm the `sources` URL contains a version number rather than `$CHART_VERSION`.
> 
> ### Why make this change?
> 
> `Chart.yaml` has always recorded where the chart comes from, but nothing displayed it, so the published chart page gave no link back to the source at that version. Rendering it from `Chart.yaml` means it follows the value the release process already maintains, rather than becoming another thing to update by hand.
> 
> Both sections were originally raised by @ari in #582.

</details>
