# partner-charts
This repository is reserved for partner charts in the Rancher's v2.5+ catalog.

As part of this catalog, all charts will benefit of a cloud native packaging system
that directly references an upstream chart from a helm repo and automates applying 
Rancher specific modifications and adding overlay files on top of it.

## Requirements
* Chart must be Helm v3 compatible

    A common cause for Helm v3 incompatibility is using the `crd-install` hook provided in Helm 2 for 
    the installation of CRDs. This hook was removed in v3 in favor of a `crds` directory where your 
    crds should now reside. Templating and upgrading crds is also no longer supported.

    More information:
    * Supported Hooks: https://helm.sh/docs/topics/charts_hooks/
    * Helm v2 to v3 migration: https://helm.sh/docs/topics/v2_v3_migration/
    * Managing CRDs and best practices: https://helm.sh/docs/chart_best_practices/custom_resource_definitions/

* Chart must be in a hosted Helm repository we can reference
    * The chart repository guide: https://helm.sh/docs/topics/chart_repository/

* Chart must have the following Rancher specific add-ons
    * partner label and annotations
    * app-readme.md
    * questions.yaml

## Workflow
### 1. Clone repository
Make sure to execute `make` commands from next steps at the top level

### 2. Create new chart (**SKIP IF UPGRADING EXISTING CHART**)
Run the following command to create a new chart
```
make create URL={REQUIRED_URL_TO_UPSTREAM_CHART}
```
If successful, a new directory for your chart will be created in `packages` like this.
Where `{CHART_NAME}` is replaced by the name of your chart.
```text
partner-charts
└── packages
    └── {CHART_NAME}
        ├── charts              # Auto generated regular helm repo, do not create
        ├── {CHART_NAME}.patch  # Contains `diff` between modified chart and upstream
        ├── overlay             # Overlay files to be added on top of upstream chart
        │   ├── app-readme.md
        │   └── questions.yaml
        └── package.yaml        # Metadata manifest containing upstream location version
```

**OPTIONAL:** A `CHART` parameter can be used to explicitly set the name of the chart directory, which
can be useful in cases where you want your chart to have a different name in our catalog. When left unset, 
a name is automatically generated using the basename of the `URL`.

```
make create URL={URL_TO_UPSTREAM_CHART} CHART={OPTIONAL_CHART_NAME}
```

### 3. Prepare for changes
```
make prepare CHART={CHART_NAME}
```
This will fetch the upstream chart (`URL` value stored in `package.yaml`), generate a `charts` directory, and prepare
it with the upstream chart and changes in the patch file.

### 4. Make changes
Any modifications to your upstream chart like **adding the partner label** will be done in the `charts` directory.

Add the partner label and required annotations in `Chart.yaml`:
```yaml
annotations:
  catalog.cattle.io/certified: partner
  catalog.cattle.io/namespace: {CHART_NAMESPACE}       # Your chart's name is recommended
  catalog.cattle.io/release-name: {CHART_RELEASE_NAME} # Your chart's name is recommended
```

Save all your changes in the patch once you are done
```
make patch CHART={CHART_NAME}
```

### 5. Add Overlay Files
Any files you want to add on top of your upstream chart such as Rancher add-ons and logo (if you prefer keeping a local 
copy), should be placed in the `overlay` directory.

If this is a new chart, you will need to update the following:

* `app-readme.md` - Write a brief description of the app and how to use it. Is recommended to keep it short as the longer
 `README.md` in your chart will be displayed in the UI as “detailed description”.

* `questions.yaml` - These are the questions displayed in the chart's installation page, which answers are used to configure 
the chart by populating its `values.yaml`. Generally, the questions are focused on covering common use cases and include 
default values so users can install the chart with little effort.

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

### 6. Test your changes

#### Generate modified chart
To test your modified chart you will first need to generate it. The result is a tarball containing your upstream chart 
with patch changes applied, and overlay files added on top of it. It will be located in the `assets` directory and its
name will be the same as the upstream chart, but the value of `packageVersion` from `package.yaml` is appended to
it as following `{CHART_NAME}-{VERSION}{packageVersion}.tgz`. 

This will validate and generate a tarball of your modified chart
```
make validate CHART={CHART_NAME}
```

Alternatively, this will skip validation and just generate the tarball of your modified chart (Validating it before submitting a pull request is recommended)
```
make charts CHART={CHART_NAME}
```

#### Test modified chart

An easy way to test your chart is by hosting the `assets` directory (Make sure you generate the tarball first) using 
`python -m SimpleHTTPServer`, expose it using `ngrok`, and use the `ngrok` URL to add the chart as a custom catalog in Rancher.

### 7. Pull Request

Before staging your changes, clean up your chart's directory. This will delete the `charts` directory, so make sure you 
generate a new patch with your changes before doing this.

```
make clean CHART={CHART_NAME}
```

At this point, you are ready to submit a pull request.
All the contents of you chart directory should be commited, except the `charts` directory.

#### Hotfix
Our CI doesn't allow modifying existing charts, therefore bumping a chart's version after modifying it is required.
We understand there are cases a hotfix might be better suited, and although is not recommended, the option to override 
a chart may be used. To override an existing chart, delete the tarball in the `assets` directory, and commit it along 
with the replacement chart of the same `packageVersion` as the one deleted.
