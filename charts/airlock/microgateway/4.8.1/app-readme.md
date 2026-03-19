# Airlock Microgateway

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

## Features
* Kubernetes native integration with sidecar injection and Gateway API support
* Reverse proxy functionality with request routing rules, TLS termination and remote IP extraction
* Using native Envoy HTTP filters like Lua scripting, RBAC, ext_authz, JWT authentication
* Content security filters for protecting against known attacks (OWASP Top 10)
* Access control using OpenID Connect to allow only authenticated users to access the protected services
* API security features like JSON parsing, OpenAPI specification enforcement or GraphQL schema validation

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)**.

## Requirements
* (Recommended) [Airlock Microgateway CNI Helm Chart](https://artifacthub.io/packages/helm/airlock-microgateway-cni/microgateway-cni) (Required for [data plane mode sidecar](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137). Also available as Rancher Chart)
* [Airlock Microgateway License](https://github.com/airlock/microgateway?tab=readme-ov-file#obtain-airlock-microgateway-license) (After obtaining the license install it according to the [documentation](https://github.com/airlock/microgateway?tab=readme-ov-file#deploy-airlock-microgateway-operator))
* [cert-manager](https://cert-manager.io/docs/installation/)

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000059)
* [System Architecture](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137)
* [Installation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/index/1659430054787.html)
* [GitHub](https://github.com/airlock/microgateway)