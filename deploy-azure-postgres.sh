#!/bin/bash

# Azure N8N Deployment Script - PostgreSQL Backend
# Student Budget: FREE tier (F1) - 0$/month
# Database: PostgreSQL Neon Cloud (Free tier)

# Configuration variables
RESOURCE_GROUP="morgansn8n-rg"
APP_NAME="n8n-final-app"
PLAN_NAME="n8n-final-plan"
LOCATION="eastus"
DOCKER_IMAGE="n8nio/n8n:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying N8N with PostgreSQL Neon Backend${NC}"
echo -e "${YELLOW}📚 Student Budget: FREE tier deployment${NC}"
echo ""

# Check if logged in to Azure
echo -e "${BLUE}🔍 Checking Azure CLI authentication...${NC}"
if ! az account show &>/dev/null; then
    echo -e "${RED}❌ Not logged in to Azure. Please run 'az login' first.${NC}"
    exit 1
fi

# Get current subscription
SUBSCRIPTION=$(az account show --query name --output tsv)
echo -e "${GREEN}✅ Connected to Azure subscription: $SUBSCRIPTION${NC}"

# Check if resource group exists
echo -e "${BLUE}🔍 Checking if resource group exists...${NC}"
if az group show --name $RESOURCE_GROUP &>/dev/null; then
    echo -e "${GREEN}✅ Resource group '$RESOURCE_GROUP' already exists${NC}"
else
    echo -e "${YELLOW}📝 Creating resource group '$RESOURCE_GROUP'...${NC}"
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi

# Check if App Service Plan exists
echo -e "${BLUE}🔍 Checking if App Service Plan exists...${NC}"
if az appservice plan show --name $PLAN_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
    echo -e "${GREEN}✅ App Service Plan '$PLAN_NAME' already exists${NC}"
else
    echo -e "${YELLOW}📝 Creating FREE App Service Plan...${NC}"
    az appservice plan create \
        --name $PLAN_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --is-linux \
        --sku F1
fi

# Check if Web App exists
echo -e "${BLUE}🔍 Checking if Web App exists...${NC}"
if az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
    echo -e "${GREEN}✅ Web App '$APP_NAME' already exists${NC}"
else
    echo -e "${YELLOW}📝 Creating Web App...${NC}"
    az webapp create \
        --name $APP_NAME \
        --resource-group $RESOURCE_GROUP \
        --plan $PLAN_NAME \
        --deployment-container-image-name $DOCKER_IMAGE
fi

# Configure PostgreSQL Neon environment variables
echo -e "${BLUE}⚙️  Configuring PostgreSQL Neon environment variables...${NC}"

# Load environment variables from .env file
if [ -f ".env" ]; then
    source .env
    echo -e "${GREEN}✅ Loaded environment variables from .env file${NC}"
else
    echo -e "${RED}❌ .env file not found. Please create it based on .env.example${NC}"
    exit 1
fi

# PostgreSQL Neon Configuration - APPROCHE INTELLIGENTE
echo -e "${BLUE}🧠 Configuration intelligente des variables PostgreSQL...${NC}"

# Configuration par étapes séparées (plus fiable qu'en une seule fois)
echo -e "${YELLOW}📝 Étape 1: Configuration de la base de données...${NC}"
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --settings \
        DB_TYPE=postgresdb \
        DB_POSTGRESDB_HOST="$DB_POSTGRESDB_HOST" \
        DB_POSTGRESDB_PORT="$DB_POSTGRESDB_PORT" \
        DB_POSTGRESDB_DATABASE="$DB_POSTGRESDB_DATABASE" \
        DB_POSTGRESDB_USER="$DB_POSTGRESDB_USER" \
        DB_POSTGRESDB_PASSWORD="$DB_POSTGRESDB_PASSWORD" \
        DB_POSTGRESDB_SSL=true

sleep 10  # Attendre que la première configuration soit appliquée

echo -e "${YELLOW}📝 Étape 2: Configuration N8N core...${NC}"
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --settings \
        N8N_ENCRYPTION_KEY="$N8N_ENCRYPTION_KEY" \
        N8N_USER_MANAGEMENT_JWT_SECRET="$N8N_USER_MANAGEMENT_JWT_SECRET" \
        N8N_PORT=5678 \
        N8N_HOST=0.0.0.0 \
        N8N_PROTOCOL=https

