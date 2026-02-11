{{- /*
As this chart deploys what it should be three charts to maintain the transition to v3 as smooth as possible.
This means that this chart has 3 affinity so a helper should be done per scraper.
*/ -}}
{{- define "nriKubernetes.ksm.affinity" -}}
{{- if or .Values.ksm.affinity .Values.nodeAffinity -}}
    {{- $legacyNodeAffinity := fromYaml ( include "newrelic.compatibility.nodeAffinity" . ) | default dict -}}
    {{- $valuesAffinity := .Values.ksm.affinity | default dict -}}
    {{- $affinity := mustMergeOverwrite $legacyNodeAffinity $valuesAffinity -}}
    {{- toYaml $affinity -}}
{{- else if include "newrelic.common.affinity" . -}}
    {{- include "newrelic.common.affinity" . -}}
{{- end -}}
{{- end -}}
