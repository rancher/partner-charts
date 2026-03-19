<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_Negative.svg" width="400">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled.svg" width="400">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled.svg" width="400">
</picture>

[![Release](https://img.shields.io/badge/Release-v5.0.0-6bba62)](https://github.com/airlock/microgateway/releases/tag/5.0.0)
[![Gateway API Conformance](https://img.shields.io/badge/Gateway%20API%20Conformance-v1.5.1-6bba62?logo=kubernetes&logoColor=white)](https://github.com/kubernetes-sigs/gateway-api/blob/main/conformance/reports/v1.5.1/airlock-microgateway)
[![GitHub](https://img.shields.io/badge/GitHub-Published-6bba62?logo=github&logoColor=white)](https://github.com/airlock/microgateway/releases/tag/5.0.0)
[![Artifact Hub](https://img.shields.io/badge/Artifact%20Hub-Published-6bba62?logo=artifacthub&logoColor=white)](https://artifacthub.io/packages/helm/airlock-microgateway/microgateway)
[![OpenShift Certified](https://img.shields.io/badge/OpenShift%20Certification-Passed-6bba62?logo=redhatopenshift)](https://catalog.redhat.com/en/software/container-stacks/detail/67177f927cfedb209761e48f)

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance, optimized for Kubernetes environments. Airlock Microgateway protects your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.
__This Helm chart is part of Airlock Microgateway. See our [GitHub repo](https://github.com/airlock/microgateway/tree/5.0.0).__

### Features
* Kubernetes native integration with Gateway API
* Comprehensive set of security features, including deny rules to protect against known attacks (OWASP Top 10), header filtering, JSON parsing, OpenAPI specification enforcement, GraphQL schema validation, and antivirus scanning with ICAP
* Identity aware proxy which makes it possible to enforce authentication using client certificate based authentication, JWT authentication or OIDC with step-up authentication to realize multi factor authentication (MFA). Provides OAuth 2.0 Token Introspection and Token Exchange for continuous validation and secure delegation across services
* Reverse proxy functionality with request routing rules, TLS termination, and remote IP extraction
* Easy-to-use Grafana dashboards which provide valuable insights in allowed and blocked traffic and other metrics

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)**.

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000059)
* [System Architecture](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137)
* [Installation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/index/1659430054787.html)
* [GitHub](https://github.com/airlock/microgateway)

# Quick start guide

The instructions below provide a quick start guide. Detailed information on the installation are provided in the **[manual](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)**.

## Prerequisites
* [Airlock Microgateway License](#obtain-airlock-microgateway-license)
* [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api)
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)

### Obtain Airlock Microgateway License
1. Either request a community or premium license
   * Community license (free): [airlock.com/microgateway-community](https://airlock.com/en/microgateway-community)
   * Premium license: [airlock.com/microgateway-premium](https://airlock.com/en/microgateway-premium)
2. Check your inbox and save the license file microgateway-license.txt locally.

> See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056) to choose the right license type.

### Deploy Kubernetes Gateway API CRDs

```console
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
```

## Deploy Airlock Microgateway Operator

> This guide assumes a microgateway-license.txt file is present in the working directory.

1. Install CRDs and Operator:

    ```console
    # Create namespace
    kubectl create namespace airlock-microgateway-system

    # Install License
    kubectl create secret generic airlock-microgateway-license \
      -n airlock-microgateway-system \
      --from-file=microgateway-license.txt

    # Install Operator (CRDs are included via the standard Helm 3 mechanism, i.e. Helm will handle initial installation but not upgrades)
    helm install airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.0.0' \
      -n airlock-microgateway-system \
      --wait
    ```

2. Verify that the Operator started successfully:

    ```console
    kubectl -n airlock-microgateway-system wait \
      --for=condition=Available deployments --all --timeout=3m
    ```

3. Verify the correctness of the installation (Recommended):

    ```console
    helm upgrade airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.0.0' \
      -n airlock-microgateway-system \
      --set tests.enabled=true \
      --reuse-values

    helm test airlock-microgateway -n airlock-microgateway-system --logs

    helm upgrade airlock-microgateway \
      oci://quay.io/airlockcharts/microgateway \
      --version '5.0.0' \
      -n airlock-microgateway-system \
      --set tests.enabled=false \
      --reuse-values
    ```

### Upgrading CRDs

The `helm install/upgrade` command currently does not support upgrading CRDs that already exist in the cluster.
CRDs should instead be manually upgraded before upgrading the Operator itself via the following command:

```console
kubectl apply -k https://github.com/airlock/microgateway/deploy/charts/airlock-microgateway/crds/?ref=5.0.0 \
  --server-side \
  --force-conflicts
```

**Note**: Certain GitOps solutions such as e.g. Argo CD or Flux CD have their own mechanisms for automatically upgrading CRDs included with Helm charts.

## What’s next
After installing the Airlock Microgateway Operator, the next steps describe how to deploy and configure a Gateway in your cluster and how to implement common scenarios.

* [Gateway deployment](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000147)

    Deploy the gateway either as an Ingress or as an in-cluster Gateway.

* [Session handling](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000148)

    Enable session handling to persist session information and correlate requests with a session ID. This is a prerequisite for OIDC-based authentication.

* [Use cases](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000146)

    Learn how to use Airlock Microgateway for other typical scenarios such as request routing, request filtering or authentication enforcement.

## Support

### Premium support
If you have a paid license, please follow the [premium support process](https://techzone.ergon.ch/support-process).

### Community support
For the community edition, check our **[Airlock community forum](https://forum.airlock.com/)** for FAQs or register to post your question.
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Custom affinity to apply to the operator Deployment. Used to influence the scheduling. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| config.engineImage.digest | string | `"sha256:f056de3af507c14fa83e6663ab4670bbe8529c4ed27f6434f6d7cff278a42f6b"` | SHA256 image digest to pull (in the format "sha256:a3051f42d3013813b05f7513bb86ed6a3209cb3003f1bb2f7b72df249aa544d3"). Overrides tag when specified. |
| config.engineImage.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| config.engineImage.repository | string | `"quay.io/airlock/microgateway-engine"` | Image repository from which to pull the Airlock Microgateway Engine image. |
| config.engineImage.tag | string | `"5.0.0"` | Image tag to pull. |
| config.gatewayPodMonitor.create | bool | `false` | Whether the controller should create a PodMonitor per Gateway. Requires that the monitoring.coreos.com/v1 resources are installed on the cluster. |
| config.gatewayPodMonitor.labels | object | `{}` | Allows to define additional labels that should be set on the PodMonitors. |
| config.logLevel | string | `"info"` | Operator application log level. |
| config.sessionAgentImage.digest | string | `"sha256:e7e09849946720198a21d2995bd4eca3b8584e94b04cb130eaf3c90652d509ef"` | SHA256 image digest to pull (in the format "sha256:a3051f42d3013813b05f7513bb86ed6a3209cb3003f1bb2f7b72df249aa544d3"). Overrides tag when specified. |
| config.sessionAgentImage.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| config.sessionAgentImage.repository | string | `"quay.io/airlock/microgateway-session-agent"` | Image repository from which to pull the Airlock Microgateway Session Agent image. |
| config.sessionAgentImage.tag | string | `"5.0.0"` | Image tag to pull. |
| controllerName | string | `"microgateway.airlock.com/gatewayclass-controller"` | Controller name referred in the GatewayClasses managed by this operator. The value must be a path prefixed by the domain `microgateway.airlock.com`. |
| crds.skipGatewayAPICheck | bool | `false` | Whether to skip the sanity check which prevents installing/upgrading the helm chart in a cluster which does not have GatewayAPI v1 CRDs installed. |
| crds.skipVersionCheck | bool | `false` | Whether to skip the sanity check which prevents installing/upgrading the helm chart in a cluster with outdated Airlock Microgateway CRDs. The check aims to prevent unexpected behavior and issues due to Helm v3 not automatically upgrading CRDs which are already present in the cluster when performing a "helm install/upgrade". |
| dashboards.config.grafana.dashboardLabel.name | string | `"grafana_dashboard"` | Name of the label that lets Grafana identify ConfigMaps that represent dashboards. |
| dashboards.config.grafana.dashboardLabel.value | string | `"1"` | Value of the label that lets Grafana identify ConfigMaps that represent dashboards. |
| dashboards.config.grafana.folderAnnotation.name | string | `"grafana_folder"` | Name of the annotation containing the folder name to file dashboards into. |
| dashboards.config.grafana.folderAnnotation.value | string | `"Airlock Microgateway"` | Name of the folder dashboards are filed into within the Grafana UI. |
| dashboards.create | bool | `false` | Whether to create any ConfigMaps containing Grafana dashboards to import. |
| dashboards.instances.accessCtrlLogs.create | bool | `true` | Whether to create the access control logs dashboard. |
| dashboards.instances.accessCtrlMetrics.create | bool | `true` | Whether to create the access control metrics dashboard. |
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
| extraEnv | list | `[]` | Additional environment variables to set for the operator container. |
| fullnameOverride | string | `""` | Allows overriding the name to use as full name of resources. |
| gatewayClass.create | bool | `true` | Whether to create a default GatewayClass during installation. |
| gatewayClass.name | string | `"airlock-microgateway"` | Name of the default GatewayClass. The name must adhere to the DNS Subdomain Name format as defined in RFC1123. See https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-subdomain-names for details. |
| image.digest | string | `"sha256:4d12323c5e6ed6ee916e846a8f740190f300b6f5cf4db4af7a37c6d50c0a3068"` | SHA256 image digest to pull (in the format "sha256:c79ee3f85862fb386e9dd62b901b607161d27807f512d7fbdece05e9ee3d7c63"). Overrides tag when specified. |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| image.repository | string | `"quay.io/airlock/microgateway-operator"` | Image repository from which to pull the Airlock Microgateway Operator image. |
| image.tag | string | `"5.0.0"` | Image tag to pull. |
| imagePullSecrets | list | `[]` | ImagePullSecrets to use when pulling images. Can be defined either as a list of objects or as a list of strings. |
| license.secretName | string | `"airlock-microgateway-license"` | Name of the secret containing the "microgateway-license.txt" key. |
| nameOverride | string | `""` | Allows overriding the name to use instead of "microgateway". |
| nodeSelector | object | `{}` | Custom nodeSelector to apply to the operator Deployment to constrain its Pods to certain nodes. |
| podAnnotations | object | `{}` | Annotations to add to all operator Pods. |
| podDisruptionBudget | object | `{}` | PodDisruptionBudget to create for the operator Deployment. If empty, no PDB is created. Note: The selector is automatically configured to match the labels of the operator Deployment and does not need to be set manually. See https://kubernetes.io/docs/tasks/run-application/configure-pdb/ for details. |
| podLabels | object | `{}` | Labels to add to all operator Pods. |
| rbac.create | bool | `true` | Whether to create RBAC resources which are required for the Airlock Microgateway Operator to function. |
| replicaCount | int | `1` | Number of replicas for the operator Deployment. |
| resources | object | `{"limits":{"cpu":"2000m","memory":"256Mi"},"requests":{"cpu":"250m","memory":"256Mi"}}` | Resource restrictions to apply to the operator container. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount. |
| serviceAccount.create | bool | `true` | Whether a ServiceAccount should be created for the operator Deployment. |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template. |
| serviceAnnotations | object | `{}` | Annotations to add to the operator Service. |
| serviceLabels | object | `{}` | Labels to add to the operator Service. |
| serviceMonitor.create | bool | `false` | Whether to create a ServiceMonitor resource for monitoring of the operator Deployment. Requires that the monitoring.coreos.com/v1 resources are installed on the cluster. |
| serviceMonitor.labels | object | `{}` | Labels to add to the ServiceMonitor. |
| tests.enabled | bool | `false` | Whether additional resources required for running `helm test` should be created (e.g. Roles and ServiceAccounts). If set to false, `helm test` will not run any tests. |
| tolerations | list | `[]` | Custom tolerations to apply to the operator Deployment to allow its Pods to run on tainted nodes. |
| topologySpreadConstraints | list | `[]` | Custom topologySpreadConstraints to apply to the operator Deployment. Used to influence how replicas are spread across the cluster. |
| updateStrategy | object | `{"type":"RollingUpdate"}` | Specifies the operator Deployment update strategy. |

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
