terraform {
  required_version = ">= 1.5"
}

module "basic_project" {
  source = "../../modules/gcp-project"

  project_name       = "Example Basic Project"
  project_id         = "example-basic-${random_id.project_suffix.hex}"
  org_id             = var.org_id
  billing_account_id = var.billing_account_id
  environment        = "dev"

  labels = {
    created_by = "terraform"
    example    = "basic-project"
  }
}

resource "random_id" "project_suffix" {
  byte_length = 4
}

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account_id" {
  description = "GCP Billing Account ID"
  type        = string
}

output "project_id" {
  value = module.basic_project.project_id
}

output "project_number" {
  value = module.basic_project.project_number
}
