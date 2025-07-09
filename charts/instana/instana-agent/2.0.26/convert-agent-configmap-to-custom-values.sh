#!/bin/bash
# Script to extract configuration.yaml from instana-agent configmap and convert it to custom-values.yaml
# Usage: ./convert-agent-configmap-to-custom-values.sh [namespace] [configmap-name] [output-file]

# Default values
NAMESPACE=${1:-"instana-agent"}
CONFIGMAP_NAME=${2:-"instana-agent"}
OUTPUT_FILE=${3:-"custom-values.yaml"}

echo "Extracting configuration.yaml from configmap $CONFIGMAP_NAME in namespace $NAMESPACE..."

# Get the configmap and extract the configuration.yaml content
CONFIG_YAML=$(kubectl get cm -n "$NAMESPACE" "$CONFIGMAP_NAME" -o 'jsonpath={.data.configuration\.yaml}')

if [ -z "$CONFIG_YAML" ]; then
    echo "Error: configuration.yaml not found in configmap $CONFIGMAP_NAME"
    exit 1
fi

# Create the custom-values.yaml file with the extracted configuration
echo "agent:" > "$OUTPUT_FILE"
echo "  configuration_yaml: |" >> "$OUTPUT_FILE"

# Process each line of the configuration.yaml and add proper indentation
echo "$CONFIG_YAML" | while IFS= read -r line; do
    echo "    $line" >> "$OUTPUT_FILE"
done

echo "Successfully created $OUTPUT_FILE with the configuration from the configmap."

echo "You can apply this configuration during an upgrade from instana agent helm chart v1 to v2:"
echo "helm pull --repo https://agents.instana.io/helm --untar instana-agent"
echo "kubectl apply -f instana-agent/crds"
echo "# On OpenShift, you need to add the privileged SCC to the instana-agent service account:"
echo "oc adm policy add-scc-to-user privileged -z instana-agent -n instana-agent"
echo "helm upgrade --namespace instana-agent instana-agent \
--repo https://agents.instana.io/helm instana-agent \
--reuse-values -f custom-values.yaml"
