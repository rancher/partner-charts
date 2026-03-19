# Airlock Microgateway

![Version: 4.3.4](https://img.shields.io/badge/Version-4.3.4-informational?style=flat-square) ![AppVersion: 4.3.4](https://img.shields.io/badge/AppVersion-4.3.4-informational?style=flat-square)

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight_Negative.svg">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg" align="right" width="250">
</picture>

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance, optimized for Kubernetes environments. Airlock Microgateway protects your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.
__This Helm chart is part of Airlock Microgateway. See our [GitHub repo](https://github.com/airlock/microgateway/tree/4.3.4).__

### Features
* Kubernetes native integration with its Operator, Custom Resource Definitions, hot-reload, automatic sidecar injection.
* Reverse proxy functionality with request routing rules, TLS termination and remote IP extraction
* Using native Envoy HTTP filters like Lua scripting, RBAC, ext_authz, JWT authentication
* Content security filters for protecting against known attacks (OWASP Top 10)
* Access control using OpenID Connect to allow only authenticated users to access the protected services
* API security features like JSON parsing, OpenAPI specification enforcement or GraphQL schema validation

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
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --version '1.15.1' -n cert-manager --create-namespace --set crds.enabled=true --wait
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
   helm install airlock-microgateway -n airlock-microgateway-system oci://quay.io/airlockcharts/microgateway --version '4.3.4' --wait
   ```

2. (Recommended) You can verify the correctness of the installation with `helm test`.
   ```bash
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.3.4'
   helm test airlock-microgateway -n airlock-microgateway-system --logs
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.3.4'
   ```

### Upgrading CRDs

The `helm install/upgrade` command currently does not support upgrading CRDs that already exist in the cluster.
CRDs should instead be manually upgraded before upgrading the Operator itself via the following command:
```bash
kubectl apply -k https://github.com/airlock/microgateway/deploy/charts/airlock-microgateway/crds/?ref=4.3.4 --server-side --force-conflicts
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
| dashboards.config.grafana.dashboardLabel.name | string | `"grafana_dashboard"` | Name of the label that lets Grafana identify ConfigMaps that represent dashboards. |
| dashboards.config.grafana.dashboardLabel.value | string | `"1"` | Value of the label that lets Grafana identify ConfigMaps that represent dashboards. |
| dashboards.config.grafana.folderAnnotation.name | string | `"grafana_folder"` | Name of the annotation containing the folder name to file dashboards into. |
| dashboards.config.grafana.folderAnnotation.value | string | `"Airlock Microgateway"` | Name of the folder dashboards are filed into within the Grafana UI. |
| dashboards.create | bool | `false` | Whether to create any ConfigMaps containing Grafana dashboards to import. |
| dashboards.instances.blockLogs.create | bool | `true` | Whether to create the block logs dashboard. |
| dashboards.instances.blockMetrics.create | bool | `true` | Whether to create the block metrics dashboard. |
| dashboards.instances.license.create | bool | `true` | Whether to create the license dashboard. |
| dashboards.instances.overview.create | bool | `true` | Whether to create the overview dashboard. |
| engine.image.digest | string | `"sha256:91e05c509bed3b51ff4888d7475980d56cbc85db121aa766d1bde413204f9070"` | SHA256 image digest to pull (in the format "sha256:a3051f42d3013813b05f7513bb86ed6a3209cb3003f1bb2f7b72df249aa544d3"). Overrides tag when specified. |
| engine.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| engine.image.repository | string | `"quay.io/airlock/microgateway-engine"` | Image repository from which to pull the Airlock Microgateway Engine image. |
| engine.image.tag | string | `"4.3.4"` | Image tag to pull. |
| engine.resources | object | `{}` | Resource restrictions to apply to the Airlock Microgateway Engine container. |
| engine.sidecar.podMonitor.create | bool | `false` | Whether to create a PodMonitor resource for monitoring. |
| engine.sidecar.podMonitor.labels | object | `{}` | Labels to add to the PodMonitor. |
| fullnameOverride | string | `""` | Allows overriding the name to use as full name of resources. |
| imagePullSecrets | list | `[]` | ImagePullSecrets to use when pulling images. |
| license.secretName | string | `"airlock-microgateway-license"` | Name of the secret containing the "microgateway-license.txt" key. |
| nameOverride | string | `""` | Allows overriding the name to use instead of "microgateway". |
| networkValidator.image.digest | string | `"sha256:7a73d4b82a2d4165bbc5efa55de4fee9d43f2b1c1edb3505cdc8afd1361bad9b"` | SHA256 image digest to pull (in the format "sha256:7a73d4b82a2d4165bbc5efa55de4fee9d43f2b1c1edb3505cdc8afd1361bad9b"). Overrides tag when specified. |
| networkValidator.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| networkValidator.image.repository | string | `"cgr.dev/chainguard/netcat"` | Image repository from which to pull the netcat image for the Airlock Microgateway Network Validator init-container. |
| networkValidator.image.tag | string | `""` | Image tag to pull. |
| operator.affinity | object | `{}` | Custom affinity to apply to the operator Deployment. Used to influence the scheduling. |
| operator.config.logLevel | string | `"info"` | Operator application log level. |
| operator.image.digest | string | `"sha256:6819c78d5570de66edce6c13964c6e1b4cc4746d0c0bc6f4975cd38e324828c0"` | SHA256 image digest to pull (in the format "sha256:c79ee3f85862fb386e9dd62b901b607161d27807f512d7fbdece05e9ee3d7c63"). Overrides tag when specified. |
| operator.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| operator.image.repository | string | `"quay.io/airlock/microgateway-operator"` | Image repository from which to pull the Airlock Microgateway Operator image. |
| operator.image.tag | string | `"4.3.4"` | Image tag to pull. |
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
| operator.watchNamespaceSelector | object | `{}` | Allows to dynamically select watch namespaces of the operator and the scope of the webhooks based on a Namespace label selector. It is able to detect and reconcile resources in all namespaces that match the label selector automatically, even for new namespaces, without restarting the operator. This facilitates a dynamic `MultiNamespace` installation mode, but still requires cluster-scoped permissions (i.e., ClusterRoles and ClusterRoleBindings). An `AllNamespaces` installation or the usage of the `watchNamespaces` requires the `watchNamespaceSelector` to be empty. Please note that this feature requires a Premium license. |
| operator.watchNamespaces | list | `[]` | Allows to restrict the operator to specific namespaces, depending on your needs. For a `OwnNamespace` or `SingleNamespace` installation the list may only contain one namespace (e.g., `watchNamespaces: ["airlock-microgateway-system"]`). In case of the `OwnNamespace` installation mode the specified namespace should be equal to the installation namespace. For a static `MultiNamespace` installation, the complete list of namespaces must be provided in the `watchNamespaces`. An `AllNamespaces` installation or the usage of the `watchNamespaceSelector` requires the `watchNamespaces` to be empty. Regardless of the installation modes supported by `watchNamespaces`, RBAC is created only namespace-scoped (using Roles and RoleBindings) in the respective namespaces. Please note that this feature requires a Premium license. |
| sessionAgent.image.digest | string | `"sha256:df4e50d0929cb4c5e4486452979b59ec17f5e49a1516b685acd3a1ab0ddb3cf4"` | SHA256 image digest to pull (in the format "sha256:a3051f42d3013813b05f7513bb86ed6a3209cb3003f1bb2f7b72df249aa544d3"). Overrides tag when specified. |
| sessionAgent.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| sessionAgent.image.repository | string | `"quay.io/airlock/microgateway-session-agent"` | Image repository from which to pull the Airlock Microgateway Session Agent image. |
| sessionAgent.image.tag | string | `"4.3.4"` | Image tag to pull. |
| sessionAgent.resources | object | `{}` | Resource restrictions to apply to the Airlock Microgateway Session Agent container. |
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
