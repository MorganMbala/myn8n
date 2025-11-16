#!/bin/bash

# Script simple pour lancer N8N en local et voir les données

echo "🏠 Lancement de N8N en local"
echo "============================"
echo ""

# Configuration du PATH
export PATH="/Users/morganmbala/.npm-global/bin:$PATH"

# Créer un dossier local pour N8N
LOCAL_DATA="$HOME/.n8n-local"
mkdir -p "$LOCAL_DATA"

echo "📁 Dossier de données local: $LOCAL_DATA"
echo "🌐 Interface web: http://localhost:5678"
echo "🛑 Arrêter: Ctrl+C"
echo ""

# Variables d'environnement pour N8N local
export N8N_USER_FOLDER="$LOCAL_DATA"
export N8N_PORT=5678
export N8N_HOST=localhost
export N8N_PROTOCOL=http

echo "🚀 Démarrage de N8N..."
n8n
