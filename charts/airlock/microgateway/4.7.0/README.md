# Airlock Microgateway

![Version: 4.7.0](https://img.shields.io/badge/Version-4.7.0-informational?style=flat-square) ![AppVersion: 4.7.0](https://img.shields.io/badge/AppVersion-4.7.0-informational?style=flat-square)

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight_Negative.svg">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg" align="right" width="250">
</picture>

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance, optimized for Kubernetes environments. Airlock Microgateway protects your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.
__This Helm chart is part of Airlock Microgateway. See our [GitHub repo](https://github.com/airlock/microgateway/tree/4.7.0).__

### Features
* Kubernetes native integration with sidecar injection and Gateway API support
* Reverse proxy functionality with request routing rules, TLS termination and remote IP extraction
* Using native Envoy HTTP filters like Lua scripting, RBAC, ext_authz, JWT authentication
* Content security filters for protecting against known attacks (OWASP Top 10)
* Access control using OpenID Connect to allow only authenticated users to access the protected services
* API security features like JSON parsing, OpenAPI specification enforcement or GraphQL schema validation

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)**.

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000059)
* [System Architecture](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137)
* [Installation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/index/1659430054787.html)

# Quick start guide

The instructions below provide a quick start guide. Detailed information are provided in the **[manual](https://docs.airlock.com/microgateway/latest/)**.

## Prerequisites
* (Recommended) [Airlock Microgateway CNI](https://artifacthub.io/packages/helm/airlock-microgateway-cni/microgateway-cni) (Required for [data plane mode sidecar](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137))
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

> See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056) to choose the right license type.
### Deploy cert-manager
```console
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --version 'v1.18.2' -n cert-manager --create-namespace --set crds.enabled=true --wait
```

## Deploy Airlock Microgateway Operator

> This guide assumes a microgateway-license.txt file is present in the working directory.

1. Install CRDs and Operator.
   ```console
   # Create namespace
   kubectl create namespace airlock-microgateway-system

   # Install License
   kubectl -n airlock-microgateway-system create secret generic airlock-microgateway-license --from-file=microgateway-license.txt

   # Install Operator (CRDs are included via the standard Helm 3 mechanism, i.e. Helm will handle initial installation but not upgrades)
   helm install airlock-microgateway -n airlock-microgateway-system oci://quay.io/airlockcharts/microgateway --version '4.7.0' --wait
   ```

2. (Recommended) You can verify the correctness of the installation with `helm test`.
   ```console
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.7.0'
   helm test airlock-microgateway -n airlock-microgateway-system --logs
   helm upgrade airlock-microgateway -n airlock-microgateway-system --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway --version '4.7.0'
   ```

### Upgrading CRDs

The `helm install/upgrade` command currently does not support upgrading CRDs that already exist in the cluster.
CRDs should instead be manually upgraded before upgrading the Operator itself via the following command:
```console
kubectl apply -k https://github.com/airlock/microgateway/deploy/charts/airlock-microgateway/crds/?ref=4.7.0 --server-side --force-conflicts
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
| dashboards.instances.accessCtrlLogs.create | bool | `true` | Whether to create the access control logs dashboard. |
| dashboards.instances.blockLogs.create | bool | `true` | Whether to create the block logs dashboard. |
| dashboards.instances.blockMetrics.create | bool | `true` | Whether to create the block metrics dashboard. |
| dashboards.instances.downstreamMetrics.create | bool | `true` | Whether to create the downstream metrics dashboard. |
| dashboards.instances.headerLogs.create | bool | `true` | Whether to create the header rewrite logs dashboard. |
| dashboards.instances.license.create | bool | `true` | Whether to create the license dashboard. |
| dashboards.instances.logOnlyLogs.create | bool | `true` | Whether to create the log only logs dashboard. |
| dashboards.instances.logOnlyMetrics.create | bool | `true` | Whether to create the log only metrics dashboard |
| dashboards.instances.overview.create | bool | `true` | Whether to create the overview dashboard. |
| dashboards.instances.requestLogs.create | bool | `true` | Whether to create the request logs dashboard. |
| dashboards.instances.systemMetrics.create | bool | `true` | Whether to create the system metrics dashboard. |
| dashboards.instances.upstreamMetrics.create | bool | `true` | Whether to create the upstream metrics dashboard. |
| engine.image.digest | string | `"sha256:810a8febfe4bfd35a154cedbd2b6144e07917cef26b46d7eb6b76f079c08e7e9"` | SHA256 image digest to pull (in the format "sha256:a3051f42d3013813b05f7513bb86ed6a3209cb3003f1bb2f7b72df249aa544d3"). Overrides tag when specified. |
| engine.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| engine.image.repository | string | `"quay.io/airlock/microgateway-engine"` | Image repository from which to pull the Airlock Microgateway Engine image. |
| engine.image.tag | string | `"4.7.0"` | Image tag to pull. |
| engine.resources | object | `{"requests":{"cpu":"100m","memory":"256Mi"}}` | Default resource restrictions to apply to the Airlock Microgateway Engine container when deployed as a sidecar. |
| engine.sidecar.podMonitor.create | bool | `false` | Whether the controller should create a PodMonitor per SidecarGateway. Requires that the monitoring.coreos.com/v1 resources are installed on the cluster. |
| engine.sidecar.podMonitor.labels | object | `{}` | Labels to add to the PodMonitor. |
| fullnameOverride | string | `""` | Allows overriding the name to use as full name of resources. |
| imagePullSecrets | list | `[]` | ImagePullSecrets to use when pulling images. |
| license.secretName | string | `"airlock-microgateway-license"` | Name of the secret containing the "microgateway-license.txt" key. |
| nameOverride | string | `""` | Allows overriding the name to use instead of "microgateway". |
| networkValidator.image | string | `nil` | Deprecated |
| networkValidator.resources | object | `{"limits":{"cpu":"25m","memory":"12Mi"},"requests":{"cpu":"5m","memory":"1Mi"}}` | Resource restrictions to apply to the Airlock Microgateway Network Validator init-container. |
| operator.affinity | object | `{}` | Custom affinity to apply to the operator Deployment. Used to influence the scheduling. |
| operator.config.logLevel | string | `"info"` | Operator application log level. |
| operator.extraEnv | list | `[]` | Additional environment variables to set for the operator container. |
| operator.gatewayAPI.controllerName | string | `"microgateway.airlock.com/gatewayclass-controller"` | Controller name referred in the GatewayClasses managed by this operator. The value must be a path prefixed by the domain `microgateway.airlock.com`. |
| operator.gatewayAPI.enabled | bool | `false` | Whether to enable the Kubernetes Gateway API related controllers. Requires that the gateway.networking.k8s.io/v1 resources are installed on the cluster. |
| operator.gatewayAPI.gatewayClass.create | bool | `true` | Whether to create a default GatewayClass during installation. |
| operator.gatewayAPI.gatewayClass.name | string | `"airlock-microgateway"` | Name of the default GatewayClass. The name must adhere to the DNS Subdomain Name format as defined in RFC1123. See https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-subdomain-names for details. |
| operator.gatewayAPI.podMonitor.create | bool | `false` | Whether the controller should create a PodMonitor per Gateway. Requires that the monitoring.coreos.com/v1 resources are installed on the cluster. |
| operator.gatewayAPI.podMonitor.labels | object | `{}` | Allows to define additional labels that should be set on the PodMonitors. |
| operator.image.digest | string | `"sha256:b9a20d3e763678c284bf1333fd974dc40efbebf50cfdb40ccc2cbe37ad8b65b3"` | SHA256 image digest to pull (in the format "sha256:c79ee3f85862fb386e9dd62b901b607161d27807f512d7fbdece05e9ee3d7c63"). Overrides tag when specified. |
| operator.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| operator.image.repository | string | `"quay.io/airlock/microgateway-operator"` | Image repository from which to pull the Airlock Microgateway Operator image. |
| operator.image.tag | string | `"4.7.0"` | Image tag to pull. |
| operator.nodeSelector | object | `{}` | Custom nodeSelector to apply to the operator Deployment in order to constrain its Pods to certain nodes. |
| operator.podAnnotations | object | `{}` | Annotations to add to all Pods. |
| operator.podDisruptionBudget | object | `{}` | PodDisruptionBudget to create for the operator Deployment. If empty, no PDB is created. Note: The selector is automatically configured to match the labels of the operator Deployment and does not need to be set manually. See https://kubernetes.io/docs/tasks/run-application/configure-pdb/ for details. |
| operator.podLabels | object | `{}` | Labels to add to all Pods. |
| operator.rbac.create | bool | `true` | Whether to create RBAC resources which are required for the Airlock Microgateway Operator to function. |
| operator.replicaCount | int | `2` | Number of replicas for the operator Deployment. |
| operator.resources | object | `{"limits":{"cpu":"2500m","memory":"512Mi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Resource restrictions to apply to the operator container. |
| operator.serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount. |
| operator.serviceAccount.create | bool | `true` | Whether a ServiceAccount should be created. |
| operator.serviceAccount.name | string | `""` | Name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template. |
| operator.serviceAnnotations | object | `{}` | Annotations to add to the Service. |
| operator.serviceLabels | object | `{}` | Labels to add to the Service. |
| operator.serviceMonitor.create | bool | `false` | Whether to create a ServiceMonitor resource for monitoring. Requires that the monitoring.coreos.com/v1 resources are installed on the cluster. |
| operator.serviceMonitor.labels | object | `{}` | Labels to add to the ServiceMonitor. |
| operator.sidecarGateway.enabled | bool | `true` | Whether to enable the Sidecar Gateway related controllers and webhooks. |
| operator.tolerations | list | `[]` | Custom tolerations to apply to the operator Deployment in order to allow its Pods to run on tainted nodes. |
| operator.topologySpreadConstraints | list | `[]` | Custom topologySpreadConstraints to apply to the operator Deployment. Used to influence how replicas are spread across the cluster. |
| operator.updateStrategy | object | `{"type":"RollingUpdate"}` | Specifies the operator update strategy. |
| operator.watchNamespaceSelector | object | `{}` | Allows to dynamically select watch namespaces of the operator and the scope of the webhooks based on a Namespace label selector. It is able to detect and reconcile resources in all namespaces that match the label selector automatically, even for new namespaces, without restarting the operator. This facilitates a dynamic `MultiNamespace` installation mode, but still requires cluster-scoped permissions (i.e., ClusterRoles and ClusterRoleBindings). An `AllNamespaces` installation or the usage of the `watchNamespaces` requires the `watchNamespaceSelector` to be empty. Please note that this feature requires a Premium license. |
| operator.watchNamespaces | list | `[]` | Allows to restrict the operator to specific namespaces, depending on your needs. For a `OwnNamespace` or `SingleNamespace` installation the list may only contain one namespace (e.g., `watchNamespaces: ["airlock-microgateway-system"]`). In case of the `OwnNamespace` installation mode the specified namespace should be equal to the installation namespace. For a static `MultiNamespace` installation, the complete list of namespaces must be provided in the `watchNamespaces`. An `AllNamespaces` installation or the usage of the `watchNamespaceSelector` requires the `watchNamespaces` to be empty. Regardless of the installation modes supported by `watchNamespaces`, RBAC is created only namespace-scoped (using Roles and RoleBindings) in the respective namespaces. Please note that this feature requires a Premium license. |
| operator.webhook.certificateProvider | string | `"cert-manager"` | Configure which provider is responsible for webhook certificates |
| sessionAgent.image.digest | string | `"sha256:15f3a3d476c01c4f17de4e17ac08627d32d6d036714e29b8bf262db45aa0720e"` | SHA256 image digest to pull (in the format "sha256:a3051f42d3013813b05f7513bb86ed6a3209cb3003f1bb2f7b72df249aa544d3"). Overrides tag when specified. |
| sessionAgent.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| sessionAgent.image.repository | string | `"quay.io/airlock/microgateway-session-agent"` | Image repository from which to pull the Airlock Microgateway Session Agent image. |
| sessionAgent.image.tag | string | `"4.7.0"` | Image tag to pull. |
| sessionAgent.resources | object | `{}` | Resource restrictions to apply to the Airlock Microgateway Session Agent container when the Airlock Microgateway Engine is deployed as a sidecar. |
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
