#!/bin/sh

MAX_ATTEMPTS=150
SHIPA_URL="http://${SHIPA_INTERNAL_DNS}:${SHIPA_API_SERVICE_PORT}"

function logError {
  local _msg="${1}"
  local _event_id="${2}"
  echo -e "-n[ERROR] ${_msg}\n"
  if [[ "${_event_id:-"null"}" != "null" ]]; then
    echo -e "    shipa event info ${_event_id}\n"
    echo "Log:"
    curl -sSH "${AUTH_HEADER}" "${EVENT_INFO_URL}" | jq -r '.Log'
    echo "Error:"
    curl -sSH "${AUTH_HEADER}" "${EVENT_INFO_URL}" | jq -r '.Error'
    echo ""
  fi
  echo "[ERROR] Main cluster could not be updated. To handle manually, see https://learn.shipa.io/docs/managing-clusters#updating-clusters"
  exit 1
}

function iterate {
  local _msg="${1}"
  local _event_id="${2}"
  sleep 2
  ATTEMPTS=$((ATTEMPTS + 1))
  if [[ ${ATTEMPTS} -gt ${MAX_ATTEMPTS} ]]; then
    logError "${_msg}" "${_event_id}"
  fi
}

function getLatestUpdateSegment {
  local _segment="${1}"
  local _result="$(shipa event list --target cluster --target-value shipa-cluster --kind "cluster.update" | grep '^| ID' -A2 | tail -n1 | awk -F'|' "/1/ {print \$${_segment}}" | xargs echo | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?(;[0-9]{1,2})?)?[mGK]//g")"
  if [[ -z "${_result}" ]]; then
    echo "..."
  else
    echo "${_result}"
  fi
}

function getLatestUpdateEventId {
  getLatestUpdateSegment 2
}

function getLatestUpdateEventSuccess {
  getLatestUpdateSegment 4
}

function getEventLog {
  local _eventId="${1}"
  shipa event info $(getLatestUpdateEventId) | grep '^[^ ]*Log:' -A1000
}

function getEventError {
  local _eventId="${1}"
  shipa event info $(getLatestUpdateEventId) | grep '^[^ ]*Error:'
}

echo "[INFO] Waiting for API to be available"
ATTEMPTS=0
until [[ "$(curl -o /dev/null -w '%{http_code}\n' -s ${SHIPA_URL})" == "200" ]]; do
  iterate "Failed to get a response from ${SHIPA_URL}"
done

echo "[INFO] Adding target as local-target"
ATTEMPTS=0
until shipa target add -s local-target ${SHIPA_INTERNAL_DNS} --port ${SHIPA_API_SERVICE_PORT} --insecure; do
  iterate "Failed to add target for ${SHIPA_URL}"
done

echo "[INFO] Logging in to local-target"
ATTEMPTS=0
TOKEN_PATTERN="^[0-9a-f]{64}$"
until [[ "${SHIPA_TOKEN}" =~ ${TOKEN_PATTERN} ]]; do
  shipa login <<EOF
${SHIPA_ADMIN_USER}
${SHIPA_ADMIN_PASSWORD}
EOF
  SHIPA_TOKEN="$(shipa token show | awk -F': ' '{print $2}')"
  iterate "Failed to login to target"
done

AUTH_HEADER="Authorization: Bearer ${SHIPA_TOKEN}"

NOW="$(date -uIseconds | sed 's/+00:00/Z/')"
sleep 2
echo "[INFO] Updating shipa-cluster"
ATTEMPTS=0
until shipa cluster update shipa-cluster; do
  iterate "cluster-agent was unable to be updated"
done
echo ""

KIND_NAME="cluster.update"
TARGET_TYPE="cluster"
TARGET_VALUE="shipa-cluster"
FILTERED_EVENTS_URL="${SHIPA_URL}/1.0/events?kindname=${KIND_NAME}&org=${SHIPA_ORGANIZATION_ID}&since=${NOW}&target.type=${TARGET_TYPE}&target.value=${TARGET_VALUE}"
echo $FILTERED_EVENTS_URL

sleep 5
echo "[INFO] Waiting for new cluster.update event"
ATTEMPTS=0
EVENT_ID=""
until [[ -n "${EVENT_ID}" && "${EVENT_ID}" != "null" ]]; do
  EVENT_ID="$(curl -sSH "${AUTH_HEADER}" "${FILTERED_EVENTS_URL}" | jq -r '.events[0].UniqueID')"
  iterate "could not find new cluster.update event:\n    shipa event list --target \"cluster\" --target-value \"shipa-cluster\" --kind \"cluster.update\""
done

EVENT_INFO_URL="${SHIPA_URL}/1.0/events/${EVENT_ID}"

echo "[INFO] Waiting for cluster.update event ${EVENT_ID} to finish"
ATTEMPTS=0
until [[ "$(curl -sSH "${AUTH_HEADER}" "${EVENT_INFO_URL}" | jq -r '.IsDone')" == "true" ]]; do
  iterate "cluster.update event did not complete" "${EVENT_ID}"
done

echo "[INFO] Checking for cluster.update event success"
if [[ -n "$(curl -sSH "${AUTH_HEADER}" "${EVENT_INFO_URL}" | jq -r '.Error')" || "$(curl -sSH "${AUTH_HEADER}" "${EVENT_INFO_URL}" | jq -r '.CancelInfo.Canceled')" != "false" ]]; then
  logError "cluster.update event did not succeed" "${EVENT_ID}"
fi

echo "[INFO] Cluster update completed successfully"
