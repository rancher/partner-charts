#!/usr/bin/env bash
# Verifies kyverno-notation-aws mounts the same license Secret as the
# admission controller when the subchart is enabled. Guards against the
# two charts silently drifting apart on the Secret name, which would leave
# notation-aws unlicensed while the admission controller stays licensed.
#
# Requires the kyverno-notation-aws dependency archive under
# charts/kyverno/charts/ (helm dependency build).
set -euo pipefail

# The chart declares kubeVersion >=1.25, and helm otherwise assumes its own
# built-in default, which is older and fails the render before any assertion runs.
KUBE_VERSION="${KUBE_VERSION:-1.31.0}"
HELM="${HELM:-$(command -v helm)}"

CHART_DIR="${1:-charts/kyverno}"
RELEASE_NAME="${2:-kyverno}"

VALUES_FILE=$(mktemp)
trap 'rm -f "$VALUES_FILE"' EXIT
# license.value is required whenever license.create is true: the parent chart
# fails the render without it, which would look like drift rather than a bad fixture.
cat > "$VALUES_FILE" <<EOF
license:
  create: true
  value: |
    dummy-license-body-for-rendering-only
kyverno-notation-aws:
  install: true
EOF

RENDERED=$("$HELM" template "$RELEASE_NAME" "$CHART_DIR" --kube-version "$KUBE_VERSION" -f "$VALUES_FILE")

ADMISSION_SECRET=$(echo "$RENDERED" | yq e '
  select(.kind == "Deployment" and (.metadata.name | test("admission-controller$")))
  | .spec.template.spec.volumes[]
  | select(.name == "nirmata-license")
  | .secret.secretName
' - | head -n1)

NOTATION_SECRET=$(echo "$RENDERED" | yq e '
  select(.kind == "Deployment" and (.metadata.name | test("kyverno-notation-aws$")))
  | .spec.template.spec.volumes[]
  | select(.name == "license")
  | .secret.secretName
' - | head -n1)

if [[ -z "$ADMISSION_SECRET" || "$ADMISSION_SECRET" == "null" ]]; then
  echo "::error::could not find the admission controller's license secretName in the rendered output"
  exit 1
fi

if [[ -z "$NOTATION_SECRET" || "$NOTATION_SECRET" == "null" ]]; then
  echo "::error::could not find kyverno-notation-aws's license secretName in the rendered output"
  exit 1
fi

if [[ "$ADMISSION_SECRET" != "$NOTATION_SECRET" ]]; then
  echo "::error::license Secret name drift: admission-controller mounts '$ADMISSION_SECRET', kyverno-notation-aws mounts '$NOTATION_SECRET'"
  exit 1
fi

echo "OK: admission-controller and kyverno-notation-aws both mount Secret '$ADMISSION_SECRET'"
