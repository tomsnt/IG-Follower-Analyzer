# 📦 Guida alla Distribuzione - Instagram Analyzer

## 🎯 Opzioni di Distribuzione

### 1. 🏆 **App Store Distribution** (Raccomandata)

#### Vantaggi:
- ✅ Installazione con un click per gli utenti
- ✅ Aggiornamenti automatici
- ✅ Fiducia massima (Apple vetting)
- ✅ Funziona su tutti i dispositivi Apple

#### Requisiti:
- Apple Developer Account ($99/anno)
- App deve passare App Store Review
- Tempo: 1-7 giorni per review

#### Step per App Store:
```bash
# 1. Configura il progetto per release
# In Xcode:
# - Product → Archive
# - Organizer → Distribute App
# - App Store Connect

# 2. Crea App Store Connect listing
# - Screenshots
# - Descrizione
# - Metadata
```

---

### 2. ⚡ **TestFlight Distribution** (Migliore per Beta)

#### Vantaggi:
- ✅ Facile da distribuire
- ✅ Fino a 10,000 beta tester
- ✅ Feedback integrato
- ✅ Stesso processo App Store ma più veloce

#### Come distribuire:
```bash
# 1. Archive in Xcode
# 2. Upload to App Store Connect
# 3. Crea TestFlight build
# 4. Invita tester via email o link pubblico
```

---

### 3. 🔧 **Direct Distribution** (Per utenti tecnici)

#### A. Distribuzione via GitHub Releases
```bash
# 1. Build release
xcodebuild -project "IG analizer.xcodeproj" \
           -scheme "IG analizer" \
           -configuration Release \
           -archivePath build/IG-Analyzer.xcarchive \
           archive

# 2. Export app
xcodebuild -exportArchive \
           -archivePath build/IG-Analyzer.xcarchive \
           -exportPath build/ \
           -exportOptionsPlist ExportOptions.plist

# 3. Crea DMG per macOS
create-dmg build/IG-Analyzer.app build/
```

#### B. Notarization per macOS (Necessaria)
```bash
# 1. Code signing
codesign --force --deep --sign "Developer ID Application: Your Name" IG-Analyzer.app

# 2. Notarization
xcrun notarytool submit IG-Analyzer.dmg \
                 --apple-id your-apple-id \
                 --password app-specific-password \
                 --team-id TEAM_ID

# 3. Staple notarization
xcrun stapler staple IG-Analyzer.dmg
```

---

### 4. 🌐 **Web App Alternative** (Cross-platform)

Trasforma l'app in una Progressive Web App:

#### Tecnologie:
- **React/Vue.js** per UI
- **File API** per drag & drop
- **IndexedDB** per storage locale
- **PWA** per installazione

#### Vantaggi:
- ✅ Funziona su tutti i sistemi operativi
- ✅ Nessun app store necessario
- ✅ Installabile come app nativa
- ✅ Aggiornamenti istantanei

---

## 🚀 **Raccomandazione per i Tuoi Amici**

### Opzione A: **TestFlight** (Più Facile)
```
1. Hai un Apple Developer Account? 
   ↳ Sì → TestFlight
   ↳ No → Opzione B

2. Upload su TestFlight
3. Condividi link pubblico con amici
4. Loro installano con un click
```

### Opzione B: **Web App** (Universal)
```
1. Converti a React/JavaScript
2. Deploy su Netlify/Vercel (gratis)
3. Condividi URL
4. Funziona ovunque (iOS, Android, Windows, Mac)
```

---

## 🛠️ **Setup per TestFlight (Passo-Passo)**

### 1. **Apple Developer Setup**
```bash
# Se non hai un account:
# 1. Vai su developer.apple.com
# 2. Iscriviti al Developer Program ($99/anno)
# 3. Verifica identità (1-2 giorni)
```

### 2. **Configura Xcode Project**
```swift
// In IG_analizerApp.swift, aggiungi:
.windowResizability(.contentSize)
.windowToolbarStyle(.unified(showsTitle: true))

// Verifica Bundle Identifier sia unico:
// com.tuonome.ig-analyzer
```

### 3. **Build e Upload**
```bash
# In Xcode:
# 1. Product → Archive
# 2. Window → Organizer
# 3. Distribute App → App Store Connect
# 4. Upload
```

### 4. **TestFlight Setup**
```
1. Vai su appstoreconnect.apple.com
2. My Apps → + → New App
3. TestFlight tab
4. Crea External Group
5. Copia link pubblico
6. Condividi con amici!
```

---

## 🌐 **Alternative: Web App Conversion**

Se preferisci evitare App Store:

### Tech Stack Consigliato:
```javascript
// Frontend: React + TypeScript
// Drag & Drop: react-dropzone
// File Parsing: DOMParser per HTML
// Storage: IndexedDB
// Build: Vite
// Deploy: Netlify (gratis)
```

### Vantaggi Web App:
- 🌍 **Universal**: iPhone, Android, Windows, Mac, Linux
- 💰 **Gratis**: No developer fees
- ⚡ **Istantaneo**: Condividi URL, pronto all'uso
- 🔄 **Auto-update**: Aggiornamenti trasparenti

---

## 📱 **File Necessari per Distribuzione**

### Per App Store/TestFlight:
```
- Info.plist configurato
- App Icons (tutti i formati)
- Privacy Usage Descriptions
- Code Signing Certificate
- Provisioning Profiles
```

### Per Direct Distribution:
```
- Notarization Certificate
- Developer ID Certificate
- Entitlements configurati
- DMG installer
```

### Per Web App:
```
- HTML5 File API implementation
- Service Worker per PWA
- Web App Manifest
- Icons per installazione
```
