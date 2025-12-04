# App Store Wrapper voor Hardlopen met Virgil

Deze folder bevat configuratie voor het publiceren van je PWA naar de App Store via een WebView wrapper.

## 🎯 Opties voor App Store Publicatie

### Optie 1: PWABuilder (Aanbevolen - Gratis)
**Website:** https://www.pwabuilder.com/

**Stappen:**
1. Ga naar https://www.pwabuilder.com/
2. Voer je URL in: `https://hardlopen.metvirgil.nl`
3. Klik "Start" en wacht op de analyse
4. Klik "Package for Stores"
5. Selecteer "iOS" en download het package
6. Upload naar App Store Connect

**Voordelen:**
- ✅ Gratis
- ✅ Automatische configuratie
- ✅ Ondersteunt iOS en Android
- ✅ Regelmatige updates

### Optie 2: Capacitor (Ionic)
**Website:** https://capacitorjs.com/

**Installatie:**
```bash
npm install -g @capacitor/cli
cd /home/vsm/webapps/hardlopen.metvirgil.nl/app-store-wrapper
npm init -y
npm install @capacitor/core @capacitor/cli @capacitor/ios
npx cap init "Run for Fun" "nl.metvirgil.hardlopen" --web-dir="../public"
npx cap add ios
```

**Configuratie (capacitor.config.json):**
```json
{
  "appId": "nl.metvirgil.hardlopen",
  "appName": "Run for Fun",
  "webDir": "../public",
  "server": {
    "url": "https://hardlopen.metvirgil.nl",
    "cleartext": false
  },
  "ios": {
    "contentInset": "automatic"
  }
}
```

**Build:**
```bash
npx cap sync
npx cap open ios
```

### Optie 3: Cordova
**Website:** https://cordova.apache.org/

**Installatie:**
```bash
npm install -g cordova
cd /home/vsm/webapps/hardlopen.metvirgil.nl/app-store-wrapper
cordova create RunForFun nl.metvirgil.hardlopen "Run for Fun"
cd RunForFun
cordova platform add ios
```

**Config.xml aanpassingen:**
```xml
<content src="https://hardlopen.metvirgil.nl" />
<allow-navigation href="https://hardlopen.metvirgil.nl/*" />
```

## 📋 Vereisten voor App Store

### Apple Developer Account
- Kosten: €99/jaar
- Aanmelden: https://developer.apple.com/

### App Store Connect Informatie
Bereid deze informatie voor:

**App Metadata:**
- **App Naam:** Run for Fun - Hardlopen met Virgil
- **Subtitle:** Blessurevrij hardlopen met ASM-methode
- **Categorie:** Health & Fitness
- **Trefwoorden:** hardlopen, training, loopgroep, ASM, fitness
- **Support URL:** https://hardlopen.metvirgil.nl
- **Privacy Policy URL:** [nog aan te maken]

**Screenshots Vereist:**
- iPhone 6.7" (1290 x 2796)
- iPhone 6.5" (1242 x 2688)
- iPhone 5.5" (1242 x 2208)
- iPad Pro 12.9" (2048 x 2732)

**App Icon:**
- 1024x1024 PNG (zonder alpha channel)
- Geen afgeronde hoeken (Apple doet dit automatisch)

## 🚀 Snelste Route naar App Store

### Aanbevolen Workflow:

1. **Test PWA eerst goed**
   ```bash
   # Bezoek op mobiel:
   https://hardlopen.metvirgil.nl/pwa-test.html
   ```

2. **Gebruik PWABuilder**
   - Ga naar https://www.pwabuilder.com/
   - Voer URL in
   - Download iOS package
   - Upload naar App Store Connect

3. **Screenshots maken**
   - Open app op iPhone
   - Maak screenshots van belangrijkste schermen:
     * Home/Dashboard
     * Trainingsschema
     * Presentielijst
     * Profiel/Zones
     * Training details

4. **Privacy Policy**
   - Maak een simpele privacy policy pagina
   - Plaats op: https://hardlopen.metvirgil.nl/privacy
   - Verplicht voor App Store

## 📱 Test Checklist

Voor je submit naar App Store:

- [ ] PWA werkt perfect op https://hardlopen.metvirgil.nl
- [ ] Service Worker geregistreerd en werkend
- [ ] Manifest.json valide
- [ ] Alle iconen aanwezig (192x192, 512x512, 1024x1024)
- [ ] Offline pagina werkt
- [ ] App installeerbaar via "Add to Home Screen"
- [ ] Geen console errors
- [ ] Privacy policy pagina gemaakt
- [ ] Screenshots gemaakt (alle formaten)
- [ ] App icon 1024x1024 klaar
- [ ] Apple Developer account actief
- [ ] App Store Connect account aangemaakt

## 🔗 Nuttige Links

- PWA Checklist: https://web.dev/pwa-checklist/
- PWABuilder: https://www.pwabuilder.com/
- Capacitor Docs: https://capacitorjs.com/docs
- App Store Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Icon Generator: https://realfavicongenerator.net/

## 💡 Tips

1. **Start met PWABuilder** - dit is de snelste en makkelijkste optie
2. **Test grondig** op verschillende iOS versies voordat je submit
3. **Privacy Policy** is verplicht - maak een simpele pagina
4. **Screenshots** zijn belangrijk - maak ze aantrekkelijk
5. **Review proces** duurt 1-3 dagen, bereid je voor op mogelijk feedback

## ⚠️ Belangrijke Opmerkingen

- Apple's review proces is streng
- WebView apps moeten "significant value" toevoegen
- Zorg dat je app goed werkt offline (basis functionaliteit)
- Push notifications vereisen native code (niet mogelijk met pure WebView)
- In-app purchases vereisen Apple's systeem (30% commissie)


