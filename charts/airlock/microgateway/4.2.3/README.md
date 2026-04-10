# Airlock Microgateway

![Version: 4.2.3](https://img.shields.io/badge/Version-4.2.3-informational?style=flat-square) ![AppVersion: 4.2.3](https://img.shields.io/badge/AppVersion-4.2.3-informational?style=flat-square)

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight_Negative.svg">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg" align="right" width="250">
</picture>

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance, optimized for Kubernetes environments. Airlock Microgateway protects your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.
__This Helm chart is part of Airlock Microgateway. See our [GitHub repo](https://github.com/airlock/microgateway/tree/4.2.3).__

### Features
* Kubernetes native integration with its Operator, Custom Resource Definitions, hot-reload, automatic sidecar injection.
* Reverse proxy functionality with request routing rules, TLS termination and remote IP extraction
* Using native Envoy HTTP filters like Lua scripting, RBAC, ext_authz, JWT authentication
* Content security filters for protecting against known attacks (OWASP Top 10)
* Access control to allow only authenticated users to access the protected services
* API security features like JSON parsing or OpenAPI specification enforcement

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/#data/1675772882054.html)**.

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/#data/1660804708742.html)
* [System Architecture](https://docs.airlock.com/microgateway/latest/#data/1660804709650.html)
* [Installation](https://docs.airlock.com/microgateway/latest/#data/1660804708637.html)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/#data/1659430054787.html)
* [GitHub](https://github.com/airlock/microgateway)

# Quick start guide

The instructions below provide a quick start guide. Detailed information are provided in the **[manual](https://docs.airlock.com/microgateway/latest/)**.

## Prerequisites
* [Airlock Microgateway CNI](https://artifacthub.io/packages/helm/airlock-microgateway-cni/microgateway-cni)
* [Airlock Microgateway License](#obtain-airlock-microgateway-license)
* [cert-manager](https://cert-manager.io/)
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)

In order to use Airlock Microgateway you need a license and the cert-manager. You may either request a community license free of charge or purchase a premium license.
For an easy start in non-production environments, you may deploy the same cert-manager we are using internally for testing.
### Obtain Airlock Microgateway License
1. Either request a community or premium license
   * Community license: [airlock.com/microgateway-community](https://airlock.com/en/microgateway-community)
   * Premium license: [airlock.com/microgateway-premium](https://airlock.com/en/microgateway-premium)
2. Check your inbox and save the license file microgateway-license.txt locally.

> See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/#data/1675772882054.html) to choose the right license type.
### Deploy cert-manager
```bash
# Install cert-manager
kubectl apply -k https://github.com/airlock/microgateway/examples/utilities/cert-manager/?ref=4.2.3

# Wait for the cert-manager to be up and running
kubectl -n cert-manager wait --for=condition=ready --timeout=600s pod -l app.kubernetes.io/instance=cert-manager
```

## Deploy Airlock Microgateway Operator

> This guide assumes a microgateway-license.txt file is present in the working directory.

1. Install CRDs and Operator.
   ```bash
   # Create namespace
   kubectl create namespace airlock-microgateway-system

   # Install License
   kubectl -n airlock-microgateway-system create secret generic airlock-microgateway-license --from-file=microgateway-license.txt

   # Install Operator (CRDs are included via the standard Helm 3 mechanism, i.e. Helm will handle initial installation but not upgrades)
   helm install airlock-microgateway -n airlock-microgateway-system oci://quay.io/airlockcharts/microgateway --version '4.2.3' --wait
   ```

2. (Recommended) You can verify the correctness of the installation with `helm test`.
   ```bash
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.2.3'
   helm test airlock-microgateway -n airlock-microgateway-system --logs
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.2.3'
   ```

### Upgrading CRDs

The `helm install/upgrade` command currently does not support upgrading CRDs that already exist in the cluster.
CRDs should instead be manually upgraded before upgrading the Operator itself via the following command:
```bash
kubectl apply -k https://github.com/airlock/microgateway/deploy/charts/airlock-microgateway/crds/?ref=4.2.3 --server-side --force-conflicts
```

**Note**: Certain GitOps solutions such as e.g. Argo CD or Flux CD have their own mechanisms for automatically upgrading CRDs included with Helm charts.

## Support

### Premium support
If you have a paid license, please follow the [premium support process](https://techzone.ergon.ch/support-process).

### Community support
For the community edition, check our **[Airlock community forum](https://forum.airlock.com/)** for FAQs or register to post your question.
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| crds.skipVersionCheck | bool | `false` | Whether to skip the sanity check which prevents installing/upgrading the helm chart in a cluster with outdated Airlock Microgateway CRDs. The check aims to prevent unexpected behavior and issues due to Helm v3 not automatically upgrading CRDs which are already present in the cluster when performing a "helm install/upgrade". |
| engine.image.digest | string | `"sha256:9b0debeef611172aa5ca79c6b8cd045e56a3c883763ec62c0fa211bb86d35304"` | SHA256 image digest to pull (in the format "sha256:a3051f42d3013813b05f7513bb86ed6a3209cb3003f1bb2f7b72df249aa544d3"). Overrides tag when specified. |
| engine.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| engine.image.repository | string | `"quay.io/airlock/microgateway-engine"` | Image repository from which to pull the Airlock Microgateway Engine image. |
| engine.image.tag | string | `"4.2.3"` | Image tag to pull. |
| engine.resources | object | `{}` | Resource restrictions to apply to the Airlock Microgateway Engine container. |
| engine.sidecar.podMonitor.create | bool | `false` | Whether to create a PodMonitor resource for monitoring. |
| engine.sidecar.podMonitor.labels | object | `{}` | Labels to add to the PodMonitor. |
| fullnameOverride | string | `""` | Allows overriding the name to use as full name of resources. |
| imagePullSecrets | list | `[]` | ImagePullSecrets to use when pulling images. |
| license.secretName | string | `"airlock-microgateway-license"` | Name of the secret containing the "microgateway-license.txt" key. |
| nameOverride | string | `""` | Allows overriding the name to use instead of "microgateway". |
| networkValidator.image.digest | string | `"sha256:a212cef6665b2464a41307162fa96e9623aa45c3fa32c39d320eae8b730d81e0"` | SHA256 image digest to pull (in the format "sha256:a212cef6665b2464a41307162fa96e9623aa45c3fa32c39d320eae8b730d81e0"). Overrides tag when specified. |
| networkValidator.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| networkValidator.image.repository | string | `"cgr.dev/chainguard/busybox"` | Image repository from which to pull the busybox image for the Airlock Microgateway Network Validator init-container. |
| networkValidator.image.tag | string | `""` | Image tag to pull. |
| operator.affinity | object | `{}` | Custom affinity to apply to the operator Deployment. Used to influence the scheduling. |
| operator.config.logLevel | string | `"info"` | Operator application log level. |
| operator.image.digest | string | `"sha256:a429dfdb636e76bfbee7c59cfbe53d5f396c1f5603d5cb187f6283301ba4d7ba"` | SHA256 image digest to pull (in the format "sha256:c79ee3f85862fb386e9dd62b901b607161d27807f512d7fbdece05e9ee3d7c63"). Overrides tag when specified. |
| operator.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| operator.image.repository | string | `"quay.io/airlock/microgateway-operator"` | Image repository from which to pull the Airlock Microgateway Operator image. |
| operator.image.tag | string | `"4.2.3"` | Image tag to pull. |
| operator.nodeSelector | object | `{}` | Custom nodeSelector to apply to the operator Deployment in order to constrain its Pods to certain nodes. |
| operator.podAnnotations | object | `{}` | Annotations to add to all Pods. |
| operator.podLabels | object | `{}` | Labels to add to all Pods. |
| operator.rbac.create | bool | `true` | Whether to create RBAC resources which are required for the Airlock Microgateway Operator to function. |
| operator.replicaCount | int | `2` | Number of replicas for the operator Deployment. |
| operator.resources | object | `{}` | Resource restrictions to apply to the operator container. |
| operator.serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount. |
| operator.serviceAccount.create | bool | `true` | Whether a ServiceAccount should be created. |
| operator.serviceAccount.name | string | `""` | Name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template. |
| operator.serviceAnnotations | object | `{}` | Annotations to add to the Service. |
| operator.serviceLabels | object | `{}` | Labels to add to the Service. |
| operator.serviceMonitor.create | bool | `false` | Whether to create a ServiceMonitor resource for monitoring. |
| operator.serviceMonitor.labels | object | `{}` | Labels to add to the ServiceMonitor. |
| operator.tolerations | list | `[]` | Custom tolerations to apply to the operator Deployment in order to allow its Pods to run on tainted nodes. |
| operator.updateStrategy | object | `{"type":"RollingUpdate"}` | Specifies the operator update strategy. |
| tests.enabled | bool | `false` | Whether additional resources required for running `helm test` should be created (e.g. Roles and ServiceAccounts). If set to false, `helm test` will not run any tests. |

## License
View the [detailed license terms](https://www.airlock.com/en/airlock-license) for the software contained in this image.
* Decompiling or reverse engineering is not permitted.
* Using any of the deny rules or parts of these filter patterns outside of the image is not permitted.

Airlock<sup>&#174;</sup> is a security innovation by [ergon](https://www.ergon.ch/en)

<!-- Airlock SAH Logo (different image for light/dark mode) -->
<a href="https://www.airlock.com/en/secure-access-hub/">
<picture>
    <source media="(prefers-color-scheme: dark)"
        srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Airlock_Logo_Negative.png">
    <source media="(prefers-color-scheme: light)"
        srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Airlock_Logo.png">
    <img alt="Airlock Secure Access Hub" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Airlock_Logo.png" width="150">
</picture>
</a>
