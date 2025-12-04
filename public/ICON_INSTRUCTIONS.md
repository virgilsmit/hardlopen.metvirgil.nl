# PWA Iconen Instructies

## ⚠️ Actie Vereist: PWA Iconen Genereren

De PWA werkt nu, maar heeft nog echte PNG iconen nodig voor optimale weergave.

### Optie 1: Online Tool (Makkelijkst)
1. Ga naar: https://realfavicongenerator.net/
2. Upload je logo: `/app/assets/images/RunForFun-zwart.svg` of `.jpg`
3. Selecteer "Web App Manifest" settings
4. Download de gegenereerde iconen
5. Upload deze bestanden naar `/public/`:
   - `icon-192x192.png`
   - `icon-512x512.png`
   - `apple-touch-icon.png` (180x180)
   - `favicon.ico`

### Optie 2: Handmatig met Image Editor
Open je logo in GIMP, Photoshop, of Paint.NET:

1. **icon-192x192.png**
   - Resize naar 192x192 pixels
   - Voeg oranje achtergrond toe (#FC4C02)
   - Export als PNG
   
2. **icon-512x512.png**
   - Resize naar 512x512 pixels
   - Voeg oranje achtergrond toe (#FC4C02)
   - Export als PNG

3. **apple-touch-icon.png**
   - Resize naar 180x180 pixels
   - Voeg oranje achtergrond toe (#FC4C02)
   - Export als PNG

### Optie 3: HTML Generator
1. Bezoek: https://hardlopen.metvirgil.nl/generate-icons.html
2. Klik "Genereer Alle Iconen"
3. Download elke icoon
4. Hernoem correct en upload naar `/public/`

### Verwachte Bestanden in /public/:
```
/public/
  ├── icon-192x192.png   (192x192, any)
  ├── icon-512x512.png   (512x512, any)
  ├── apple-touch-icon.png (180x180)
  └── favicon.ico        (32x32)
```

### Na Upload:
1. Restart server: `touch tmp/restart.txt`
2. Test PWA: Chrome DevTools → Application → Manifest
3. Test installatie op mobiel

## Huidige Status
✅ Manifest.json geconfigureerd
✅ Service Worker actief
⚠️ Iconen zijn tijdelijke SVG placeholders
❌ PNG iconen nog niet gegenereerd

## Kleuren voor Iconen
- Primary: #FC4C02 (oranje)
- Gradient: #FC4C02 → #FF6B35
- Text: white (#FFFFFF)


