---
# Resilience and availability evidence entries.
# Protocols:
#   file://  → assert path exists in repo; scan for rate limiting, timeout, and circuit breaker patterns
#   https:// → HTTP GET → assert 200 (links to architecture docs, load test reports)
evidences: []
  # - url: file://k8s/values.yaml
  # - url: https://docs.example.com/architecture/resilience
---

# Resilience and Availability

## Annex I, Part I(2)(h) — Availability and DoS Resilience

> (h) protect the availability of essential and basic functions, also after an incident, including through resilience and
> mitigation measures against denial-of-service attacks;

**Question: What are the essential functions of this product whose availability must be protected?** `[maintainer]`

- **Scan ingestion API**: Accepts vulnerability scan submissions (SARIF, CycloneDX) from CI/CD pipelines and the devguard-scanner CLI
- **Vulnerability management dashboard**: Provides vulnerability status, risk scores, compliance reports, and audit trails to users
- **SBOM and provenance management**: Stores and serves SBOMs, provenance attestations, CSAF advisories, and VEX documents
- **Authentication and access control**: User authentication (via Ory Kratos) and organisation-scoped RBAC (via Casbin)


**Question: What mechanisms does the product implement natively to protect against denial of service attacks? (e.g., built-in rate limiting, request throttling, connection limits, circuit breakers)** `[maintainer]`

DevGuard does not implement application-level rate limiting or request throttling. The only rate limiter in the codebase is on outbound GitLab OAuth2 API calls (10 req/s via `golang.org/x/time/rate` in `gitlab_client_factory.go`), which protects against upstream rate limits, not against inbound DoS.

DoS protection must be provided at the infrastructure layer (ingress controller, reverse proxy, WAF, load balancer). The Helm chart defines Kubernetes resource limits (CPU and memory) for all containers, preventing a single pod from consuming unbounded node resources.

**Question: How does the product behave under resource exhaustion — does it degrade gracefully or fail in a way that could affect other systems?** `[maintainer]`

DevGuard is deployed in Kubernetes with the following resilience mechanisms:

- The API health endpoint (`/api/v1/health`) verifies database connectivity via a `Ping()` call. It does not check Ory Kratos or external integrations.
- Kubernetes liveness and readiness probes are configured for all components. Failed probes trigger automatic pod restarts.
- Resource limits (CPU and memory) are set on all containers. If limits are reached, Kubernetes enforces them (OOMKill or CPU throttling).
- NetworkPolicies (enabled by default) restrict inbound traffic.
- The API and web containers are stateless. The Helm chart supports HorizontalPodAutoscaler for both (disabled by default).

**Post-incident recovery**: Application state is persisted in PostgreSQL. After an incident, operators can restore the database from backup, rotate secrets via Kubernetes Secrets, and redeploy the Helm chart. The backup/restore procedure is documented at https://docs.devguard.org/how-to-guides/administration/backup-restore. Essential functions resume once the pods pass health checks and the database is available.

**Question: What infrastructure-level protections against DoS/DDoS are in place in the deployment? (e.g., WAF, CDN, load balancer rate limiting)** `[manufacturer]`

This question must be answered by the operator. DevGuard does not ship WAF, CDN, or DDoS mitigation. The Helm chart provides NetworkPolicies restricting inbound pod-to-pod traffic but does not configure ingress-level rate limiting or external DDoS protection. Operators must configure these at the infrastructure layer (e.g. ingress controller rate limiting annotations, cloud provider DDoS protection, external WAF).

**Question: What redundancy or failover mechanisms are configured in the deployment for essential functions? (e.g., replicated pods, load balancing, multi-AZ)** `[manufacturer]`

This question must be answered by the operator. The Helm chart provides HorizontalPodAutoscaler templates for the API and web frontend (disabled by default). Operators can enable autoscaling or set static replica counts via Helm values.  PostgreSQL is deployed as a single-instance StatefulSet - operators requiring database HA must provision an external PostgreSQL cluster or use a PostgreSQL operator (e.g. CloudNativePG).

**Question: Have load or stress tests been conducted to verify availability under adverse conditions? If so, what were the results?** `[manufacturer]`

No systematic load or stress tests have been conducted. Operational experience from large installations exists but is not formally documented. The PostgreSQL connection pool is configured with sensible defaults (25 max connections, 5 min connections, 4h max lifetime, 15min idle timeout) and is tuneable via environment variables.

**Question: How are availability incidents detected and responded to in the deployment? (e.g., monitoring, alerting, runbooks, on-call)** `[manufacturer]`

This question must be answered by the operator. DevGuard provides the following building blocks for availability monitoring:

- Health endpoints for all components (API, web, Kratos) used by Kubernetes probes for automatic restart on failure
- Prometheus ServiceMonitor resources for the API (span metrics) and PostgreSQL (postgres-exporter)
- A built-in Grafana dashboard ("DevGuard — Span Metrics") showing latency percentiles, error rates, and request throughput
- OpenTelemetry trace export (optional) for distributed tracing

Operators must configure alerting rules (e.g. in Prometheus/Alertmanager) for security-relevant events and define incident response runbooks for their deployment.
