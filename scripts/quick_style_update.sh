#!/bin/bash

# Quick Styling Update Script
# Gebruik: ./scripts/quick_style_update.sh

cd /home/vsm/webapps/hardlopen.metvirgil.nl

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║           🎨 QUICK STYLING UPDATE WORKFLOW 🎨             ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "1️⃣ Cleaning old assets..."
rm -rf tmp/cache/*
RAILS_ENV=production bundle exec rake assets:clobber > /dev/null 2>&1

echo "2️⃣ Recompiling assets..."
RAILS_ENV=production bundle exec rake assets:precompile > /dev/null 2>&1

echo "3️⃣ Restarting server..."
touch tmp/restart.txt

echo "4️⃣ New CSS hash:"
ls -t public/assets/application-*.css | head -1 | xargs basename

echo ""
echo "✅ DONE!"
echo ""
echo "📱 Test Nu:"
echo "  Browser: Hard refresh (Cmd + Shift + R)"
echo "  PWA: Pull down om te refreshen"
echo ""
echo "Als PWA niet werkt:"
echo "  → https://hardlopen.metvirgil.nl/clear-sw-cache.html"
echo "  → Of PWA opnieuw installeren"
echo ""

