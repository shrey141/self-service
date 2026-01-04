# Architecture Overview

This document describes the architecture of the self-service platform.

## High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                         End Users                             │
└─────────────────────────┬────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                    Backstage Portal                          │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │   Catalog      │  │  Scaffolder    │  │   TechDocs     │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │   Search       │  │  Auth          │  │   Plugins      │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└─────────────────────────┬────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                      PostgreSQL                               │
│              (Catalog & User Data)                           │
└──────────────────────────────────────────────────────────────┘

                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                    GitHub (Source Control)                    │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │  Templates     │  │  Terraform     │  │   Workflows    │ │
│  │  Repository    │  │  Modules       │  │   (Actions)    │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└─────────────────────────┬────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│              GitHub Actions (CI/CD Runner)                    │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │ Terraform      │  │  OIDC Auth     │  │   Policy       │ │
│  │ Plan/Apply     │  │                │  │   Checks       │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└─────────────────────────┬────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│           Workload Identity Federation (OIDC)                 │
└─────────────────────────┬────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────────┐
│                    Google Cloud Platform                      │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │   Projects     │  │    VPCs        │  │  IAM / APIs    │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Backstage Portal

**Purpose**: Developer-facing UI for self-service actions

**Key Features**:
- Software catalog for discovering resources
- Software templates for standardized provisioning
- TechDocs for documentation
- Plugin ecosystem for extensibility

**Technology Stack**:
- React frontend
- Node.js backend
- PostgreSQL database
- Docker containerized

**Responsibilities**:
- User authentication and authorization
- Template rendering and parameter collection
- GitHub repository creation
- Workflow triggering

### 2. Software Templates

**Purpose**: Standardized blueprints for creating infrastructure

**Template Structure**:
```
template.yaml          # Template definition
skeleton/
  ├── main.tf         # Terraform configuration
  ├── variables.tf    # Input variables
  ├── outputs.tf      # Output values
  ├── README.md       # Documentation
  └── .github/
      └── workflows/
          └── terraform.yml  # CI/CD pipeline
```

**Features**:
- Parameter validation
- Conditional logic (VPC creation, etc.)
- Multi-step workflows
- Integration with version control

### 3. Terraform Modules

**Purpose**: Reusable infrastructure as code

**Module Structure**:
```
modules/
  └── gcp-project/
      ├── main.tf       # Resource definitions
      ├── variables.tf  # Input parameters
      ├── outputs.tf    # Output values
      └── README.md     # Usage documentation
```

**Capabilities**:
- GCP project creation
- API enablement
- Service account management
- VPC network provisioning
- Cloud NAT setup
- IAM policy management

**Best Practices**:
- Version pinning
- Input validation
- Comprehensive outputs
- Idempotent operations

### 4. GitHub Actions

**Purpose**: Automated CI/CD pipeline

**Workflow Steps**:
1. **Checkout**: Get repository code
2. **Authenticate**: OIDC authentication with GCP
3. **Initialize**: Run `terraform init`
4. **Validate**: Run `terraform validate`
5. **Plan**: Run `terraform plan` (on PR)
6. **Apply**: Run `terraform apply` (on merge)

**Security**:
- Short-lived tokens via OIDC
- No long-lived credentials
- Least privilege service accounts
- Audit logging

### 5. Workload Identity Federation

**Purpose**: Secure, keyless authentication

**Flow**:
```
GitHub Actions
    ↓
1. Request OIDC token from GitHub
    ↓
2. Exchange token with GCP Workload Identity
    ↓
3. Impersonate Service Account
    ↓
4. Get short-lived access token
    ↓
5. Access GCP resources
```

**Benefits**:
- No service account keys
- Automatic token rotation
- Fine-grained access control
- Audit trail

### 6. GCP Resources

**Purpose**: Target infrastructure

**Managed Resources**:
- **Projects**: Organizational units
- **APIs**: Enabled services
- **Networks**: VPCs and subnets
- **IAM**: Service accounts and roles
- **Cloud NAT**: Outbound connectivity

