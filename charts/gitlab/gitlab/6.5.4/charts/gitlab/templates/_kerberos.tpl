{{- define "gitlab.appConfig.kerberos.configuration" -}}
kerberos:
  enabled: {{ .Values.global.appConfig.kerberos.enabled }}
  keytab: /etc/krb5.keytab
{{-   if .Values.global.appConfig.kerberos.servicePrincipalName }}
  service_principal_name: {{ .Values.global.appConfig.kerberos.servicePrincipalName | quote }}
{{-   end }}
  use_dedicated_port: {{ .Values.global.appConfig.kerberos.dedicatedPort.enabled }}
  port: {{ .Values.global.appConfig.kerberos.dedicatedPort.port }}
  https: {{ .Values.global.appConfig.kerberos.dedicatedPort.https }}
  simple_ldap_linking_allowed_realms: {{ toJson .Values.global.appConfig.kerberos.simpleLdapLinkingAllowedRealms }}
{{- end -}}{{/* "gitlab.appConfig.kerberos.configuration" */}}

{{- define "gitlab.appConfig.kerberos.volume" -}}
{{- if .Values.global.appConfig.kerberos.keytab.secret }}
# volume for kerberos
- name: kerberos-keytab
  secret:
    secretName: {{ .Values.global.appConfig.kerberos.keytab.secret }}
{{- end -}}
{{- end -}}{{/* "gitlab.appConfig.kerberos.volume" */}}

{{- define "gitlab.appConfig.kerberos.volumeMount" -}}
{{- if .Values.global.appConfig.kerberos.keytab.secret }}
# volume mount for kerberos
- mountPath: "/etc/krb5.keytab"
  subPath: {{ .Values.global.appConfig.kerberos.keytab.key }}
  name: kerberos-keytab
  readOnly: true
{{- end -}}
{{- end -}}{{/* "gitlab.appConfig.kerberos.volumeMount" */}}
