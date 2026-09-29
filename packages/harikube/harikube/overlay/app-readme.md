# HariKube

## Introduction

This chart bootstraps the [HariKube Kubernetes Hyper-scaler](https://github.com/HariKube/harikube) using the [Helm](https://helm.sh) package manager.

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

## Supported Versions

| Edition | Version |
|-|-|
| Open Source | v0.15.0, v0.16.3 | 
| Enterprise | Coming soon ... |

### Helm Deploy

```bash
helm install harikube oci://quay.io/harikube/harikube \
    --version ${{ steps.extract_version.outputs.version }} \
    --create-namespace \
    --namespace harikube \
    --set vcluster.exportKubeConfig.server=https://harikube.harikube:443
kubectl wait -n harikube --for=jsonpath='{.status.readyReplicas}'=1 statefulset/harikube --timeout=5m
```
