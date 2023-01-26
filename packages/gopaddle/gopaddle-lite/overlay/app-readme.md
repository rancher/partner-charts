## gopaddle
gopaddle is a low-code Internal Developer Plaform (IDP) for Kubernetes developers and operators. It provides a self-service portal through which developers can scaffold code to containers, auto-generate YAML files, build docker images, deploy applications on to Kubernetes and manage the application life cycle from a single dashboard.

### Version Number

gopaddle Lite - v4.2.5

### Pre-requisite
a) Install the necessary CSI driver to provision Persistent Volumes.

For eg., If you are running Rancher RKE on AWS, install the AWS EBS CSI driver. 

```
kubectl create secret generic aws-secret --namespace kube-system --from-literal "key_id=<aws-access-key>" --from-literal "access_key=<aws-secret-key>"
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.13"
```

You can find more information on AWS CSI Driver [here](https://github.com/kubernetes-sigs/aws-ebs-csi-driver#kubernetes-version-compatibility-matrix)

In case of AWS CSI Driver, patch the first node in the cluster to add the labels `topology.kubernetes.io` & `topology.kubernetes.io/zone` to point to the node's region and zone. The below script patches the node labels to `us-east-1` region and `us-east-1a` zone.

```
apt install jq -y
node=$(kubectl get nodes -o json | jq -r '.items[0].metadata.annotations["rke2.io/hostname"]')
kubectl patch node $node -p '{"metadata": {"labels":{"topology.kubernetes.io/region": "us-east-1"}}}'
kubectl patch node $node -p '{"metadata": {"labels":{"topology.kubernetes.io/zone":"us-east-1a"}}}'
```

b) Create default storageClass.
Create a storageClass named `standard` from the Rancher Dashboard https://rancher-endpoint/dashboard/c/local/explorer/storage.k8s.io.storageclass.

In case of AWS, create an Amazon EBS Disk.

<img src="https://user-images.githubusercontent.com/74309181/211659744-adde9594-5a33-4fea-8578-b9347142ba1c.png" width="80%">

Patch the storageClass `standard` and add the `is-default-class` annotation to make it the default storageClass.

```
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

c) Open INBOUND firewall ports 30003 and 30004. If RKE is installed on AWS, then open the ports 30003 and 30004 in the instance security group.

Once the gopaddle chart is installed, the dashboard can be accessed at http://node_ip:30003

### Support URL

[![Slack Channel](https://img.shields.io/badge/Slack-Join-purple)](https://gopaddleio.slack.com/join/shared_invite/zt-1l73p8wfo-vYk1XcbLAZMo9wcV_AChvg#/shared-invite/email/expanded-email-form)

### Documentation

[Documentation](https://help.gopaddle.io)
