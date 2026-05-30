# Epinio

[Epinio](https://epinio.io) is an opinionated Platform-as-a-Service (PaaS) that runs on Kubernetes. It lets you deploy applications directly from source code with a single command — no Dockerfiles, no Kubernetes manifests, no CI pipelines required. Epinio wraps Cloud Native Buildpacks to automatically detect and build your application, then deploys it to your cluster and exposes it via an ingress.

## Prerequisites

Before installing Epinio, ensure the following are present in your cluster:

- **cert-manager** — Epinio uses it to issue TLS certificates for its API server, registry, and applications.
- **An Ingress controller** — NGINX Ingress Controller is recommended. Both the Epinio API server and deployed applications are reached via ingress.
- **A wildcard DNS entry** — All applications share a single wildcard domain (e.g. `*.apps.example.com`). Point this DNS record to your ingress controller's external IP.

## Key Features

- Single-command source-to-URL deployments (`epinio push`)
- Built-in container registry (or bring your own)
- Built-in S3-compatible object storage via MinIO (or bring your own S3/S3-compatible bucket)
- OIDC authentication via Dex (optional)
- Rancher UI extension for in-dashboard application management

## Documentation

Full documentation, including quickstart guides, configuration reference, and troubleshooting, is available at [https://docs.epinio.io](https://docs.epinio.io).
