{{/*
  Include using:
  {{ include "gitlab.scripts.configure.secrets" (
            dict
                "required" "your required secrets dirs" // optional, for defaults, see `$required` below
                "optional" "your optional secrets dirs" // optional, for defaults, see `$optional` below
    ) }}

  - Either can be disabled with "none"
  - Duplicates from required will be removed from optional
*/}}
{{- define "gitlab.scripts.configure.secrets" -}}
{{- $required := default "shell gitaly registry rails-secrets gitlab-workhorse" $.required | splitList " " -}}
{{- $optional := default "redis minio objectstorage postgres ldap duo omniauth smtp kas pages oauth-secrets mailroom gitlab-exporter microsoft_graph_mailer suggested_reviewers" $.optional | splitList " " -}}
{{- range (without $required "none") -}}
{{- $optional = without $optional . -}}
{{- end -}}
# BEGIN gitlab.scripts.configure.secrets
set -e
config_dir="/init-config"
secret_dir="/init-secrets"
{{- if len (without $required "none") }}
# required
for secret in {{ without $required "none" | join " " }} ; do
  mkdir -p "${secret_dir}/${secret}"
  cp -f -v -r -L "${config_dir}/${secret}/." "${secret_dir}/${secret}/"
done
{{- end }}
{{- if len (without $optional "none") }}
# optional
for secret in {{ without $optional "none" | join " " }} ; do
  if [ -e "${config_dir}/${secret}" ]; then
    mkdir -p "${secret_dir}/${secret}"
    cp -f -v -r -L "${config_dir}/${secret}/." "${secret_dir}/${secret}/"
  fi
done
{{- end }}
# END gitlab.scripts.configure.secrets
{{- end }}
