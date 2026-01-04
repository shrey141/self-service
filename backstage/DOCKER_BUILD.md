# Building Backstage with Docker

Backstage doesn't provide a pre-built Docker image. You need to build it yourself.

## Problem

The error you encountered is because there's no `spotify/backstage:latest` image available.

## Solutions

You have three options:

### Option 1: Build with Docker (Recommended for Server)

This builds Backstage inside Docker. It takes ~10-20 minutes on first build.

```bash
cd backstage

# Build the image (this will take a while)
docker-compose build

# Start services
docker-compose up -d

# Monitor the build
docker-compose logs -f backstage
```

**Note**: The first build will download dependencies and compile TypeScript. Subsequent builds will be faster.

### Option 2: Run Locally with Node.js (Recommended for Development)

This is faster and better for learning:

```bash
# Install Node.js 18+ if not installed
# On Ubuntu:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Navigate to backstage directory
cd backstage

# Create Backstage app (one-time, takes ~5 minutes)
npx @backstage/create-app@latest

# This creates a new Backstage app in the current directory
# Answer the prompts or use default values

# Install dependencies
yarn install

# Start the database only
docker-compose up -d postgres

# Configure database connection
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=backstage
export POSTGRES_PASSWORD=backstage

# Start Backstage
yarn dev
```

Access Backstage at http://localhost:3000

### Option 3: Use Pre-built Demo (Quickest)

If you just want to see Backstage quickly:

```bash
# Use the standalone demo
npx @backstage/create-app@latest my-backstage-app
cd my-backstage-app
yarn install
yarn dev
```

This runs Backstage with SQLite (no PostgreSQL needed) for testing.

## Recommendation

For your Ubuntu server setup:

1. **First time/Learning**: Use Option 2 (local Node.js) to understand how Backstage works
2. **Production/Long-term**: Use Option 1 (Docker build) for containerized deployment

## Troubleshooting

### Build is taking too long
- First build can take 10-20 minutes
- Ensure you have good internet connection
- Check available disk space (need ~5GB)

### Out of memory during build
- Increase Docker memory limit to 4GB+
- Or use Option 2 (local Node.js)

### Node.js not installed
```bash
# Install Node.js 18 on Ubuntu
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

## What's Happening in the Build

1. Downloads Node.js base image
2. Installs system dependencies (Python, build tools)
3. Creates a Backstage app using `@backstage/create-app`
4. Installs all npm dependencies (~500MB)
5. Compiles TypeScript to JavaScript
6. Builds the backend bundle
7. Creates production image

This is why it takes time on first build!

## Next Steps

Once Backstage is running:
1. Access http://localhost:3000
2. Sign in as guest
3. Explore the catalog
4. Check "Create" to see templates
5. Review our custom configuration in app-config.yaml
