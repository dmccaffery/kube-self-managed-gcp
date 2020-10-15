## Requirements

The following requirements are needed by this module:

- terraform (~> 0.13.0)

- google (~> 3.43)

- local (~> 2.0)

- tls (~> 3.0)

## Providers

The following providers are used by this module:

- google (~> 3.43)

- local (~> 2.0)

- tls (~> 3.0)

## Required Inputs

The following input variables are required:

### name

Description: The name of the kubernetes environment.

Type: `string`

### project

Description: The project in which to create resources. To see a list of projects you have access to use
`gcloud projects list`.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### cidr\_blocks

Description: The CIDR blocks to use for the nodes, pods, and services.

Type:

```hcl
object({
    nodes    = string
    pods     = string
    services = string
  })
```

Default:

```json
{
  "nodes": "192.168.0.0/24",
  "pods": "172.16.0.0/16",
  "services": "172.17.0.0/16"
}
```

### cpu

Description: The number of CPUs to allocate to each node.

Type: `number`

Default: `2`

### image

Description: The image to use for the nodes.

Type: `string`

Default: `"centos-cloud/centos-7"`

### masters

Description: The number of master nodes to create.

Type: `number`

Default: `1`

### memory

Description: The amount of memory to allocate to each node.

Type: `number`

Default: `4096`

### region

Description: The compute region in which to create the resources, such as `europe-west2`. use `gcloud compute regions list`  
to get a complete list.

Type: `string`

Default: `"europe-west2"`

### workers

Description: The number of worker nodes to create.

Type: `number`

Default: `1`

## Outputs

The following outputs are exported:

### cluster

Description: The cluster configuration that was created, including the management, masters, workers, and api server load  
balancer.

### project

Description: The name of the google project in which resources were deployed.

### region

Description: The region in which resources were deployed.

### ssh

Description: The SSH command used to access the management node.

