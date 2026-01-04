# ${{ values.projectName }}

GCP Project: `${{ values.projectId }}`

## Overview

This repository contains Terraform configuration for the GCP project **${{ values.projectName }}**.

**Configuration:**
- **Environment**: ${{ values.environment }}
- **Region**: ${{ values.defaultRegion }}
- **VPC**: ${{ values.createVpc }}
- **Cloud NAT**: ${{ values.createNat }}

## Setup

1. Copy `terraform.tfvars.example` to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your GCP organization/folder ID and billing account

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the plan:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## CI/CD

This repository includes a GitHub Actions workflow that:
- Runs `terraform plan` on pull requests
- Runs `terraform apply` on merges to main
- Uses OIDC for authentication (no long-lived credentials)

### Required Secrets

Configure these secrets in your GitHub repository:
- `GCP_WORKLOAD_IDENTITY_PROVIDER`: Workload Identity Provider resource name
- `GCP_SERVICE_ACCOUNT`: Service account email for Terraform

See [GCP OIDC Setup](../../docs/GCP_SETUP.md) for configuration steps.

## Resources Created

This Terraform configuration creates:
- GCP Project
- Enabled APIs
- Default service account (if configured)
{%- if values.createVpc %}
- VPC network
- Subnet(s)
{%- endif %}
{%- if values.createNat %}
- Cloud Router
- Cloud NAT
{%- endif %}

## Links

- [GCP Console](https://console.cloud.google.com/home/dashboard?project=${{ values.projectId }})
- [Terraform Registry](https://registry.terraform.io/)
