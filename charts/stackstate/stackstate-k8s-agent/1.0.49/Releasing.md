To make a new release of this helm chart, follow the following steps:


- Create a branch from master
- Set the latest tags for the docker images, based on the dev settings (while we do not promote to prod, the moment we promote to prod we should take those tags) from https://gitlab.com/stackvista/devops/agent-promoter/-/blob/master/config.yml. Set the value to the folowing keys:
  * stackstate-k8s-cluster-agent:
    * [clusterAgent.image.tag]
  * stackstate-k8s-agent:
    * [nodeAgent.containers.agent.image.tag]
    * [checksAgent.image.tag]
  * stackstate-k8s-process-agent:
    * [nodeAgent.containers.processAgent.image.tag]
- Bump the version of the chart
- Merge the mr and hit the public release button on the ci pipeline
- Manually smoke-test (deploy) the newly released stackstate/stackstate-k8s-agent chart to make sure it runs
