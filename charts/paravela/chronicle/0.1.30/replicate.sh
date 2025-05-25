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
    # Restore tee
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
    # Use mktemp for robustness
    local temp_yaml=$(mktemp /tmp/${pod_name}.yaml.XXXXXX)
    # Ensure cleanup even on errors
    trap "rm -f '$temp_yaml'" EXIT INT TERM

    log "Creating temporary pod '$pod_name' in namespace '$namespace'."

    # Create Pod YAML definition in the temporary file
    cat > "$temp_yaml" <<EOF
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
      command: ["sh", "-c"]
      args:
        - |
          set -ex
          echo "--- Listing source before sync ---"
          ls -al /source
          echo "--- Listing target before sync ---"
          ls -al /target
          echo "--- Removing pbft.log from target ---"
          rm -f /target/pbft.log
          echo "--- Removing pbft.log from source ---"
          rm -f /source/pbft.log
          echo "--- Running rsync (excluding pbft.log) ---"
          rsync -aSWH --delete --exclude=pbft.log /source/ /target/
          echo "--- Listing source after sync ---"
          ls -al /source
          echo "--- Listing target after sync ---"
          ls -al /target
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

    # Apply the temporary YAML file, redirecting stdout and stderr
    if ! kubectl apply -f "$temp_yaml" >/dev/null 2>&1; then
        log "ERROR: kubectl apply failed for $temp_yaml. Check permissions or connectivity."
        # Cleanup is handled by trap
        return 1 # Indicate failure
    fi

    CREATED_PODS="${CREATED_PODS} $pod_name"
    log "Temporary pod '$pod_name' creation command submitted."
    # Cleanup is handled by trap
    # Remove the specific trap for this file now that it's successfully applied
    trap - EXIT INT TERM
    rm -f "$temp_yaml"
    return 0 # Indicate success
}

# Function to wait for a pod to complete and log its status
wait_for_pod() {
    local pod_name="$1"
    local namespace="$2"
    local start_time="$3" # Accept start_time as argument

    log "Waiting for pod '$pod_name' to complete (Timeout: ${RSYNC_TIMEOUT}s). Started at $start_time."

    while true; do
        log "Polling pod status for '$pod_name' using: kubectl get pod \"$pod_name\" -n \"$namespace\" -o jsonpath='{.status.phase}'"

        # Execute kubectl directly, capture output and exit status
        pod_status=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.status.phase}')
        local kubectl_exit_code=$?

        # Check kubectl exit code first
        if [ $kubectl_exit_code -ne 0 ]; then
            log "kubectl command failed with exit code $kubectl_exit_code. Assuming failure."
            # Attempt to get pod description or events for debugging
            log "Trying to get pod description:"
            kubectl describe pod "$pod_name" -n "$namespace" || log "Could not describe pod '$pod_name'."
            log "Trying to get pod events:"
            kubectl get events --field-selector involvedObject.name="$pod_name",involvedObject.namespace="$namespace" || log "Could not get events for pod '$pod_name'."
            return 1
        fi

        if [ "$pod_status" = "Succeeded" ]; then
            log "Pod '$pod_name' succeeded."
            return 0
        elif [ "$pod_status" = "Failed" ]; then
            log "Pod '$pod_name' failed. Fetching logs:"
            kubectl logs "$pod_name" -n "$namespace" || log "Could not fetch logs for failed pod '$pod_name'."
            return 1
        # Handling unexpected empty status (might indicate pod terminating/not found cleanly)
        elif [ -z "$pod_status" ]; then
             log "Pod '$pod_name' status query returned empty. Checking if pod exists..."
             if ! kubectl get pod "$pod_name" -n "$namespace" >/dev/null 2>&1; then
                 log "Pod '$pod_name' no longer exists. Assuming completion/failure."
                 return 1
             else
                 log "Pod '$pod_name' exists but status query was empty. Retrying..."
             fi
        fi

        local current_time=$(date +%s)
        local elapsed_time=$((current_time - start_time))

        if [ "$elapsed_time" -ge "$RSYNC_TIMEOUT" ]; then
            log "Timeout waiting for pod '$pod_name' to complete (last status attempt: '$pod_status'). Fetching logs:"
            kubectl logs "$pod_name" -n "$namespace" --tail=50 || log "Could not fetch logs for timed-out pod '$pod_name'."
            log "Trying to get pod description on timeout:"
            kubectl describe pod "$pod_name" -n "$namespace" || log "Could not describe pod '$pod_name' on timeout."
            log "Trying to get pod events on timeout:"
            kubectl get events --field-selector involvedObject.name="$pod_name",involvedObject.namespace="$namespace" || log "Could not get events for pod '$pod_name' on timeout."
            return 1
        fi

        log "Pod '$pod_name' status is '$pod_status'. Waiting..."
        sleep 5 # Poll every 5 seconds
    done
}

# Function to delete a temporary pod
delete_temp_pod() {
    local pod_name="$1"
    local namespace="$2"

    log "Deleting temporary pod '$pod_name' in namespace '$namespace'."
    # Add --wait=true to ensure deletion completes before proceeding
    kubectl delete pod "$pod_name" -n "$namespace" --ignore-not-found=true --wait=true
    log "Temporary pod '$pod_name' deleted."
}

# Function to perform rsync with retries
perform_rsync() {
    local target_pvc="$1"
    local namespace="$2"

    local attempt=1
    while [ "$attempt" -le "$MAX_RETRIES" ]; do
        log "Attempt $attempt of $MAX_RETRIES for rsync to '$target_pvc'."
        # Call create_temp_pod and check its return status
        if ! create_temp_pod "$SOURCE_PVC" "$target_pvc" "$namespace"; then
            log "ERROR: Failed to create temporary pod for '$target_pvc'. Skipping attempt $attempt."
            # Optional: add delay before retrying pod creation
            # sleep 5
            attempt=$((attempt + 1))
            continue # Skip to next attempt
        fi

        # Get timestamp before calling wait_for_pod
        local current_start_time=$(date +%s)
        if wait_for_pod "replication-temp-pod-$target_pvc" "$namespace" "$current_start_time"; then
            log "Rsync succeeded on attempt $attempt for '$target_pvc'."
            break
        else
            log "Rsync failed or pod wait failed on attempt $attempt for '$target_pvc'."
            if [ "$attempt" -lt "$MAX_RETRIES" ]; then
                log "Retrying rsync after delay..."
                sleep 10  # Delay before next attempt
            else
                log "Exceeded maximum retries for rsync to '$target_pvc'. Skipping to next PVC."
            fi
        fi

        attempt=$((attempt + 1))
    done

    # Delete temporary pod if it exists (ensure pod_name is consistent)
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
