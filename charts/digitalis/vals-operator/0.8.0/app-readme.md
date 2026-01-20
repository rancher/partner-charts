# Vals-Operator

Here at [Digitalis](https://digitalis.io) we love [vals](https://github.com/variantdev/vals), it's a tool we use daily to keep secrets stored securely. We also use [secrets-manager](https://github.com/tuenti/secrets-manager) on the Kubernetes deployment we manage. Inspired by these two wonderful tools we have created this operator.

*vals-operator* syncs secrets from any secrets store supported by [vals](https://github.com/variantdev/vals) into Kubernetes. It works very similarly to [secrets-manager](https://github.com/tuenti/secrets-manager) and the code is actually based on it. Where they differ is that it not just supports HashiCorp Vault but many other secrets stores.

## Mirroring secrets

We have also added the ability to copy secrets between namespaces. It uses the format `ref+k8s://namespace/secret#key`. This way you can keep secrets generated in one namespace in sync with any other namespace in the cluster.
