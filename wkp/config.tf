locals {
  git_config = {
    gitProvider    = var.git_provider
    gitProviderOrg = var.git_organization
    gitUrl         = var.git_url
  }

  docker_config = {
    dockerIOUser         = var.docker.user
    dockerIOPasswordFile = local.docker_password_file
  }

  cluster_config = {
    track       = "wks-ssh"
    clusterName = var.name
    wks_config = {
      kubernetesVersion  = var.kubernetes_version
      apiServerArguments = var.api_server_args
      kubeletArguments   = var.kubelet_args
      minDiskSpace       = 20
    }
    features = { for feature in var.features : feature => true }
  }

  sealed_secrets_config = {
    sealedSecretsCertificate = local.sealed_secrets_certificate
    sealedSecretsPrivateKey  = local.sealed_secrets_private_key
  }

  network_config = {
    controlPlaneLbAddress = var.load_balancer_address
    serviceCIDRBlocks     = var.cidr_blocks.services
    podCIDRBlocks         = var.cidr_blocks.pods
  }

  masters_config = [for master in var.masters : {
    role           = "master"
    name           = master.name
    publicAddress  = master.public_ip
    privateAddress = master.public_ip
  }]

  workers_config = [for worker in var.workers : {
    role           = "worker"
    name           = worker.name
    publicAddress  = worker.public_ip
    privateAddress = worker.public_ip
  }]

  ssh_config = {
    sshUser    = "kube-admin"
    sshKeyFile = var.ssh_key
    machines   = concat(local.masters_config, local.workers_config)
  }

  config = yamlencode(
    merge(
      local.cluster_config,
      local.sealed_secrets_config,
      local.docker_config,
      local.git_config,
      local.network_config,
      local.ssh_config
  ))
}
