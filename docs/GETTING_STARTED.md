# Getting Started with Self-Service Platform

This guide will help you set up and start using the self-service platform on your Ubuntu server.

## Server Requirements

- Ubuntu Server (20.04 or later)
- 16GB RAM
- 8 CPU cores
- Docker and Docker Compose installed
- Git installed

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_ORG/self-service.git
cd self-service
```

### 2. Install Docker (if not already installed)

```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo apt install -y docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### 3. Configure Backstage

```bash
cd backstage

# Copy environment template
cp .env.example .env

# Edit .env and add your GitHub token
nano .env
```

Create a GitHub Personal Access Token:
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo`, `workflow`
4. Copy the token and add to `.env`

### 4. Start Backstage

```bash
# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f backstage

# Check if services are healthy
docker-compose ps
```

Wait a few minutes for Backstage to start. Access it at:
- http://localhost:3000 (or http://YOUR_SERVER_IP:3000)

### 5. Initial Configuration

The first time you access Backstage:
1. Sign in as a guest (development mode)
2. Navigate to "Create" to see available templates
3. You should see the "Create GCP Project" template

## Project Structure

```
self-service/
├── backstage/              # Backstage portal
│   ├── docker-compose.yml
│   ├── app-config.yaml
│   └── README.md
├── terraform/
│   ├── modules/
│   │   └── gcp-project/   # Reusable project module
│   └── examples/          # Example usage
├── templates/
│   └── gcp-project/       # Backstage template
│       ├── template.yaml
│       └── skeleton/      # Template files
├── .github/workflows/     # CI/CD examples
└── docs/                  # Documentation
```

## Next Steps

### Without GCP Integration (Learning Mode)

You can explore Backstage features without GCP:
1. Browse the catalog
2. Explore the template structure
3. Review the Terraform modules
4. Understand the workflow automation

### With GCP Integration

To actually create GCP projects:
1. Follow [GCP_SETUP.md](./GCP_SETUP.md) to configure OIDC
2. Update the template to reference your repository
3. Configure GitHub secrets
4. Test the workflow

## Using the Platform

### Creating a GCP Project

1. Click "Create" in Backstage
2. Select "Create GCP Project"
3. Fill in the form:
   - Project name
   - Project ID (must be globally unique)
   - Environment (dev/staging/prod)
   - Network settings
   - APIs to enable
4. Choose repository location
5. Click "Create"

This will:
- Create a new GitHub repository
- Generate Terraform code
- Create a pull request
- Set up GitHub Actions workflow

### Reviewing and Approving

1. Go to the generated pull request
2. Review the Terraform configuration
3. GitHub Actions will show `terraform plan` output
4. Merge when ready
5. GitHub Actions will run `terraform apply`
6. Your GCP project will be created

## Customization

### Adding More Templates

Create new templates in `templates/`:
1. Copy the `gcp-project` structure
2. Modify `template.yaml`
3. Update the `skeleton/` directory
4. Add to Backstage catalog in `app-config.yaml`

### Modifying the Terraform Module

The GCP project module is in `terraform/modules/gcp-project/`:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `README.md` - Documentation

### Custom Workflows

Add workflows in `.github/workflows/`:
- Terraform automation
- Policy validation
- Cost estimation
- Security scanning

## Troubleshooting

### Backstage won't start

```bash
# Check logs
cd backstage
docker-compose logs backstage postgres

# Restart services
docker-compose restart

# Full reset
docker-compose down -v
docker-compose up -d
```

### Can't access Backstage from another machine

Update `app-config.yaml`:
```yaml
app:
  baseUrl: http://YOUR_SERVER_IP:3000

backend:
  baseUrl: http://YOUR_SERVER_IP:7007
```

### Template not showing up

1. Check `backstage/app-config.yaml` catalog locations
2. Verify template path is correct
3. Restart Backstage: `docker-compose restart backstage`

### GitHub Actions failing

1. Verify secrets are configured
2. Check OIDC setup is complete
3. Review workflow logs in GitHub
4. Ensure service account has permissions

## Additional Resources

- [Backstage Documentation](https://backstage.io/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Getting Help

Common issues and solutions:
- Port conflicts: Change ports in `docker-compose.yml`
- Permission errors: Check Docker group membership
- Memory issues: Adjust Docker resource limits
- Network issues: Check firewall rules

For more help, see the project README or open an issue on GitHub.
