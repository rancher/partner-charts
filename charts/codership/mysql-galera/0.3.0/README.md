# HELM charts for MySQL/Galera cluster

## Common usage:
```
helm install [set values] <cluster name> .
```
see values.yaml for supported/required oprtions.

### Setting values for Docker image
On `helm install` you will need to set some environmet variables for the image, e.g.
```
--set env.MYSQL_ROOT_PASSWORD=<value> --set env.MYSQL_USER=<value> --set env.MYSQL_PASSWORD=<value>
```
For all variables see https://hub.docker.com/_/mysql. Not all of them are supported, e.g. datadir mount point is fixed.

These variables will be used to initialize the database if not yet initialized. Otherwise MYSQL_USER and MYSQL_PASSWORD will be used for the readiness probe so they must be specified on all chart installs. MYSQL_ROOT_PASSWORD is used only once for database initialization.

### Requesting kubernetes resources for pods
The usual kubernetes stuff:
```
--set resorces.requests.memory=4Gi --set resources.requests.storage=16Gi --set resources.requests.cpu=4
```

### Connecting to cluster
By default MySQL client service is open through load balancer on port 30006. It can be changed (if supported by k8s cluster) by:
```
--set service.port=NNNN
```
*NOTE:* in Scaleway Kubernetes cluster load balancer opens port 3306 regardless of the `service.port` setting.

### Graceful cluster shutdown
Graceful cluster shutdown requires scaling the cluster to one node before `helm uninstall`:
```
helm upgrade --reuse-values --set replicas=1 <cluster name> .
mysql <options> -e "shutdown;"
helm uninistall <cluster name>
```
This will leave the last pod in the stateful set (0) safe to automatically bootstrap the cluster from.

### Force bootstrap from a particular pod
In case the cluster need to be recovered from scratch (e.g. `helm uninstall` was called), it can be forced to bootstrap from a particular pod. To find which pod to use the cluster can be started in "recover-only" mode:
```
$ helm install --set env.WSREP_RECOVER_ONLY <cluster name> .
```
Then
```
$ kubectl logs <pod name> | grep 'Recovered position'
```
shall print diagnostic output showing pod position in replication history. Most updated pod should be chosen as a bootstrap node.
`find_most_updated.sh` script can help to identify the right pod. It will look like:
```
$ ./find_most_updated.sh <cluster name>
Candidates (NB: if there is more than one, choose carefully):
UUID count: 3 bf6bd3e5-020e-11ef-ae7a-ceb1e82e2567:425 <cluster name>-mysql-galera-2
```
Where bf6bd3e5-020e-11ef-ae7a-ceb1e82e2567 is the cluster/dataset UUID and 425 is the sequence number of the last data change.

After the most updated pod has been identified, check its `grastate.dat` file:
```
$ kubectl exec <cluster name>-mysql-galera-2 -- cat /var/lib/mysql/grastate.dat
# GALERA saved state
version: 2.1
uuid: bf6bd3e5-020e-11ef-ae7a-ceb1e82e2567
seqno:   -1
safe_to_bootstrap: 0
```
Then run the followwing command:
```
$ kubectl exec <cluster-name>-mysql-galera-2 -- sed -i "s/safe_to_bootstrap:[[:blank:]]*[0-9]/safe_to_bootstrap: 1/" /var/lib/mysql/grastate.dat
```
And if the `uuid:` field above is `00000000-0000-0000-0000-000000000000` run the follwowing:
```
$ kubectl exec <cluster-name>-mysql-galera-2 -- sed -i "s/uuid:[[:blank:]]*00000000-0000-0000-0000-000000000000/uuid: <UUID from the output above>/" /var/lib/mysql/grastate.dat
```
Verify that resulting `grastate.dat` makes sense:
```
$ kubectl exec <cluster name>-mysql-galera-2 -- cat /var/lib/mysql/grastate.dat
...
```
Now uninstall the cluster:
```
$ helm uninstall <cluster name>
```
Wait for the pods to be deleted and install with the production options:
```
$ helm install --set env.MYSQL_USER=... --set env.MYSQL_PASSWORD=... <cluster name> .
```
The cluster should be up and running after nodes synchronization. The progress can be monitored through
```
$ kubectl logs <pod name>
```
Once the nodes reach `SYNCED` state they will be available through the Kubernetes load balancer.
