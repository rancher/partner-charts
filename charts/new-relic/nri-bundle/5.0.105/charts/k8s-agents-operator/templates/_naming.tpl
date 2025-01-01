{{/* Controller manager service certificate's secret. */}}
{{- define "k8s-agents-operator.certificateSecret.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "controller-manager-service-cert") -}}
{{- end }}

{{- define "k8s-agents-operator.webhook.service.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "webhook-service") -}}
{{- end -}}

{{- define "k8s-agents-operator.webhook.mutating.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "mutation") -}}
{{- end -}}

{{- define "k8s-agents-operator.webhook.validating.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "validation") -}}
{{- end -}}

{{- define "k8s-agents-operator.cert-manager.issuer.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "selfsigned-issuer") -}}
{{- end -}}

{{- define "k8s-agents-operator.cert-manager.certificate.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "serving-cert") -}}
{{- end -}}

{{- define "k8s-agents-operator.rbac.proxy.role.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "proxy-role") -}}
{{- end -}}

{{- define "k8s-agents-operator.rbac.proxy.roleBinding.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "proxy-rolebinding") -}}
{{- end -}}

{{- define "k8s-agents-operator.rbac.manager.role.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "manager-role") -}}
{{- end -}}

{{- define "k8s-agents-operator.rbac.manager.roleBinding.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "manager-rolebinding") -}}
{{- end -}}

{{- define "k8s-agents-operator.rbac.leaderElection.role.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "leader-election-role") -}}
{{- end -}}

{{- define "k8s-agents-operator.rbac.leaderElection.roleBinding.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "leader-election-rolebinding") -}}
{{- end -}}

{{- define "k8s-agents-operator.rbac.metricsReader.role.name" -}}
{{- include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "metrics-reader") -}}
{{- end -}}
