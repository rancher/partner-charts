{{/*
This file is used to fail the helm deployment if Workload Identity settings are not
compatible.
*/}}
{{- include "validate.gwif.idp.type" . -}}
{{- include "validate.gwif.idp.aud" . -}}




