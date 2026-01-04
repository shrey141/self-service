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
echo "=================================="
echo "Backstage Setup Options"
echo "=================================="
echo ""
echo "Backstage needs to be built before it can run."
echo "You have two options:"
echo ""
echo "1. Build with Docker (takes 10-20 min, good for server)"
echo "2. Run with Node.js (takes ~5 min, good for learning)"
echo ""
read -p "Choose option (1 or 2): " option

if [ "$option" = "1" ]; then
    echo ""
    echo "Building Backstage with Docker..."
    echo "This will take 10-20 minutes on first build."
    echo "You can monitor progress in another terminal with:"
    echo "  docker-compose logs -f backstage"
    echo ""
    read -p "Continue? (y/n): " confirm
    if [[ "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if docker compose version &> /dev/null; then
            docker compose build
            docker compose up -d
        else
            docker-compose build
            docker-compose up -d
        fi
        echo ""
        echo "✓ Backstage is building/starting"
        echo ""
        echo "Access Backstage at:"
        echo "  - http://localhost:3000"
        echo "  - http://$(hostname -I | awk '{print $1}'):3000"
        echo ""
        echo "Monitor the build:"
        echo "  cd backstage && docker-compose logs -f backstage"
    else
        echo "Setup cancelled. You can run this script again anytime."
    fi

elif [ "$option" = "2" ]; then
    if ! command -v node &> /dev/null; then
        echo ""
        echo "Node.js is not installed."
        echo ""
        echo "Install Node.js 18+ with:"
        echo "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
        echo "  sudo apt-get install -y nodejs"
        echo ""
        echo "Then run: cd backstage && ./run-local.sh"
        exit 1
    fi

    echo ""
    echo "Starting Backstage with Node.js..."
    echo "This will create a Backstage app and run it locally."
    echo ""
    cd backstage
    ./run-local.sh

else
    echo ""
    echo "Invalid option. Please run the script again and choose 1 or 2."
    echo ""
    echo "For more information, see:"
    echo "  - backstage/DOCKER_BUILD.md"
    echo "  - SETUP_ISSUE.md"
    exit 1
fi

echo ""
echo "=================================="
echo "Next Steps"
echo "=================================="
echo ""
echo "1. Wait for Backstage to start (may take a few minutes)"
echo "2. Open Backstage in your browser"
echo "3. Click 'Guest' to sign in (development mode)"
echo "4. Review the documentation in docs/"
echo "5. Set up GCP OIDC when ready (see docs/GCP_SETUP.md)"
echo ""
