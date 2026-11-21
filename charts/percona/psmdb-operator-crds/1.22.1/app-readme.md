# Percona Operator for MongoDB CRDs

This chart installs only the Custom Resource Definitions (CRDs) of the Percona
Operator for MongoDB, so they can be upgraded independently of the operator:
Helm never upgrades CRDs shipped in the operator chart. Install it **before**
the Percona Operator for MongoDB chart. If the operator is already installed,
its CRDs must first be adopted by this release (add the
`app.kubernetes.io/managed-by=Helm` label and the `meta.helm.sh/release-name`
and `meta.helm.sh/release-namespace` annotations), otherwise the install fails
with an ownership error.

Uninstalling the CRDs deletes every MongoDB cluster managed by the operator.
From 1.22.1 the chart keeps the CRDs on uninstall by default
(`preserveCrds: true`). Full documentation:
https://docs.percona.com/percona-operator-for-mongodb/
