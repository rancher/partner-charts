# Rancher Partner Charts Repository

The Rancher Partner Charts Repository is a collection of helm charts from
SUSE partners that are certified to run on Rancher-supported Kubernetes
distributions. Users can deploy these charts directly from the Apps view in
Rancher Manager. Minor Rancher-specific modifications are added to these charts
in order to provide the best possible experience using them from within Rancher.

[`partner-charts-ci`](https://github.com/rancher/partner-charts-ci) is used to
automate many aspects of this repository. For the technical details of this
repository, please consult the `partner-charts-ci` documentation.


### What are the requirements for adding a project to this repository?

Before submitting a chart to this repository, you must become a
[SUSE "Ready" Verified partner](https://www.suse.com/product-certification/ready/certify-your-applications/).
You can start this process with a [Partner Application](https://partner.suse.com/s/apply).

To certify your software as SUSE "Ready", you need to attest that the software:

* has been tested on RKE2 or K3s and publishes documentation showing supported
  versions, including
  * version of Rancher (e.g. 2.8) 
  * Rancher-supported distribution of Kubernetes (RKE2, K3s, EKS, etc.)
  * version of Kubernetes (e.g. 1.27)
* is supported by your organization on the declared Rancher versions and configurations
* is actively maintained and proactively updated
  * critical vulnerabilities are patched in a timely way
  * release notes disclose serious bugs and vulnerabilities
* has a license and/or terms and conditions for use available in public
  documentation or via the chart itself
* does not compete commercially with Rancher Prime

Once your software is certified as SUSE "Ready", there are a few more requirements
for inclusion in this repository. Your software's helm chart must:

* be helm 3 compatible
* be available from a public [helm repository](https://helm.sh/docs/topics/chart_repository/)
  (recommended) or a public git repository
* have `kubeVersion` set in the chart's metadata
* contain an `app-readme.md` file (refer to the [`partner-charts-ci` documentation](https://github.com/rancher/partner-charts-ci) for more details)
* be deployable from the current version of Rancher with the default values

Meeting these requirements ensures that Rancher users can easily deploy your
software.

> [!NOTE]
> This repository is not intended for certain kinds of software. For example:
>
> * slightly modified software or helm charts that meet the needs of only a
>   few people
> * software maintained by an open source community without any backing
>   organization with which SUSE can have a partnership


### How do I add my project to this repository?

In order to add a helm chart to this repository:

1. Fork this repository.
2. Follow the process for adding a package as described in the
[`partner-charts-ci` documentation](https://github.com/rancher/partner-charts-ci).
`partner-charts-ci` can be obtained by running `scripts/pull-scripts`, which
downloads the right version for your machine to `bin/partner-charts-ci`.
3. Create a pull request for your changes targeting the `main-source` branch in
this repository. **Please ensure that your pull request only contains changes
related to the package that you are adding.** The `PACKAGE` environment variable
is useful for this; for more information please see the `partner-charts-ci`
documentation.


### Who is responsible for maintaining the helm charts in this repository?

Each SUSE partner organzation is responsible for maintaining the versions
of their helm charts in this repository. However, SUSE also monitors this
repository and may make changes if necessary.


### When and how are helm charts removed from this repository?

Charts may be removed from this repository for a number of reasons:

* Technical requirements are not met
* A serious security problem is discovered
* The vendor's SUSE "Ready" partnership is no longer active

In these cases, the chart will first be deprecated. While a chart is deprecated,
no new versions of the chart will be added to this repository. The chart will
be left in the deprecated state for a minimum of 3 months, and then it will be
removed. The pull requests that deprecate and remove the chart will indicate an
alternative source (e.g. the corresponding upstream project or [Rancher Prime
Application Collection](https://apps.rancher.io)) if one is available.
