# 🎨 Styling Workflow & Cache Preventie

## 📋 Wat Ging Er Mis?

### Root Causes van de Styling Problemen:

1. **PWA Service Worker Cache** (Grootste probleem!)
   - Service Worker cachte CSS "Cache First"
   - Oude CSS werd altijd geserveerd
   - Nieuwe CSS pas na 2e page load actief
   - PWA heeft eigen cache los van browser

2. **CSS Specificity Conflicts**
   - `mobile_sport_app.scss` had `color: var(--sport-text-secondary)` (lichtgrijs)
   - Deze regel overschreef alle andere CSS
   - Meerdere CSS files probeerden hetzelfde element te stylen

3. **Browser Cache Layers**
   - Browser cache
   - Service Worker cache
   - PWA app cache
   - Asset pipeline cache

4. **CSS Classes vs Inline Styles**
   - External CSS kon worden ge-cached
   - Classes hadden lagere priority
   - Inline styles werkten wel, maar werden overschreven door CSS

---

## ✅ De Oplossing (Wat Nu Werkt)

### 1. Pure Inline HTML Styling
```html
<!-- GOED: Kan niet worden ge-cached -->
<a style="color: #f7fbff; font-weight: 500;">Text</a>

<!-- SLECHT: Wordt ge-cached -->
<a class="menu-item">Text</a>
```

### 2. Service Worker v3.0 - Network First voor CSS
```javascript
// CSS: Altijd vers van server
if (url.pathname.match(/\.css$/)) {
  fetch first → cache → fallback bij offline
}

// JS/Images: Cache first (snelheid)
if (url.pathname.match(/\.js|\.png/)) {
  cache first → network als backup
}
```

### 3. Inline Style Tags in HTML
```html
<div id="component">
  <style>
    #component .item { color: #fff !important; }
  </style>
  <!-- Component HTML -->
</div>
```

---

## 🚀 Workflow Voor Toekomstige Styling Wijzigingen

### STAP 1: Development Mode

**Tijdelijk Service Worker uitschakelen tijdens development:**

```ruby
# In app/views/layouts/application.html.erb
<% if Rails.env.development? %>
  <!-- Service Worker DISABLED in development -->
  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(regs => {
        regs.forEach(reg => reg.unregister());
      });
    }
  </script>
<% end %>
```

### STAP 2: Styling Wijzigen

**Kies de juiste methode:**

