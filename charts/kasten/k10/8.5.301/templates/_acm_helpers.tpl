{{/*
Returns the minimal ACM-required configuration for remote write.
This only includes the THANOS-TENANT header. The caller is responsible
for merging this with user-provided URL and other settings.
*/}}
{{- define "k10.acm.remoteWriteConfig" -}}
name: acm
headers:
  THANOS-TENANT: {{ include "k10.acm.hubThanosTenantId" . }}
{{- end -}}

{{/*
Returns the Cluster ID.
Prioritizes .Values.global.acm.managedClusterId.
If not set, attempts to lookup OpenShift ClusterVersion.

Fallback behavior:
- If the lookup fails (e.g., not running on OpenShift, insufficient RBAC permissions),
  or if spec.clusterID is missing, an empty string is returned.
- Callers should handle empty string appropriately. In the ACM observability context,
  an empty cluster ID may result in metrics being sent without cluster identification,
  which could lead to metric aggregation issues on the ACM hub.
*/}}
{{- define "k10.acm.openshiftClusterID" -}}
{{- $clusterId := .Values.global.acm.managedClusterId -}}
{{- if not $clusterId -}}
  {{- $clusterVersion := (lookup "config.openshift.io/v1" "ClusterVersion" "" "version") -}}
  {{- if $clusterVersion -}}
    {{- $clusterId = $clusterVersion.spec.clusterID -}}
  {{- end -}}
{{- end -}}
{{- $clusterId -}}
{{- end -}}

{{/*
Returns the ACM Tenant ID.
Prioritizes .Values.global.acm.hubThanosTenantId.
*/}}
{{- define "k10.acm.hubThanosTenantId" -}}
{{- required "A valid .Values.global.acm.hubThanosTenantId is required when global.acm.enabled is true!" .Values.global.acm.hubThanosTenantId -}}
{{- end -}}

{{/*
Returns the Cluster Name.
Prioritizes .Values.clusterName.
If not set and ACM is enabled, attempts to lookup OpenShift Infrastructure name.
*/}}
{{- define "k10.acm.clusterName" -}}
{{- $clusterName := .Values.clusterName -}}
{{- if and .Values.global.acm.enabled (not $clusterName) -}}
  {{- $infrastructure := (lookup "config.openshift.io/v1" "Infrastructure" "" "cluster") -}}
  {{- if $infrastructure -}}
    {{- $clusterName = $infrastructure.status.infrastructureName -}}
  {{- end -}}
{{- end -}}
{{- $clusterName -}}
{{- end -}}

{{/*
Checks if a remote write entry is intended for ACM.
Returns "true" if:
- The entry is named "acm"
- OR the entry has no name AND contains ACM-specific fields (dashboardUrl or metricsRegex)
*/}}
{{- define "k10.acm.isAcmEntry" -}}
{{- $isUnnamedAcmEntry := and (not (hasKey . "name")) (or (hasKey . "dashboardUrl") (hasKey . "metricsRegex")) -}}
{{- if or (eq .name "acm") $isUnnamedAcmEntry -}}
true
{{- end -}}
{{- end -}}

{{/*
Merges ACM remote write configuration with existing remote writes.
Returns a JSON-encoded list of remote write configurations.

Logic:
- Iterates through all remote writes.
- If ACM is enabled:
  - Searches for a user-provided ACM entry (identified by name="acm" or presence of dashboardUrl/metricsRegex).
  - If found, merges the user's ACM entry with ACM-required configuration (THANOS-TENANT header).
- Processes ACM-specific extension fields (dashboardUrl, metricsRegex) for ALL entries (regardless of ACM status)
  and converts them to Prometheus write_relabel_configs. This ensures invalid fields are removed.
- Returns all remote writes as JSON for reliable parsing.

Parameters:
- .root: The template context
- .remoteWrites: List of existing remote write configurations
*/}}
{{- define "k10.acm.mergeRemoteWrites" -}}
{{- $remoteWrites := .remoteWrites | default list }}
{{- $acmEnabled := .root.Values.global.acm.enabled }}
{{- $acmRequired := dict }}
{{- if $acmEnabled }}
  {{- $acmRequiredStr := include "k10.acm.remoteWriteConfig" .root }}
  {{- $acmRequired = fromYaml $acmRequiredStr }}
{{- end }}

{{- $newRemoteWrites := list }}
{{- range $rw := $remoteWrites }}
  {{- $currentRw := $rw }}
  {{- /* If ACM is enabled and this entry matches ACM criteria, merge required config */ -}}
  {{- if and $acmEnabled $acmRequired (include "k10.acm.isAcmEntry" $rw) }}
    {{- /* Merge into a new dict to avoid side effects. Give precedence to user config ($rw) over defaults ($acmRequired) */ -}}
    {{- $currentRw = merge (dict) $acmRequired $rw }}
  {{- end }}

  {{- /* Process ACM-specific extension fields and convert to Prometheus relabel configs */ -}}
  {{- $relabelConfigs := $currentRw.write_relabel_configs | default list }}
  {{- if hasKey $currentRw "dashboardUrl" }}
    {{- if $currentRw.dashboardUrl }}
      {{- $relabelConfigs = append $relabelConfigs (dict "target_label" "k10_dashboard_url" "replacement" $currentRw.dashboardUrl) }}
    {{- end }}
    {{- $_ := unset $currentRw "dashboardUrl" }}
  {{- end }}
  {{- if hasKey $currentRw "metricsRegex" }}
    {{- if $currentRw.metricsRegex }}
      {{- $relabelConfigs = append $relabelConfigs (dict "source_labels" (list "__name__") "regex" $currentRw.metricsRegex "action" "keep") }}
    {{- end }}
    {{- $_ := unset $currentRw "metricsRegex" }}
  {{- end }}
  {{- if $relabelConfigs }}
    {{- $_ := set $currentRw "write_relabel_configs" $relabelConfigs }}
  {{- end }}
  {{- $newRemoteWrites = append $newRemoteWrites $currentRw }}
{{- end }}

{{- mustToJson $newRemoteWrites }}
{{- end -}}

{{/*
Validates ACM configuration.
Fails if ACM is enabled but required fields (like cluster ID) are missing.
*/}}
{{- define "k10.acm.validate" -}}
{{- if .Values.global.acm.enabled -}}
  {{- $clusterId := include "k10.acm.openshiftClusterID" . -}}
  {{- if not $clusterId -}}
    {{- fail "global.acm.managedClusterId is required when global.acm.enabled is true. Auto-detection of the cluster ID failed or is not supported on this platform. Please set .Values.global.acm.managedClusterId explicitly." -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Returns ACM-specific external labels.
*/}}
{{- define "k10.acm.externalLabels" -}}
{{- if .Values.global.acm.enabled -}}
  {{- $clusterName := include "k10.acm.clusterName" . -}}
  {{- $clusterId := include "k10.acm.openshiftClusterID" . -}}
  {{- dict "cluster_name" $clusterName "cluster_id" $clusterId | toYaml -}}
{{- end -}}
{{- end -}}
