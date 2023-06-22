<img alt="gopaddle" src="https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/gopaddle.png?s=200&v=4" width="200" align="left">

# [gopaddle](https://gopaddle.io/)

## Simplest DevSecOps platform for Kubernetes developers and operators.

gopaddle is a simple low-code Internal Developer Platform (IDP) for Kubernetes developers and operators. Using gopaddle, developers can generate everything they need to set up Kubernetes infrastructure on multiple cloud environments and deployment applications with ease. From Dockerfiles to Kubernetes YAML files, Helm Charts, and pipeline code, gopaddle will help  containerize and get the applications running in minutes. Developers can also efficiently manage existing applications on the Kubernetes cluster by monitoring the application performance and setting alerts and notificications.
<br>

## gopaddle Lite
gopaddle Lite is a life-time free community edition of gopaddle that can be installed in a single node/single user mode on a Kubernetes cluster. gopaddle lite comes with many capabilities that helps developers to built a self-service portal for a small scale Kubernetes deployment at zero cost.  gopaddle Lite is available on a variety of marketplaces like microk8s add-on, SUSE Rancher Prime, ArtifactHub and many more.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/gopaddle-lite)](https://artifacthub.io/packages/search?repo=gopaddle-lite)
[![Slack Channel](https://img.shields.io/badge/Slack-Join-purple)](https://gopaddleio.slack.com/join/shared_invite/zt-1l73p8wfo-vYk1XcbLAZMo9wcV_AChvg#/shared-invite/email/expanded-email-form)
[![Twitter](https://img.shields.io/twitter/follow/gopaddleio?style=social)](https://twitter.com/gopaddleio)
[![YouTube Channel](https://img.shields.io/badge/YouTube-Subscribe-red)](https://www.youtube.com/channel/UCtbfM3vjjJJBAka8DCzKKYg)
<br><br>

## Installation 

### Minimum System Requirements
gopaddle installation requires a minimum of `8GB RAM` and `4 vCPUs`

### Firewall Ports
The following incoming firewall ports need to be opened - `30003`, `30004`, `30006`, `32000` and any port that is needed for nodeport based application deployment.

### Step to install using Helm Charts

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

One the installation is complete, gopaddle dashboard can be accessed at http://[NodeIP]:30003/

NodeIP can be obtained by executing the command below:

```sh
root@localhost:~# kubectl get nodes -o wide
```

## microk8s addon for gopaddle lite

The microk8s addon for gopaddle community (lite) edition uses this helm
repository for helm-based installation of gopaddle-lite.

For documentation specific to microk8s addon for gopaddle community (lite)
edition, see:
https://help.gopaddle.io/en/articles/6654354-install-gopaddle-lite-microk8s-addon-on-ubuntu

## gopaddle lite on SUSE Rancher Prime
gopaddle Lite can be easily installed by choosing the gopaddle chart from the Rancher Prime marketplace place. 
For documentation specific to installing gopaddle community (lite) edition on Rancher Prime, see:

https://help.gopaddle.io/en/articles/6977654-install-gopaddle-lite-on-suse-rancher-prime

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

## Features 
## 1\. DevOps Dashboard

The main dashboard gives a bird's eye view of the clusters, volumes, applications, events and projects imported and managed by gopaddle.

![DevOps Dashboard](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-dashboard.png>)

## 2\. Builds & Vulnerabilities

The builds and vulnerabilities dashboard captures the status of the Docker builds and the severity of the vulnerabilities identified in the builds.

![Builds & Vulnerabilities](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-devops-dashboard.png>)

## 3\. Quick start wizards

gopaddle offers 3 type of quick start wizards -

**1\. Provision Clusters** \- Onboard GKE or AWS cloud accounts with fine grained access controls and provision multi-cloud Kubernetes cluster. Available only in SaaS & Enterprise Editions.

**2\. Dockerize & Deploy** \- Automatically generate Dockerfiles and Kubernetes YAML files by analyzing the source code in GitHub or GitLab accounts and deploy them on to Kubernetes clusters.

**3\.Generate Pipeline code** \- Generate Jenkins or GitHub Actions or Azure DevOps pipeline Code for an application deployed through gopaddle.

![Quickstart Wizards](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/quick-start-wizards.png>)

## 4\. Marketplace

Subscribe to a gopaddle marketplace application, and visualize the helm chart in the design studio. These templates can be launched on a Kubernetes cluster using simple UI based wizards.

![Marketplace](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-marketplace.png>)

## 5\. Cluster Management

Clusters can be centrally managed. gopaddle automatically installs a few addons on these clusters - like Prometheus and Grafana for an out-of-the-box monitoring and alerting capabilties.

![Cluster Management](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-cluster.png>)

## 6\. Designer Studio

Design Studio provides a visual representation of the Kubernetes resources and helps to quickly design and compose Kubernetes resources without having to learn YAML.

![Designer Studio](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-designstudio.png>)

## 7\. Application Management

Centrally monitor the existing Kubernetes deployments.

![Application Management](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-app-dashboard.png>)

## 8\. Alerts & Notifications

Set alerts and notifications for the applications and clusters managed by gopaddle. gopaddle supports any type of incoming webhooks, slack, AWS SNS, Jenkins Jobs and PagerDuty as notification channel.

![Alerts & Notifications](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-alerts-notifications.png>)

## 9\. Developer Tools - Container Terminal

Easily troubleshoot issues in deployments using inbuilt developer tools like Container terminal without having to use Kubectl commands.

![Container Terminal](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-devtools-1.png>)

## 10\. Developer Tools - Container Logs

Easily troubleshoot issues in deployments using inbuilt developer tools like Container logs without having to use Kubectl commands.

![Container Logs](<https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/docker-desktop-screenshots/gp-devtools-2.png>)

## Help

For help related to gopaddle community (lite) edition, visit the gopaddle Help Center at:  https://help.gopaddle.io