## Data Flow

### Creating a GCP Project

```
1. User fills form in Backstage
   ↓
2. Backstage validates input
   ↓
3. Backstage creates GitHub repository
   ↓
4. Backstage generates Terraform code from template
   ↓
5. Backstage creates Pull Request
   ↓
6. GitHub Actions runs terraform plan
   ↓
7. User reviews plan in PR comments
   ↓
8. User merges PR
   ↓
9. GitHub Actions authenticates via OIDC
   ↓
10. GitHub Actions runs terraform apply
   ↓
11. GCP project is created
   ↓
12. Backstage catalog is updated
```

## Security Architecture

### Authentication

- **Backstage**: Guest mode (dev) or OAuth/SAML (prod)
- **GitHub**: Personal Access Token or GitHub App
- **GCP**: Workload Identity Federation (OIDC)

### Authorization

- **Backstage**: RBAC for templates and actions
- **GitHub**: Repository permissions
- **GCP**: IAM roles and policies

### Secrets Management

- **GitHub Secrets**: Workload Identity Provider, Service Account
- **Environment Variables**: Sensitive configuration
- **No Keys**: Keyless authentication everywhere

### Network Security

- **TLS/SSL**: Encrypted communication
- **Firewall Rules**: Restricted access
- **Private Networking**: VPCs with Cloud NAT

## Scalability

### Current Setup (Single Server)

- **Capacity**: ~50 concurrent users
- **Throughput**: ~10 project creations/hour
- **Storage**: 100GB for databases and logs

### Scaling Strategies

1. **Horizontal Scaling**:
   - Multiple Backstage instances
   - Load balancer in front
   - Shared PostgreSQL backend

2. **Database Scaling**:
   - Managed PostgreSQL (Cloud SQL)
   - Read replicas
   - Connection pooling

3. **Caching**:
   - Redis for session data
   - CDN for static assets

## Disaster Recovery

### Backup Strategy

- **Database**: Daily automated backups
- **Configuration**: Version controlled
- **Terraform State**: Remote backend in GCS

### Recovery Procedures

1. Restore database from backup
2. Pull latest configuration from Git
3. Redeploy containers
4. Verify connectivity

**RTO**: < 1 hour
**RPO**: < 24 hours

## Monitoring and Observability

### Metrics

- Container health (CPU, memory, disk)
- Database performance (connections, queries)
- API response times
- Error rates

### Logging

- Application logs (Docker logs)
- Audit logs (Backstage, GCP)
- Access logs (Nginx)

### Alerting

- Service down alerts
- High error rate alerts
- Disk space alerts
- SSL certificate expiration

## Future Enhancements

### Short Term

- [ ] Multi-cloud support (AWS, Azure)
- [ ] Cost estimation in templates
- [ ] Policy as Code (OPA)
- [ ] Self-service permissions

### Long Term

- [ ] GitOps workflows (ArgoCD, Flux)
- [ ] Service mesh integration
- [ ] Kubernetes cluster provisioning
- [ ] Database provisioning
- [ ] ML workspace provisioning

## Technology Stack Summary

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Portal | Backstage | Developer portal |
| Frontend | React | UI framework |
| Backend | Node.js | API server |
| Database | PostgreSQL | Data persistence |
| VCS | GitHub | Source control |
| CI/CD | GitHub Actions | Automation |
| IaC | Terraform | Infrastructure provisioning |
| Auth | OIDC | Keyless authentication |
| Container | Docker | Application packaging |
| Orchestration | Docker Compose | Container management |
| Reverse Proxy | Nginx | SSL termination |
| Cloud | GCP | Target infrastructure |

## Design Principles

1. **Infrastructure as Code**: Everything defined in code
2. **GitOps**: Git as source of truth
3. **Least Privilege**: Minimal required permissions
4. **Immutable Infrastructure**: Replace, don't modify
5. **Automated Testing**: Validate before deploying
6. **Observability**: Comprehensive logging and monitoring
7. **Self-Service**: Empower developers
8. **Standardization**: Enforce best practices
