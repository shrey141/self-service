# Deployment Guide

This guide covers deploying the self-service platform on your Ubuntu server for production use.

## Production Deployment

### System Requirements

- Ubuntu Server 22.04 LTS
- 16GB RAM minimum
- 8 CPU cores minimum
- 100GB SSD storage
- Static IP address
- Domain name (optional but recommended)

### Security Considerations

#### 1. Firewall Configuration

```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS (if using reverse proxy)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow Backstage (if accessing directly)
sudo ufw allow 3000/tcp
sudo ufw allow 7007/tcp

# Enable firewall
sudo ufw enable
```

#### 2. SSL/TLS Setup with Nginx

```bash
# Install Nginx
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/backstage
```

Nginx configuration:
```nginx
upstream backstage {
    server localhost:3000;
}

upstream backstage_backend {
    server localhost:7007;
}

server {
    listen 80;
    server_name backstage.yourdomain.com;

    location / {
        proxy_pass http://backstage;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://backstage_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/backstage /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Get SSL certificate
sudo certbot --nginx -d backstage.yourdomain.com
```

#### 3. Environment Variables

```bash
# Create production .env
cd backstage
cp .env.example .env

# Edit with production values
nano .env
```

Add:
```bash
NODE_ENV=production
GITHUB_TOKEN=your_token_here
POSTGRES_PASSWORD=strong_random_password_here
```

#### 4. Docker Compose Production Override

Create `docker-compose.prod.yml`:
```yaml
version: '3.8'

services:
  postgres:
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - /data/postgres:/var/lib/postgresql/data
    restart: always

  backstage:
    environment:
      NODE_ENV: production
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Start with production config:
```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Monitoring and Logging

#### 1. Container Monitoring

```bash
# Install monitoring stack (optional)
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /data/prometheus:/prometheus \
  prom/prometheus

docker run -d \
  --name grafana \
  -p 3001:3000 \
  -v /data/grafana:/var/lib/grafana \
  grafana/grafana
```

#### 2. Log Collection

```bash
# View logs
docker-compose logs -f

# Export logs
docker-compose logs > backstage.log

# Rotate logs
docker-compose logs --tail=1000 > backstage-$(date +%Y%m%d).log
```

### Backup and Recovery

#### 1. Database Backup

```bash
# Backup script
cat > /usr/local/bin/backup-backstage.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=/backups/backstage
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

# Backup PostgreSQL
docker exec backstage-postgres pg_dump -U backstage backstage | \
  gzip > $BACKUP_DIR/postgres-$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "postgres-*.sql.gz" -mtime +7 -delete
EOF

chmod +x /usr/local/bin/backup-backstage.sh
```

Add to crontab:
```bash
# Daily backup at 2 AM
crontab -e
# Add:
0 2 * * * /usr/local/bin/backup-backstage.sh
```

#### 2. Configuration Backup

```bash
# Backup configuration
tar -czf backstage-config-$(date +%Y%m%d).tar.gz \
  backstage/app-config.yaml \
  backstage/docker-compose.yml \
  backstage/.env
```

#### 3. Restore

```bash
# Restore database
gunzip < postgres-backup.sql.gz | \
  docker exec -i backstage-postgres psql -U backstage backstage
```

### Updates and Maintenance

#### 1. Update Backstage

```bash
cd backstage

# Pull latest images
docker-compose pull

# Recreate containers
docker-compose up -d

# Check health
docker-compose ps
```

#### 2. Update Terraform Modules

```bash
# Update module
cd terraform/modules/gcp-project
git pull

# Test changes
cd ../../examples/basic-project
terraform init -upgrade
terraform plan
```

### High Availability (Optional)

For production workloads:

#### 1. Database HA

Use managed PostgreSQL:
- Cloud SQL (GCP)
- RDS (AWS)
- Azure Database for PostgreSQL

Update `app-config.yaml`:
```yaml
backend:
  database:
    client: pg
    connection:
      host: your-managed-db-host
      ssl:
        rejectUnauthorized: true
```

#### 2. Load Balancing

Deploy multiple Backstage instances behind a load balancer:
```yaml
services:
  backstage-1:
    ...
  backstage-2:
    ...
  backstage-3:
    ...
```

### Performance Tuning

#### 1. Docker Resources

Update Docker daemon config (`/etc/docker/daemon.json`):
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
```

#### 2. PostgreSQL Tuning

Create `postgres.conf`:
```conf
max_connections = 100
shared_buffers = 4GB
effective_cache_size = 12GB
maintenance_work_mem = 1GB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 10485kB
min_wal_size = 1GB
max_wal_size = 4GB
```

Mount in docker-compose:
```yaml
postgres:
  volumes:
    - ./postgres.conf:/etc/postgresql/postgresql.conf
  command: postgres -c config_file=/etc/postgresql/postgresql.conf
```

### Security Hardening

#### 1. Regular Updates

```bash
# System updates
sudo apt update
sudo apt upgrade -y

# Docker updates
sudo apt install docker-ce docker-ce-cli containerd.io
```

#### 2. Secret Management

Use external secret managers:
- HashiCorp Vault
- GCP Secret Manager
- AWS Secrets Manager

#### 3. Audit Logging

Enable audit logs in `app-config.yaml`:
```yaml
backend:
  auth:
    keys:
      - secret: ${AUTH_SECRET}

  # Enable audit logs
  csp:
    connect-src: ["'self'", 'http:', 'https:']
    upgrade-insecure-requests: false
```

### Disaster Recovery

1. **Backup Strategy**: Daily automated backups
2. **Recovery Time Objective (RTO)**: < 1 hour
3. **Recovery Point Objective (RPO)**: < 24 hours
4. **DR Testing**: Monthly restore tests

### Monitoring Checklist

- [ ] Container health checks
- [ ] Database performance
- [ ] Disk space usage
- [ ] Network connectivity
- [ ] SSL certificate expiration
- [ ] Backup success
- [ ] Application logs
- [ ] Security updates

### Maintenance Windows

Schedule regular maintenance:
- Weekly: Security updates
- Monthly: Dependency updates
- Quarterly: Major version updates

### Support and Escalation

Document escalation procedures:
1. Check logs: `docker-compose logs`
2. Verify services: `docker-compose ps`
3. Review metrics: Prometheus/Grafana
4. Check external dependencies: GitHub, GCP
5. Escalate to platform team

## Production Readiness Checklist

- [ ] SSL/TLS configured
- [ ] Firewall rules configured
- [ ] Backups automated
- [ ] Monitoring setup
- [ ] Logging configured
- [ ] Secrets secured
- [ ] Documentation updated
- [ ] Team trained
- [ ] DR plan tested
- [ ] Performance tuned

## Next Steps

After deployment:
1. Configure authentication (OAuth, SAML)
2. Set up CI/CD for template updates
3. Create team onboarding documentation
4. Establish SLAs and support processes
