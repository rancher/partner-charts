{{/* ######## Rails database related templates */}}
{{/*
Returns the contents of the `database.yml` blob for Rails pods
*/}}
{{- define "gitlab.database.yml" -}}
{{- include "database.datamodel.prepare" . -}}
{{- include "gitlab.database.setDefaultForDatabaseTasks" . -}}
{{- if .Values.global.debugDatabaseDatamodel }}
# global.debugDatabaseDatamodel=true
# helm template . -f test_values.yml | yq -r '.data."database.yml.erb" | select(. != null)'
datamodel: {{ .Values.local | toYaml | nindent 4 }}
{{- end }}
production:
{{- range $database := without (keys .Values.local.psql) "main" | concat (list "main") }}
{{-   $context := get $.Values.local.psql $database }}
{{-   if eq (include "gitlab.psql.database.enabled" $context) "true" }}
  {{ $database }}:
    adapter: postgresql
    encoding: unicode
    database: {{ template "gitlab.psql.database" $context }}
    username: {{ template "gitlab.psql.username" $context }}
    password: <%= File.read({{ template "gitlab.psql.password.file" $context }}).strip.to_json %>
    host: {{ include "gitlab.psql.host" $context | quote }}
    port: {{ template "gitlab.psql.port" $context }}
    connect_timeout: {{ template "gitlab.psql.connectTimeout" $context }}
    keepalives: {{ template "gitlab.psql.keepalives" $context }}
    keepalives_idle: {{ template "gitlab.psql.keepalivesIdle" $context }}
    keepalives_interval: {{ template "gitlab.psql.keepalivesInterval" $context }}
    keepalives_count: {{ template "gitlab.psql.keepalivesCount" $context }}
    tcp_user_timeout: {{ template "gitlab.psql.tcpUserTimeout" $context }}
    application_name: {{ template "gitlab.psql.applicationName" $context }}
    prepared_statements: {{ template "gitlab.psql.preparedStatements" $context }}
    database_tasks: {{ template "gitlab.psql.databaseTasks" $context }}
    {{- include "gitlab.database.loadBalancing" $context | nindent 4 }}
    {{- include "gitlab.psql.ssl.config" $context | nindent 4 }}
{{-   end -}}
{{- end }}
{{- if include "gitlab.geo.secondary" . }}
{{-   include "gitlab.geo.database.yml" . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Return if the database is enabled
Returns psql.enabled if it is a boolean,
otherwise it will fallback to "true" default
*/}}
{{- define "gitlab.psql.database.enabled" -}}
{{- $globalSet := and (hasKey .Values.global.psql "enabled") (kindIs "bool" .Values.global.psql.enabled) -}}
{{- if $globalSet }}
{{-   .Values.global.psql.enabled }}
{{- else }}
{{-   true }}
{{- end -}}
{{- end -}}

{{/*
Sets 'databaseTasks: false' if the additional database points to the same database
as 'main:', where the db, host and port do match.
*/}}
{{- define "gitlab.database.setDefaultForDatabaseTasks" -}}
{{-   $mainDB := include "gitlab.psql.database" $.Values.local.psql.main -}}
{{-   $mainHost := include "gitlab.psql.host" $.Values.local.psql.main -}}
{{-   $mainPort := include "gitlab.psql.port" $.Values.local.psql.main -}}
{{-   range $database := without (keys $.Values.local.psql) "main" -}}
{{-     $context := get $.Values.local.psql $database -}}
{{-     $currentDB := include "gitlab.psql.database" $context -}}
{{-     $currentHost := include "gitlab.psql.host" $context -}}
{{-     $currentPort := include "gitlab.psql.port" $context -}}
{{-     if and (not (hasKey $context.Values.psql "databaseTasks")) (not (hasKey $context.Values.global.psql "databaseTasks")) -}}
{{-       if and (eq $currentDB $mainDB) (eq $currentHost $mainHost) (eq $currentPort $mainPort) -}}
{{-         $_ := set $context.Values.global.psql "databaseTasks" false -}}
{{-       end -}}
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Returns the contents of `load_balancing` section of database.yml

See https://docs.gitlab.com/ee/administration/database_load_balancing.html#enabling-load-balancing

Note: Many `if` used here, allowing Rails to provide defaults inside the codebase.
*/}}
{{- define "gitlab.database.loadBalancing" -}}
{{- with default .Values.global.psql .Values.psql -}}
{{-   if kindIs "map" .load_balancing -}}
load_balancing:
  {{-   if kindIs "slice" .load_balancing.hosts }}
  hosts:
    {{- toYaml .load_balancing.hosts | nindent 2 }}
  {{-   else if kindIs "map" .load_balancing.discover }}
  discover:
    {{- with .load_balancing.discover -}}
    {{-   if index . "nameserver" }}
    nameserver: {{ .nameserver }}
    {{- end }}
    record: {{ .record | required "`psql.load_balancing.discover` requires `record` to be provided." | quote }}
    {{-   if index . "record_type" }}
    record_type: {{ .record_type | quote }}
    {{- end }}
    {{-   if index . "port" }}
    port: {{ .port | int }}
    {{- end }}
    {{-   if index . "interval" }}
    interval: {{ .interval | int }}
    {{- end }}
    {{-   if index . "disconnect_timeout" }}
    disconnect_timeout: {{ .disconnect_timeout | int }}
    {{- end }}
    {{-   if index . "use_tcp" }}
    use_tcp: {{ empty .use_tcp | not }}
    {{-   end -}}
    {{-   if index . "max_replica_pools" }}
    max_replica_pools: {{ .max_replica_pools | int }}
    {{- end }}
    {{- end -}}
  {{-   end }}
  {{-   if index .load_balancing "max_replication_difference" }}
  max_replication_difference: {{ .load_balancing.max_replication_difference | int }}
  {{-  end }}
  {{-  if index .load_balancing "max_replication_lag_time" }}
  max_replication_lag_time: {{ .load_balancing.max_replication_lag_time | int }}
  {{-  end }}
  {{-  if index .load_balancing "replica_check_interval" }}
  replica_check_interval: {{ .load_balancing.replica_check_interval | int }}
  {{-  end }}
{{-   end -}}
{{- end -}}
{{- end -}}
