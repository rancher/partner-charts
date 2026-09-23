# OpenBao

OpenBao is an open source, community-driven fork of Vault managed by the Linux Foundation.

Use cases:

* Secure Secret Storage
  * Arbitrary key/value secrets can be stored in OpenBao. OpenBao encrypts these secrets prior to writing them to persistent storage, so gaining access to the raw storage is not enough to access your secrets.
* Dynamic Secrets
  * OpenBao can generate secrets on-demand for some systems, such as Kubernetes or SQL databases. After creating these dynamic secrets, OpenBao will also automatically revoke them after the lease is up.
* Data Encryption
  * OpenBao provides encryption as a service with centralized key management to simplify encrypting data in transit and stored across clouds and datacenters.
* Identity based access
  * Organizations need a way to manage identity sprawl with the use of different clouds, services, and systems. OpenBao solves this challenge by using a unified ACL system to broker access to systems and secrets and merges identities across providers.
* Leasing and Renewal
  * All secrets in OpenBao have a lease associated with them. At the end of the lease, OpenBao will automatically revoke that secret. Clients are able to renew leases via built-in renew APIs.
* Revocation
  * OpenBao has built-in support for secret revocation. OpenBao can revoke not only single secrets, but a tree of secrets, for example all secrets read by a specific user, or all secrets of a particular type.