sleep 10  # Attendre que la deuxième configuration soit appliquée

echo -e "${YELLOW}📝 Étape 3: Configuration Azure et sécurité...${NC}"
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --settings \
        N8N_SECURE_COOKIE=true \
        WEBHOOK_URL="https://$APP_NAME.azurewebsites.net/" \
        N8N_EDITOR_BASE_URL="https://$APP_NAME.azurewebsites.net" \
        N8N_USER_FOLDER="/home/site/wwwroot/.n8n" \
        GENERIC_TIMEZONE="America/Toronto" \
        N8N_METRICS=true \
        N8N_LOG_LEVEL=info \
        WEBSITES_ENABLE_APP_SERVICE_STORAGE=true \
        WEBSITES_PORT=5678

sleep 10  # Attendre que la troisième configuration soit appliquée

echo -e "${YELLOW}📝 Étape 4: Optimisation des performances et correction des erreurs...${NC}"
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --settings \
        N8N_DISABLE_RATE_LIMITING=true \
        N8N_TRUST_PROXY=true \
        N8N_PROXY_HOPS=1 \
        EXPRESS_TRUST_PROXY=true \
        DB_POSTGRESDB_POOL_SIZE=5 \
        DB_POSTGRESDB_MAX_QUERY_EXECUTION_TIME=30000 \
        N8N_DATABASE_LOGGING=false \
        N8N_LOG_LEVEL=warn \
        EXECUTIONS_DATA_PRUNE=true \
        EXECUTIONS_DATA_MAX_AGE=336 \
        N8N_DIAGNOSTICS_ENABLED=false \
        N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true \
        NODE_OPTIONS="--max-old-space-size=512"

sleep 10  # Attendre que la configuration d'optimisation soit appliquée

# Validation intelligente des variables
echo -e "${BLUE}🔍 Validation des variables configurées...${NC}"
DB_CHECK=$(az webapp config appsettings list --name $APP_NAME --resource-group $RESOURCE_GROUP --query "[?name=='DB_TYPE'].value" --output tsv)
if [ "$DB_CHECK" = "postgresdb" ]; then
    echo -e "${GREEN}✅ PostgreSQL Neon configuration applied successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Reconfiguration des variables critiques...${NC}"
    # Re-configuration forcée si les variables ne sont pas appliquées
    az webapp config appsettings set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_NAME \
        --settings \
            DB_TYPE=postgresdb \
            WEBSITES_PORT=5678 \
            N8N_ENCRYPTION_KEY="$N8N_ENCRYPTION_KEY"
fi

# Configure container settings
echo -e "${BLUE}⚙️  Configuring container settings...${NC}"
az webapp config container set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --docker-custom-image-name $DOCKER_IMAGE \
    --docker-registry-server-url "https://index.docker.io"

# Enable HTTPS only
echo -e "${BLUE}🔒 Enabling HTTPS only...${NC}"
az webapp update \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --https-only true

# Show deployment information
echo ""
echo -e "${GREEN}🎉 N8N with PostgreSQL Neon deployment completed!${NC}"
echo ""
echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo -e "  • App Name: $APP_NAME"
echo -e "  • Resource Group: $RESOURCE_GROUP"
echo -e "  • Pricing Tier: F1 (FREE)"
echo -e "  • Database: PostgreSQL Neon (SSL enabled)"
echo -e "  • URL: https://$APP_NAME.azurewebsites.net"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo -e "  1. Wait 2-3 minutes for the container to start"
echo -e "  2. Visit: https://$APP_NAME.azurewebsites.net"
echo -e "  3. Create your N8N admin account"
echo -e "  4. Start building workflows!"
echo ""
echo -e "${BLUE}📈 Monitor costs with:${NC} ./monitor-costs.sh"
echo -e "${BLUE}🔍 Check logs with:${NC} az webapp log tail --name $APP_NAME --resource-group $RESOURCE_GROUP"

# Optional: Open the website
read -p "$(echo -e ${YELLOW}🌐 Open N8N website in browser? [y/N]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open &> /dev/null; then
        open "https://$APP_NAME.azurewebsites.net"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "https://$APP_NAME.azurewebsites.net"
    else
        echo -e "${BLUE}🌐 Visit: https://$APP_NAME.azurewebsites.net${NC}"
    fi
fi

echo -e "${GREEN}✅ Deployment script completed successfully!${NC}"
