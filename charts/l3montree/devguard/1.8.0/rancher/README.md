# Rancher Partner Charts

This chart is distributed via [rancher/partner-charts](https://github.com/rancher/partner-charts). To pull in a new upstream version, run in the partner-charts repo:

```bash
scripts/pull-scripts # download the partner-charts-ci binary (only once per setup/computer)
PACKAGE=l3montree/devguard bin/partner-charts-ci update
bin/partner-charts-ci validate
```

## Updating questions.yaml

`questions.yaml` is generated from [`schema/schema.ts`](../schema/schema.ts) in this repo. After changing the schema, regenerate it (this also writes to the partner-charts overlay):

```bash
cd schema
bun run generate.ts
```

The partner-charts CI only regenerates a chart version when its template version is bumped. To update `questions.yaml` for an already-generated version instead, delete that version and regenerate it (example for 1.7.0):

```bash
rm -f assets/l3montree/devguard-1.7.0.tgz
rm -rf charts/l3montree/devguard/1.7.0
# remove the 1.7.0 entry from index.yaml
PACKAGE=l3montree/devguard bin/partner-charts-ci update
```

After that you might have to delete the repo inside Rancher and re-add it for the updated information to show up.

## Testing in a local Rancher

To test and validate the charts end-to-end, run a local Rancher instance — see [Rancher-Setup.md](Rancher-Setup.md) for how to set it up.
