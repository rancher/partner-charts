{{/* vim: set filetype=mustache: */}}

{{- /* Allow to change pod defaults dynamically */ -}}
{{- define "nri-metadata-injection.securityContext.pod" -}}
{{- if include "newrelic.common.securityContext.pod" . -}}
{{- include "newrelic.common.securityContext.pod" . -}}
{{- else -}}
fsGroup: 1001
runAsUser: 1001
runAsGroup: 1001
{{- end -}}
{{- end -}}

{{- /*
Naming helpers
*/ -}}

{{- define "nri-metadata-injection.name.admission" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "admission") }}
{{- end -}}

{{- define "nri-metadata-injection.fullname.admission" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission") }}
{{- end -}}

{{- define "nri-metadata-injection.fullname.admission.serviceAccount" -}}
{{- if include "newrelic.common.serviceAccount.create" . -}}
  {{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission") }}
{{- else -}}
  {{ include "newrelic.common.serviceAccount.name" . }}
{{- end -}}
{{- end -}}

{{- define "nri-metadata-injection.name.admission-create" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "admission-create") }}
{{- end -}}

{{- define "nri-metadata-injection.fullname.admission-create" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission-create") }}
{{- end -}}

{{- define "nri-metadata-injection.name.admission-patch" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "admission-patch") }}
{{- end -}}

{{- define "nri-metadata-injection.fullname.admission-patch" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "admission-patch") }}
{{- end -}}

{{- define "nri-metadata-injection.name.self-signed-issuer" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "self-signed-issuer") }}
{{- end -}}

{{- define "nri-metadata-injection.fullname.self-signed-issuer" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "self-signed-issuer") }}
{{- end -}}

{{- define "nri-metadata-injection.name.root-issuer" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "root-issuer") }}
{{- end -}}

{{- define "nri-metadata-injection.fullname.root-issuer" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "root-issuer") }}
{{- end -}}

{{- define "nri-metadata-injection.name.webhook-cert" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.name" .) "suffix" "webhook-cert") }}
{{- end -}}

{{- define "nri-metadata-injection.fullname.webhook-cert" -}}
{{ include "newrelic.common.naming.truncateToDNSWithSuffix" (dict "name" (include "newrelic.common.naming.fullname" .) "suffix" "webhook-cert") }}
{{- end -}}
