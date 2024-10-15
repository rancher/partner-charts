#!/bin/sh

# Script to synchronize data from a source PVC to existing target PVCs in Kubernetes.
# Usage: ./replicate.sh <Source_PVC> <Target_PVC_1> [Target_PVC_2 ...] [Namespace]
# Example: ./replicate.sh sawtooth-data-chronicle-sawtooth-0 sawtooth-data-chronicle-sawtooth-1 default

set -eu

# Constants
LOG_FILE="./replicate.log"
MAX_RETRIES=10
RSYNC_TIMEOUT=300  # in seconds

# Variable to keep track of created pods for cleanup
CREATED_PODS=""

# Function to display usage information
usage() {
    echo "Usage: $0 <Source_PVC> <Target_PVC_1> [Target_PVC_2 ...] [Namespace]"
    echo "Example: $0 sawtooth-data-chronicle-sawtooth-0 sawtooth-data-chronicle-sawtooth-1 default"
    exit 1
}

# Function to log messages with timestamps
log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Function to check if a namespace exists
namespace_exists() {
    local namespace="$1"
    kubectl get namespace "$namespace" >/dev/null 2>&1
}

# Function to create a temporary pod for rsync
create_temp_pod() {
    local source_pvc="$1"
    local target_pvc="$2"
    local namespace="$3"
    local pod_name="replication-temp-pod-${target_pvc}"

    log "Creating temporary pod '$pod_name' in namespace '$namespace'."

    kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: $pod_name
  namespace: $namespace
spec:
  restartPolicy: Never
  containers:
    - name: rsync-container
      image: ianayoung/rsync:latest
      command: ["rsync"]
      args: ["-aSWHin", "/source/", "/target/"]
      volumeMounts:
        - name: source-pvc
          mountPath: /source
        - name: target-pvc
          mountPath: /target
  volumes:
    - name: source-pvc
      persistentVolumeClaim:
        claimName: $source_pvc
    - name: target-pvc
      persistentVolumeClaim:
        claimName: $target_pvc
EOF

    CREATED_PODS="${CREATED_PODS} $pod_name"
    log "Temporary pod '$pod_name' created."
}

# Function to wait for a pod to complete and log its status
wait_for_pod() {
    local pod_name="$1"
    local namespace="$2"

    log "Waiting for pod '$pod_name' to complete."
    # Wait for the pod to reach the 'Succeeded' or 'Failed' phase
    kubectl wait --for=condition=ready --timeout=${RSYNC_TIMEOUT}s pod/"$pod_name" -n "$namespace" >/dev/null 2>&1

    # Check the pod status
    pod_status=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.status.phase}')

    if [ "$pod_status" = "Succeeded" ]; then
        log "Rsync succeeded for '$pod_name'."
        return 0
    else
        log "Rsync failed for '$pod_name' with status: $pod_status."
        return 1
    fi
}

# Function to delete a temporary pod
delete_temp_pod() {
    local pod_name="$1"
    local namespace="$2"

    log "Deleting temporary pod '$pod_name' in namespace '$namespace'."
    kubectl delete pod "$pod_name" -n "$namespace" --ignore-not-found=true
    log "Temporary pod '$pod_name' deleted."
}

# Function to perform rsync with retries
perform_rsync() {
    local target_pvc="$1"
    local namespace="$2"

    local attempt=1
    while [ "$attempt" -le "$MAX_RETRIES" ]; do
        log "Attempt $attempt of $MAX_RETRIES for rsync to '$target_pvc'."
        create_temp_pod "$SOURCE_PVC" "$target_pvc" "$namespace"

        if wait_for_pod "replication-temp-pod-$target_pvc" "$namespace"; then
            log "Rsync succeeded on attempt $attempt for '$target_pvc'."
            break
        else
            log "Rsync failed on attempt $attempt for '$target_pvc'."
            if [ "$attempt" -lt "$MAX_RETRIES" ]; then
                log "Retrying rsync after delay..."
                sleep 10  # Delay before next attempt
            else
                log "Exceeded maximum retries for rsync to '$target_pvc'. Skipping to next PVC."
            fi
        fi

        attempt=$((attempt + 1))
    done

    # Delete temporary pod if it exists
    delete_temp_pod "replication-temp-pod-$target_pvc" "$namespace"
}

# Function to handle cleanup on script exit or interruption
cleanup() {
    log "Cleanup initiated. Deleting all temporary pods."
    for pod in $CREATED_PODS; do
        delete_temp_pod "$pod" "$NAMESPACE"
    done
    log "Cleanup completed."
    exit 0
}

# Trap SIGINT (Ctrl-C) to perform cleanup
trap cleanup INT

# Function to parse the provided arguments
parse_arguments() {
    if [ "$#" -lt 2 ]; then
        log "Error: Insufficient arguments provided."
        usage
    fi

    SOURCE_PVC="$1"
    shift
    TARGET_PVCS="$@"

    # Determine if the last argument is a namespace
    LAST_ARG=$(echo "$TARGET_PVCS" | awk '{print $NF}')
    if namespace_exists "$LAST_ARG"; then
        NAMESPACE="$LAST_ARG"
        # Remove the namespace from TARGET_PVCS
        TARGET_PVCS=$(echo "$TARGET_PVCS" | awk '{$NF=""; print $0}' | sed 's/ *$//')
    else
        NAMESPACE="default"
    fi

    # Convert TARGET_PVCS string to a space-separated list
    TARGET_PVCS_ARRAY="$TARGET_PVCS"

    if [ -z "$TARGET_PVCS_ARRAY" ]; then
        log "Error: At least one target PVC must be specified."
        usage
    fi
}

# Main Script Execution

# Parse the provided arguments
parse_arguments "$@"

log "Starting PVC synchronization from '$SOURCE_PVC' in namespace '$NAMESPACE'."

for TARGET_PVC in $TARGET_PVCS_ARRAY; do
    log "Synchronizing from '$SOURCE_PVC' to '$TARGET_PVC'."
    perform_rsync "$TARGET_PVC" "$NAMESPACE"
    log "--------------------------------------------"
done

log "PVC synchronization for all replicas completed."
