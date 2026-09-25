# AlchemiStudio Platform

> **AI governance for modern teams.**

**AlchemiStudio** is an enterprise **AI-governance control plane**: one platform to **build, govern, and run AI agents** across every team, every model, and every workflow — with no compromise on security, visibility, or control. This chart deploys the **complete platform onto your own RKE2 / Rancher-managed cluster** from a single install — no SaaS, your data and models stay in your cluster.

**Four pillars on one shared control plane** (centralized audit, identity, and billing):

- **Cockpit** — admin control plane: real-time spend tracking & budget caps, immutable audit trails, fine-grained RBAC + SSO, and guardrail pipelines (PII, jailbreak, toxicity, secret-detection).
- **Console** — developer gateway: multi-LLM routing with BYOK, an MCP + OpenAPI tool registry, trace replay & debugging, and per-run cost attribution.
- **Codesk** — no-code agent builder: a visual canvas for non-technical users, 1,200+ app connectors, scheduled autonomous workflows, and shared team canvases.
- **Compute** — ephemeral runtime: sub-second isolated sandboxes, runtime secret injection, hard resource caps + timeouts, and auto-teardown on completion.

## What this chart installs

A complete, working platform — nothing external to provision:

| Component | What it does |
|---|---|
| **Web** | The AlchemiStudio UI — Copilot, threads, knowledge, Files, workflows |
| **AI** | The reasoning/agent backend + **AIOS** (the agent "computer" and code sandboxes) |
| **Compute API + Workers** | Sandbox orchestration and background jobs |
| **Zenith** | Operator / admin console |
| **Guardrails** *(optional)* | AI-safety services — PII, secret-detection, jailbreak, toxicity, topical, content-filter |
| **Keycloak** | Authentication / SSO |
| **Data tier** *(bundled)* | PostgreSQL (pgvector), Redis, object storage (SeaweedFS), OpenObserve audit logs |
| **APISIX gateway** | Serves every app at `<subdomain>.<your-domain>` and terminates TLS |

Already run your own PostgreSQL / Redis / object store? Flip the `*.mode=external` toggles and point the chart at them.

## How it's delivered

- **Rancher App** — install from **Apps → Charts**; a guided form collects your domain, admin email, TLS, and options.
- **AI Factory Blueprint** — reference this same chart as a component; installs with values (domain, admin email).

## What you provide

Just application settings — the cluster, registry, and nodes are already yours:

- **Base domain** (e.g. `alchemi.acme.com`) — every app is served at `<subdomain>.<domain>`
- **Admin email** — becomes your first login
- **TLS** — **Bring Your Own Certificate** (`byo`, default — paste your cert + key) or **Let's Encrypt** (`acme`, automatic)
- *Optional:* sizing tier, SMTP, LLM provider keys, and **Enable AI guardrails**

Images pull automatically (a baked, revocable, pull-only trial token), and it runs in **fixed-seats mode** — no license key needed to install and evaluate.

---

# ⚠️ PREREQUISITE — prepare a Kata node (for code execution)

> **Who needs this:** only if you use the **code-execution / AIOS sandbox** features.
> The **core platform** (web, AI, chat, workspaces) installs and runs on **any** cluster
> with **no** node setup — and the install **always succeeds**. But sandbox pods for user
> code stay **`Pending`** until a Kata node exists, so prepare one **before** using those
> features.

**Why Kata:** user-submitted code runs in **Kata Containers** — each sandbox in its own
lightweight **micro-VM** — so untrusted code is hardware-isolated from the platform.
Enabled by default (strong isolation, on purpose).

Prepare **one** node (a small worker is fine) — **in this order**. A chart cannot do any
of these for you:

### Step 1 — pick a KVM-capable node (hardware)
Kata boots real micro-VMs, so the node must have **nested virtualization** (`/dev/kvm`):
- **Cloud:** choose a nested-virt-capable VM **size** — Azure `Dsv5`/`Dsv3`, AWS `*.metal`, GCP with nested virt enabled.
- **Bare-metal:** works by default (VT-x / AMD-V).
- Check: `ls /dev/kvm` (must exist). **This is a property of the machine — it cannot be installed.**

### Step 2 — install the Kata runtime on that node (host-level)
- **SUSE / RKE2:** run our helper **`add-kata-node.sh`** — it checks KVM, installs Kata, and does Step 3 for you.
- **Any Kubernetes:** the upstream **`kata-deploy`** DaemonSet installs the runtime onto existing nodes.

### Step 3 — label + taint the node (two commands)
Your **own** labels — portable across Azure / AWS / SUSE / bare-metal (**not** a cloud's `agentpool`):
```sh
kubectl label node <NODE_NAME> kata=true              # 1) sandboxes TARGET this node
kubectl taint node <NODE_NAME> pool=kata:NoSchedule   # 2) FENCE it — nothing else lands here
```

### Verify
```sh
kubectl get node <NODE_NAME> -o jsonpath='{.metadata.labels.kata}{"\n"}'   # -> true
kubectl get runtimeclass kata                                             # exists after install
kubectl run kata-test --image=busybox --restart=Never --overrides='{"spec":{"runtimeClassName":"kata"}}' -- sleep 20
kubectl get pod kata-test -o wide     # Running on <NODE_NAME>  ->  kubectl delete pod kata-test
```

**Notes**
- **Use the standard labels** (`kata=true` / `pool=kata`) — the platform expects them. *Only* if your node genuinely uses different labels, override `kata.nodeLabelKey`/`nodeLabelValue` + `kata.taintKey`/`taintValue` via the install screen's **"Edit YAML"** tab (they are intentionally **not** editable form fields, so a mismatch can't leave sandboxes `Pending`).
- **No KVM (nested virtualization)?** Kata cannot run there — `gVisor` (`runsc`) is a strong alternative that needs no KVM (contact support to switch the sandbox runtime).

