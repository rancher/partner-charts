# partner-charts

This repository is reserved for partner charts in the Rancher's v2.5+ catalog. As part of this catalog,
all charts will benefit of a cloud native packaging system that directly references an upstream chart
from a Helm repository and automates applying Rancher specific modifications and adding overlay
files on top of it.

## Requirements

* Chart must be Helm 3 compatible.

    Helm 2 installed CRDs via an `helm.sh/hook: crd-install` annotation that installed 
    CRDs via a special hook. In Helm 3, this annotation was removed in favor of a `crds/` 
    directory where your CRDs should now reside. Templating and upgrading CRDs is also no 
    longer supported by default. Users who need to support templating / upgrading CRDs should 
    use a separate CRD chart that installs the CRDs via the `templates/` directory instead. 
    Leaving this hook in your chart will not cause it to break, but will cause the Helm logs 
    to emit the warning `manifest_sorter.go:175: info: skipping unknown hook: "crd-install"` 
    on an install or upgrade. 

    More information:
    * Supported Hooks: https://helm.sh/docs/topics/charts_hooks/
    * Helm 2 to 3 migration: https://helm.sh/docs/topics/v2_v3_migration/
    * Managing CRDs and best practices: https://helm.sh/docs/chart_best_practices/custom_resource_definitions/

