#!/bin/bash
set -e

echo "=================================="
echo "Backstage Local Setup"
echo "=================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed!"
    echo ""
    echo "Install Node.js 18+ with:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    echo ""
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "Node.js 18+ required. You have: $(node --version)"
    exit 1
fi

echo "✓ Node.js $(node --version) detected"
echo ""

# Check if we need to create the app
if [ ! -f "package.json" ]; then
    echo "Creating new Backstage app..."
    echo "This is a one-time setup and will take ~5 minutes."
    echo ""

    # Create app in current directory
    npx @backstage/create-app@latest --skip-install

    echo ""
    echo "Installing dependencies..."
    yarn install

    echo ""
    echo "✓ Backstage app created"
else
    echo "✓ Backstage app already exists"
fi

echo ""
echo "Starting PostgreSQL in Docker..."
docker-compose up -d postgres

echo ""
echo "Waiting for PostgreSQL to be ready..."
sleep 5

echo ""
echo "=================================="
echo "Starting Backstage Development Server"
echo "=================================="
echo ""
echo "Backstage will be available at http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Set environment variables for database
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=backstage
export POSTGRES_PASSWORD=backstage

# Start Backstage in development mode
yarn dev
