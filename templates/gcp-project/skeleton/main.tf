terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Uncomment for remote state
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "projects/${{ values.projectId }}"
  # }
}

provider "google" {
  # Authentication via OIDC in GitHub Actions
  # No credentials needed when running in CI/CD
}

module "gcp_project" {
  source = "github.com/YOUR_ORG/self-service//terraform/modules/gcp-project?ref=main"

  project_name       = "${{ values.projectName }}"
  project_id         = "${{ values.projectId }}"
  billing_account_id = var.billing_account_id
  org_id             = var.org_id
  folder_id          = var.folder_id
  environment        = "${{ values.environment }}"

  create_vpc     = ${{ values.createVpc }}
  create_nat     = ${{ values.createNat }}
  default_region = "${{ values.defaultRegion }}"

  enabled_apis = [
    {%- for api in values.enabledApis %}
    "${{ api }}",
    {%- endfor %}
  ]

  labels = {
    {%- for key, value in values.labels %}
    "${{ key }}" = "${{ value }}"
    {%- endfor %}
    created_by = "backstage"
  }

  {%- if values.createVpc %}
  subnets = {
    "subnet-${{ values.defaultRegion }}" = {
      region        = "${{ values.defaultRegion }}"
      ip_cidr_range = "10.0.0.0/24"
    }
  }
  {%- endif %}
}
