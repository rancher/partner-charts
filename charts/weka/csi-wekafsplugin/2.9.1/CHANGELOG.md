## What's Changed

### Bug Fixes
* fix: reject malformed API endpoints and secrets instead of failing later by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/758 [(more details)](#pr-758)

### Documentation
* fix(ci): point helm-docs at the root README template by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/754 [(more details)](#pr-754)

### Miscellaneous
* ci: draft release notes on main only by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/757 [(more details)](#pr-757)
* chore(deps): update to Go 1.26 and current external libraries by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/759 [(more details)](#pr-759)
* chore(deps): update the UBI base image by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/760 [(more details)](#pr-760)
* chore(deps): update the CSI sidecars to their current releases by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/761 [(more details)](#pr-761)
* ci: add make update-sidecars and repair the Renovate config by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/762 [(more details)](#pr-762)
* ci: run the Go unit tests on every pull request by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/763 [(more details)](#pr-763)

---
## PR Details

### <a name="pr-754"></a>PR #754 - fix(ci): point helm-docs at the root README template
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/754

> ### TL;DR
> Restores the project README, which the v2.9.0 release overwrote with generated boilerplate.
> 
> ### What changed?
> - Restored the README sections the release removed: pre-requisites, deployment, usage, volume health monitoring, additional documentation and build instructions
> - Corrected the documentation-generator template path in the release, pull-request and push-dev workflows, so this cannot happen again
> 
> ### How to test?
> 1. Open the README on this branch and confirm every section is present, with the 2.9.0 version badges and value table.
> 2. On the next release, confirm the README changes only where the version and values changed.
> 
> ### Why make this change?
> The documentation generator was pointed at a template path that does not exist in this repository. Rather than failing, it fell back to its own default template and wrote that over the README, deleting 54 lines of hand-written documentation. The v2.9.0 release was the first to run this workflow to completion, so this is the first time it happened. Nothing was permanently lost — the source template still held every section. Nothing changes for anyone running the driver.

### <a name="pr-757"></a>PR #757 - ci: draft release notes on main only
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/757

> ### TL;DR
> Release note drafts are now produced for the release branch only, instead of once per merged change.
> 
> ### What changed?
> - A draft release is generated when something lands on `main`, and no longer when something lands on `dev`
> - Drafting any branch on demand still works, by running the workflow manually and naming the branch
> 
> ### How to test?
> 1. Merge a pull request into `dev` and confirm no draft release appears.
> 2. Merge `dev` into `main` and confirm a draft release is created.
> 3. Run the draft workflow manually against any branch and confirm it still produces a draft.
> 
> ### Why make this change?
> Development lands on `dev` continuously and is merged into `main` only when there is enough for a release. Drafting on every push to `dev` would create a draft release per merged pull request, burying the one that matters. Nothing changes for anyone running the driver.

### <a name="pr-758"></a>PR #758 - fix: reject malformed API endpoints and secrets instead of failing later
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/758

> ### TL;DR
> A malformed or incomplete API secret is now rejected with a message naming the problem, instead of failing later with a generic error.
> 
> ### What changed?
> - An endpoint that includes a URL scheme, or that is not a valid address, is rejected rather than quietly skipped
> - If no endpoint in a secret is usable, creating the API client fails immediately instead of producing a client with nothing to talk to
> - `username`, `password` and `organization` are now required in the secret, and a missing one is named in the error
> - Refreshing the endpoint list from the cluster will no longer replace a working set with an empty one
> 
> ### How to test?
> 1. Create an API secret whose `endpoints` value includes a scheme, for example `https://1.2.3.4:14000`.
> 2. Create a PVC using it, and confirm provisioning fails with an error naming the endpoint rather than a generic "no endpoints" message.
> 3. Repeat with `username` omitted from the secret and confirm the error names the missing key.
> 
> ### Why make this change?
> Endpoints that failed validation were skipped one by one, so a secret where every entry was malformed still produced an API client — just one with an empty endpoint list, which then failed at the first request, far from the secret that caused it. Missing credentials behaved the same way, defaulting to empty and surfacing later as an authentication failure. The error now arrives when the volume is created, and says which part of the secret is wrong.
> 
> 
> This is a rework of the fixes originally made in #615 and #617, reimplemented against the endpoint
> handling as it stands now, which was rewritten in the meantime. Neither of those pull requests
> recorded a ticket.

### <a name="pr-759"></a>PR #759 - chore(deps): update to Go 1.26 and current external libraries
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/759

> ### TL;DR
> Updates the driver to Go 1.26 and refreshes every third-party library it depends on.
> 
> ### What changed?
> - Built with Go 1.26, in both the driver image and the test harness image
> - Kubernetes client libraries, controller-runtime, gRPC, Prometheus and OpenTelemetry all moved to their current releases
> - One Kubernetes library was a version behind the others and now matches them
> 
> ### How to test?
> 1. Deploy the chart and confirm the driver starts and reports ready.
> 2. Create a PVC, confirm it binds, then delete it.
> 3. Take a snapshot and restore from it.
> 
> ### Why make this change?
> Routine currency: newer releases carry security and bug fixes, and staying close to upstream keeps each future update small. The CSI specification itself is deliberately not updated here — the newest version removes an interface the volume health reporting depends on, which is a decision of its own rather than a dependency bump.

### <a name="pr-760"></a>PR #760 - chore(deps): update the UBI base image
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/760

> ### TL;DR
> Rebuilds the driver images on the current Red Hat base image.
> 
> ### What changed?
> - The UBI 9 minimal base image moves to its latest build, in both the released image and the one used by CI
> 
> ### How to test?
> 1. Pull the resulting image and confirm the driver runs.
> 2. Confirm the base image build number in the image labels matches the one in the Dockerfile.
> 
> ### Why make this change?
> The pinned base image had fallen behind the current build, so images were being produced on an older base carrying older system packages. Both Dockerfiles pin it separately and have to move together, or the image CI tests differs from the image that ships.

### <a name="pr-761"></a>PR #761 - chore(deps): update the CSI sidecars to their current releases
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/761

> ### TL;DR
> Updates the Kubernetes CSI sidecar containers deployed alongside the driver.
> 
> ### What changed?
> - liveness probe, attacher, provisioner, node driver registrar, resizer, snapshotter and external health monitor all move to their current releases
> - No configuration change is required: every option the chart passes still exists, and no new permissions are needed
> 
> ### How to test?
> 1. Upgrade the chart and confirm all controller and node pods reach Running.
> 2. Create a PVC, expand it, snapshot it, and delete it.
> 3. Confirm no sidecar container restarts.
> 
> ### Why make this change?
> Routine currency, and these had drifted further behind than intended. Two things worth watching after upgrading: the provisioner now runs a periodic clean-up pass over snapshots in the cluster, which is new steady-state activity; and the external health monitor is at the last release that supports the volume health interface the driver implements today.

### <a name="pr-762"></a>PR #762 - ci: add make update-sidecars and repair the Renovate config
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/762

> ### TL;DR
> Adds a command that reports which CSI sidecars are out of date, and repairs the automation that was supposed to be doing it.
> 
> ### What changed?
> - `make update-sidecars` reports which sidecars are behind their latest release; `make update-sidecars APPLY=1` updates the chart
> - Fixed the automatic dependency configuration, which pointed at a directory that no longer exists and so had stopped updating anything
> - Added the two sidecars that were never covered by it
> 
> ### How to test?
> 1. Run `make update-sidecars` and confirm it reports every sidecar as current.
> 2. Edit one sidecar version in the chart to an older release and run it again; confirm it reports that one as behind and exits non-zero.
> 
> ### Why make this change?
> The sidecars had fallen several releases behind with nothing flagging it. The cause was that the automatic updater was watching a path left over from before the chart moved, so it silently matched no files. This repairs that and adds a check that does not depend on that configuration being correct.

### <a name="pr-763"></a>PR #763 - ci: run the Go unit tests on every pull request
by @sergeyberezansky in https://github.com/weka/csi-wekafs/pull/763

> ### TL;DR
> The Go unit tests now run automatically on every pull request.
> 
> ### What changed?
> - A new job runs the unit tests and the Go static checks on each pull request
> - It starts at the same time as the build rather than waiting for it, so a test failure is reported early
> - Tests run with the race detector enabled
> 
> ### How to test?
> 1. Open a pull request and confirm a `test-go` check appears alongside the build.
> 2. Push a commit that breaks a unit test and confirm the check fails.
> 
> ### Why make this change?
> Only the end-to-end storage tests ran automatically; the unit tests covering volume identifiers, the WEKA API client, quota handling and mount reference counting were run by hand, so a broken one could reach the branch unnoticed. The race detector matters here because most of those tests guard concurrent access, and without it a data race passes silently. The tests need no WEKA cluster and take about ninety seconds. Nothing changes for anyone running the driver.
