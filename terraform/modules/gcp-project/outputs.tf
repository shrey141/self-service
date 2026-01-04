output "project_id" {
  description = "The project ID"
  value       = google_project.project.project_id
}

output "project_number" {
  description = "The project number"
  value       = google_project.project.number
}

output "project_name" {
  description = "The project name"
  value       = google_project.project.name
}

output "enabled_apis" {
  description = "List of enabled APIs"
  value       = [for service in google_project_service.services : service.service]
}

output "service_account_email" {
  description = "Email of the default service account"
  value       = var.create_default_service_account ? google_service_account.default[0].email : null
}

output "service_account_id" {
  description = "ID of the default service account"
  value       = var.create_default_service_account ? google_service_account.default[0].id : null
}

output "vpc_id" {
  description = "ID of the VPC network"
  value       = var.create_vpc ? google_compute_network.vpc[0].id : null
}

output "vpc_name" {
  description = "Name of the VPC network"
  value       = var.create_vpc ? google_compute_network.vpc[0].name : null
}

output "vpc_self_link" {
  description = "Self-link of the VPC network"
  value       = var.create_vpc ? google_compute_network.vpc[0].self_link : null
}

output "subnets" {
  description = "Map of created subnets"
  value = var.create_vpc ? {
    for name, subnet in google_compute_subnetwork.subnets : name => {
      id            = subnet.id
      name          = subnet.name
      region        = subnet.region
      ip_cidr_range = subnet.ip_cidr_range
      self_link     = subnet.self_link
    }
  } : {}
}
