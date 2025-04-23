## Deploy

The following will deploy Kasm in your Kubernetes cluster.

## Prerequisite
1. StorageClass for Persistent Volume Claims (PVC): A StorageClass must be configured in the cluster to create Persistent Volume Claims (PVC) for the postgres-db.
2. A Virtual Machine or Bare-Metal server that meets the [system requirements](https://kasmweb.com/docs/latest/install/system_requirements.html) for installing Kasm agent.

## Deploy Helm Chart
Refer to the [values.yaml](https://helm.kasmweb.com/values.yaml) for available Helm values and their default configurations.

To begin, it's recommended to start by adding the global.hostname value in the values.yaml file. This will set the hostname for the ingress URL.

## Next Steps
Once the Helm chart is fully deployed, add the ingress IP address to your DNS zone. After that, you should be able to access your Kasm instance at https://{global.hostname}, for example: https://kasm.example.com.

### Login Kasm Admin Console
The default admin username is `admin@kasm.local`. To retrieve the password, run the following kubectl command:

```bash
kubectl get secret --namespace {namespace} kasm-secrets -o jsonpath="{.data.admin-password}" | base64 -d
```

### Retrieve Manager Token (Required For Agent Install)

To retrieve the manager token, use the following kubectl command:

```bash
kubectl get secret --namespace {namespace} kasm-secrets -o jsonpath="{.data.manager-token}" | base64 -d
```

### Install Agent

Please ensure you have a Virtual Machine or Bare-Metal server that meets the [system requirements](https://kasmweb.com/docs/latest/install/system_requirements.html) for installing Kasm agent. Follow the steps below to install Kasm agent on the server.

```bash
cd /tmp
curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.17.0.bbc15c.tar.gz
tar -xf kasm_release_1.17.0.bbc15c.tar.gz
sudo bash kasm_release/install.sh --role agent --public-hostname [AGENT_HOSTNAME] --manager-hostname [MANAGER_HOSTNAME] --manager-token [MANAGER_TOKEN]
```

* AGENT_HOSTNAME : The hostname or IP address of the Agent Server that is resolvable and reachable by the Kasm helm deployment.
* MANAGER_HOSTNAME : The hostname or IP address of the Agent server, which must be resolvable and accessible by the Kasm Helm deployment.
* MANAGER_TOKEN : The manager token, which can be retrieved in the previous step. It is used for authentication by the Agent.

**Note:** To make the above command non-interactive, add the following flags:

- `--accept-eula`: Non-interactively accept the [Kasm End User License Agreement](https://kasmweb.com/assets/pdf/Kasm_Workspaces_EULA.pdf).
- `--swap-size`: Create a swap partition on the agent server (in MB). Example value: `8192`. To skip the swap check, use the `--no-swap-check` flag instead. For more information, refer to the [Kasm Documentation](https://kasmweb.com/docs/latest/install/swap_warning.html).

### Enable the Agent
In the Kasm admin console, select **Infrastructure > Docker Agents** and using the arrow menu select **Edit** on the agent you just created. Make sure **Enabled** is selected and click **Save**.


### Install a Workspace
In the Kasm admin console, select **Workspaces > Registry** and choose the workspace image you would like to install.

*Note: The agent may take a few minutes to download the selected workspace image before a session can be started.*

### Start A Kasm Session
Navigate to the **WORKSPACES** tab at the top of the page and start your first Kasm session once the workspace image is ready!
