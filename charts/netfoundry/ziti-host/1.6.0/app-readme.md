# OpenZiti Service-Hosting Deployment for Kubernetes

[OpenZiti](https://ziti.dev) makes it easy to embed Zero Trust, programmable networking directly into your app. With Ziti you can have Zero Trust, high performance networking on any Internet connection, without VPNs!

You will need an enrollment token from your Ziti network to install this chart. Then you may control access to your Rancher cluster workloads by assigning services to the enrolled edge identity in your Ziti network dashboard.

This chart installs a Ziti edge tunneler in a namespace of your cluster. Like all edge identities in a Ziti network, this tunneler too will need an identity. You will need to create the identity and paste its enrollment token when you install this chart. If you haven't already created your network you can do so for free with [the self-hosted quickstarts](https://openziti.github.io/) or take [the managed route with NetFoundry Teams](https://netfoundry.io/) (free tier).
