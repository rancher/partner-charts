# What's Changed

### Chores
- **sysdig, node-analyzer** [17d2e503](https://github.com/sysdiglabs/charts/commit/17d2e50326f587b154f43beb706627416ca6a4b6): bump sysdig/vuln-runtime-scanner to v1.5.4 ([#1305](https://github.com/sysdiglabs/charts/issues/1305))

    * * Runtime Scanner bumped to 1.5.4
     * Fixed a misbehavior of the image layer analyzer, which could lead to non-existing software artifacts being reported in the SBOM as a result of incorrect handling of opaque directories (ESC-3511).
#### Full diff: https://github.com/sysdiglabs/charts/compare/sysdig-deploy-1.18.0...sysdig-1.16.8
