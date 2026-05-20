# Airlock Microgateway

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

## Features
* Kubernetes native integration with Gateway API
* Comprehensive set of security features, including deny rules to protect against known attacks (OWASP Top 10), header filtering, JSON parsing, OpenAPI specification enforcement, GraphQL schema validation, and antivirus scanning with ICAP
* Identity aware proxy which makes it possible to enforce authentication using client certificate based authentication, JWT authentication or OIDC with step-up authentication to realize multi factor authentication (MFA). Provides OAuth 2.0 Token Introspection and Token Exchange for continuous validation and secure delegation across services
* Reverse proxy functionality with request routing rules, TLS termination, and remote IP extraction
* Easy-to-use Grafana dashboards which provide valuable insights in allowed and blocked traffic and other metrics

For a list of all features, view the **[comparison of the community and premium edition](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)**.

## Requirements
* [Airlock Microgateway License](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056)
* [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api)

## Documentation and links

Check the official documentation at **[docs.airlock.com](https://docs.airlock.com/microgateway/latest/)** or the product website at **[airlock.com/microgateway](https://www.airlock.com/en/microgateway)**. The links below point out the most interesting documentation sites when starting with Airlock Microgateway.

* [Getting Started](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000059)
* [System Architecture](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000137)
* [Installation](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000138)
* [Troubleshooting](https://docs.airlock.com/microgateway/latest/index/1659430054787.html)
* [GitHub](https://github.com/airlock/microgateway)