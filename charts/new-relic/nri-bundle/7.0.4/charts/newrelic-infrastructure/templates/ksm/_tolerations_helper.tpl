{{- /*
As this chart deploys what it should be three charts to maintain the transition to v3 as smooth as possible.
This means that this chart has 3 tolerations so a helper should be done per scraper.
*/ -}}
{{- define "nriKubernetes.ksm.tolerations" -}}
{{- if .Values.ksm.tolerations -}}
    {{- toYaml .Values.ksm.tolerations -}}
{{- else if include "newrelic.common.tolerations" . -}}
    {{- include "newrelic.common.tolerations" . -}}
{{- else -}}
    {{- /* Default KSM tolerations: tolerate node pressure conditions but not unschedulable nodes */ -}}
- key: "node.kubernetes.io/disk-pressure"
  operator: "Exists"
  effect: "NoSchedule"
- key: "node.kubernetes.io/memory-pressure"
  operator: "Exists"
  effect: "NoSchedule"
- key: "node.kubernetes.io/pid-pressure"
  operator: "Exists"
  effect: "NoSchedule"
- key: "node.kubernetes.io/network-unavailable"
  operator: "Exists"
  effect: "NoSchedule"
- operator: "Exists"
  effect: "NoExecute"
{{- end -}}
{{- end -}}
