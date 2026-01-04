#!/bin/bash
set -e

echo "=================================="
echo "Installing Node.js 18"
echo "=================================="
echo ""

# Check if Node.js is already installed
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo "✓ Node.js $(node --version) is already installed"
        exit 0
    else
        echo "Node.js $(node --version) is installed but version 18+ is required"
        echo "Upgrading..."
    fi
fi

# Install Node.js 18
echo "Installing Node.js 18 from NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
echo ""
echo "✓ Node.js installed successfully!"
echo "  Node.js version: $(node --version)"
echo "  npm version: $(npm --version)"
echo ""
echo "Next step: Run Backstage"
echo "  cd backstage && ./run-local.sh"
echo ""
