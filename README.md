# hng-stage1-deploy
Automated Deployment Script

Project Overview:
This project demonstrates a complete automated deployment workflow for a web application using Bash scripting, Docker, and Nginx. It is designed to simplify server setup, container deployment, and web server configuration in a single step, making it beginner-friendly and easy to follow.

Key Features:

Automated Server Setup: Updates and installs required packages such as Nginx and Docker.

Docker Integration: Builds and runs a Docker container for the web application.

Nginx Reverse Proxy: Configures Nginx to serve the application on port 80 with proper proxy headers.

Single-step Deployment: Everything is handled by a single deploy.sh script.

Beginner-Friendly: Each step is automated, with clear feedback messages in the terminal.

How It Works:

The script updates and upgrades the server packages.

Installs and starts Docker and Nginx services.

Builds a Docker image from the project files.

Runs the Docker container and exposes it to a designated port.

Configures Nginx to act as a reverse proxy for the running container.

Reloads Nginx and confirms that the application is accessible through the server IP.

Usage:

Make the script executable:

chmod +x deploy.sh


Run the deployment script:

./deploy.sh


Visit your server’s IP in a web browser to confirm the application is running.

Learning Outcomes:

Understanding Bash scripting for automation.

Hands-on experience with Docker containerization.

Configuring Nginx as a reverse proxy.

Automating deployment workflows for web applications.

This project is an excellent starting point for anyone looking to learn deployment automation, containerization, and web server configuration in a practical, hands-on way.
