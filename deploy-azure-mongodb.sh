#!/bin/bash

# Script de déploiement N8N avec MongoDB Atlas pour forfait étudiant
# Base de données cloud au lieu de SQLite local

# Variables de configuration ÉCONOMIQUES pour Web Apps + MongoDB
RESOURCE_GROUP="morgansn8n-rg"
APP_NAME="morgansn8n"
LOCATION="East US"  # Région la moins chère
APP_SERVICE_PLAN="morgansn8n-plan"
SKU="F1"  # FREE tier pour forfait étudiant !

echo "🎓 Déploiement N8N + MongoDB Atlas (Forfait GRATUIT!)"
echo "💰 N8N: Gratuit sur Azure F1 + MongoDB: 512MB gratuit"
echo ""

# Vérifications
if ! az account show &> /dev/null; then
    echo "❌ Vous devez d'abord vous connecter avec: az login"
    exit 1
fi

# Demander les informations MongoDB
echo "📋 Configuration MongoDB Atlas requise:"
echo "Vous devez d'abord créer un cluster MongoDB Atlas gratuit sur:"
echo "https://cloud.mongodb.com/"
echo ""

read -p "🔗 Connection string MongoDB (ex: mongodb+srv://user:pass@cluster.mongodb.net/n8n): " MONGODB_URI
read -p "📝 Nom de la base de données (défaut: n8n): " DB_NAME
DB_NAME=${DB_NAME:-n8n}

if [ -z "$MONGODB_URI" ]; then
    echo "❌ Connection string MongoDB requis!"
    echo "💡 Format: mongodb+srv://username:password@cluster.mongodb.net/database"
    exit 1
fi

echo ""
echo "💳 Vérification de votre abonnement Azure..."
az account show --query "name" -o tsv
echo ""

# 1. Créer le groupe de ressources (réutiliser s'il existe)
echo "📦 Création/vérification du groupe de ressources dans $LOCATION..."
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# 2. Créer le plan App Service GRATUIT
echo "🆓 Création du plan App Service GRATUIT (F1)..."
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --sku F1 \
    --is-linux

# 3. Créer l'application web avec container N8N
echo "🌐 Création de l'application web morgansn8n..."
az webapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --deployment-container-image-name n8nio/n8n:latest

# 4. Configurer les variables d'environnement avec MongoDB
echo "⚙️ Configuration des variables d'environnement avec MongoDB..."
ENCRYPTION_KEY=$(openssl rand -base64 32)
az webapp config appsettings set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "N8N_HOST=0.0.0.0" \
        "N8N_PORT=8000" \
        "N8N_PROTOCOL=https" \
        "WEBHOOK_URL=https://$APP_NAME.azurewebsites.net/" \
        "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY" \
        "DB_TYPE=mongodb" \
        "DB_MONGODB_CONNECTION_URL=$MONGODB_URI" \
        "DB_MONGODB_DATABASE=$DB_NAME" \
        "N8N_RUNNERS_ENABLED=false" \
        "N8N_BLOCK_ENV_ACCESS_IN_NODE=false" \
        "N8N_GIT_NODE_DISABLE_BARE_REPOS=true" \
        "N8N_SECURE_COOKIE=true" \
        "N8N_METRICS=false" \
        "WEBSITES_PORT=8000" \
        "NODE_ENV=production"

# 5. Configurer le container
echo "🐳 Configuration du container Docker..."
az webapp config container set \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --docker-custom-image-name n8nio/n8n:latest

# 6. Redémarrer l'application
echo "🔄 Redémarrage de l'application..."
az webapp restart --name $APP_NAME --resource-group $RESOURCE_GROUP

# 7. Attendre le démarrage
echo "⏳ Attente du démarrage (45 secondes - MongoDB prend plus de temps)..."
sleep 45

# 8. Afficher les informations
echo ""
echo "✅ Déploiement N8N + MongoDB terminé!"
echo ""
echo "📋 Informations de votre déploiement:"
echo "  - Nom de l'app: $APP_NAME"  
echo "  - URL: https://$APP_NAME.azurewebsites.net"
echo "  - Groupe de ressources: $RESOURCE_GROUP"
echo "  - Base de données: MongoDB Atlas ($DB_NAME)"
echo "  - Coût total: 0$/mois 🎉 (Tout gratuit!)"
echo ""
echo "🎓 CONFIGURATION:"
echo "  - N8N: Azure App Service F1 (gratuit)"
echo "  - Base: MongoDB Atlas M0 (512MB gratuit)"
echo "  - Région: $LOCATION (économique)"
echo ""
echo "✅ AVANTAGES MongoDB vs SQLite:"
echo "  - 🚀 Meilleures performances"
echo "  - 📊 Données persistantes (ne se perdent pas)"
echo "  - 🔄 Scaling automatique"
echo "  - 🌐 Accessible depuis partout"
echo "  - 📈 Monitoring intégré"
echo ""
echo "🔧 Commandes utiles:"
echo "  Voir les logs: az webapp log tail --name $APP_NAME --resource-group $RESOURCE_GROUP"
echo "  Redémarrer: az webapp restart --name $APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
echo "🗃️ Accès MongoDB Atlas:"
echo "  - Dashboard: https://cloud.mongodb.com/"
echo "  - Database: $DB_NAME"
echo "  - Collections N8N: workflow, execution, credentials, etc."
echo ""
echo "🗑️ Pour supprimer:"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
