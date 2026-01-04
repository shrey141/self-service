# Setup Issue - Docker Image Not Found

## What Happened

You encountered this error:
```
Error response from daemon: pull access denied for spotify/backstage,
repository does not exist or may require 'docker login'
```

## Why This Happened

Backstage doesn't provide a pre-built Docker image. Unlike most applications, you need to build your own Backstage instance because:
1. Backstage is a framework, not a finished application
2. Each organization customizes their Backstage with different plugins
3. Configuration is unique to each deployment

## Solutions

You have **two main options**:

### Option 1: Build Backstage with Docker (Server Setup)

**Best for**: Running on your Ubuntu server long-term

```bash
cd backstage

# This will build Backstage (takes 10-20 minutes first time)
docker-compose build

# Then start everything
docker-compose up -d

# Watch the build/startup logs
docker-compose logs -f
```

**What this does**:
- Downloads Node.js and dependencies
- Creates a Backstage app
- Compiles TypeScript
- Builds a Docker image
- Starts Backstage + PostgreSQL

**Time**: ~10-20 minutes on first build, then fast

### Option 2: Run Locally with Node.js (Quick Start)

**Best for**: Learning and testing quickly

**Step 1**: Install Node.js 18+ (if not installed)
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Step 2**: Run the setup script
```bash
cd backstage
./run-local.sh
```

**What this does**:
- Creates a Backstage app using Node.js
- Starts just PostgreSQL in Docker
- Runs Backstage directly on your system
- Opens at http://localhost:3000

**Time**: ~5 minutes first time

## Which Option Should You Choose?

| Scenario | Recommendation |
|----------|---------------|
| Just want to see Backstage quickly | Option 2 (Node.js) |
| Learning and testing | Option 2 (Node.js) |
| Running on server long-term | Option 1 (Docker build) |
| Don't want to install Node.js | Option 1 (Docker build) |
| Want to customize and develop | Option 2 (Node.js) |

## My Recommendation

Since you're learning self-service platforms:

1. **Start with Option 2** (Node.js local)
   - It's faster to get running
   - Easier to understand what's happening
   - Better for experimenting with configs
   - Can see live changes

2. **Move to Option 1** when ready for production
   - Once you understand how it works
   - When you want it running 24/7
   - For a more "production-like" setup

## Next Steps

### If using Option 1 (Docker):
```bash
cd backstage
docker-compose build  # Go get coffee, this takes ~15 min
docker-compose up -d
# Wait a few minutes for startup
# Then visit http://YOUR_SERVER_IP:3000
```

### If using Option 2 (Node.js):
```bash
# Install Node.js 18+ first (if needed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Then run
cd backstage
./run-local.sh
# Visit http://localhost:3000
```

## Troubleshooting

### "Docker build is taking forever"
- First build is slow (10-20 min is normal)
- Downloads ~500MB of npm packages
- Compiles TypeScript code
- Be patient, it's worth it!

### "Out of memory during build"
- Increase Docker memory to 4GB+ in Docker settings
- Or use Option 2 (Node.js) instead

### "I don't have Node.js"
- Use Option 1 (Docker build)
- Or install Node.js with the commands above

## Understanding Backstage

Backstage is different from typical Docker apps because:
- It's a **framework** you build on, not a ready-made app
- You **customize** it with plugins and config
- Each company's Backstage looks different
- That's why there's no one-size-fits-all image

This repo provides:
- ✅ Terraform modules (ready to use)
- ✅ Templates (ready to use)
- ✅ Configuration (ready to use)
- ⏳ Backstage app (you need to build/create it)

## After You Get It Running

Once Backstage starts:
1. Visit http://localhost:3000
2. Click "Guest" to sign in (dev mode)
3. Click "Create" to see our GCP project template
4. Explore the catalog
5. Review the documentation

The rest of the platform (Terraform, templates, workflows) is ready to go!

## Questions?

- See [backstage/DOCKER_BUILD.md](./backstage/DOCKER_BUILD.md) for more details
- Check [docs/GETTING_STARTED.md](./docs/GETTING_STARTED.md) for the full guide
- The Terraform and templates work independently of Backstage
