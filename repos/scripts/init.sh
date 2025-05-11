#!/bin/bash

echo "🚀 Starting setup..."

# 1️⃣ Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker not found. Installing..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    newgrp docker
fi

# 2️⃣ Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "🔧 Docker Compose not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y docker-compose
fi

# 3️⃣ Pull the latest dev_environment repository
REPO_URL="https://github.com/YOUR_USERNAME/dev_environment.git"
CLONE_DIR="$HOME/dev_environment"

if [ -d "$CLONE_DIR" ]; then
    echo "🔄 Existing directory found. Pulling latest changes..."
    cd "$CLONE_DIR" && git pull
else
    echo "📦 Cloning development environment..."
    git clone $REPO_URL "$CLONE_DIR"
fi

cd "$CLONE_DIR"

# 4️⃣ ✅ Environment Variable Check
echo "🔍 Checking required environment variables..."
REQUIRED_VARS=("INFISICAL_PROJECT_ID" "INFISICAL_ENV" "INFISICAL_TOKEN")
MISSING_VARS=()

for VAR in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "$VAR" .env; then
        MISSING_VARS+=("$VAR")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo "❌ Missing environment variables in .env:"
    for VAR in "${MISSING_VARS[@]}"; do
        echo "   - $VAR"
    done
    echo "Please add them to the .env file and rerun the script."
    exit 1
fi

# 5️⃣ Login to Infisical and pull secrets
echo "🔑 Logging into Infisical..."
infisical login --token $INFISICAL_TOKEN

echo "🌐 Pulling environment secrets from Infisical..."
infisical env pull --env=$INFISICAL_ENV --format=dotenv > .env

# 6️⃣ Clone predefined repositories
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

# 7️⃣ Build and start Docker Compose
cd "$CLONE_DIR"
echo "🐋 Building Docker containers..."
docker-compose up --build -d

# 8️⃣ Output services
echo "✅ Setup Complete!"
echo "VSCode → http://localhost:8443"
echo "PyCharm (VNC) → http://localhost:8888"
