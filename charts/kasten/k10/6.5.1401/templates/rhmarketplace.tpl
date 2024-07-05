{{/*
This file is used to fail the helm deployment if certain values are set which are
not compatible with an Operator deployment.
*/}}

{{- if and (.Values.global.rhMarketPlace) (.Values.reporting.pdfReports) -}}
  {{- fail "reporting.pdfReports cannot be enabled for the K10 Red Hat Marketplace Operator" -}}
{{- end -}}
