output "project_id" {
  description = "The GCP project ID"
  value       = module.gcp_project.project_id
}

output "project_number" {
  description = "The GCP project number"
  value       = module.gcp_project.project_number
}

output "project_name" {
  description = "The GCP project name"
  value       = module.gcp_project.project_name
}

output "service_account_email" {
  description = "Default service account email"
  value       = module.gcp_project.service_account_email
}

output "vpc_id" {
  description = "VPC network ID"
  value       = module.gcp_project.vpc_id
}
