# Trusted Certificate Service

## Introduction

Trusted Certificate Service (TCS) is a Kubernetes certificate signing application, which protects the signing keys using Intel's SGX technology. TCS supports [Kubernetes Certificate Signing Request](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/) and [cert-manager certificate request](https://cert-manager.io/docs/concepts/certificaterequest/) APIs. The APIs provides an easy integration to Kubernetes applications such as Istio.

## Prerequisites

- Helm 3.x
- Kubernetes cluster with at least one SGX node (e.g., Azure DCsv3 instance)
- Cert-manager