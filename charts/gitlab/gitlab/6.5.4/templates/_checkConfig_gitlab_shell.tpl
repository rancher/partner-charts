{{- define "gitlab.checkConfig.gitlabShell.proxyPolicy" -}}
{{- $config := (index .Values "gitlab" "gitlab-shell").config -}}
{{/*
We enable ProxyProtocol between nginx-ingress and gitlab-shell whenever
gitlab-sshd is enabled to ensure the right remote IPs are seen by SSH.
By default, gitlab-sshd will optionally use the ProxyProtocol if
available. Setting the proxy policy to "reject" would prevent
gitlab-shell from working, so we check that this can't be done.
*/}}
{{- if and $config.proxyProtocol (eq $config.proxyPolicy "reject") }}
gitlab-shell:
  gitlab.gitlab-shell.config.proxyProtocol is enabled, but gitlab.gitlab-shell.config.proxyPolicy is set to "reject".
  gitlab-shell will not accept connections since these settings conflict with each other.
  Either disable proxyProtocol or set proxyPolicy to "use", "require", or "ignore".
{{- end -}}
{{- end -}}
{{/* END "gitlab.checkConfig.gitlabShell.proxyPolicy" */}}
