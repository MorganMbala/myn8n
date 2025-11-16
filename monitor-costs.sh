#!/bin/bash

# Script de monitoring des coûts pour forfait étudiant Azure
# À exécuter régulièrement pour surveiller votre budget de 100$

echo "💳 Monitoring des coûts - Forfait Étudiant Azure"
echo "================================================="
echo ""

# Vérifier la connexion
if ! az account show &> /dev/null; then
    echo "❌ Vous devez d'abord vous connecter avec: az login"
    exit 1
fi

# Afficher l'abonnement actuel
echo "📊 Abonnement actuel:"
az account show --query "{Name:name, ID:id}" -o table
echo ""

# Afficher les groupes de ressources et leurs coûts potentiels
echo "🏗️ Groupes de ressources actifs:"
az group list --query "[].{Name:name, Location:location}" -o table
echo ""

# Lister les containers Azure (ACI) actifs
echo "🐳 Containers Azure (ACI) actifs:"
if az container list --query "[].{Name:name, State:instanceView.state, ResourceGroup:resourceGroup, Location:location}" -o table 2>/dev/null; then
    echo ""
else
    echo "Aucun container trouvé ou erreur d'accès."
    echo ""
fi

# Conseils d'économie
echo "💡 CONSEILS D'ÉCONOMIE:"
echo "======================="
echo "1. 🛑 Arrêtez vos containers quand vous ne les utilisez pas:"
echo "   az container stop --name CONTAINER_NAME --resource-group RESOURCE_GROUP"
echo ""
echo "2. 🔄 Redémarrez-les seulement quand nécessaire:"
echo "   az container start --name CONTAINER_NAME --resource-group RESOURCE_GROUP"
echo ""
echo "3. 🗑️ Supprimez les ressources inutilisées:"
echo "   az group delete --name RESOURCE_GROUP --yes --no-wait"
echo ""
echo "4. 📈 Consultez vos coûts dans le portail Azure:"
echo "   https://portal.azure.com -> Cost Management + Billing"
echo ""
echo "5. 🚨 Configurez des alertes de budget:"
echo "   - Alerte à 60$ (60% du budget)"
echo "   - Alerte à 80$ (80% du budget)"
echo ""
echo "💰 Budget recommandé avec votre config:"
echo "   - Container N8N (0.5 CPU, 1GB): ~10-15$/mois"
echo "   - Marge de sécurité: Garder 20$ de crédit"
echo "   - Budget utilisable: 80$ sur vos 100$"
echo ""
echo "⚠️  Si vous approchez 75$ de consommation, arrêtez temporairement vos services!"
