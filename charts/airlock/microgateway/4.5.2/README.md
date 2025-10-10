# Airlock Microgateway CNI

![Version: 4.5.2](https://img.shields.io/badge/Version-4.5.2-informational?style=flat-square) ![AppVersion: 4.5.2](https://img.shields.io/badge/AppVersion-4.5.2-informational?style=flat-square)

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

<picture>
  <source media="(prefers-color-scheme: dark)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight_Negative.svg">
  <source media="(prefers-color-scheme: light)"
          srcset="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg">
  <img alt="Microgateway" src="https://raw.githubusercontent.com/airlock/microgateway/main/media/Microgateway_Labeled_AlignRight.svg" align="right" width="250">
</picture>

Modern application security is embedded in the development workflow and follows DevSecOps paradigms. Airlock Microgateway is the perfect fit for these requirements. It is a lightweight alternative to the Airlock Gateway appliance, optimized for Kubernetes environments. Airlock Microgateway protects your applications and microservices with the tried-and-tested Airlock security features against attacks, while also providing a high degree of scalability.
__This Helm chart is part of Airlock Microgateway. See our [GitHub repo](https://github.com/airlock/microgateway/tree/4.5.2).__

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
* [helm](https://helm.sh/docs/intro/install/) (>= v3.8.0)

## Deploy Airlock Microgateway CNI
1. Install the CNI Plugin with Helm.
   > **Note**: Certain environments such as OpenShift or GKE require non-default configurations when installing the CNI plugin. For the most common setups, values files are provided in the [chart folder](/deploy/charts/airlock-microgateway-cni).
   ```console
   # Standard setup
   helm install airlock-microgateway-cni -n kube-system oci://quay.io/airlockcharts/microgateway-cni --version '4.5.2'
   kubectl -n kube-system rollout status daemonset -l app.kubernetes.io/instance=airlock-microgateway-cni
   ```
   ```console
   # GKE setup
   helm install airlock-microgateway-cni -n kube-system oci://quay.io/airlockcharts/microgateway-cni --version '4.5.2' -f https://raw.githubusercontent.com/airlock/microgateway/4.5.2/deploy/charts/airlock-microgateway-cni/gke-values.yaml
   kubectl -n kube-system rollout status daemonset -l app.kubernetes.io/instance=airlock-microgateway-cni
   ```
   ```console
   # OpenShift setup
   helm install airlock-microgateway-cni -n openshift-operators oci://quay.io/airlockcharts/microgateway-cni --version '4.5.2' -f https://raw.githubusercontent.com/airlock/microgateway/4.5.2/deploy/charts/airlock-microgateway-cni/openshift-values.yaml
   kubectl -n openshift-operators rollout status daemonset -l app.kubernetes.io/instance=airlock-microgateway-cni
   ```
   > **Important:** On OpenShift, all pods which should be protected by Airlock Microgateway must explicitly reference the Airlock Microgateway CNI NetworkAttachmentDefinition via the annotation `k8s.v1.cni.cncf.io/networks` (see [documentation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000140) for details).

2. (Recommended) You can verify the correctness of the installation with `helm test`.
   ```console
   # Standard and GKE setup
   helm upgrade airlock-microgateway-cni -n kube-system --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.5.2'
   helm test airlock-microgateway-cni -n kube-system --logs
   helm upgrade airlock-microgateway-cni -n kube-system --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.5.2'
   ```
   ```console
   # OpenShift setup
   helm upgrade airlock-microgateway-cni -n openshift-operators --set tests.enabled=true --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.5.2'
   helm test airlock-microgateway-cni -n openshift-operators --logs
   helm upgrade airlock-microgateway-cni -n openshift-operators --set tests.enabled=false --reuse-values oci://quay.io/airlockcharts/microgateway-cni --version '4.5.2'
   ```

   Consult our [documentation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000139) in case of any installation error.

## Support

### Premium support
If you have a paid license, please follow the [premium support process](https://techzone.ergon.ch/support-process).

### Community support
For the community edition, check our **[Airlock community forum](https://forum.airlock.com/)** for FAQs or register to post your question.
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Custom affinity for the DaemonSet to only deploy the CNI plugin on specific nodes. |
| commonAnnotations | object | `{}` | Annotations to add to all resources. |
| commonLabels | object | `{}` | Labels to add to all resources. |
| config.cniBinDir | string | `"/opt/cni/bin"` | Directory where the CNI plugin binaries reside on the host. This path can either be found in the documentation of your Kubernetes distribution or CNI provider. It can also be queried by running the command `crictl info -o go-template --template '{{.config.cni.binDir}}'` on your Kubernetes node. |
| config.cniNetDir | string | `"/etc/cni/net.d"` | Directory where the CNI config files reside on the host. This path can either be found in the documentation of your Kubernetes distribution or CNI provider. It can also be queried by running the command `crictl info -o go-template --template '{{.config.cni.confDir}}'` on your Kubernetes node. |
| config.excludeNamespaces | list | `["kube-system"]` | Namespaces for which this CNI plugin should not apply any modifications. |
| config.installMode | string | `"chained"` | Whether to install the CNI plugin as a `chained` plugin (default, required with most interface CNI providers), as a `standalone` plugin (required for use with Multus CNI, e.g. on OpenShift) or in `manual` mode, where no CNI network configuration is written. |
| config.logLevel | string | `"info"` | Log level for the CNI installer and plugin. |
| config.repairMode | string | `"none"` | Specifies the repair mode There is a race condition regarding the installation of the CNI Plugin and creation of Pods when starting a Node. This would cause Pods to be unprotected, because the CNI did not reconfigure the Pod's network. The Airlock Microgateway Network Validator prevents this and causes the Pod to fail on purpose. Pods can be repaired by choosing the appropriate repair mode. Available options are: `deletePods` will delete failing Pods, such that the CNI Plugin can correctly configure them `none` will not perform any action for failing Pods |
| fullnameOverride | string | `""` | Allows overriding the name to use as full name of resources. |
| image.digest | string | `"sha256:f7ff544beb73476831222688df381d2eff83f674a1a6849100ed0fff6cd8cf24"` | SHA256 image digest to pull (in the format "sha256:7144f7bab3d4c2648d7e59409f15ec52a18006a128c733fcff20d3a4a54ba44a"). Overrides tag when specified. |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy for this image. |
| image.repository | string | `"quay.io/airlock/microgateway-cni"` | Image repository from which to pull the Airlock Microgateway CNI image. |
| image.tag | string | `"4.5.2"` | Image tag to pull. |
| imagePullSecrets | list | `[]` | ImagePullSecrets to use when pulling images. |
| multusNetworkAttachmentDefinition.create | bool | `false` | Whether a NetworkAttachmentDefinition CR should be created, which can be used for applying the CNI plugin to Pods. |
| multusNetworkAttachmentDefinition.namespace | string | `"default"` | Namespace in which the NetworkAttachmentDefinition is deployed. Note: If namespace is set to a custom value, referencing the created NetworkAttachmentDefinition from other namespaces may not work if Multus namespace isolation is enabled. https://github.com/k8snetworkplumbingwg/multus-cni/blob/v4.0.2/docs/configuration.md#namespace-isolation |
| nameOverride | string | `""` | Allows overriding the name to use instead of "microgateway-cni". |
| nodeSelector | object | `{"kubernetes.io/os":"linux"}` | NodeSelector to apply to the CNI DaemonSet in order to only deploy the CNI plugin on specific nodes. |
| podAnnotations | object | `{}` | Annotations to add to all Pods. |
| podLabels | object | `{}` | Labels to add to all Pods. |
| privileged | bool | `false` | Whether the DaemonSet should run in privileged mode. Must be enabled for environments which require it for writing files to the host (e.g. OpenShift). |
| rbac.create | bool | `true` | Whether to create RBAC resources which are required for the CNI plugin to function. |
| rbac.createSCCRole | OpenShift | `false` | Whether to create RBAC resources which allow the CNI installer to use the "privileged" security context constraint. |
| resources | object | `{"requests":{"cpu":"10m","memory":"100Mi"}}` | Resource restrictions to apply to the CNI installer container. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount. |
| serviceAccount.create | bool | `true` | Whether a ServiceAccount should be created. |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template. |
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