1. **Voor kritieke UI (menu's, navigation):**
   → **Inline HTML styles** (kan niet worden ge-cached)

2. **Voor algemene styling:**
   → SCSS files aanpassen
   → Assets precompilen
   → Service Worker cache invalideren

3. **Voor kleine tweaks:**
   → Inline `<style>` tag in view
   → ID selectors gebruiken (#id heeft hoogste specificity)

### STAP 3: Assets Compileren

```bash
# Volledige rebuild
RAILS_ENV=production bundle exec rake assets:clobber
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt
```

### STAP 4: Cache Invalidatie

**Voor PWA:**
1. Service Worker versie verhogen in `sw.js`
2. Manifest versie verhogen in `manifest.json`
3. HTML `?v=timestamp` parameter toevoegen

**Voor Browser:**
1. Hard refresh: `Cmd + Shift + R`
2. Of cache clear tool gebruiken

### STAP 5: Testen

**Test Matrix:**
- [ ] Desktop Chrome (hard refresh)
- [ ] Desktop Safari (empty cache + refresh)
- [ ] Mobile Browser (Safari/Chrome)
- [ ] Mobile PWA (refresh + reopen)

---

## 🛠️ Tools & Scripts

### 1. Quick Styling Test Script

```bash
# test_styling.sh
cd /home/vsm/webapps/hardlopen.metvirgil.nl

echo "🎨 Styling Update Workflow"
echo ""

# 1. Precompile assets
echo "1. Recompiling assets..."
RAILS_ENV=production bundle exec rake assets:precompile

# 2. Restart server
echo "2. Restarting server..."
touch tmp/restart.txt

# 3. Check CSS hash
echo "3. New CSS hash:"
ls -t public/assets/application-*.css | head -1 | xargs basename

echo ""
echo "✅ Done! Test in browser (hard refresh)"
echo ""
echo "For PWA: Verhoog Service Worker versie in sw.js"
```

### 2. Cache Debug Tool

Al aanwezig:
- `/clear-sw-cache.html` - Clear alle caches
- `/mobile-menu-debug.html` - Visual comparison
- `/contrast-checker.html` - WCAG validation

### 3. Quick Cache Clear Command

```bash
# clear_all_caches.sh
rm -rf tmp/cache/*
rm -rf public/assets/*
RAILS_ENV=production bundle exec rake assets:clobber
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt
echo "✅ All caches cleared and assets rebuilt"
```

---

## 📐 CSS Architecture Best Practices

### Layer Order (Specificity):

```scss
// 1. Base variables (lowest priority)
@import 'contrast-system';

// 2. Theme defaults
@import 'theme';

// 3. Component styles
@import 'mobile_sport_app';

// 4. Override layers
@import 'wcag-compliance-overrides';

// 5. Ultra high contrast (highest priority)
@import 'ultra-high-contrast';
```

### Specificity Rules:

```scss
// LAAG (vermijd voor kritieke UI)
.menu-item { }

// MEDIUM
.mobile-menu .menu-item { }

// HOOG
#mobile-menu .menu-item { }

// HOOGST (gebruik voor fixes)
[id="mobile-menu"] .menu-item { }

// ULTIMATE (inline)
<a style="..."> (altijd hoogste priority)
```

### !important Usage:

```scss
// ALLEEN gebruiken voor:
// 1. Cache-override fixes
// 2. Third-party CSS overrides
// 3. Kritieke accessibility (contrast)

.menu-item {
  color: #f7fbff !important;  // ✓ Cache override
  font-weight: 500 !important; // ✓ Accessibility
}
```

---

## 🚨 Voorkomen van Cache Problemen

### 1. Development Environment

```ruby
# config/environments/development.rb
config.consider_all_requests_local = true
config.action_controller.perform_caching = false

# Disable Service Worker in development
```

### 2. Service Worker Strategie

```javascript
// sw.js - Best Practice

// CSS: Network First (always fresh)
if (url.endsWith('.css')) {
  return fetch(request)
    .then(response => {
      cache.put(request, response.clone());
      return response;
    })
    .catch(() => cache.match(request));
}

// JS: Cache First (performance)
if (url.endsWith('.js')) {
  return cache.match(request) || fetch(request);
}
```

### 3. Cache Busting

```erb
<!-- In layout -->
<%= stylesheet_link_tag "application", 
  "data-turbo-track": "reload",
  "data-version": "<%= Rails.application.config.assets.version %>"
%>
```

### 4. Manifest Versioning

```json
{
  "name": "App Name",
  "version": "3.0",  // ← Verhoog bij elke grote update
  "start_url": "/?v=3.0"  // ← Force nieuwe sessie
}
```

---

## 📝 Checklist Voor Styling Changes

### Voor ELKE styling wijziging:

- [ ] **1. Bepaal scope**
  - Kritieke UI? → Inline HTML styles
  - Algemeen? → SCSS file

- [ ] **2. Wijzig code**
  - SCSS aanpassen
  - Of inline styles toevoegen

- [ ] **3. Compile assets**
  ```bash
  RAILS_ENV=production rake assets:precompile
  touch tmp/restart.txt
  ```

- [ ] **4. Test in browser EERST**
  - Hard refresh (`Cmd + Shift + R`)
  - Check of wijziging zichtbaar is

- [ ] **5. Als het werkt in browser maar niet in PWA:**
  - Service Worker versie verhogen
  - Manifest versie verhogen
  - PWA opnieuw installeren

- [ ] **6. Test matrix**
  - Desktop Chrome ✓
  - Desktop Safari ✓
  - Mobile Browser ✓
  - Mobile PWA ✓

---

## 🎯 Quick Reference

### Snelle Styling Fix:

```bash
# Voor kritieke UI changes
1. Edit inline styles in HTML view
2. touch tmp/restart.txt
3. Test in browser (no cache)
4. Re-install PWA if needed
```

### Normale Styling Change:

```bash
# Voor algemene styling
1. Edit SCSS file
2. rake assets:precompile
3. touch tmp/restart.txt
4. Hard refresh browser
5. Test PWA (may need reinstall)
```

### Emergency Cache Clear:

```bash
# Nuclear option
rm -rf tmp/cache/* public/assets/*
RAILS_ENV=production rake assets:clobber
RAILS_ENV=production rake assets:precompile
touch tmp/restart.txt

# In PWA: De-install & Re-install
```

---

## 🔧 Recommended Changes Voor Production

### 1. Development vs Production Service Worker

```javascript
// sw.js
const CACHE_STRATEGY = {
  css: 'network-first',  // Always fresh CSS
  js: 'cache-first',     // Fast loading
  html: 'network-first', // Fresh content
  images: 'cache-first'  // Performance
};
```

### 2. Inline Styles Voor Kritieke UI

**Altijd inline styles gebruiken voor:**
- ✅ Navigation menus
- ✅ Headers
- ✅ Critical buttons
- ✅ Error messages
- ✅ Forms

### 3. Asset Versioning

```ruby
# config/initializers/assets.rb
Rails.application.config.assets.version = '3.0'

# Verhoog dit nummer bij breaking CSS changes
```

### 4. Cache Headers

```ruby
# config/environments/production.rb
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000',
  'Expires' => 1.year.from_now.httpdate
}

# Maar NIET voor HTML!
```

---

## 📚 Lessons Learned

### Wat We Geleerd Hebben:

1. **PWA Service Worker is krachtig maar gevaarlijk**
   - Cacht agressief
   - Moeilijk te invalideren
   - Test altijd in PWA én browser

2. **Inline styles zijn de veiligste optie**
   - Kunnen niet worden ge-cached (zitten in HTML)
   - Hoogste specificity
   - Geen external dependencies

3. **CSS specificity matters**
   - Later geladen CSS wint
   - Meer specifieke selectors winnen
   - `!important` als laatste redmiddel

4. **Test early, test often**
   - Test in alle browsers/platforms
   - PWA is een aparte test case
   - Cache clear tools zijn essentieel

---

## 🎉 Samenvatting

### Voor Styling Changes:

**SIMPEL (Aanbevolen):**
```
1. Inline HTML styles gebruiken
2. touch tmp/restart.txt
3. Test in browser
4. PWA opnieuw installeren als nodig
```

**COMPLEX (Alleen als echt nodig):**
```
1. SCSS aanpassen
2. Assets precompilen
3. Service Worker versie verhogen
4. Test overal
5. PWA cache invalideren
```

### Cache Problemen Oplossen:

**Snelst:**
```
/clear-sw-cache.html → Clear alles → Refresh
```

**Definitief:**
```
PWA de-installeren → Browser test → PWA opnieuw installeren
```

---

## 🚀 Aanbevelingen Voor Toekomst

1. **Gebruik inline styles voor kritieke UI**
2. **Test in browser VOOR je PWA test**
3. **Service Worker: Network First voor CSS**
4. **Verhoog versie nummers bij breaking changes**
5. **Gebruik debug tools (/clear-sw-cache.html)**
6. **Document elke CSS change**

---

**Met deze workflow zou elke styling change max 2 minuten moeten duren!** 🎉