---

## Defaults

- **AIOS is ON** — the Files UI and agent "computer" work out of the box.
- **Guardrails are OFF** — the AI-safety tier is heavy (several GB of model images); enable it any time via the **"Enable AI guardrails"** toggle.
- **First install** pulls several GB of images — see the install-page notes and **allow ~30 minutes**.
- **Code execution needs a Kata node** — see the Kata section above; the core platform installs without it.

## First install takes ~30 minutes — raise the install timeout

The first install pulls several GB of container images, which can exceed Rancher's
**default 10-minute** Helm timeout and leave the release stuck (`another operation is in
progress`). **Before you click Install**, raise the timeout in the Rancher UI:

**1.** On the chart's install page, expand **Customize Helm options before install** (the final "Edit YAML / options" step).

![Rancher — Customize Helm options before install](https://zentiencelabs.github.io/alchemi-public-helm-charts/docs/rancher-customize-helm.png)

**2.** On the **Helm options** step, set **Timeout** to **1800** seconds (30 min), leave **Wait** ticked, then **Install**.

![Rancher — set the Helm Timeout to 1800 seconds](https://zentiencelabs.github.io/alchemi-public-helm-charts/docs/rancher-helm-timeout.png)

> **Enabling guardrails?** The AI-safety tier pulls several more GB of model images, so the 30-minute timeout matters even more — set it whenever **"Enable AI guardrails"** is on.
>
> **CLI equivalent:** `helm install <release> alchemi/alchemistudio-platform --wait --timeout 30m`

If an install or upgrade ever gets stuck on a timeout, clear it with
`helm uninstall <release> -n <namespace>`, then reinstall with the longer timeout.

## Sizing

The platform is **modest** and fits comfortably on a small cluster. Per-pod CPU/memory are **fixed** by each service; the **Deployment tier** changes only **replica counts** — there is **no autoscaling (HPA)** and tier does **not** change per-pod resources.

**Per-service resources** (requests → limits):

| Service | Requests | Limits |
|---|---|---|
| web | 250m / 512Mi | 500m / 1Gi |
| ai | 500m / 1Gi | 1 / 2Gi |
| worker | 100m / 256Mi | 500m / 512Mi |
| compute-api | 75m / 256Mi | 500m / 512Mi |
| zenith | 250m / 512Mi | 500m / 1Gi |

…plus the bundled data tier (PostgreSQL, Redis, SeaweedFS, OpenObserve, Keycloak) and 3 small AIOS workers.

**Tier = replicas** (form field "Deployment tier"):

| | web | ai | everything else |
|---|---|---|---|
| **basic** (default) | 1 | 1 | 1 |
| **standard** | 2 | 2 | 1 |

- **basic** — smallest footprint; whole platform ≈ **~2 CPU / 5.5Gi** requested.
- **standard** — doubles the two load-bearing, user-facing services (web + ai) for throughput + availability; adds **~0.75 CPU / 1.5Gi** → ≈ **~2.75 CPU / 7Gi**.

**AI guardrails** (optional, OFF by default) add **6 stateless services ≈ 2.2 CPU / 6.6Gi** requested (no extra storage). Because guardrails add latency on the AI path, **choose `standard` when you enable them.**

**What your cluster needs:**

| Configuration | CPU (requests) | Memory (requests) | Storage |
|---|---|---|---|
| basic, no guardrails | ~2 CPU | ~5.5Gi | bundled data-tier PVCs |
| standard, no guardrails | ~2.75 CPU | ~7Gi | same |
| standard **+ guardrails** | **~5 CPU** | **~13.5Gi** | same (replicas + guardrails are stateless) |

**Rule of thumb:** a cluster of **≥3 nodes × 4 CPU / 8Gi** (≈12 CPU / 24Gi total) runs **standard + guardrails** with plenty of headroom. The **bundled storage volumes** — not CPU/memory — are the real constraint on tiny Longhorn clusters; the trial defaults are lean (raise `postgres.storage`, `objectStore.bundled.storage`, `aios.dataPlane.storage`, etc. for production).

## After install

The post-install notes show your **URLs, first-login, and next steps**. Point your domain's DNS at the gateway's external IP, and you're in.

## Moving to production

Your own registry, a license, multi-tenant scale, and support — an in-place upgrade of this same install (your data is preserved):

**📧 support@alchemistudio.ai**

---

<sub>ℹ️ **Trial / evaluation install — 30 days.** This chart installs a **30-day trial** of AlchemiStudio in **fixed-seats mode** (no license key required). You get the **full platform for evaluation** — Cockpit, Console, Codesk, and Compute — and images pull via a **revocable, pull-only** trial token. It is **not licensed for production use**. To continue past 30 days or go to production (your own registry, a license, multi-tenant scale, and support), contact **support@alchemistudio.ai**.</sub>
