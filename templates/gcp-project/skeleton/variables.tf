variable "org_id" {
  description = "GCP Organization ID (provide this OR folder_id)"
  type        = string
  default     = null
}

variable "folder_id" {
  description = "GCP Folder ID (provide this OR org_id)"
  type        = string
  default     = null
}

variable "billing_account_id" {
  description = "GCP Billing Account ID"
  type        = string
}
