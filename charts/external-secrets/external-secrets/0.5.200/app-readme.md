**External Secrets Operator** is a Kubernetes operator that integrates external secret management systems like [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), [HashiCorp Vault](https://www.vaultproject.io/), [Google Secrets Manager](https://cloud.google.com/secret-manager), [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) and many more. 
The operator reads information from external APIs and automatically injects the values into a [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/).

### What is the goal of External Secrets Operator?

The goal of External Secrets Operator is to synchronize secrets from external APIs into Kubernetes. ESO is a collection of custom API resources - `ExternalSecret`, `SecretStore` and `ClusterSecretStore` that provide a user-friendly abstraction for the external API that stores and manages the lifecycle of the secrets for you.

