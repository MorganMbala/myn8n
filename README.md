# MyN8N - Déploiement N8N sur Azure Cloud

Ce projet contient tout le nécessaire pour déployer N8N sur Microsoft Azure avec un forfait étudiant.

## 🎓 **Optimisé pour les étudiants**
- ✅ **Déploiement gratuit** avec Azure App Service F1
- ✅ **Budget 0€/mois** avec le tier gratuit
- ✅ **Scripts de monitoring** des coûts
- ✅ **Configuration sécurisée** pour l'apprentissage

## 🏗️ Options de déploiement

### Option 1: Azure Container Instances (Recommandé pour commencer)
- ✅ **Simple** et rapide à déployer
- ✅ **Moins cher** (pas de coûts fixes)
- ✅ **Parfait** pour les tests et développement
- ❌ Moins de fonctionnalités avancées

### Option 2: Azure App Service
- ✅ **Production ready** avec scaling automatique  
- ✅ **Domaine personnalisé** et SSL intégré
- ✅ **Monitoring** et diagnostics avancés
- ❌ Plus cher (coûts fixes)

## 🚀 Instructions de déploiement

### Prérequis
1. **Azure CLI** installé et configuré
2. **Compte Azure** avec un abonnement actif
3. **Permissions** pour créer des ressources

### Installation d'Azure CLI (si pas déjà fait)
```bash
# macOS
brew install azure-cli

# Connexion à Azure
az login
```

### Déploiement rapide (Container Instances)
```bash
# Lancer le déploiement ACI
./deploy-azure-aci.sh
```

### Déploiement production (App Service)
```bash
# Lancer le déploiement App Service
./deploy-azure.sh
```

## ⚙️ Configuration

### Configuration initiale
```bash
# Copier le fichier de configuration exemple
cp .env.example .env

# Modifier les variables selon vos besoins
# (Les valeurs par défaut fonctionnent pour la plupart des cas)
```

### Variables d'environnement importantes
- `N8N_ENCRYPTION_KEY`: Clé de chiffrement (générée automatiquement)
- `WEBHOOK_URL`: URL publique de votre instance N8N
- `N8N_SECURE_COOKIE=true`: Cookies sécurisés pour HTTPS

### Fichiers de configuration
- `.env`: Variables d'environnement locales
- `Dockerfile`: Image Docker personnalisée (optionnel)
- `docker-compose.yml`: Configuration pour développement local

## 🔧 Commandes utiles après déploiement

### Voir les logs
```bash
# Container Instances
az container logs --name n8n-container --resource-group n8n-aci-rg

# App Service  
az webapp log tail --name YOUR-APP-NAME --resource-group n8n-rg
```

### Redémarrer l'application
```bash
# Container Instances
az container restart --name n8n-container --resource-group n8n-aci-rg

# App Service
az webapp restart --name YOUR-APP-NAME --resource-group n8n-rg
```

### Supprimer les ressources
```bash
# Container Instances
az group delete --name n8n-aci-rg --yes --no-wait

# App Service
az group delete --name n8n-rg --yes --no-wait  
```

## 🔒 Sécurité

### Configuration recommandée pour production
- ✅ HTTPS activé (automatique sur Azure)
- ✅ Cookies sécurisés activés
- ✅ Variables d'environnement chiffrées
- ✅ Clé de chiffrement unique générée

### Première connexion
1. Ouvrir l'URL fournie après le déploiement
2. Créer votre compte administrateur
3. Configurer les authentifications nécessaires

## 💰 Coûts estimés

### Container Instances (ACI)
- ~5-15€/mois pour usage normal
- Facturation à l'usage (CPU/RAM/temps)

### App Service (B1)  
- ~15-25€/mois forfaitaire
- Inclut domaine, SSL, scaling

## 🆘 Dépannage

### Problème: Container ne démarre pas
```bash
# Vérifier les logs
az container logs --name n8n-container --resource-group n8n-aci-rg
```

### Problème: URL non accessible
- Vérifier que le port 5678 est exposé
- Attendre 2-3 minutes après le déploiement

### Problème: Erreur de cookies
- Vérifier que `N8N_PROTOCOL=https`
- Utiliser l'URL HTTPS fournie par Azure
