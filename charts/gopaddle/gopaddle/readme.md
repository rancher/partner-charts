<img alt="gopaddle" src="https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/gopaddle.png?s=200&v=4" width="200" align="left">

# [gopaddle](https://gopaddle.io/)

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/gopaddle-lite)](https://artifacthub.io/packages/search?repo=gopaddle-lite)
[![Slack Channel](https://img.shields.io/badge/Slack-Join-purple)](https://gopaddleio.slack.com/join/shared_invite/zt-1l73p8wfo-vYk1XcbLAZMo9wcV_AChvg#/shared-invite/email/expanded-email-form)
[![Twitter](https://img.shields.io/twitter/follow/gopaddleio?style=social)](https://twitter.com/gopaddleio)
[![YouTube Channel](https://img.shields.io/badge/YouTube-Subscribe-red)](https://www.youtube.com/channel/UCtbfM3vjjJJBAka8DCzKKYg)
<br><br><br><br>

## Installation 

### Minimum System Requirements
gopaddle installation requires a minimum of `8GB RAM` and `4 vCPUs`

### Step to install

Add the helm repo

```sh
helm repo add gopaddle https://gopaddle-io.github.io/gopaddle-lite/
helm repo update
```
Install the chart

```sh
helm install gp-lite gopaddle/gopaddle --namespace gp-lite-4-2 --create-namespace
```

### Validating the installation
gopaddle installation can be validated by waiting for the gopaddle services to move to `ready` state.

```sh
root@localhost:~# kubectl wait --for=condition=ready pod -l released-by=gopaddle -n gp-lite-4-2 --timeout=15m
pod/webhook-7c49ddfb78-ssvcz condition met
pod/mongodb-0 condition met
pod/esearch-0 condition met
pod/deploymentmanager-65897c7b9c-qlgk8 condition met
pod/appworker-8546598fd-7svzv condition met
pod/influxdb-0 condition met
pod/costmanager-6496dfd6c4-npqj8 condition met
pod/rabbitmq-0 condition met
pod/gpcore-85c7c6f65b-5vfmh condition met
```

One the installation is complete, gopaddle dashboard can be accessed at http://<NodeIP>:30003/

NodeIP can be obtained by executing the command below:

```sh
root@localhost:~# kubectl get nodes -o wide
```


## Getting started with gopaddle

Once the gopaddle lite dashboard is available, developers can open the gopaddle dashboard in the browser, review the evaluation agreement and subscribe to the lite edition.

<img width="865" alt="gp-evaluation-agreement" src="https://user-images.githubusercontent.com/74309181/205760559-478ebb58-d1fd-4517-ba1f-5710ed9694c6.png">


### Containerize and Deploy

Once the subscription is complete, developers can login to the gopaddle console, using their email ID and the initial password.

In the main dashboard, the **Containerize and Deploy** Quickstart wizard helps to onboard a Source Code project from GitHub using the GitHub personal access token, build and push the generated container image to the Docker Registry. Once the build completes, gopaddle generates the necessary YAML files and deploys the docker image to the local microk8s cluster. 

<img width="1392" alt="gp-quickstart-wizards" src="https://user-images.githubusercontent.com/74309181/205762236-3ade6aaa-bfeb-40c5-8996-c68eed4126cf.png">

#### Pre-requisites

[Docker Access Token with Read & Write Permissions](https://www.docker.com/blog/docker-hub-new-personal-access-tokens/)

[GitHub Person Access Token for containerizing Private Repositories](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

In the final step of the Containerize and Deploy Quickstart wizard, enable the option to **Disable TLS verification**. 

<img width="1409" alt="containerize-deploy-quickstart" src="https://user-images.githubusercontent.com/74309181/205758353-7ce833e6-e493-4680-b7e9-a04f43e541ff.png">

All the artificats generated during the process can be edited and re-deployed at a later stage.

### Application Templates - Marketplace

Under Templates, the Marketplace Applications hosts a variety of pre-built Kubernetes templates. Developers can subscribe to these templates and deploy them on the local microk8s cluster.

<img width="1445" alt="gp-app-templates-1" src="https://user-images.githubusercontent.com/74309181/205758999-2a50eac6-d292-4280-85dd-3d617eda623a.png">

## Help

For help related to gopaddle community (lite) edition, visit the gopaddle Help Center at:  https://help.gopaddle.io


