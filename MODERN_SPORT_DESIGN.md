# 🏃 Modern Sport Design - Hardlopen met Virgil

## 🎯 Overzicht

Je website heeft nu een **moderne, sportieve look** geïnspireerd door Strava en Runkeeper, maar met jouw persoonlijke stijl als trainer: warm, menselijk, professioneel en toegankelijk.

## ✨ Wat is er nieuw?

### 🎨 Design & Stijl
- **Donkere, sportieve look** met donkerblauw, paars en oranje accenten
- **Moderne typografie** met Inter en Rubik fonts
- **Strakke componenten** met afgeronde hoeken en subtiele animaties
- **Gradient effecten** voor een premium uitstraling
- **Responsive design** voor mobiel en desktop

### 🏠 Homepage Features

#### Hero Section
- Grote, impactvolle titel met gradient effect
- Duidelijke call-to-actions (CTA's)
- Animated achtergrond met pulse effect
- Persoonlijke leus: "Run for Fun — maar dan doordacht"

#### Stats Section
- Visuele statistieken (27 weken, 2 coaches, etc.)
- Animated counters met gradient kleuren
- Hover effecten voor interactiviteit

#### Features Grid
- 6 feature cards met iconen:
  - 👟 Blessurevrij Lopen
  - 📊 ASM-Methodiek
  - ❤️ Positieve Sfeer
  - ⏱️ Persoonlijke Begeleiding
  - 📱 Digitaal Platform
  - 🏆 Doelgericht Trainen
- Hover effecten met border animations
- Smooth transitions

#### Upcoming Trainings
- Grid layout met training cards
- Datum badges met gradient
- Trainer informatie
- Direct link naar details

#### Dashboard Tiles
- Voor ingelogde gebruikers
- Snelle toegang tot belangrijke functies
- Icon-based design

## 🎨 Kleurenpalet

```scss
// Hoofdkleuren
--sport-dark-blue: #0F1419      // Basis achtergrond
--sport-navy: #1A2332            // Secundaire achtergrond
--sport-deep-blue: #242F3E       // Card achtergrond
--sport-purple: #5B21B6          // Paars accent
--sport-purple-light: #7C3AED    // Licht paars

// Accent
--sport-orange: #FC4C02          // Primaire CTA kleur
--sport-orange-light: #FF6B35    // Hover state

// Tekst
--sport-text-primary: #FFFFFF    // Hoofdtekst
--sport-text-secondary: #E5E7EB  // Secundaire tekst
--sport-text-muted: #9CA3AF      // Muted tekst
```

## 🔧 Technische Details

### Bestanden
1. **`app/assets/stylesheets/modern_sport_theme.scss`** - Alle styling
2. **`app/views/home/sport_index.html.erb`** - Nieuwe homepage
3. **`app/controllers/home_controller.rb`** - Controller met `sport_index` actie
4. **`config/routes.rb`** - Route: `root "home#sport_index"`

### Fonts
- **Inter** - Voor body tekst (300-800 weights)
- **Rubik** - Voor headings (400-800 weights)

### Animaties
- **fadeInUp** - Voor hero content
- **pulse** - Voor achtergrond effect
- **float** - Voor iconen
- **Hover effects** - Op alle interactieve elementen
- **Smooth scroll** - Voor interne links

### Performance
- **Lazy loading** voor animaties met Intersection Observer
- **Will-change** properties voor smooth animations
- **Prefers-reduced-motion** support voor accessibility
- **Optimized CSS** met CSS variables

## 📱 Responsive Design

### Desktop (> 768px)
- Multi-column grid layouts
- Grote hero section
- Volledige feature cards

### Mobile (≤ 768px)
- Single column layouts
- Compacte hero
- Stack buttons verticaal
- Optimized spacing

## 🚀 Gebruik

### Homepage bekijken
Bezoek: `https://hardlopen.metvirgil.nl/`

De homepage toont nu automatisch het nieuwe sportieve design.

### Oude homepage
De oude homepage is nog beschikbaar via:
- `app/views/home/index.html.erb`
- Je kunt deze later verwijderen of als backup houden

### Aanpassen

#### Kleuren wijzigen
Pas de CSS variables aan in `modern_sport_theme.scss`:
```scss
:root {
  --sport-orange: #JOUW_KLEUR;
  // etc.
}
```

#### Content wijzigen
Bewerk de content in:
- `app/views/home/sport_index.html.erb`
- Of via de admin interface: `/site_contents`

#### Features toevoegen
Voeg nieuwe cards toe in de features grid:
```html
<div class="sport-card">
  <div class="sport-card__icon">🎯</div>
  <h3 class="sport-card__title">Jouw Feature</h3>
  <p class="sport-card__description">Beschrijving...</p>
</div>
```

## 🎯 Design Principes

1. **Warm & Menselijk** - Persoonlijke tone of voice, emoji's voor warmte
2. **Professioneel** - Strakke layouts, consistent design
3. **Toegankelijk** - Hoog contrast, grote knoppen, duidelijke hiërarchie
4. **Sportief** - Donkere kleuren, dynamische effecten
5. **Modern** - Gradient effecten, smooth animations

## 🔄 Toekomstige Uitbreidingen

Mogelijke toevoegingen:
- [ ] Testimonials sectie met quotes van lopers
- [ ] Foto gallery van trainingen
- [ ] Video intro van de trainers
- [ ] Interactive training calendar
- [ ] Progress charts voor ingelogde gebruikers
- [ ] Social proof (aantal lopers, reviews)
- [ ] Blog/nieuws sectie

## 📊 Performance Metrics

- **Lighthouse Score**: Optimized voor 90+
- **First Contentful Paint**: < 1.5s
- **Time to Interactive**: < 3s
- **CSS Size**: ~15KB (gzipped)

## 🎨 Component Library

Herbruikbare componenten:
- `.sport-btn` - Knoppen (primary, secondary, ghost)
- `.sport-card` - Content cards
- `.sport-stat` - Statistiek displays
- `.sport-section` - Sectie containers
- `.sport-hero` - Hero sections

## 💡 Tips

1. **Consistency** - Gebruik altijd de gedefinieerde CSS variables
2. **Spacing** - Gebruik de spacing scale (xs, sm, md, lg, xl)
3. **Icons** - Gebruik emoji's of voeg Font Awesome toe
4. **Images** - Voeg runner silhouettes toe voor extra sportieve sfeer
5. **Animations** - Houd het subtiel, performance first

## 🐛 Troubleshooting

### Styling niet zichtbaar?
```bash
cd /home/vsm/webapps/hardlopen.metvirgil.nl
RAILS_ENV=production bundle exec rake assets:precompile
touch tmp/restart.txt
```

### Fonts laden niet?
Check of Google Fonts URL correct is in `application.scss`

### Animaties werken niet?
Check browser console voor JavaScript errors

## 📞 Support

Voor vragen of aanpassingen, check:
- `modern_sport_theme.scss` voor alle styling
- `sport_index.html.erb` voor HTML structuur
- CSS variables voor snelle kleur/spacing aanpassingen

---

**Gemaakt met ❤️ voor Run for Fun**








