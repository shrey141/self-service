# GCP Project Module

This Terraform module creates a GCP project with optional networking and service account configuration.

## Features

- Creates GCP project in organization or folder
- Enables specified GCP APIs
- Optional default service account with IAM roles
- Optional VPC network with subnets
- Optional Cloud NAT for private instances
- Configurable labels and environment tags

## Usage

### Basic Project

```hcl
module "basic_project" {
  source = "./modules/gcp-project"

  project_name        = "My Project"
  project_id          = "my-project-12345"
  org_id              = "123456789012"
  billing_account_id  = "ABCDEF-123456-GHIJKL"
  environment         = "dev"
}
```

### Project with VPC

```hcl
module "project_with_vpc" {
  source = "./modules/gcp-project"

  project_name        = "My Project"
  project_id          = "my-project-12345"
  org_id              = "123456789012"
  billing_account_id  = "ABCDEF-123456-GHIJKL"
  environment         = "dev"

  create_vpc     = true
  create_nat     = true
  default_region = "us-central1"

  subnets = {
    "subnet-01" = {
      region        = "us-central1"
      ip_cidr_range = "10.0.0.0/24"
    }
    "subnet-02" = {
      region        = "us-east1"
      ip_cidr_range = "10.1.0.0/24"
    }
  }

  enabled_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com"
  ]
}
```

### Project in Folder with Service Account

```hcl
module "project_in_folder" {
  source = "./modules/gcp-project"

  project_name        = "My Project"
  project_id          = "my-project-12345"
  folder_id           = "folders/123456789012"
  billing_account_id  = "ABCDEF-123456-GHIJKL"
  environment         = "prod"

  create_default_service_account = true
  service_account_roles = [
    "roles/compute.admin",
    "roles/storage.admin"
  ]

  labels = {
    team        = "platform"
    cost_center = "engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| google | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | The display name of the project | `string` | n/a | yes |
| project_id | The ID of the project | `string` | n/a | yes |
| billing_account_id | The billing account ID | `string` | n/a | yes |
| org_id | The organization ID | `string` | `null` | no |
| folder_id | The folder ID | `string` | `null` | no |
| environment | Environment name | `string` | `"dev"` | no |
| labels | Labels to apply | `map(string)` | `{}` | no |
| enabled_apis | APIs to enable | `list(string)` | See variables.tf | no |
| auto_create_network | Create default network | `bool` | `false` | no |
| create_default_service_account | Create default SA | `bool` | `true` | no |
| service_account_roles | Roles for SA | `list(string)` | `["roles/viewer"]` | no |
| create_vpc | Create VPC network | `bool` | `false` | no |
| default_region | Default region | `string` | `"us-central1"` | no |
| subnets | Map of subnets | `map(object)` | `{}` | no |
| create_nat | Create Cloud NAT | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| project_id | The project ID |
| project_number | The project number |
| project_name | The project name |
| enabled_apis | List of enabled APIs |
| service_account_email | Email of default service account |
| vpc_id | ID of VPC network |
| vpc_name | Name of VPC network |
| subnets | Map of created subnets |

## Notes

- Either `org_id` or `folder_id` must be provided
- Project ID must be globally unique
- Billing account must be accessible
- User/SA must have `resourcemanager.projects.create` permission
