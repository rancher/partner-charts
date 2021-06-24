# Upbound Universal Crossplane (UXP)

Upbound Universal Crossplane (UXP) is [Upbound's](https://upbound.io) official enterprise-grade distribution of [Crossplane](https://crossplane.io). It's fully compatible with upstream Crossplane, [open source](https://github.com/upbound/universal-crossplane), capable of connecting to [Upbound Cloud](https://cloud.upbound.io) for real-time dashboard visibility, and maintained by Upbound. It's the easiest way for both individual community members and enterprises to build their production control planes.

## Connecting to Upbound Cloud

You can optionally connect your Universal Crossplane instance to Upbound Cloud.
Follow the steps below to connect your Universal Crossplane cluster to your Upbound Cloud Console.

1. Install Upbound CLI

	You will need to make sure you have the Upbound CLI installed before you continue. If you need more information on how to install the Upbound CLI, you can read the [Installing Upbound CLI Documentation](https://cloud.upbound.io/docs/cli).

	```
	curl -sL https://cli.upbound.io | sh
	```

2. Log in to Upbound Cloud

	```
	up cloud login --profile=rancher --account=$UPBOUND_ACCOUNT
	```

	Or, to log in using an Upbound [API token](https://cloud.upbound.io/account/settings/tokens):

	```
	up cloud login --profile=rancher --account=$UPBOUND_ACCOUNT --token=$API_TOKEN
	```

3. Create a Self-Hosted Control Plane

	```
	up cloud controlplane attach $CONTROL_PLANE_NAME --profile=rancher
	```

4. Provide the token obtained in the previous step as `upbound.controlPlane.token` under `Upbound Cloud` section