# AlchemiStudio Platform

The **AlchemiStudio AI platform** (web, AI, compute, workers, guardrails, and auth), packaged for SUSE Rancher / AI Factory.

## What you get
- A **full, working install** on your RKE2 / Rancher-managed cluster from one guided form.
- **Images pull automatically** from AlchemiStudio's registry — no credentials to set up.
- Runs in **fixed-seats mode** — no license key required to install and evaluate.
- Bundled by default: **PostgreSQL, Redis, object storage, Keycloak** — nothing external to provision.

## Before you install
Your cluster already exists — the trial only asks for **application** settings:
- **Base domain** (e.g. `alchemi.acme.com`) and TLS mode (`selfsigned` is fine for trials)
- **Admin email** — this becomes your first login
- Optional: sizing tier, SMTP, and LLM provider keys

You do **not** need to configure a registry, credentials, VNet, or nodes.

## ⏱️ Before you click Install — raise the timeout to 30 minutes
The first install pulls **several GB of images**, which can exceed Rancher's default **10-minute** timeout and leave the release stuck (*"another operation in progress"*). Raise it:

1. On **Step 1 (Metadata)**, tick **"Customize Helm options before install"** — this reveals a **Helm Options** step.

   ![Tick “Customize Helm options before install”](https://zentiencelabs.github.io/alchemi-public-helm-charts/docs/rancher-customize-helm.png)

2. Open the **Helm Options** step and change **Timeout** from `600` to **`1800`** (30 minutes). *(Alternatively, uncheck **Wait** — the app then reports "deployed" immediately and pods finish in the background.)*

   ![Set Timeout to 1800 in Helm Options](https://zentiencelabs.github.io/alchemi-public-helm-charts/docs/rancher-helm-timeout.png)

Then continue to **Values**, fill in your **domain** and **admin email**, and Install.

## AI guardrails are OFF by default — enable when you're ready
The **AI-safety tier** (PII, secret-detection, jailbreak, toxicity, topical, content-filter) is **disabled by default** to keep the first install fast (it adds 6 services and pulls several GB of model images). To turn it on:

1. On the **Values** step, enable **"Enable AI guardrails"**.
2. Because it's heavy, **also raise the Timeout to `1800`** (Helm Options, as above).

Best practice: install **without** guardrails first, then enable it later as an **Upgrade** with the 30-minute timeout.

## Prefer the command line?
```sh
helm repo add alchemi https://zentiencelabs.github.io/alchemi-public-helm-charts
helm repo update
helm install alchemistudio-platform alchemi/alchemistudio-platform --version 1.1.0 \
  -n alchemi --create-namespace \
  --set global.domain=alchemi.acme.com \
  --set admin.email=you@acme.com \
  --wait --timeout 30m
```
(no registry creds needed — the trial pull-token is baked into the chart.)

## Moving to production
When you're ready to run in production — your **own registry**, a **license**, multi-tenant scale, and support — reach out and we'll set you up (it's an in-place upgrade of this same install; your data is preserved):

**📧 support@alchemistudio.ai**

Production adds: mirroring images into your own registry, a licensed plan (managed centrally, no redeploy), and air-gapped options.

---
*Trial usage is subject to fixed-seat limits. The trial registers with AlchemiStudio so we can support your evaluation.*
