# Quick Start Guide

Get up and running in 5 minutes!

## Prerequisites

- Ubuntu server with Docker installed
- GitHub account
- 10 minutes of your time

## Installation

### Option 1: Automated Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/YOUR_ORG/self-service.git
cd self-service

# Run the setup script
./scripts/setup.sh
```

The script will:
- Check for Docker
- Install Docker if needed
- Create configuration files
- Start Backstage

### Option 2: Manual Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_ORG/self-service.git
cd self-service

# Navigate to backstage directory
cd backstage

# Copy environment template
cp .env.example .env

# Edit .env and add your GitHub token
nano .env

# Start services
docker-compose up -d
```

## Access Backstage

Wait 2-3 minutes for services to start, then open:
- http://localhost:3000 (local)
- http://YOUR_SERVER_IP:3000 (remote)

## First Steps

1. **Explore the Portal**
   - Browse the catalog
   - Check out the documentation
   - Familiarize yourself with the UI

2. **View Templates**
   - Click "Create" in the sidebar
   - You should see "Create GCP Project"
   - Click to view the form

3. **Review Terraform Module**
   ```bash
   cd terraform/modules/gcp-project
   cat README.md
   ```

4. **Understand the Flow**
   - User fills form → Backstage creates repo → GitHub Actions runs Terraform → GCP project created

## Common Commands

```bash
# Check service status
cd backstage
docker-compose ps

# View logs
docker-compose logs -f backstage

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Start services
docker-compose up -d

# View all logs
docker-compose logs

# Update services
docker-compose pull
docker-compose up -d
```

## Next Steps

### Learning Mode (No GCP)

1. Explore Backstage features
2. Review template structure
3. Understand Terraform modules
4. Study GitHub Actions workflows
5. Plan your GCP setup

### Production Mode (With GCP)

1. **Set up GCP OIDC**
   ```bash
   # Follow the guide
   cat docs/GCP_SETUP.md
   ```

2. **Configure GitHub Secrets**
   - GCP_WORKLOAD_IDENTITY_PROVIDER
   - GCP_SERVICE_ACCOUNT

3. **Test Template**
   - Create a test project
   - Review generated code
   - Verify GitHub Actions workflow

4. **Deploy to Production**
   ```bash
   # Follow the deployment guide
   cat docs/DEPLOYMENT.md
   ```

## Troubleshooting

### Services won't start

```bash
# Check Docker is running
docker ps

# Check logs for errors
cd backstage
docker-compose logs

# Restart everything
docker-compose down
docker-compose up -d
```

### Can't access from another machine

1. Check firewall rules
2. Update app-config.yaml with server IP
3. Restart Backstage

### Template not showing

1. Verify path in app-config.yaml
2. Check template.yaml syntax
3. Restart Backstage

## Getting Help

- **Documentation**: Check `docs/` directory
- **README**: See main README.md
- **Examples**: Review `terraform/examples/`
- **Issues**: Open a GitHub issue

## Quick Reference

### Important Files

```
README.md                    # Project overview
QUICK_START.md              # This file
docs/GETTING_STARTED.md     # Detailed setup guide
docs/GCP_SETUP.md           # GCP OIDC configuration
docs/DEPLOYMENT.md          # Production deployment
docs/ARCHITECTURE.md        # System architecture

backstage/
  docker-compose.yml        # Service definitions
  app-config.yaml          # Backstage configuration
  .env                     # Environment variables (create this)

terraform/
  modules/gcp-project/     # Main Terraform module
  examples/                # Usage examples

templates/
  gcp-project/            # Backstage template
    template.yaml         # Template definition
    skeleton/            # Generated files
```

### Important URLs

- **Backstage**: http://localhost:3000
- **Backend API**: http://localhost:7007
- **GitHub Tokens**: https://github.com/settings/tokens
- **GCP Console**: https://console.cloud.google.com

### Default Credentials

- **PostgreSQL**:
  - User: backstage
  - Password: backstage
  - Database: backstage
  - Port: 5432

(Change these for production!)

## What's Next?

1. **Week 1**: Learn Backstage, explore templates
2. **Week 2**: Set up GCP OIDC integration
3. **Week 3**: Create first project via self-service
4. **Week 4**: Customize templates for your team
5. **Week 5**: Deploy to production

## Success Criteria

You're successful when you can:
- [ ] Access Backstage UI
- [ ] View the GCP Project template
- [ ] Understand the template structure
- [ ] Create a test repository manually
- [ ] Set up GCP OIDC (when ready)
- [ ] Create a GCP project via Backstage

Happy building!
