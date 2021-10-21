# Shipa

[Shipa](http://www.shipa.io/) is an Application-as-Code [AaC] provider that is designed for having a cleaner developer experience and allowing for guardrails to be easily created. The "platform engineering dilemma" is how do you allow for innovation yet have control. Shipa is application focused so allowing developers who are not experienced in Kubernetes run through several critical tasks such as deploying,  managing, and iterating on their applications without detailed Kubernetes knowledge. From the operator or admin standpoint, easily enforcing rules/convention without building multiple abstraction layers.

## Install Shipa - Helm Chart

The [Installation Requirements](https://learn.shipa.io/docs/installation-requirements) specify up to date cluster and ingress requirements. Installing the chart is pretty straight forward.

Intially will need to set an intial Admin User and Admin Password/Secret to first access Shipa.

```
helm repo add shipa-charts https://shipa-charts.storage.googleapis.com

helm repo update

helm upgrade --install shipa shipa-charts/shipa \

--set auth.adminUser=admin@acme.com --set auth.adminPassword=this-is-a-secret \

--namespace shipa-system --create-namespace --timeout=1000s --wait
```