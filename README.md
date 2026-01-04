# Self-Service Platform

A learning environment for building internal developer platforms with self-service capabilities.

## Overview

This project sets up a self-service platform using Backstage to enable teams to provision infrastructure resources (like GCP projects) through a developer portal.

## Architecture

```
┌─────────────────┐
│   Backstage     │  Developer Portal
│   (Docker)      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ GitHub Actions  │  Workflow Automation
│   (OIDC Auth)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Terraform     │  Infrastructure Provisioning
│  (GCP Projects) │
└─────────────────┘
```

## Components

- **backstage/** - Backstage configuration and Docker setup
- **terraform/** - Infrastructure as Code modules
- **templates/** - Backstage software templates
- **workflows/** - GitHub Actions workflows

## Quick Start

**New to this project?** See [QUICK_START.md](./QUICK_START.md) for the fastest way to get running.

### Automated Setup

```bash
./scripts/setup.sh
```

### Manual Setup

```bash
cd backstage
cp .env.example .env
# Edit .env and add your GitHub token
docker-compose up -d
```

Access Backstage at http://localhost:3000

**Next steps**: See [GETTING_STARTED.md](./docs/GETTING_STARTED.md) for detailed instructions.

### Setting up GCP OIDC (when ready)

See [GCP_SETUP.md](./docs/GCP_SETUP.md) for detailed instructions.

## Repository Structure

```
.
├── backstage/           # Backstage app and Docker setup
├── terraform/           # Terraform modules
│   └── modules/
│       └── gcp-project/ # GCP project creation module
├── templates/          # Backstage software templates
│   └── gcp-project/   # Template for creating GCP projects
├── .github/
│   └── workflows/     # GitHub Actions workflows
└── docs/              # Documentation
```

## Learning Resources

- [Backstage Documentation](https://backstage.io/docs)
- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## Documentation

- [Quick Start](./QUICK_START.md) - Get running in 5 minutes
- [Getting Started](./docs/GETTING_STARTED.md) - Complete setup guide
- [Architecture](./docs/ARCHITECTURE.md) - System design and components
- [GCP Setup](./docs/GCP_SETUP.md) - Configure OIDC authentication
- [Deployment](./docs/DEPLOYMENT.md) - Production deployment guide
- [Contributing](./CONTRIBUTING.md) - How to contribute

## Features

- ✅ Backstage portal with Docker Compose
- ✅ GCP project creation Terraform module
- ✅ Software template for self-service
- ✅ GitHub Actions workflows with OIDC
- ✅ Comprehensive documentation
- ⏳ GCP OIDC integration (ready to configure)
- ⏳ Multi-cloud support (future)
