# Professional solution for nginx proxy cache
# 
# Problem: Nginx proxy is caching HTML responses despite no-cache headers
# Root cause: Missing proxy_cache_bypass configuration in nginx
#
# This file documents the proper fix that needs to be applied to nginx config:
#
# File: /etc/nginx/sites-enabled/hardlopen.metvirgil.nl
# 
# Add to location / block:
#   proxy_cache_bypass $http_pragma $http_cache_control;
#   proxy_no_cache $http_cache_control;
#
# Then reload: sudo systemctl reload nginx
#
# Until nginx config is fixed, users must use hard refresh (Cmd+Shift+R / Ctrl+F5)
# after deployments to see changes.

Rails.application.config.action_dispatch.default_headers.merge!({
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
  'X-Content-Type-Options' => 'nosniff',
  'X-Download-Options' => 'noopen',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
})

