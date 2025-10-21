#!/bin/bash

# ============================================================
# Automated Deployment Script – HNG Stage 1 DevOps
# Author: Iniabasi Okorie
# Description: Automates setup and deployment of a Dockerized app
# ============================================================

# === CONFIGURATION ===
REPO_URL="https://github.com/inijoy/Mediplus-website.git"
APP_DIR="mediplus"
SERVER_USER="${SERVER_USER:-ubuntu}"
SERVER_IP="${SERVER_IP:?Server IP not set. Please export SERVER_IP before running.}"
SSH_KEY="${SSH_KEY:?SSH key path not set. Please export SSH_KEY before running.}"
LOG_FILE="deployment.log"

# === LOGGING SETUP ===
exec > >(tee -i "$LOG_FILE") 2>&1
echo "============================================================"
echo "🚀 Starting Automated Deployment for HNG Stage 1..."
echo "============================================================"

# === VALIDATION CHECKS ===
echo "[STEP 1] Validating prerequisites..."

if [ ! -f "$SSH_KEY" ]; then
  echo "❌ SSH key not found at $SSH_KEY. Exiting..."
  exit 1
fi

if ping -c 2 github.com > /dev/null 2>&1 || ping -n 2 github.com > /dev/null 2>&1; then
  echo "✅ Internet connection detected."
else
  echo "❌ No internet connection detected. Exiting..."
  exit 1
fi


echo "✅ Validation complete."

# === CLONE APPLICATION REPOSITORY ===
echo "[STEP 2] Cloning Mediplus repository..."
if [ -d "$APP_DIR" ]; then
  echo "ℹ️ Removing existing $APP_DIR directory..."
  rm -rf "$APP_DIR"
fi

git clone "$REPO_URL" "$APP_DIR" || { echo "❌ Failed to clone repo."; exit 1; }
echo "✅ Repository cloned successfully."

# === CONNECT TO REMOTE SERVER AND INSTALL DEPENDENCIES ===
echo "[STEP 3] Setting up remote server..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_IP" <<'EOF'
set -e

echo "🖥️ Connected to remote server: $(hostname)"
echo "[INSTALL] Updating packages..."
sudo apt update -y && sudo apt upgrade -y

echo "[INSTALL] Installing Docker..."
if ! command -v docker &> /dev/null; then
  sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
fi

echo "[INSTALL] Installing Docker Compose..."
if ! docker compose version &> /dev/null; then
  sudo apt install -y docker-compose-plugin
fi

echo "[INSTALL] Installing Nginx..."
if ! command -v nginx &> /dev/null; then
  sudo apt install -y nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx
fi

echo "✅ Remote server setup complete."
EOF

# === COPY APPLICATION TO REMOTE SERVER ===
echo "[STEP 4] Uploading application to server..."
scp -i "$SSH_KEY" -r "$APP_DIR" "$SERVER_USER@$SERVER_IP:/home/$SERVER_USER/" || { echo "❌ File transfer failed."; exit 1; }
echo "✅ Application uploaded successfully."

# === DEPLOY DOCKERIZED APPLICATION ===
echo "[STEP 5] Deploying Docker container..."
ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_IP" <<'EOF'
cd ~/mediplus

echo "🧱 Building Docker image..."
sudo docker build -t mediplus-app .

echo "🚀 Running Docker container..."
sudo docker rm -f mediplus-container || true
sudo docker run -d -p 8080:80 --name mediplus-container mediplus-app

echo "✅ Application deployed and running."
EOF

# === CONFIGURE NGINX AS REVERSE PROXY ===
echo "[STEP 6] Configuring Nginx reverse proxy..."
ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_IP" <<'EOF'
sudo tee /etc/nginx/sites-available/mediplus <<NGINX_CONF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINX_CONF

sudo ln -sf /etc/nginx/sites-available/mediplus /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
echo "✅ Nginx configured successfully on port 80."
EOF

echo "============================================================"
echo "🎉 Deployment completed successfully!"
echo "Logs saved to $LOG_FILE"
echo "============================================================"


