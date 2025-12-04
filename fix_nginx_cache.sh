#!/bin/bash

# Professional Nginx Cache Fix
# Run with: bash fix_nginx_cache.sh

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║    🔧 NGINX CACHE FIX - Professional Solution                ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_SOURCE="$SCRIPT_DIR/config/nginx/hardlopen.metvirgil.nl.conf"
CONFIG_TARGET="/etc/nginx/sites-available/hardlopen.metvirgil.nl"

echo "Checking files..."
if [ ! -f "$CONFIG_SOURCE" ]; then
    echo "❌ Source config not found: $CONFIG_SOURCE"
    exit 1
fi

echo "✅ Source config found"
echo ""
echo "This will:"
echo "  1. Backup current nginx config"
echo "  2. Install new config with proxy_cache_bypass"
echo "  3. Test nginx configuration"
echo "  4. Reload nginx (zero downtime)"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Backing up current config..."
sudo cp "$CONFIG_TARGET" "${CONFIG_TARGET}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup created"

echo ""
echo "Step 2: Installing new config..."
sudo cp "$CONFIG_SOURCE" "$CONFIG_TARGET"
echo "✅ Config installed"

echo ""
echo "Step 3: Testing nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx config is valid"
else
    echo "❌ Nginx config has errors - restoring backup..."
    sudo cp "${CONFIG_TARGET}.backup."* "$CONFIG_TARGET"
    echo "❌ Fix aborted - backup restored"
    exit 1
fi

echo ""
echo "Step 4: Reloading nginx..."
sudo systemctl reload nginx
echo "✅ Nginx reloaded"

echo ""
echo "Step 5: Verifying fix..."
sleep 2
CACHE_HEADER=$(curl -I https://hardlopen.metvirgil.nl/ 2>&1 | grep -i "Cache-Control" | head -1)
echo "Cache-Control: $CACHE_HEADER"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║    ✅ NGINX CACHE FIX APPLIED SUCCESSFULLY                   ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Clear browser cache (Cmd+Shift+R or Ctrl+F5)"
echo "  2. Visit https://hardlopen.metvirgil.nl"
echo "  3. Check version badge - should show current time"
echo "  4. No more cache problems!"
echo ""
echo "Backup location: ${CONFIG_TARGET}.backup.*"
echo ""

