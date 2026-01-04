variable "project_name" {
  description = "The display name of the project"
  type        = string
}

variable "project_id" {
  description = "The ID of the project. Must be unique across GCP."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, contain only lowercase letters, numbers, and hyphens."
  }
}

variable "org_id" {
  description = "The organization ID. Required if folder_id is not set."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "The folder ID to create the project in. Required if org_id is not set."
  type        = string
  default     = null
}

variable "billing_account_id" {
  description = "The billing account ID to associate with the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "labels" {
  description = "Labels to apply to the project"
  type        = map(string)
  default     = {}
}

variable "enabled_apis" {
  description = "List of APIs to enable in the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage-api.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

variable "auto_create_network" {
  description = "Whether to create the default network"
  type        = bool
  default     = false
}

variable "create_default_service_account" {
  description = "Whether to create a default service account"
  type        = bool
  default     = true
}

variable "service_account_roles" {
  description = "Roles to grant to the default service account"
  type        = list(string)
  default = [
    "roles/viewer"
  ]
}

variable "create_vpc" {
  description = "Whether to create a VPC network"
  type        = bool
  default     = false
}

variable "default_region" {
  description = "Default region for resources"
  type        = string
  default     = "us-central1"
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    region                   = string
    ip_cidr_range            = string
    private_ip_google_access = optional(bool, true)
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = {}
}

variable "create_nat" {
  description = "Whether to create Cloud NAT"
  type        = bool
  default     = false
}
