# Self-Managed Kubernetes Infrastructure for Google Compute Engine (GCE)

> Represents a repository used to create virtual machines in Google Compute Engine (GCE) suitable for the deployment of
> a self-managed Kubernetes cluster.

## Prerequisites

* [terraform][terraform-url]
* [gcloud-sdk][gcloud-sdk-url]

We recommend using [Homebrew][brew-url]:

```sh
brew install terraform
brew cask install google-cloud-sdk
```

You will also need a github account with an SSH key configured. At least one of the keys must align with a private key
on the machine you intend to use to SSH to the management node.

## Getting Started

### Login to the Google SDK

```sh
gcloud auth login --update-adc --no-launch-browser
```

> NOTE: the above will also set the application default credentials (ADC), which terraform will need.

### Setup Variables

You can use any of the normal mechanics to specify variables used by this module, but we have provided an example
`terraform.tfvars` file with the vars that are most interesting.

To copy and edit the file (or do it your own way):

```sh
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars
```

### Create the Infrastructure

```sh
./terraform.sh
```

This will setup the infrastructure and also create a GCS bucket to store the state (so you can get back to it later). It
also dynamically generates the backend.tfvars used to initialise the backend in GCS after the first execution.

> NOTE: The script itself is a thin wrapper around the terraform cli that checks for the backend.tfvars file and
> completes the partial configuration on subsequent invocations. Feel free to ignore it!

### Use the Infrastructure

The `terraform.sh` script will print the SSH command required to connect to the management node. From there, you can
simply ssh to any of the Kubernetes node ips directly without specifying any user or credentials:

```
ssh <IP>
```

## Naming Conventions

The following naming conventions are used:

* Management Node (${var.name}-management)
* Master Nodes (${var.name}-master-##)
* Worker Nodes (${var.name}-worker-##)

## Be Super Snazzy

Create your own terraform root module with the necessary google provider and consume the inner cluster module directly:

```hcl
module "gcp-kube" {
  source = "github.com/deavon-and-tiffany/kube-self-managed-gcp.git//cluster"
  name = "my-cluster"
  ssh_keys = [
    "my-ssh-public-keys"
  ]
}
```

## Go Deep!

You can get more information about this module in the [module docs][module-docs-url].

Copyright (c). Deavon McCaffery, Tiffany Wang, and Contributors. See [License](LICENSE) for details.

[brew-url]: https://brew.sh
[terraform-url]: https://www.terraform.io
[gcloud-sdk-url]: https://cloud.google.com/sdk/
[module-docs-url]: docs.md