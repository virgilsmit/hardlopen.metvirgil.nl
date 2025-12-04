# Nginx Cache Fix - Professional Solution

## Problem

Nginx is caching HTML responses from the Rails application despite `Cache-Control: no-cache` headers. This causes users to see outdated content even after deployments.

**Root Cause**: Missing `proxy_cache_bypass` directives in nginx configuration.

## Solution

Apply the proper nginx configuration that respects Rails cache headers.

### Steps

```bash
# 1. Backup current configuration
sudo cp /etc/nginx/sites-enabled/hardlopen.metvirgil.nl /etc/nginx/sites-enabled/hardlopen.metvirgil.nl.backup

# 2. Apply new configuration
sudo cp config/nginx/hardlopen.metvirgil.nl.conf /etc/nginx/sites-enabled/hardlopen.metvirgil.nl

# 3. Test configuration
sudo nginx -t

# 4. Reload nginx (zero downtime)
sudo systemctl reload nginx

# 5. Verify fix
curl -I https://hardlopen.metvirgil.nl/ | grep Cache-Control
```

### What Changes

The key additions to `location /` block:

```nginx
proxy_cache_bypass $http_pragma $http_cache_control;
proxy_no_cache $http_cache_control;
proxy_buffering off;
proxy_pass_header Cache-Control;
```

**Effect**: 
- Nginx respects `Cache-Control` headers from Rails
- Dynamic content is never cached
- Static assets (JS/CSS/images) are still cached efficiently

### Verification

After applying the fix:

1. Clear browser cache
2. Visit https://hardlopen.metvirgil.nl
3. Check version badge - should match current server time
4. Make a change, restart Rails
5. Refresh browser - should see changes immediately

## Benefits

- ✅ **Professional**: Industry standard solution
- ✅ **Maintainable**: Clear configuration, well-documented
- ✅ **Performant**: Static assets still cached, only dynamic content fresh
- ✅ **Reliable**: No JavaScript hacks, works for all browsers
- ✅ **Future-proof**: Works with all future deployments

## Alternative (If No Sudo Access)

If you don't have sudo access, contact your system administrator with this file and ask them to apply the nginx configuration fix.

**Priority**: HIGH - This blocks deployments from being visible to users.

## Current Workaround

Until nginx is fixed, users must do a hard refresh after deployments:
- **Mac**: Cmd + Shift + R
- **Windows/Linux**: Ctrl + F5
- **Mobile**: Clear browser cache manually

This is a temporary workaround. The proper fix is to update nginx configuration.

