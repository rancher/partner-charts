# Codezero

Codezero introduces an innovative overlay network that transforms VMs / Kubernetes clusters into Teamspaces, enhancing collaborative development.

**Teamspaces**: These are specialized development environments where developers can work together seamlessly. Teamspaces facilitate real-time collaboration by allowing developers to:

- **Consume Services**: Developers can access and utilize services listed in a Service Catalog. This Catalog includes services running either within a Kubernetes cluster / VM or on a team member's local machine, ensuring that all team members have access to the necessary components for development and testing.
- **Serve Local Variants**: Team members can temporarily share their own local versions (or Variants) of Services. By serving these local variants through the Service Catalog, developers can test and iterate on their work in a shared environment, promoting rapid feedback and integration.

This simplifies the development process and bridges the gap between Local development and Remote deployment, allowing developers to focus more on coding and less on managing network configurations.

## Rancher Installation

1. Log in to https://hub.codezero.io, navigate to "API Keys" and note the Organization ID and API Key.
1. Go to Apps in the Rancher UI. In the Chart section click on the Codezero chart and then on Install.
1. Select a namespace for Codezero Space Agent to be installed (recommended new namespace: codezero) and click "Next".
1. Paste the Organization ID and API Key from the Codezero API Keys page (see step 1).
1. Enter a name for the new Teamspace, e.g. the name of the cluster and click Next.
1. Click on the Install button to complete installation of the agent.

To perform an upgrade, click on Edit/Upgrade.
