{{- /*
As this chart deploys what it should be three charts to maintain the transition to v3 as smooth as possible.
This means that this chart has 3 tolerations so a helper should be done per scraper.
*/ -}}
{{- define "nriKubernetes.controlPlane.tolerations" -}}
{{- if .Values.controlPlane.tolerations -}}
    {{- toYaml .Values.controlPlane.tolerations -}}
{{- else if include "newrelic.common.tolerations" . -}}
    {{- include "newrelic.common.tolerations" . -}}
{{- end -}}
{{- end -}}
