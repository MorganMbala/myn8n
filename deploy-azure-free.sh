#!/bin/bash

# Script de déploiement N8N sur Azure Web Apps pour forfait étudiant
# Alternative plus fiable à Container Instances
# Configuration optimisée pour les coûts

# Variables de configuration ÉCONOMIQUES pour Web Apps
RESOURCE_GROUP="morgansn8n-rg"
APP_NAME="morgansn8n"
LOCATION="East US"  # Région la moins chère
APP_SERVICE_PLAN="morgansn8n-plan"
SKU="F1"  # FREE tier pour forfait étudiant !

echo "🎓 Déploiement N8N sur Azure Web Apps (Forfait GRATUIT!)"
echo "💰 Utilisation du tier GRATUIT F1 - Coût: 0$/mois !"
echo ""

# Vérifier la connexion Azure
if ! az account show &> /dev/null; then
    echo "❌ Vous devez d'abord vous connecter avec: az login"
    exit 1
fi

# Afficher l'abonnement
echo "💳 Vérification de votre abonnement..."
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

# 4. Configurer les variables d'environnement
echo "⚙️ Configuration des variables d'environnement..."
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
        "DB_SQLITE_POOL_SIZE=3" \
        "N8N_RUNNERS_ENABLED=false" \
        "N8N_BLOCK_ENV_ACCESS_IN_NODE=false" \
        "N8N_GIT_NODE_DISABLE_BARE_REPOS=true" \
        "N8N_SECURE_COOKIE=true" \
        "N8N_METRICS=false" \
        "WEBSITES_PORT=8000"

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
echo "⏳ Attente du démarrage (30 secondes)..."
sleep 30

# 8. Afficher les informations
echo ""
echo "✅ Déploiement terminé!"
echo ""
echo "📋 Informations de votre déploiement GRATUIT:"
echo "  - Nom de l'app: $APP_NAME"  
echo "  - URL: https://$APP_NAME.azurewebsites.net"
echo "  - Groupe de ressources: $RESOURCE_GROUP"
echo "  - Région: $LOCATION"
echo "  - Plan: $SKU (GRATUIT!)"
echo "  - Coût: 0$/mois 🎉"
echo ""
echo "🎓 AVANTAGES du tier GRATUIT F1:"
echo "  - ✅ Complètement GRATUIT"
echo "  - ✅ 1GB d'espace disque"
echo "  - ✅ 165 MB de RAM"
echo "  - ✅ 60 minutes CPU/jour"
echo "  - ✅ Parfait pour apprendre N8N"
echo ""
echo "⚠️  Limitations du tier gratuit:"
echo "  - 🕐 L'app se met en veille après 20min d'inactivité"
echo "  - 🕐 60 minutes de CPU par jour maximum" 
echo "  - 💾 RAM limitée (peut être lent)"
echo ""
echo "🔧 Commandes utiles:"
echo "  Voir les logs: az webapp log tail --name $APP_NAME --resource-group $RESOURCE_GROUP"
echo "  Redémarrer: az webapp restart --name $APP_NAME --resource-group $RESOURCE_GROUP"
echo "  Voir le statut: az webapp show --name $APP_NAME --resource-group $RESOURCE_GROUP --query state"
echo ""
echo "🗑️ Pour supprimer (si nécessaire):"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""
echo "💡 Si vous voulez plus de performances plus tard:"
echo "  az appservice plan update --name $APP_SERVICE_PLAN --resource-group $RESOURCE_GROUP --sku B1"
echo "  (Coût: ~15$/mois avec le B1)"
