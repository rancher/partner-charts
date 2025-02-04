if [ -z "$1" ]
then
    echo "Usage:"
    echo "  $0 <NAME>"
    exit 1
fi

set -eu

declare -A seqno_map # highest seqno for an UUID
declare -A count_map # number of nodes with that UUID
declare -A pod_map   # pod candidate for UUID

get_gtid()
{
    kubectl logs $1 2>&1 |\
    grep "WSREP: Recovered position" |\
    cut -d ' ' -f4 |\
    cut -d '/' -f1
}

get_pods()
{
    kubectl get pods |\
    grep $1 |\
    cut -d ' ' -f1
}

list_most_updated()
{
    for pod in $(get_pods $1)
    do
        gtid=$(get_gtid $pod)
        uuid=${gtid%%:*}; seqno=${gtid##*:}

        count_map[$uuid]=$(( ${count_map[$uuid]:-0} + 1 ))

        has_seqno=${seqno_map[$uuid]:-"-1"}
        if [ $has_seqno -lt $seqno ]
        then
            seqno_map[$uuid]=$seqno
            pod_map[$uuid]="$gtid $pod"
        fi
    done

    echo "Candidates (NB: if there is more than one, choose carefully):"
    (for entry in "${!pod_map[@]}"
     do
        echo "UUID count: ${count_map[$entry]} ${pod_map[$entry]}"
     done) | sort -rn # sort in order of max count
}

list_most_updated $1
