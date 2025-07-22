# Mobiele App Functionaliteit - Hardlopen met Virgil

Deze gids legt uit hoe je de nieuwe app-achtige functionaliteit kunt gebruiken om je website meer als een mobiele app te laten lijken.

## 🚀 Wat is er toegevoegd?

### 1. Progressive Web App (PWA)
- **Web App Manifest**: Maakt installatie mogelijk op mobiele apparaten
- **Service Worker**: Voor offline functionaliteit en caching
- **App-achtige meta tags**: Voor betere mobiele ervaring

### 2. App-achtige UI Componenten
- **Fixed Header**: Blijft bovenaan tijdens scrollen
- **Bottom Navigation**: Mobiele navigatie onderaan het scherm
- **App Cards**: Moderne kaart-achtige containers
- **Touch-friendly Buttons**: Grote, aanraak-vriendelijke knoppen
- **App Forms**: Styling voor formulieren

### 3. Mobiele Optimalisaties
- **Safe Area Support**: Voor notches en home indicators
- **Pull to Refresh**: Trek naar beneden om te vernieuwen
- **Touch Feedback**: Visuele feedback bij aanraking
- **Loading States**: App-achtige laadindicatoren

## 📱 Hoe te gebruiken

### Helper Methodes

```erb
<!-- App Card -->
<%= app_card do %>
  <h2>Titel</h2>
  <p>Inhoud</p>
<% end %>

<!-- App Button -->
<%= app_button "Klik hier", some_path %>

<!-- App List -->
<%= app_list do %>
  <%= app_list_item do %>
    <h3>Item 1</h3>
    <p>Beschrijving</p>
  <% end %>
<% end %>

<!-- App Form -->
<%= app_form_group do %>
  <%= app_form_label "Naam" %>
  <%= app_form_input "text", "name" %>
<% end %>
```

### CSS Classes

```html
<!-- App Card -->
<div class="app-card">
  <h2>Titel</h2>
  <p>Inhoud</p>
</div>

<!-- App Button -->
<a href="/path" class="app-btn">Klik hier</a>

<!-- App List -->
<div class="app-list">
  <div class="app-list-item">
    <h3>Item</h3>
  </div>
</div>

<!-- App Form -->
<div class="app-form-group">
  <label class="app-form-label">Label</label>
  <input type="text" class="app-form-input">
</div>
```

## 🎨 Customisatie

### Kleuren aanpassen
De app gebruikt CSS custom properties die je kunt aanpassen in `app/assets/stylesheets/theme.scss`:

```scss
:root {
  --color-primary: #448923;
  --color-bg: #f9fbfc;
  --color-bg-alt: #fff;
  --color-text: #222;
  --color-border: #e6e6e6;
}
```

### Dark Mode
De app ondersteunt automatisch dark mode via `prefers-color-scheme: dark`.

## 📋 Bestanden Overzicht

### Nieuwe Bestanden
- `public/manifest.json` - PWA manifest
- `public/sw.js` - Service Worker
- `app/assets/stylesheets/mobile_app.scss` - App styling
- `app/assets/javascripts/mobile_app.js` - App functionaliteit
- `app/helpers/application_helper.rb` - Helper methodes

### Aangepaste Bestanden
- `app/views/layouts/application.html.erb` - PWA meta tags en bottom nav
- `app/assets/stylesheets/application.scss` - Import van mobile_app

## 🔧 Installatie

1. **Assets precompileren**:
   ```bash
   RAILS_ENV=production bundle exec rake assets:precompile
   ```

2. **Server herstarten**:
   ```bash
   touch tmp/restart.txt
   ```

## 📱 PWA Installatie

Gebruikers kunnen de app installeren op hun mobiele apparaat:

1. **iOS Safari**: 
   - Tik op de deel-knop
   - Kies "Zet op beginscherm"

2. **Android Chrome**:
   - Tik op het menu (3 puntjes)
   - Kies "App installeren"

3. **Desktop Chrome**:
   - Klik op het installatie-icoon in de adresbalk

## 🎯 Best Practices

### Voor Views
- Gebruik `app-card` voor content containers
- Gebruik `app-btn` voor knoppen
- Gebruik `app-list` voor lijsten
- Houd content kort en bondig

### Voor Forms
- Gebruik `app-form-group` voor formulier secties
- Gebruik `app-form-label` voor labels
- Gebruik `app-form-input` voor input velden

### Voor Navigatie
- De bottom navigation verschijnt automatisch op mobiel
- Desktop menu blijft beschikbaar op grotere schermen

## 🐛 Troubleshooting

### Assets niet laden
```bash
RAILS_ENV=production bundle exec rake assets:clobber
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt
```

### Service Worker niet werken
- Controleer of HTTPS actief is (vereist voor service workers)
- Controleer browser console voor errors

### Styling niet correct
- Controleer of `mobile_app.scss` correct geïmporteerd is
- Controleer of assets geprecompileerd zijn

## 📞 Support

Voor vragen of problemen, neem contact op met de ontwikkelaar. 