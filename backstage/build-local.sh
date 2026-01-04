#!/bin/bash
set -e

echo "=================================="
echo "Building Backstage Locally"
echo "=================================="
echo ""
echo "This will create a Backstage app in the current directory."
echo "This is a one-time setup and may take 10-15 minutes."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed."
    echo "Please install Node.js 18+ and try again."
    exit 1
fi

echo "Node.js version: $(node --version)"
echo ""

# Check if we're in the backstage directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: Please run this script from the backstage/ directory"
    exit 1
fi

# Check if app already exists
if [ -d "node_modules" ]; then
    echo "Backstage app already exists. Skipping creation."
else
    echo "Creating Backstage app..."
    echo ""

    # Create Backstage app (non-interactive)
    npx @backstage/create-app@latest --skip-install

    echo ""
    echo "Installing dependencies..."
    yarn install
fi

echo ""
echo "Building Backstage..."
yarn build:backend

echo ""
echo "=================================="
echo "Build Complete!"
echo "=================================="
echo ""
echo "You can now start Backstage with:"
echo "  docker-compose up -d"
echo ""
