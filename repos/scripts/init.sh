#!/bin/bash

echo "🚀 Starting setup..."

# 1️⃣ Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker not found. Installing..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    newgrp docker
fi

# 2️⃣ Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "🔧 Docker Compose not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y docker-compose
fi

# 3️⃣ Pull the latest dev_environment repository
REPO_URL="https://github.com/Y4ng0/dev_environment"
CLONE_DIR="$HOME/dev_environment"

if [ -d "$CLONE_DIR" ]; then
    echo "🔄 Existing directory found. Pulling latest changes..."
    cd "$CLONE_DIR" && git pull
else
    echo "📦 Cloning development environment..."
    git clone $REPO_URL "$CLONE_DIR"
fi

# 4️⃣ Navigate to the dev_environment folder
cd "$CLONE_DIR"

# 5️⃣ Install Infisical CLI if not installed
if ! command -v infisical &> /dev/null; then
    echo "🔒 Installing Infisical CLI..."
    npm install -g infisical
fi

# 6️⃣ Login to Infisical and pull secrets
echo "🔑 Logging into Infisical..."
infisical login
echo "🌐 Pulling environment secrets from Infisical..."
infisical env pull --env=dev --format=dotenv > .env

# 7️⃣ Clone predefined repositories
echo "📁 Cloning repositories..."
mkdir -p repos
cd repos
REPOS=("repo1" "repo2" "repo3")  # Replace with your actual repo names
for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        echo "🔄 Pulling latest changes for $repo..."
        cd "$repo" && git pull && cd ..
    else
        echo "📦 Cloning $repo..."
        git clone "https://github.com/YOUR_USERNAME/$repo.git"
    fi
done

# 8️⃣ Build and start Docker Compose
cd "$CLONE_DIR"
echo "🐋 Building Docker containers..."
docker-compose up --build -d

# 9️⃣ Output services
echo "✅ Setup Complete!"
echo "VSCode → http://localhost:8443"
echo "PyCharm (VNC) → http://localhost:8888"
