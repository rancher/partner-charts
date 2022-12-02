# CloudCasa Kubernetes Agent

[CloudCasa](https://cloudcasa.io) - A Smart Home in the Cloud for Kubernetes Backups

# Introduction

CloudCasa is a SaaS solution that provides class-leading data protection services for Kubernetes and cloud native applications.
Configuration is quick and easy, and basic service is free.

This Helm chart installs and configures the CloudCasa agent on a Kubernetes cluster.
See the CloudCasa [Getting Started Guide](https://cloudcasa.io/get-started) for more information.

## Prerequisites

1. Kubernetes 1.17+
2. Helm 3.0+

## Installation

### Rancher Installation (Apps & Marketplace)

1. Log in to https://home.cloudcasa.io and add your Kubernetes cluster under the Protection tab. Note the returned cluster ID.
2. Go to Apps & Marketplace in the Rancher UI. In the Chart section, check the Partners checkbox and click on the CloudCasa chart.
3. Provide a Name (e.g. CloudCasa) and optional description.
4. In the CloudCasa Configuration section, provide the Cluster ID obtained above.
5. Click on the Install button to complete installation of the agent.
6. Click on Upgrade version to upgrade the existing helmchart. 
 
**Note**: Validate the existence of four CRDS viz. volumesnapshotlocations.velero.io, volumesnapshotcontents.snapshot.storage.k8s.io, volumesnapshots.snapshot.storage.k8s.io and volumesnapshotclasses.snapshot.storage.k8s.io. If any one of the crds doesnt exist, execute the edit/upgrade operation.

### Helm CLI Installation

1. Log in to https://home.cloudcasa.io and add your Kubernetes cluster under the Protection tab. Note the returned cluster ID.
2. Execute the following helm commands, replacing ```<ClusterID>``` with the Cluster ID obtained above:
    ```
    $ helm repo add cloudcasa-repo https://catalogicsoftware.github.io/cloudcasa-helmchart
    $ helm install cloudcasa.io cloudcasa-repo/cloudcasa --set cluster_id=<Cluster ID>
    ```
This will install the CloudCasa agent and complete registration of the cluster with the CloudCasa service.

## Updating the CloudCasa Agent
1. Log in to https://home.cloudcasa.io and obtain the cluster ID for your cluster by selecting it under the Protection tab.
2. Execute the following commands to update the agent:
    ```
    $ helm repo update
    $ helm upgrade cloudcasa.io cloudcasa-repo/cloudcasa --set cluster_id=<Cluster ID>
    ```

**Note**: Validate the existence of four CRDS viz. volumesnapshotlocations.velero.io, volumesnapshotcontents.snapshot.storage.k8s.io, volumesnapshots.snapshot.storage.k8s.io and volumesnapshotclasses.snapshot.storage.k8s.io. If any one of the crds doesnt exist, again execute the upgrade command.

## Uninstalling the CloudCasa Agent
1. Execute the following commands to uninstall CloudCasa.
    ```    
    $ helm uninstall cloudcasa.io
    $ kubectl delete namespace/cloudcasa-io clusterrolebinding/cloudcasa-io
    $ kubectl delete crds -l component=kubeagent-backup-helper
    ```
*CloudCasa is a trademark of Catalogic Software Inc.*
