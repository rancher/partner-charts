# Airlock Microgateway

*Airlock Microgateway is a Kubernetes native WAAP (Web Application and API Protection) solution to protect microservices.*

## Features
* Kubernetes native integration with Gateway API
* Comprehensive set of security features, including deny rules to protect against known attacks (OWASP Top 10), header filtering, JSON parsing, OpenAPI specification enforcement, GraphQL schema validation, and antivirus scanning with ICAP
* Identity aware proxy which makes it possible to enforce authentication using client certificate based authentication, JWT authentication or OIDC with step-up authentication to realize multi factor authentication (MFA). Provides OAuth 2.0 Token Introspection and Token Exchange for continuous validation and secure delegation across services
* Reverse proxy functionality with request routing rules, TLS termination, and remote IP extraction
* Easy-to-use Grafana dashboards which provide valuable insights in allowed and blocked traffic and other metrics


## Requirements
* [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api)

  ## What’s next

  After installing the Airlock Microgateway Operator, the various [Configuration Guides](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000146) describe how to deploy and configure a Gateway in your cluster and how to implement common scenarios.

  ***Note:*** Several features require a license. See [Community vs. Premium editions in detail](https://docs.airlock.com/microgateway/latest/?topic=MGW-00000056) to choose the right license type.
