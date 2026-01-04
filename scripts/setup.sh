#!/bin/bash
set -e

# Self-Service Platform Setup Script
# This script helps you quickly set up the self-service platform

echo "=================================="
echo "Self-Service Platform Setup"
echo "=================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Would you like to install it? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Installing Docker..."
        sudo apt update
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        sudo usermod -aG docker $USER
        echo "Docker installed successfully!"
        echo "Please log out and log back in for group changes to take effect."
        exit 0
    else
        echo "Docker is required. Please install it manually and run this script again."
        exit 1
    fi
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Docker Compose is not installed. Installing..."
    sudo apt install -y docker-compose-plugin
fi

echo "✓ Docker is installed"
echo ""

# Navigate to backstage directory
cd "$(dirname "$0")/../backstage"

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "✓ Created .env file"
    echo ""
    echo "You need to configure your GitHub token:"
    echo "1. Go to https://github.com/settings/tokens"
    echo "2. Click 'Generate new token (classic)'"
    echo "3. Select scopes: repo, workflow"
    echo "4. Copy the token"
    echo ""
    read -p "Enter your GitHub token (or press Enter to skip): " github_token
    if [ -n "$github_token" ]; then
        sed -i "s/GITHUB_TOKEN=.*/GITHUB_TOKEN=$github_token/" .env
        echo "✓ GitHub token configured"
    else
        echo "⚠ GitHub token not configured. You'll need to edit .env manually."
    fi
else
    echo "✓ .env file already exists"
fi

echo ""
echo "Starting Backstage services..."
echo ""

# Start Docker Compose
if docker compose version &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

echo ""
echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
echo "Backstage is starting up. This may take a few minutes."
echo ""
echo "Access Backstage at:"
echo "  - http://localhost:3000"
echo "  - http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "To check the status:"
echo "  cd backstage && docker-compose ps"
echo ""
echo "To view logs:"
echo "  cd backstage && docker-compose logs -f backstage"
echo ""
echo "Next steps:"
echo "1. Wait for services to be healthy"
echo "2. Open Backstage in your browser"
echo "3. Review the documentation in docs/"
echo "4. Set up GCP OIDC (see docs/GCP_SETUP.md)"
echo ""
