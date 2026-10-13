# HariKube

## 🧭 What Is HariKube?

**HariKube is a petabyte-scale, versioned state machine for any kind of data - using Kubernetes as its API and Kafka as its real-time event stream.**

### What It Does  

It acts as a single, central source of truth that tracks every single state change over time (versioning) across your entire system.

#### Imagine a Webshop on HariKube:  

An order isn't scattered across five isolated databases. It exists as a single versioned state object. When a customer purchases an item, your CNCF-compliant service processes the state transition (Created > Paid > Shipped), HariKube tracks the entire history, and streams the updates in real time - all through one unified API.

### Why It Matters

* **The Big Picture:** Standard Kubernetes breaks when forced to handle massive business state because consensus and memory have hard ceilings. HariKube replaces etcd with heavy-duty database engines, turning Kubernetes into a massive, resilient and scalable state platform.
* **For Operators:** You manage drastically fewer clusters and infrastructure layers because HariKube handles your scale in well-known databases, eliminating cluster sprawl and operational overhead.
* **For Developers:** It solves the trade-off between monoliths and microservices:
  * *Monolith simplicity:* One consistent state engine with full history - no more fragile sync code or data silos.
  * *Microservice power:* High-throughput event streaming (Kafka) and horizontal scaling out of the box.
* **For Your Business:** By unifying your business data and infrastructure into a single state engine, HariKube eliminates the custom integration code and sync pipelines that usually delay launches, letting you ship new features in days instead of months.

> ✅ HariKube isn't a Kubernetes-inspired API or a custom control plane that happens to look like Kubernetes. It is designed to preserve Kubernetes API semantics and has passed the Kubernetes conformance test suite. Test it today.

## Why this fork exists?

Both ETCD and Kine are limited by Kubernetes API server itself and how it filters data. API server manages an O(n) cache in memory, and filters data at client side, because both ETCD and Kine are lacking on data filtering. The only real option is vertical scaling of all (API, ETCD, Kine). An average cluster dies at 50-100k records. Of course, you can add more ram, more iops, but these are just postponing the problem.

By changing a few lines of Kubernetes and a few lines of Kine, this project is able to send filtering to the database level. With these changes it is able to disable watch cache in Kubernetes API, and consumes O(1) memory during operation.

Here are some benchmark results on Ultra 7 165H 18 Core 4G, single VM ran everything including the k6 benchmark itself. 120 vus, each vu created a custom resource (6 different type) and read it back via label selector:

- Vanilla Kubernetes with 3 node ETCD cluster:

```
checks_succeeded...: 100.00% 51236 out of 51236
checks_failed......: 0.00% 0 out of 51236
http_req_duration..............: avg=799.54ms min=3.87ms med=82.39ms max=4.17s p(90)=2.47s p(95)=2.82s
http_req_failed................: 0.00% 0 out of 51236
http_reqs......................: 51236 24.976013/s

time="2026-02-14T19:07:26Z" level=error msg="test run was aborted because k6 received a 'interrupt' signal" make: *** [Makefile:589: k6s-start] Error 105

OOM Killed, thanks API server
```

- HariKube OSS with Postgres:

```
checks_succeeded...: 100.00% 101772 out of 101772
checks_failed......: 0.00%   0 out of 101772
http_req_duration..............: avg=708.33ms min=6.4ms    med=300.67ms max=6.2s  p(90)=1.99s p(95)=2.48s
http_req_failed................: 0.00%  0 out of 101772
http_reqs......................: 101772 28.188433/s
```

## The numbers are talking for themselves

| Metric | HariKube OSS | Vanilla K8s |
| - | - | - |
| Throughput | 28 req/s ✅ | 25 req/s ❌ |
| Success Rate | 100% ✅ | 100% (OOM) ❌ |
| Latency average | 708ms ✅ | 799ms ❌ |
| Latency p95 | 2480ms ✅ | 2820ms ❌ |
| Latency p90 | 1990ms ✅ | 2470ms ❌ |
| Test Duration | 60m ✅ | ~34m (OOM) ❌ |
| Stability | Completed ✅ | KILLED ❌ |
| Objects Handled | 50k ✅ | ~26k (OOM) ❌ |

