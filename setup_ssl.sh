#!/bin/bash

DOMAIN="hardlopen.metvirgil.nl"
EMAIL="jouw@emailadres.nl" # ← vervang door je eigen e-mailadres

echo "🔐 Installeer Certbot + Nginx plugin..."
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

echo "🌐 Verkrijg en installeer SSL-certificaat voor $DOMAIN..."
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect

echo "✅ Certificaat geïnstalleerd. SSL is actief voor https://$DOMAIN"
