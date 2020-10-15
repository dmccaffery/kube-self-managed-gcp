output "project" {
  value       = var.project
  description = "The name of the google project in which resources were deployed."
}

output "region" {
  value       = var.region
  description = "The region in which resources were deployed."
}

output "cluster" {
  value       = module.cluster
  description = <<-EOT
    The cluster configuration that was created, including the management, masters, workers, and api server load
    balancer.
  EOT
}

output "ssh" {
  value       = "ssh kube-admin@${module.cluster.nodes.management.external_ip} -i ${local_file.private-key.filename}"
  description = "The SSH command used to access the management node."
}