### HariKube on steroids with 6 Postgres

```
checks_succeeded...: 100.00% 429180 out of 429180
checks_failed......: 0.00% 0 out of 429180
http_req_duration..............: avg=167.17ms min=7.75ms med=71.06ms max=3.71s p(90)=398ms p(95)=543.76ms
http_req_failed................: 0.00% 0 out of 429180
http_reqs......................: 429180 119.106435/s
```

| Metric | HariKube AE | Vanilla K8s | Gain |
| - | - | - | - |
| Throughput | 119 req/s ✅ | 25 req/s ❌ | 4.8x |
| Success Rate | 100% ✅ | 100% (then OOM) ❌ | not comparable |
| Latency average | 167ms ✅ | 799ms ❌ | 4.8x |
| Latency p95 | 543ms ✅ | 2820ms ❌ | 5.2x |
| Latency p90 | 398ms ✅ | 2470ms ❌ | 6.2x |
| Test Duration | 60m ✅ | ~34m (OOM) ❌ | not comparable |
| Stability | Completed ✅ | KILLED ❌ | not comparable |
| Objects Handled | 200k+ ✅ | ~26k (crashed) ❌ | 4x |

Open-Source edition is designed to interface with a single backend database instance at a time, which can become a performance bottleneck as your cluster grows. To address this, our business editions introduce various data routing capabilities. This allows you to distribute workloads across multiple database backends simultaneously, ensuring horizontal scalability for even the most demanding environments. Check out which [edition](https://harikube.info/editions/) fit's to your use-case.

## Installation

### Prerequisets

- Kubernetes cluster; supported versions Vanilla, EKS, AKS, GKE, RKE2, OpenShift >=1.34.0
- Adding CRDs if any of the `monitoring.create` is `true` via `kubectl apply -f https://raw.githubusercontent.com/HariKube/harikube-helm-charts/refs/heads/${{ steps.extract_branch.outputs.branch }}/operator-crd.yaml`

### Helm Deploy

```bash
helm install harikube oci://quay.io/harikube/harikube \
    --version ${{ steps.extract_version.outputs.version }} \
    --create-namespace \
    --namespace harikube \
    --set vcluster.exportKubeConfig.server=https://harikube.harikube:443
kubectl wait -n harikube --for=jsonpath='{.status.readyReplicas}'=1 statefulset/harikube --timeout=5m
```

> If you change namespace, please `--set vcluster.exportKubeConfig.server=https://harikube.<NAMESPACE>:443`

You can integrate services with cert-manager.

```bash
--set certManagerIntegration.create=true
```

You can enable network policies. You have to create namespace manually, label the namespace and skip `--create-namespace` flag.

```bash
--set middleware.networkPolicy.create=true # kubectl label namespace harikube harikube.info/<NAMESPACE>-middleware=enabled --overwrite
```

You can enable ServiceMonitors for middleware.

```bash
--set middleware.monitoring.create=true
```

You can enable the MutatingAdmissionPolicy to label non core resources with skip-controller-manager-metadata-caching.

```bash
--set mutatingAdmissionPolicy.create=true
```

You can enable a scalable contorl plane extension.

```bash
--set apiServer.create=true
--set controllerManager.create=true # By default all controllers are disabled, enable controllers you want to run.
```

You can enable network policies for control plane.

```bash
--set apiServer.networkPolicy.create=true # kubectl label namespace harikube harikube.info/<NAMESPACE>-apiserver=enabled --overwrite
--set controllerManager.networkPolicy.create=true # kubectl label namespace harikube harikube.info/<NAMESPACE>-controllermanager=enabled --overwrite
```

You can enable ServiceMonitors per service.

```bash
--set apiServer.monitoring.create=true
--set controllerManager.monitoring.create=true
```

#### Enterprise Editioin

Set `enterprise.key`, `enterprise.user` and `enterprise.password`, then set `operator.create=true` and the chart will deploy licensed edition to the target cluster.

## vCluster connection

Connect via vCluster CLI.

```bash
vcluster connect harikube
```

Connect via vCluster KUBECONFIG.

```bash
kubectl get secret -n harikube vc-harikube -o yaml
```

> 🔓 vCluster simplifies the operational workflow by automatically updating your local environment. For more details how to disable this behaviour, or how to get config by service account for example please wisit the official docs` [Access and expose vCluster](https://www.vcluster.com/docs/vcluster/manage/accessing-vcluster) section.

> 🔓 For service access from host, the vCluster setup keeps things simple: Create your ServiceAccount, create a secret annotated with `kubernetes.io/service-account.name` (example below), and vCluster will sync the secret to the host cluster.

```yaml
apiVersion: v1
kind: Secret
metadata:
    name: remote-your-service-account-name
    annotations:
    kubernetes.io/service-account.name: "your-service-account-name"
type: kubernetes.io/service-account-token
```

On the host cluster, you can fetch the connection details.

```bash
KUBE_API_URL=harikube.harikube.svc.cluster.local
TOKEN=$(kubectl get secret -n harikube remote-your-service-account-name-x-default-x-harikube -o jsonpath='{.data.token}' | base64 -d)
CA_CERT=$(kubectl get secret -n harikube remote-your-service-account-name-x-default-x-harikube -o jsonpath='{.data.ca\.crt}' | base64 -d)
```

## Customization

The manifests gereted for the release are covering basic setup. You can customize your setup, by changing `vcluster` values.

## Important Requirement

To use these features to their full potential, you cannot use "standard" Kubernetes. You must use the patched images provided by us These patches allow the Kubernetes API to understand the special storage instructions Kine is waiting for.

- [Kubernetes Patches](https://github.com/HariKube/kubernetes-patches)
- [Patched Images](https://quay.io/repository/harikube/kubernetes?tab=tags&tag=latest)

## 🤝 Contribution Guide

We welcome and encourage contributions from the community! Whether it's a bug fix, a new feature, or an improvement to the documentation, your help is greatly appreciated.

Before you get started, please take a moment to review our guidelines:

- Read the Documentation: Familiarize yourself with the framework's architecture and existing features.
- Open an Issue: For any significant changes or new features, please open an issue first to discuss the idea. This helps prevent duplicated work and ensures alignment with the project's goals.
- Fork the Repository: Fork the repository to your own GitHub account.
- Create a Branch: Create a new branch for your feature or bug fix: git checkout -b feature-my-awesome-feature.
- Commit Your Changes: Make your changes and commit them with a clear and descriptive message.
- Submit a Pull Request: Push your branch to your forked repository and open a pull request against the main branch of this repository. Please provide a clear description of your changes in the PR.

We are committed to providing a friendly, safe, and welcoming environment for all, regardless of background or experience. We are following Kubernetes Please see them [Code of Conduct](https://kubernetes.io/community/code-of-conduct/) for more details.

## 🙏 Share Feedback and Report Issues

Your feedback is invaluable in helping us improve this operator. If you encounter any issues, have a suggestion for a new feature, or simply want to share your experience, we want to hear from you!

- Report Bugs: If you find a bug, please open a [GitHub Issue](https://github.com/HariKube/harikube-helm-charts/issues). Include as much detail as possible, such as steps to reproduce the bug, expected behavior, and your environment (e.g., Kubernetes version, Go version).
- Request a Feature: If you have an idea for a new feature, open a [GitHub Issue](https://github.com/HariKube/harikube-helm-charts/issues) and use the `enhancement` label. Describe the use case and how the new feature would benefit the community.
- Ask a Question: For general questions or discussions, please use the [GitHub Discussions](https://github.com/HariKube/harikube-helm-charts/discussions).