* Chart must be in a hosted [Helm repository](https://helm.sh/docs/topics/chart_repository/) that we can reference.

* Chart must have the following Rancher specific add-ons (More details on this below).
    * Rancher Labels & Annotations for Partners
    * app-readme.md
    * questions.yaml

## Workflow

### 1. Fork the repository

After forking the repository, checkout the `main-source` branch and pull the latest changes. 
Then create a new branch from it (e.g. `git checkout -b <name-of-new-branch>`) and execute 
`make` commands from next steps at the repository's root level.

### 2. Track a new upstream chart as a package (**SKIP if upgrading existing package**)

Create a package in the `packages` directory by following this structure (Replace `{CHART_NAME}` with
the name of the upstream chart).

```text
partner-charts                  # Repo root level
└── packages
    └── {CHART_NAME}
        ├── overlay             # Overlay files to be added on top of upstream chart
        │   ├── app-readme.md
        │   └── questions.yaml
        └── package.yaml        # Metadata manifest containing upstream location version
```

Track the upstream chart by setting these values in `package.yaml`:

- `URL` - the URL that references you chart's tarball hosted in a Helm repository.

- `packageVersion` - The version of the package. This is appended to your chart's version 
in the form `{CHART_NAME}-{VERSION}{packageVersion}.tgz` after repackaging.

#### Example `package.yaml`

This example is repackaged as `chart-v0.1.200.tgz` after modifications are applied.

```yaml
url: https://example.com/helm-repo/chart-v0.1.2.tgz
packageVersion: 00
```

### 3. Prepare for changes

Run to pull in the upstream chart tracked by the `package.yaml`. If a patch file is defined,
it will be applied onto the upstream chart after it is pulled in as part of the `prepare` step.

```
make prepare CHART={CHART_NAME}
```

### 4. Make changes

Any modifications to your upstream chart like **adding the partner label** will be done in 
the auto-generated `charts` directory.

If this is a new chart, add the partner label and required annotations in `Chart.yaml`:

```yaml
annotations:
  catalog.cattle.io/certified: partner
  catalog.cattle.io/release-name: {CHART_RELEASE_NAME} # Your chart's name is recommended
```

Run to save the changes to a `{CHART_NAME}.patch` file once you are done making changes.
This file will automatically be created if any changes are detected and will be used to
set up the chart on a make prepare in a future change.

```
make patch CHART={CHART_NAME}
```

### 5. Add Overlay Files

Any files you want to add on top of your upstream chart such as Rancher add-ons and logo
(if you prefer keeping a local copy), should be placed in the `overlay` directory.

If this is a new chart, you will need the following:

- `app-readme.md` - Write a brief description of the app and how to use it. It's recommended to keep
it short as the longer `README.md` in your chart will be displayed in the UI as detailed description.

- `questions.yaml` - Allows you to define a set of questions that user can provide answers to.
These questions will be displayed on the chart's installation page to make it easier for a user
to configure common use cases / set default values exposed by the chart's `values.yaml` so that
users can install the chart with little effort.

#### Questions Example

```yaml
questions: 
- variable: password
  default: ""
  required: true
  type: password
  label: Admin Password
  group: "Global Settings"
- variable: service.type
  default: "ClusterIP"
  type: enum
  group: "Service Settings"
  options:
    - "ClusterIP"
    - "NodePort"
    - "LoadBalancer"
  required: true
  label: Service Type
  show_subquestion_if: "NodePort"
  subquestions:
  - variable: service.nodePort
    default: ""
    description: "NodePort port number (to set explicitly, choose port between 30000-32767)"
    type: int
    min: 30000
    max: 32767
    label: Service NodePort
```

#### Questions Variable Reference

| Variable  | Type | Required | Description |
| ------------- | ------------- | --- |------------- |
| 	variable          | string  | true    |  define the variable name specified in the `values.yaml`file, using `foo.bar` for nested object. |
| 	label             | string  | true      |  define the UI label. |
| 	description       | string  | false      |  specify the description of the variable.|
| 	type              | string  | false      |  default to `string` if not specified (current supported types are string, multiline, boolean, int, enum, password, storageclass, hostname, pvc, and secret).|
| 	required          | bool    | false      |  define if the variable is required or not (true \| false)|
| 	default           | string  | false      |  specify the default value. |
| 	group             | string  | false      |  group questions by input value. |
| 	min_length        | int     | false      | min character length.|
| 	max_length        | int     | false      | max character length.|
| 	min               | int     | false      |  min integer length. |
| 	max               | int     | false      |  max integer length. |
| 	options           | []string | false     |  specify the options when the vriable type is `enum`, for example: options:<br> - "ClusterIP" <br> - "NodePort" <br> - "LoadBalancer"|
| 	valid_chars       | string   | false     |  regular expression for input chars validation. |
| 	invalid_chars     | string   | false     |  regular expression for invalid input chars validation.|
| 	subquestions      | []subquestion | false|  add an array of subquestions.|
| 	show_if           | string      | false  | show current variable if conditional variable is true, for example `show_if: "serviceType=Nodeport"` |
| 	show\_subquestion_if |  string  | false     | show subquestions if is true or equal to one of the options. for example `show_subquestion_if: "true"`|

**subquestions**: `subquestions[]` cannot contain `subquestions` or `show_subquestions_if` keys, but all other keys in the above table are supported. 

### 6. Update package to track new upstream (Maintenance)

There are two ways you can update a package, one is to track a new updated upstream chart
and the other is to do small modifications/fixes.

#### Update package to track a new upstream chart

Update the `url` to reference the new upstream chart and reset the `packageVersion` to `00` in `package.yaml`, in order for `make prepare CHART={CHART_NAME}` to pull in the new upstream chart and apply the patch if one exists. You might need to run `make patch CHART={CHART_NAME}` to ensure the patch can be applied on the new upstream. If applying the patch fails, there's currently no method for rebasing to a new upstream when the patch gets broken as a result.

For example, an existing package tracking an upstream chart `url: https://example.com/helm-repo/chart-v0.1.2.tgz`
can be updated to track the new `url: https://example.com/helm-repo/chart-v0.1.3.tgz`, and a new package 
`chart-v0.1.300.tgz` will be generated.

```yaml
url: https://example.com/helm-repo/chart-v0.1.3.tgz
packageVersion: 00
```

#### Update existing package to introduce a small change

Increase the `packageVersion` in `package.yaml` without updating the `url`. This will
create a new version of a package tracking the same upstream chart.

For example, an existing package tracking an upstream chart `url: https://example.com/helm-repo/chart-v0.1.2.tgz`
generated a package `chart-v0.1.200.tgz`. Increasing the `packageVersion` without changing the `url`
will generate a new package `chart-v0.1.201.tgz` based off of the same upstream chart.

### 7. Test your changes

#### Generate modified chart

Run to validate the chart and generate a tarball of your modified chart.

```
make validate CHART={CHART_NAME}
```

This will create the following two directories, and several files (e.g. `index.html`, `index.yaml`, etc.) 
to set up a Helm repo in your current branch.

- `charts/{CHART_NAME}/` - Contains an unarchived version of your modified chart
- `assets/{CHART_NAME}/` - Contains an archived (tarball) version of your modified chart 
named `{CHART_NAME}-{VERSION}{packageVersion}.tgz`

Alternatively, this will skip validation and just generate the tarball of your modified chart.

```
make charts CHART={CHART_NAME}
```

#### Test modified chart
To test your changes, just push the generated files to your fork as a separate commit and add your
fork / branch as a Repository in the Dashboard UI. Your chart will then show up as an App in 
`Apps & Marketplace` under the Repository that you configured.Make sure that you revert the generated files commit before submitting a PR!

Alternatively, Python and Ngrok can be used if you rather avoid the push and revert commit approach. Use `python -m SimpleHTTPServer` to host the generated files locally, and expose them using Ngrok. Then add the Ngrok URL as a Repository in the Dashboard UI the same way you would add a fork / branch.

### 8. Pull Request

Run to clean up your working directory before staging your changes.

*Note: Any changes added to `packages/{CHART_NAME}/charts` will be lost when you run `make clean`, so always make sure to run `make patch CHART={CHART_NAME}` to save your changes before running `make clean`.*

```
make clean CHART={CHART_NAME}
```

Ensure that you've already saved your changes with `make patch CHART={CHART_NAME}` and cleaned up your working directory with `make clean`. Then, commit all the remaining changes to `packages/{CHART_NAME}` and submit your PR to the branch `main-source`.
