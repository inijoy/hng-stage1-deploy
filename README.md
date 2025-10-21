# hng-stage1-deploy

This project automates the deployment of a web application to a remote server using Docker and Nginx.

## How It Works

1. **Deploy the Application**
   - Connect to the remote server via SSH.
   - Install necessary packages: Docker and Nginx.
   - Upload the application files from your local machine to the server.
   - Build a Docker image of the application.
   - Run the Docker container.
   - Configure Nginx as a reverse proxy to route traffic to the application container on port 8080.

Once complete, the application is accessible through the server's IP on port 80.

## Features

- Fully automated deployment script
- Dockerized application
- Nginx reverse proxy configuration
- Logs saved to `deployment.log` for monitoring

## Requirements

- Ubuntu 22.04 or later
- Docker installed on server
- Nginx installed on server
- SSH access to the server

## Notes

- Make sure to replace `proxy_pass` in the Nginx configuration with the correct container port if it changes.
- A system restart may be required after package installations for kernel updates.

---

Happy deploying! 🚀
