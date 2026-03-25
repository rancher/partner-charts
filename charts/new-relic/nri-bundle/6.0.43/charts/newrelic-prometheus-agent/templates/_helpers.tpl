{{- /* Return the newrelic-prometheus configuration */ -}}

{{- /* it builds the common configuration from configurator config, cluster name and custom attributes */ -}}
{{- define "newrelic-prometheus.configurator.common" -}}
{{- $tmp := dict "external_labels" (dict "cluster_name" (include "newrelic.common.cluster" . )) -}}

{{- if .Values.config  -}}
  {{- if .Values.config.common -}}
      {{- $_ := mustMerge $tmp .Values.config.common -}}
  {{- end -}}
{{- end -}}

{{- $tmpCustomAttribute := dict "external_labels" (include "newrelic.common.customAttributes" . | fromYaml ) -}}
{{- $tmp = mustMerge $tmp $tmpCustomAttribute  -}}

common:
{{- $tmp | toYaml | nindent 2 -}}

{{- end -}}


{{- /* it builds the newrelic_remote_write configuration from configurator config */ -}}
{{- define "newrelic-prometheus.configurator.newrelic_remote_write" -}}
{{- $tmp := dict -}}

{{- if include "newrelic.common.nrStaging" . -}}
  {{- $_ := set $tmp "staging" true  -}}
{{- end -}}

{{- if include "newrelic.common.fedramp.enabled" . -}}
  {{- $_ := set $tmp "fedramp" (dict "enabled" true)  -}}
{{- end -}}

{{- $extra_write_relabel_configs :=(include "newrelic-prometheus.configurator.extra_write_relabel_configs" . | fromYaml) -}}
{{- if ne (len $extra_write_relabel_configs.list) 0 -}}
  {{- $_ := set $tmp "extra_write_relabel_configs" $extra_write_relabel_configs.list -}}
{{- end -}}

{{- if .Values.config -}}
{{- if .Values.config.newrelic_remote_write -}}
  {{- $tmp = mustMerge $tmp .Values.config.newrelic_remote_write  -}}
{{- end -}}
{{- end -}}

{{- if not (empty $tmp) -}}
  {{- dict "newrelic_remote_write" $tmp | toYaml -}}
{{- end -}}

{{- end -}}

{{- /* it builds the extra_write_relabel_configs configuration merging: lowdatamode, user ones, and metrictyperelabeldefaults  */ -}}
{{- define "newrelic-prometheus.configurator.extra_write_relabel_configs" -}}

{{- $extra_write_relabel_configs := list  -}}
{{- if (include "newrelic.common.lowDataMode" .) -}}
  {{- $lowDataModeRelabelConfig := .Files.Get "static/lowdatamodedefaults.yaml" | fromYaml -}}
  {{- $extra_write_relabel_configs = concat $extra_write_relabel_configs $lowDataModeRelabelConfig.low_data_mode -}}
{{- end -}}

{{- if .Values.metric_type_override -}}
  {{- if .Values.metric_type_override.enabled -}}
    {{- $metricTypeOverride := .Files.Get "static/metrictyperelabeldefaults.yaml" | fromYaml -}}
    {{- $extra_write_relabel_configs = concat $extra_write_relabel_configs $metricTypeOverride.metrics_type_relabel -}}
  {{- end -}}
{{- end -}}

{{- if .Values.config -}}
{{- if .Values.config.newrelic_remote_write -}}
  {{- /* it concatenates the defined 'extra_write_relabel_configs' to the ones defined in lowDataMode  */ -}}
  {{- if .Values.config.newrelic_remote_write.extra_write_relabel_configs  -}}
      {{- $extra_write_relabel_configs = concat $extra_write_relabel_configs .Values.config.newrelic_remote_write.extra_write_relabel_configs -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- /* sadly in helm we cannot pass back a list without putting it into a tmp dict  */ -}}
{{ dict "list" $extra_write_relabel_configs | toYaml}}

{{- end -}}


{{- /* it builds the extra_remote_write configuration from configurator config */ -}}
{{- define "newrelic-prometheus.configurator.extra_remote_write" -}}
{{- if .Values.config -}}
  {{- if .Values.config.extra_remote_write  -}}
extra_remote_write:
    {{- .Values.config.extra_remote_write | toYaml | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "newrelic-prometheus.configurator.static_targets" -}}
{{- if .Values.config -}}
  {{- if .Values.config.static_targets -}}
static_targets:
    {{- .Values.config.static_targets | toYaml | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "newrelic-prometheus.configurator.extra_scrape_configs" -}}
{{- if .Values.config -}}
  {{- if .Values.config.extra_scrape_configs  -}}
extra_scrape_configs:
    {{- .Values.config.extra_scrape_configs | toYaml | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "newrelic-prometheus.configurator.kubernetes" -}}
{{- if .Values.config -}}
{{- if .Values.config.kubernetes  -}}
kubernetes:
  {{- if .Values.config.kubernetes.jobs }}
  jobs:
    {{- .Values.config.kubernetes.jobs | toYaml | nindent 2 -}}
  {{- end -}}

  {{- if .Values.config.kubernetes.integrations_filter }}
  integrations_filter:
     {{- .Values.config.kubernetes.integrations_filter | toYaml | nindent 4 -}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "newrelic-prometheus.configurator.sharding" -}}
  {{- if .Values.sharding  -}}
sharding:
  total_shards_count: {{ include "newrelic-prometheus.configurator.replicas" . }}
  {{- end -}}
{{- end -}}

{{- define "newrelic-prometheus.configurator.replicas" -}}
  {{- if .Values.sharding  -}}
{{- .Values.sharding.total_shards_count | default 1 }}
  {{- else -}}
1
  {{- end -}}
{{- end -}}

{{- /*
Return the proper configurator image name
{{ include "newrelic-prometheus.configurator.images.configurator_image" ( dict "imageRoot" .Values.path.to.the.image "context" .) }}
*/ -}}
{{- define "newrelic-prometheus.configurator.configurator_image" -}}
    {{- $registryName := include "newrelic.common.images.registry" ( dict "imageRoot" .imageRoot "context" .context) -}}
    {{- $repositoryName := include "newrelic.common.images.repository" .imageRoot -}}
    {{- $tag := include "newrelic-prometheus.configurator.configurator_image.tag" ( dict "imageRoot" .imageRoot "context" .context) -}}

    {{- if $registryName -}}
        {{- printf "%s/%s:%s" $registryName $repositoryName $tag | quote -}}
    {{- else -}}
        {{- printf "%s:%s" $repositoryName $tag | quote -}}
    {{- end -}}
{{- end -}}


{{- /*
Return the proper image tag for the configurator image
{{ include "newrelic-prometheus.configurator.configurator_image.tag" ( dict "imageRoot" .Values.path.to.the.image "context" .) }}
*/ -}}
{{- define "newrelic-prometheus.configurator.configurator_image.tag" -}}
    {{- .imageRoot.tag | default .context.Chart.Annotations.configuratorVersion | toString -}}
{{- end -}}
