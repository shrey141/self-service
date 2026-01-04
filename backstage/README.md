# Backstage Setup

## Important Note

Backstage doesn't provide a pre-built Docker image. You need to either:
1. **Build it with Docker** (takes 10-20 min on first build)
2. **Run locally with Node.js** (faster, recommended for learning)

See [DOCKER_BUILD.md](./DOCKER_BUILD.md) for detailed instructions.

## Quick Start Options

### Option 1: Build with Docker (Server Deployment)

```bash
# Copy environment file
cp .env.example .env

# Build and start (first time takes 10-20 minutes)
docker-compose build
docker-compose up -d

# Monitor the build
docker-compose logs -f backstage
```

### Option 2: Run Locally with Node.js (Recommended)

```bash
# Run the local setup script
./run-local.sh
```

This will:
- Check for Node.js 18+
- Create a Backstage app
- Start PostgreSQL in Docker
- Run Backstage locally at http://localhost:3000

## Configuration

### GitHub Token

Create a GitHub Personal Access Token at https://github.com/settings/tokens with the following scopes:
- `repo` - Full control of private repositories
- `workflow` - Update GitHub Action workflows

Add the token to your `.env` file or `app-config.local.yaml`.

### Database

PostgreSQL runs in a container and data is persisted in a Docker volume. To reset the database:

```bash
docker-compose down -v
docker-compose up -d
```

## Development

For local development without Docker:

```bash
# Install the Backstage CLI
npm install -g @backstage/cli

# Create a new Backstage app (if starting from scratch)
npx @backstage/create-app@latest

# Or use the existing configuration
cd backstage
yarn install
yarn dev
```

## Troubleshooting

### Container won't start

Check logs:
```bash
docker-compose logs backstage
docker-compose logs postgres
```

### Database connection issues

Ensure PostgreSQL is healthy:
```bash
docker-compose ps
```

### Port conflicts

If ports 3000 or 7007 are in use, modify the port mappings in `docker-compose.yml`.

## Using a Pre-built Backstage Image

Note: The current setup uses a generic Backstage image. For a production setup, you would:

1. Create a custom Backstage app
2. Build your own Docker image with your plugins and configuration
3. Use that image in docker-compose.yml

See the [Backstage documentation](https://backstage.io/docs/deployment/docker) for more details.
