{{- /* Returns the Secret name holding the commercial license, or empty. */ -}}
{{- define "kyverno.license.secretName" -}}
{{- if .Values.license.create -}}
{{- default (printf "%s-license" (include "kyverno.fullname" .)) .Values.license.name -}}
{{- else if .Values.license.existingSecret -}}
{{- .Values.license.existingSecret -}}
{{- end -}}
{{- end -}}

{{- /* True when a commercial license Secret should be mounted. */ -}}
{{- define "kyverno.license.enabled" -}}
{{- if or .Values.license.create .Values.license.existingSecret -}}
true
{{- end -}}
{{- end -}}

{{- /* Mount path for the license file inside the admission controller. */ -}}
{{- define "kyverno.license.mountPath" -}}
/var/run/kyverno/license
{{- end -}}

{{- /* Full path to the license file (directory + key). */ -}}
{{- define "kyverno.license.filePath" -}}
{{- printf "%s/%s" (include "kyverno.license.mountPath" .) (default "license" .Values.license.key) -}}
{{- end -}}
