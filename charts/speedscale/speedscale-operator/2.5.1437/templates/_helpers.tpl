{{/* Pull secrets for chart-managed pods; pods the operator creates inherit them from its ServiceAccounts. */}}
{{- define "speedscale-operator.imagePullSecrets" -}}
{{- with .Values.image.pullSecrets -}}
imagePullSecrets:{{ toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
