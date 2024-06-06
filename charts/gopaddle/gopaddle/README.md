<img alt="gopaddle" src="https://gopaddle-marketing.s3.ap-southeast-2.amazonaws.com/gopaddle.png?s=200&v=4" width="200" align="left">

# [gopaddle](https://gopaddle.io/)
[![Slack Channel](https://img.shields.io/badge/Slack-Join-purple)](https://gopaddleio.slack.com/join/shared_invite/zt-1l73p8wfo-vYk1XcbLAZMo9wcV_AChvg#/shared-invite/email/expanded-email-form)

## Kubernetes IDE with AI Co-pilot

gopaddle is a low-code Kubernetes IDE with AI Co-pilot. The low-code IDE has advanced resource filtering, a YAML free form editor, and developer tools like a container terminal and logs. The AI Co-pilot provides interactive troubleshooting.

## Supported AI Models

ChatGPT models gpt-4o and gpt-4-turbo.

## Installation 

### Minimum System Requirements

gopaddle installation requires a minimum of `4GB RAM` and `2 vCPUs`

### Firewall Ports

The following incoming firewall ports need to be opened - `30003`.

### Step to install using Helm Charts

Add the helm repo

```sh
helm repo add gopaddle https://gopaddle-io.github.io/gopaddle-lite/
helm repo update
```
Install the chart

```sh
helm install gp-lite gopaddle/gopaddle --namespace gopaddle --create-namespace
```

### Validating the installation
gopaddle installation can be validated by waiting for the gopaddle services to move to `ready` state.

```sh
kubectl wait --for=condition=ready pod -l released-by=gopaddle -n gopaddle
```

One the installation is complete, gopaddle dashboard can be accessed at http://[NodeIP]:30003/

NodeIP can be obtained by executing the command below:

```sh
kubectl get nodes -o wide
```

## Usage

Open the `Ask AI` option, select the LLM Type as `OpenAI`, select a model, and provide the API Key.  

To get the OpenAI API Key, check here: [OpenAI API Key](https://platform.openai.com/api-keys). 


