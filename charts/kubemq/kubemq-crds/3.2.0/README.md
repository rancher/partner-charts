# kubemq-crds

`kubemq-crds` is the Helm chart that installs the Custom Resources Definition
required by the KubeMQ stack. It should be installed before installing
`kubemq-controller`, `kubemq-cluster` and `kubemq-connector` charts.

## Installing

For example:
```console
$ helm repo add kubemq-charts  https://kubemq-io.github.io/charts
$ helm install --create-namespace -n kubemq kubemq-crds kubemq-charts/kubemq-crds
```

For a more comprehensive documentation about how to install the whole KubeMQ
stack, check the `kubemq-controller` ,`kubemq-cluster` and `kubemq-connector` charts documentation out.

## Upgrading the CRDs

**Helm never upgrades CRDs that ship in a chart's `crds/` directory.** Helm installs the
CRDs from `crds/` once, on the first `helm install`, and leaves them **untouched** on every
subsequent `helm upgrade`. This chart's path is therefore for **fresh installs / initial
chart-managed CRDs only**.

**To move an installed CRD schema forward, the PRIMARY path is
`kubectl apply -f <canonical>`:**

```console
$ kubectl apply -f https://raw.githubusercontent.com/.../kubemqclusters.core.k8s.kubemq.io.crd.yaml
```

Adopting an already-installed CRD into this chart requires Helm **adoption annotations**
(`meta.helm.sh/release-name`, `meta.helm.sh/release-namespace`, and the
`app.kubernetes.io/managed-by: Helm` label); without them, chart adoption fails. When any
release note says "upgrade CRDs", it means run the `kubectl apply` above.

Please also refer to the release notes of each version of the helm charts.
These can be found [here](https://github.com/kubemq-io/charts/releases).

## Uninstalling the charts

To uninstall/delete kubemq-crds use the following command:

```console
$ helm uninstall -n kubemq kubemq-crds
```

The commands remove all the Kubernetes components associated with the chart.
Keep in mind that the chart is required by the `kubemq-controller`, `kubemq-cluster` and `kubemq-connector` charts.

If you want to keep the history use `--keep-history` flag.

> **The CRDs are NOT deleted by `helm uninstall`** (they ship in the chart's `crds/`
> directory, which Helm never deletes). This is deliberate: deleting a CRD garbage-collects
> **every** `KubemqCluster` / `KubemqConnector` on the cluster. To remove the CRDs — and, with
> them, all remaining KubeMQ resources — do it explicitly:
> ```console
> $ kubectl delete crd kubemqclusters.core.k8s.kubemq.io kubemqconnectors.core.k8s.kubemq.io
> ```
>
> **Migration note (chart versions where the CRDs previously shipped under `templates/`,
> i.e. `< 3.0.1`):** those versions had the CRDs Helm-managed. A `helm upgrade` across the
> move to `crds/` would otherwise let Helm delete them (they leave the templated manifest and
> `crds/` is not applied on upgrade). Before that one upgrade, pin them so Helm keeps them:
> ```console
> $ kubectl annotate crd kubemqclusters.core.k8s.kubemq.io kubemqconnectors.core.k8s.kubemq.io \
>     helm.sh/resource-policy=keep --overwrite
> ```
> Fresh installs of `>= 3.0.1` need nothing — the CRDs are install-once in `crds/`.
