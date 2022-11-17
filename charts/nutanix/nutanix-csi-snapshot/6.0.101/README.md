# Nutanix CSI Snapshot Controller Helm chart

## Introduction

It is the responsibility of the Kubernetes distribution to deploy the snapshot controller, Webhook validation as well as the related custom resource definitions. For more information, see [CSI Volume Snapshots](https://kubernetes.io/docs/concepts/storage/volume-snapshots/).

If your Kubernetes Distribution Does Not Bundle the Snapshot Components you can use this Helm Chart to deploys it in your cluster. This is required for CSI snapshotting to work and is not specific to any CSI driver.


## Important notice

Starting with version 2.5 of the `nutanix-csi-storage` chart we separate the Snapshot components to a second independent Chart (this one).
If you plan to update an existing Nutanix CSI Chart version < v2.5.x with this Chart, you need to check below recommendation.
### Upgrading from `nutanix-csi-storage` helm chart deployment
If you deployed the `nutanix-csi-storage` Helm Chart in version < 2.5 in the past, first you need update the `nutanix-csi-storage` and next apply the following procedure to deploy the `nutanix-csi-snapshot` Helm Chart.

```bash
HELM_CRD_NAME="nutanix-snapshot"
HELM_CRD_NAMESPACE="ntnx-system"

kubectl patch crd volumesnapshotclasses.snapshot.storage.k8s.io -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch crd volumesnapshotcontents.snapshot.storage.k8s.io -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch crd volumesnapshots.snapshot.storage.k8s.io -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

helm install -n ${HELM_CRD_NAMESPACE} ${HELM_CRD_NAME} nutanix-csi-snapshot
```

### Upgrading from Nutanix CSI yaml based deployment
If you are upgrading CSI driver installed from yaml based deployment, you need to apply the following procedure to deploy the `nutanix-csi-snapshot` Helm Chart.

```bash
HELM_CRD_NAME="nutanix-snapshot"
HELM_CRD_NAMESPACE="ntnx-system"

kubectl patch crd volumesnapshotclasses.snapshot.storage.k8s.io -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch crd volumesnapshotcontents.snapshot.storage.k8s.io -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch crd volumesnapshots.snapshot.storage.k8s.io -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

kubectl patch sa snapshot-controller -n ${HELM_CRD_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch ClusterRole snapshot-controller-runner -n ${HELM_CRD_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch ClusterRoleBinding snapshot-controller-role -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch Role snapshot-controller-leaderelection -n ${HELM_CRD_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch RoleBinding snapshot-controller-leaderelection -n ${HELM_CRD_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'
kubectl patch StatefulSet snapshot-controller -n ${HELM_CRD_NAMESPACE} -p '{"metadata": {"annotations":{"meta.helm.sh/release-name":"'"${HELM_CRD_NAME}"'","meta.helm.sh/release-namespace":"'"${HELM_CRD_NAMESPACE}"'"}, "labels":{"app.kubernetes.io/managed-by":"Helm"}}}'

helm install -n ${HELM_CRD_NAMESPACE} ${HELM_CRD_NAME} nutanix-csi-snapshot
```

Warning: If you delete this Helm chart, it will remove Snapshot CRDs and all existing snapshot.

## Install

The following commands install this chart in your cluster. See [below](#configuration) for available configuration
options.

```
helm repo add nutanix https://nutanix.github.io/helm/
helm install nutanix-csi-snapshot nutanix/nutanix-csi-snapshot -n ntnx-system --create-namespace
```

## Upgrade

Upgrades can be done using the normal Helm upgrade mechanism

```
helm repo update
helm upgrade nutanix-csi-snapshot nutanix/nutanix-csi-snapshot
```

You can renew webhook certificate during an upgrade by specifiying `--set "tls.renew=true"`.

## Configuration

Kubernetes Webhooks need to run on HTTPS and for this they need a certificate. This charts offers several options:

* Generate a self-signed certificate.

    This is the default method.  
    You can define the certificate validity with the `tls.validityDuration` value ( default: 3650 days ).  
    If you want to renew the certificate, specify `--set "tls.renew=true"` during an upgrade.

* Use a pre-existing certificate stored in an existing [`kubernetes.io/tls`] secret.

    To use this method, set `--set tls.source=secret`.  
    The secret must be in the same namespace, the secret name need to match with `tls.Secretname` value (default: snapshot-validation-webhook-cert ) and be valid for `snapshot-validation-service.<namespace>.svc`.

The following table lists the configurable parameters of the Nutanix-CSI chart and their default values.

| Parameter                          | Description                                                                       | Default                              |
|------------------------------------|-----------------------------------------------------------------------------------|--------------------------------------|
| `tls.source`                       | Source of the Certificate for the Webhook. Possible values: `generate`, `secret`. | `generate`                           |
| `tls.renew`                        | Force renewal of certificate when auto-generating.                                | `false`                              |
| `tls.secretName`                   | Name of the secret where certificate are stored.                                  | `"snapshot-validation-webhook-cert"` |
| `tls.validityDuration`             | Certificate Validity in day(s).                                                   | `3650`                               |
| `validationWebHook.replicas`       | Number of validationWebHook replicas to deploy.                                   | `2`                                  |
| `validationWebHook.timeoutSeconds` | Timeout to use when contacting webhook server.                                    | `2`                                  |
| `validationWebHook.failurePolicy`  | Policy to apply when webhook is unavailable. Possible values: `Fail`, `Ignore`.   | `Fail`                               |
| `nodeSelector`                     | Add nodeSelector to all pods                                                      | `{}`                                 |
| `tolerations`                      | Add tolerations to all pods                                                       | `[]`                                 |
| `imagePullPolicy`                  | Specify imagePullPolicy for all pods                                              | `IfNotPresent`                       |
| `controller.replicas`              | Number of controller replicas to deploy.                                          | `2`                                  |
| `controller.nodeSelector`          | Add nodeSelector to controller pod                                                | `{}`                                 |
| `controller.tolerations`           | Add tolerations to controller pod                                                 | `[]`                                 |
| `validationWebHook.nodeSelector`   | Add nodeSelector to validationWebHook pods                                        | `{}`                                 |
| `validationWebHook.tolerations`    | Add tolerations to validationWebHook pods                                         | `[]`                                 |

[`kubernetes.io/tls`]: https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets

## Support

The Nutanix CSI Volume Driver is fully supported by Nutanix. Please use the standard support procedure to file a ticket [here](https://www.nutanix.com/support-services/product-support).

## Community

Please file any issues, questions or feature requests you may have [here](https://github.com/kubernetes-csi/external-snapshotter/issues) for the CSI Snapshotter or [here](https://github.com/nutanix/helm/issues) for the Nutanix CSI Snapshot Helm chart.

## Contributing

We value all feedback and contributions. If you find any issues or want to contribute, please feel free to open an issue or file a PR.
