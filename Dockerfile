# Dockerfile pour N8N sur Azure
FROM n8nio/n8n:latest

# Définir les variables d'environnement par défaut
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV WEBHOOK_URL=https://your-app-name.azurewebsites.net/

# Créer le répertoire pour les données
USER root
RUN mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

# Revenir à l'utilisateur node
USER node

# Exposer le port
EXPOSE 5678

# Commande de démarrage
CMD ["n8n", "start"]
