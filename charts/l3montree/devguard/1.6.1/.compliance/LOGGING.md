---
# Logging and monitoring configuration evidence entries.
# Protocols:
#   file://  → assert path exists in repo; scan for logging configuration presence
#   https:// → HTTP GET → assert 200 (links to logging architecture docs)
evidences: []
  # - url: file://k8s/values.yaml
  # - url: https://docs.example.com/operations/logging
---

# Security Logging and Monitoring

## Annex I, Part I(2)(l) — Security Logging and Monitoring

> (l) provide security related information by recording and monitoring relevant internal activity, including the access to
> or modification of data, services or functions, with an opt-out mechanism for the user;

**Question: What security-relevant events does this product emit in its logs by default? (e.g., authentication attempts, privilege escalations, configuration changes, data access, administrative actions)** `[maintainer]`

DevGuard emits structured logs via Go's `slog` package to stderr. The log handler uses `tint` for human-readable coloured output with key-value fields (timestamp, log level, source location, message, contextual metadata). Ory Kratos logs authentication events (login attempts, registration, recovery) to its own log stream using its default configuration.

Security-relevant events logged by the DevGuard API include:

- Access denied events with user ID, target object, and attempted action (`access_control_middlewares.go`)
- Insufficient PAT scope errors with required vs. actual scopes
- HTTP request metadata (method, URL, status code, duration) for every handled request (`logging_middleware.go`)
- Database errors via a custom GORM logger that forwards to the error tracking system

At the application level, DevGuard maintains audit trails via `VulnEvent` records for all vulnerability lifecycle events:

- State transitions: detected, accepted, false-positive, fixed, reopened, mitigated
- Each event stores: user ID (attribution), justification text, mechanical justification type, vulnerability ID, asset version, and timestamp
- Events flagged as created by automated VEX rules are distinguished from manual actions
- The data model has no soft-delete mechanism; events are append-only by design

**Question: Are logs written in a structured, machine-readable format? (e.g., JSON, CEF — enabling integration with Security Information and Event Management (SIEM) systems)** `[maintainer]`

Logs are written in a human-readable key-value format to stderr via the `tint` slog handler (not JSON). Fields include timestamp, log level, source file/line, message, and contextual key-value pairs. Standard log collectors (Fluentd, Fluent Bit, Vector) can parse this format with appropriate parsers and forward to SIEM systems.

> **Known gap**: The log format is not machine-readable JSON. Switching to `slog.NewJSONHandler` would improve SIEM integration without application changes, as all log calls already use structured `slog` fields.

**Question: Can operators configure the verbosity or scope of security logging without modifying source code?** `[maintainer]`

The log level is configurable.

The OpenTelemetry trace sampling rate is configurable, and the trace exporter can be switched between stdout and OTLP. 

**Question: Does the product provide an opt-out mechanism for security logging, as required by the regulation?** `[maintainer]`

DevGuard does not currently provide a user-facing opt-out mechanism for specific security logging.

At the deployment level, operators can disable the OpenTelemetry tracing sidecar in the Helm values or overwrite logging level.

> **Known gap**: No user-facing opt-out mechanism exists for security-related logging.


**Question: Can operators export or forward logs to their own monitoring infrastructure? (e.g., syslog, OpenTelemetry, Loki, Elasticsearch)** `[maintainer]`

All application logs are emitted to stderr, which is the standard Kubernetes pattern for log collection. Operators can use any log forwarder (Fluentd, Fluent Bit, Promtail, Vector) to ship logs to their infrastructure (Loki, Elasticsearch, Splunk, etc.).

DevGuard supports distributed tracing via an optional OpenTelemetry Collector sidecar.

Prometheus metrics are available via ServiceMonitor resources for both the API and PostgreSQL (via postgres-exporter). A built-in Grafana dashboard ("DevGuard — Span Metrics") is shipped in the Helm chart, showing latency percentiles, error rates, and request throughput.

**Question: How are logs protected against tampering or deletion in the production deployment?** `[manufacturer]`

This question must be answered by the operator. DevGuard emits logs to stderr and does not implement log protection itself. Operators are responsible for configuring their log collection pipeline (e.g. append-only log storage, write-once buckets, tamper-evident forwarding) to protect logs against manipulation.

**Question: What is the log retention period configured in the deployment?** `[manufacturer]`

This question must be answered by the operator. DevGuard does not control log retention. Retention is determined by the operator's log aggregation infrastructure.

**Question: Is there monitoring or alerting configured on security-relevant log events in the deployment? (e.g., repeated authentication failures, unusual access patterns)** `[manufacturer]`

This question must be answered by the operator. DevGuard ships a Grafana dashboard for span metrics (latency, error rates, throughput) and provides ServiceMonitor resources for Prometheus scraping. Alerting rules on specific security events (e.g. repeated access denials, authentication failures) must be configured by the operator in their monitoring stack.
