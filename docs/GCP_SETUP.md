# GCP OIDC Setup Guide

This guide walks through setting up Workload Identity Federation for GitHub Actions to authenticate with GCP using OIDC (OpenID Connect). This eliminates the need for long-lived service account keys.

## Overview

```
GitHub Actions
     ↓
  OIDC Token
     ↓
Workload Identity Pool
     ↓
Service Account
     ↓
GCP Resources
```

## Prerequisites

- GCP Organization or Folder access
- Permission to create:
  - Workload Identity Pools
  - Service Accounts
  - IAM bindings
- `gcloud` CLI installed

## Step 1: Set Environment Variables

```bash
export PROJECT_ID="your-admin-project"
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export GITHUB_ORG="your-github-org"
export GITHUB_REPO="self-service"
export POOL_NAME="github-pool"
export PROVIDER_NAME="github-provider"
export SA_NAME="github-terraform-sa"
```

## Step 2: Create Workload Identity Pool

```bash
# Create the pool
gcloud iam workload-identity-pools create $POOL_NAME \
  --project="$PROJECT_ID" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# Get the pool ID
export WORKLOAD_IDENTITY_POOL_ID=$(gcloud iam workload-identity-pools describe $POOL_NAME \
  --project="$PROJECT_ID" \
  --location="global" \
  --format="value(name)")
```

## Step 3: Create OIDC Provider

```bash
gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME \
  --project="$PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_NAME" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository_owner == '$GITHUB_ORG'" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

## Step 4: Create Service Account

```bash
# Create service account
gcloud iam service-accounts create $SA_NAME \
  --project="$PROJECT_ID" \
  --display-name="GitHub Actions Terraform SA"

# Grant permissions (adjust based on your needs)
# For project creation:
gcloud organizations add-iam-policy-binding YOUR_ORG_ID \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectCreator"

gcloud organizations add-iam-policy-binding YOUR_ORG_ID \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/billing.user"

# Or for folder-level:
gcloud resource-manager folders add-iam-policy-binding YOUR_FOLDER_ID \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectCreator"
```

## Step 5: Allow Workload Identity to Impersonate Service Account

```bash
gcloud iam service-accounts add-iam-policy-binding "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --project="$PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${GITHUB_ORG}/${GITHUB_REPO}"
```

## Step 6: Get Configuration Values

```bash
# Workload Identity Provider (for GitHub secrets)
echo "GCP_WORKLOAD_IDENTITY_PROVIDER=projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_NAME/providers/$PROVIDER_NAME"

# Service Account Email (for GitHub secrets)
echo "GCP_SERVICE_ACCOUNT=$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"
```

## Step 7: Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

1. `GCP_WORKLOAD_IDENTITY_PROVIDER`
   - Value from Step 6

2. `GCP_SERVICE_ACCOUNT`
   - Value from Step 6

## Step 8: Test Authentication

Create a test workflow:

```yaml
name: Test GCP Auth
on: workflow_dispatch

permissions:
  id-token: write
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
          service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}

      - name: Test gcloud
        run: |
          gcloud auth list
          gcloud projects list
```

## Additional Configuration

### Restrict to Specific Branches

Modify the attribute condition in Step 3:

```bash
--attribute-condition="assertion.repository_owner == '$GITHUB_ORG' && assertion.ref == 'refs/heads/main'"
```

### Multiple Repositories

Use wildcards in Step 5:

```bash
--member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository_owner/${GITHUB_ORG}"
```

### Custom Attribute Mapping

Add custom claims to map additional GitHub context:

```bash
--attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.branch=assertion.ref"
```

## Troubleshooting

### "Permission denied" errors

Check:
1. Service account has necessary IAM roles
2. Workload Identity binding is correct
3. Attribute condition matches your repository

### "Token verification failed"

Verify:
1. `id-token: write` permission in workflow
2. Correct provider configuration
3. Issuer URI is `https://token.actions.githubusercontent.com`

### List current bindings

```bash
gcloud iam service-accounts get-iam-policy "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --project="$PROJECT_ID"
```

## Security Best Practices

1. Use specific attribute conditions (repository, branch)
2. Grant least privilege IAM roles
3. Regularly audit service account permissions
4. Use separate service accounts for different environments
5. Monitor service account usage in Cloud Audit Logs

## References

- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GitHub OIDC with GCP](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-google-cloud-platform)
- [google-github-actions/auth](https://github.com/google-github-actions/auth)
