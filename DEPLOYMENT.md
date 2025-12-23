# Azure Deployment Guide

This document describes the Azure deployment infrastructure for the ES NA Battlesnakes project.

## Overview

The project uses multiple deployment workflows to deploy Battlesnake applications to Azure:

1. **Automatic Production Deployment** (`docker-image.yml`) - Deploys to Azure Container Instances on every push to `main`
2. **Branch Deployment** (`deploy-branch.yml`) - Deploy branches via `.deploy` comment on PRs
3. **AKS Deployment** (`Snake-deploy.yaml`) - Manual deployment to Azure Kubernetes Service

## Deployment Workflows

### 1. Automatic Production Deployment (docker-image.yml)

**Trigger:** Automatically runs on push to `main` branch or manual workflow dispatch

**Target:** Azure Container Instances (ACI)

**Process:**
1. Builds Docker image
2. Pushes to GitHub Container Registry (ghcr.io)
3. Logs into Azure
4. Optionally deletes existing deployment (if `delete` input is true)
5. Deploys to ACI with DNS name `code-snek`

**Configuration:**
- Resource Group: `snekResourceGroup`
- Container Name: `code-snake`
- Location: `west us 2`
- Exposed Ports: `4567 4568 4569 4570 4571 8080 8081`
- Image: `ghcr.io/es-na-battlesnake/code-snake:latest`

### 2. Branch Deployment (deploy-branch.yml)

**Trigger:** Comment `.deploy` on a pull request

**Target:** Azure Container Instances (ACI)

**Process:**
1. Uses IssueOps pattern with `github/branch-deploy` action
2. Analyzes changed files to determine if full deployment needed
3. Builds and pushes Docker image with SHA tag
4. Deploys to ACI with DNS name `code-snek`

**Configuration:**
- Resource Group: `snekResourceGroup`
- Container Name: `code-snake`
- Location: `west us 3`
- Exposed Ports: `4567 8081`

### 3. AKS Deployment (Snake-deploy.yaml)

**Trigger:** Manual workflow dispatch only

**Target:** Azure Kubernetes Service (AKS)

**Process:**
1. Builds and pushes image to Azure Container Registry
2. Sets up AKS context
3. Deploys to Kubernetes cluster

**Configuration:**
- ACR Resource Group: `acrworkflow1669243560679`
- ACR Name: `snakeacr`
- Cluster Name: `es-snakes`
- Cluster Resource Group: `snekResourceGroup`
- Namespace: `essnakeswest`

## Required Azure Secrets

The following secrets must be configured in GitHub repository settings:

### For ACI Deployments (docker-image.yml, deploy-branch.yml)

- `AZURE_CLIENT_ID` - Azure Service Principal Client ID
- `AZURE_TENANT_ID` - Azure Active Directory Tenant ID
- `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID

### For AKS Deployments (Snake-deploy.yaml)

Same secrets as above, plus:
- Access to Azure Container Registry `snakeacr`
- Access to AKS cluster `es-snakes`

## Azure Resource Setup

### Service Principal

The workflows use Azure federated credentials with GitHub OIDC. The service principal needs:

1. **Permissions:**
   - Contributor role on resource group `snekResourceGroup`
   - AcrPush role on container registry `snakeacr` (for AKS deployments)
   - Azure Kubernetes Service Cluster User Role (for AKS deployments)

2. **Federated Credentials:**
   - Subject: `repo:es-na-battlesnake/snakes:ref:refs/heads/main`
   - Subject: `repo:es-na-battlesnake/snakes:pull_request`
   - Subject: `repo:es-na-battlesnake/snakes:environment:production`
   - Subject: `repo:es-na-battlesnake/snakes:environment:production-secrets`

### Azure Resources

Required Azure resources:
- Resource Group: `snekResourceGroup`
- Azure Container Registry: `snakeacr`
- AKS Cluster: `es-snakes`
- Container Instances are created/updated by workflows

## Deployment Methods

### Automatic Deployment (Main Branch)

Simply merge your PR to `main` branch. The `docker-image.yml` workflow will automatically:
1. Build and push the Docker image
2. Deploy to Azure Container Instances
3. Make it available at `code-snek.westus2.azurecontainer.io`

### Branch Deployment (Testing)

1. Create a pull request with your changes
2. Wait for CI to pass
3. Comment `.deploy` on the PR
4. The workflow will deploy your branch to Azure
5. Test at `code-snek.westus3.azurecontainer.io`
6. If successful, merge to main

### Manual Deployment with Delete

If you need to recreate the container (e.g., to change port configuration):

1. Go to Actions tab
2. Select "Docker Image build + push + deploy - main branch"
3. Click "Run workflow"
4. Set "Delete and redeploy" to `true`
5. Click "Run workflow"

### AKS Deployment

For Kubernetes deployment:

1. Go to Actions tab
2. Select "Snake-deploy"
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow"

## Monitoring and Logs

- **Azure Portal:** View container instances, logs, and metrics
- **GitHub Actions:** View deployment logs and status
- **Container Logs:** Access via Azure Portal or Azure CLI

```bash
# View container logs
az container logs --resource-group snekResourceGroup --name code-snake

# Check container status
az container show --resource-group snekResourceGroup --name code-snake
```

## Troubleshooting

### Deployment Fails with Authentication Error

Check that:
1. Azure secrets are correctly configured in GitHub
2. Service principal has required permissions
3. Federated credentials are set up for the repository

### Container Fails to Start

1. Check GitHub Actions logs for build errors
2. View container logs in Azure Portal
3. Verify exposed ports match application configuration

### Need to Change Port Configuration

Some container properties require recreation:
1. Use workflow dispatch with "Delete and redeploy" = true
2. Or manually delete container in Azure Portal first

## Rollback

To rollback to previous version:

1. Comment `.deploy main` on any PR to deploy the main branch
2. Or manually trigger the workflow for the specific commit

## Security Notes

- Uses Azure federated credentials (no long-lived secrets)
- Requires repository environment approvals for production
- Container images stored in GitHub Container Registry
- All secrets managed through GitHub Secrets
