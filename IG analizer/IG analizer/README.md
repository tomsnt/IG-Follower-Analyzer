# 📱 Instagram Follower Analyzer

Un ecosistema completo per analizzare i tuoi dati di Instagram con **massima privacy e sicurezza**. Include sia un'app nativa per macOS/iOS che un'estensione Chrome per la raccolta sicura dei dati.

## 🌟 Caratteristiche Principali

- 📊 **Analisi Completa**: Follow/Following, confronti temporali, growth tracking
- 🛡️ **Privacy Totale**: Elaborazione locale, zero invii a server esterni
- 🎯 **Doppio Metodo**: App nativa + Chrome Extension per massima flessibilità
- ⚡ **Performance**: Interfaccia nativa Swift per macOS/iOS
- 🔒 **Sicurezza**: Chrome Extension in modalità passiva (zero rischi di ban)

---

## 🚀 Installazione e Setup

### Opzione 1: App Nativa (Raccomandata)
```bash
# Clona il repository
git clone https://github.com/tuousername/IG-Follower-Analyzer.git
cd IG-Follower-Analyzer

# Compila con Xcode
open "IG analizer.xcodeproj"
```

### Opzione 2: Chrome Extension
1. Vai a `chrome://extensions/`
2. Attiva "Modalità sviluppatore"
3. Carica la cartella `Instragram follower scraper/`

---

## 📖 Metodi di Raccolta Dati

### 🏆 Metodo 1: Export Ufficiale Instagram (Più Sicuro)

**Vantaggi**: 100% sicuro, dati completi, nessun rischio
**Tempi**: 1-3 giorni per ricevere i dati

#### Procedura:
1. **Richiedi Export**:
   - Vai su Instagram Web → Impostazioni → Privacy e sicurezza
   - Clicca "Scarica i tuoi dati"
   - Seleziona formato **HTML**
   - Attendi email di conferma

2. **Estrai i File**:
   ```
   instagram-data.zip
   └── connections/
       └── followers_and_following/
           ├── followers_1.html    ← I tuoi followers
           ├── following.html      ← Chi segui
           └── ...
   ```

3. **Carica nell'App**:
   - Apri l'app nativa
   - Tab "File Upload" → Trascina i file HTML
   - L'app parsifica automaticamente i dati

### ⚡ Metodo 2: Chrome Extension (Più Veloce)

**Vantaggi**: Istantaneo, modalità passiva sicura
**Limiti**: Richiede scroll manuale

#### Procedura:
1. **Installa Extension**:
   - Carica la cartella `Instragram follower scraper/` in Chrome
   - Vai su instagram.com e accedi

2. **Raccogli Dati (Modalità Passiva)**:
   - Vai alla lista followers di un profilo
   - Clicca l'icona dell'extension
   - Clicca "Inizia Raccolta"
   - **Scrolla manualmente** la lista
   - L'extension raccoglie automaticamente i profili visibili

3. **Export e Import**:
   - Scarica JSON/CSV dall'extension
   - Importa nell'app nativa per analisi avanzate

---

## 🎯 Utilizzo dell'App

### Interface Overview
L'app è organizzata in 3 tab principali:

#### 📂 Tab 1: File Upload
- **Area Followers**: Carica file con i tuoi followers
- **Area Following**: Carica file con chi segui
- **Area Confronto**: File precedenti per analisi temporali
- **Riassunto**: Statistiche sui dati caricati

#### 📊 Tab 2: Analisi Follow
```
🔴 Non ti seguono indietro    🟠 Non ricambi il follow
🟢 Follow mutui             ⚪ Statistiche generali
```

#### 📈 Tab 3: Confronto Temporale
- **Crescita/Perdita**: Chi hai guadagnato/perso
- **Timeline**: Analisi cronologica dei cambiamenti
- **Trends**: Grafici di crescita

### Esempi Pratici d'Uso

#### 🧹 Scenario: Pulizia Following
**Obiettivo**: Ridurre gli account che segui ma che non ricambiano

1. Carica `followers.html` e `following.html`
2. Tab "Analisi Follow" → Sezione "Non ti seguono"
3. Scorri la lista e decidi chi smettere di seguire
4. Click sui link per andare direttamente ai profili Instagram

#### 📈 Scenario: Growth Monitoring
**Obiettivo**: Monitorare la crescita del tuo account

1. Carica file followers attuale + file di 1 mese fa
2. Tab "Confronto Temporale"
3. Analizza "Nuovi Followers" e "Followers Persi"
4. Identifica pattern di crescita

#### 🎯 Scenario: Engagement Strategy
**Obiettivo**: Aumentare l'engagement reciproco

1. Tab "Analisi Follow" → "Non segui"
2. Considera di seguire questi account
3. Usa i link diretti per visitare i profili
4. Segui account rilevanti per il tuo settore

---

## 🔧 Formati Dati Supportati

### Input Formats
```html
<!-- HTML Instagram Export -->
<a href="https://www.instagram.com/username">Display Name</a>

<!-- JSON da Chrome Extension -->
{
  "username": "example_user",
  "displayName": "Example User", 
  "profileUrl": "https://www.instagram.com/example_user",
  "isVerified": false,
  "scrapedAt": "2024-10-17T10:30:00.000Z"
}

<!-- CSV Export -->
Username,Display Name,Profile URL,Is Verified
example_user,Example User,https://www.instagram.com/example_user,No
```

### Output Features
- **Link Diretti**: Click per aprire profili Instagram
- **Export Data**: Copia liste per uso esterno
- **Statistiche**: Contatori e percentuali automatiche
- **Cronologia**: Salvataggio automatico per confronti futuri

---

## 🛡️ Privacy e Sicurezza

### 🔒 App Nativa
- ✅ **Elaborazione locale**: Tutti i dati restano sul tuo dispositivo
- ✅ **Zero tracking**: Nessuna analisi o invio dati
- ✅ **Sandboxing**: App isolata dal sistema
- ✅ **Crittografia**: Dati salvati in modo sicuro

### 🛡️ Chrome Extension
- ✅ **Modalità passiva**: Tu scrolli, l'extension osserva
- ✅ **Zero automazione**: Comportamento 100% umano
- ✅ **Nessun rate limiting**: Vai alla tua velocità
- ✅ **Impossibile da rilevare**: Instagram vede solo navigazione normale

### ⚠️ Confronto Sicurezza

| Metodo | Sicurezza | Velocità | Completezza | Facilità |
|--------|-----------|----------|-------------|----------|
| Export Ufficiale | 🟢 100% | 🟡 1-3 giorni | 🟢 Completo | 🟢 Facile |
| Chrome Extension | 🟢 99% | 🟢 Istantaneo | 🟡 Manuale | 🟠 Moderata |

---

## 🔧 Sviluppo e Contributi

### Struttura Progetto
```
IG-Follower-Analyzer/
├── IG analizer/                 # App nativa Swift
│   ├── ContentView.swift        # Interface principale
│   ├── Models/                  # Data models
│   ├── Services/               # HTML parsing, file management
│   ├── ViewModels/             # Business logic
│   └── Views/                  # UI components
├── Instragram follower scraper/ # Chrome Extension
│   ├── manifest.json           # Extension config
│   ├── popup.html/js           # UI extension
│   ├── content.js              # Instagram interaction
│   └── background.js           # Service worker
└── Documentazione/             # README, guides
```

### Tech Stack
- **App**: SwiftUI, macOS 12.0+, iOS 15.0+
- **Extension**: Manifest V3, Vanilla JavaScript
- **Parsing**: HTML regex, JSON handling
- **Storage**: UserDefaults, Chrome Storage API

### Contributing
```bash
# Fork e clona
git clone https://github.com/tuousername/IG-Follower-Analyzer.git

# Crea branch feature
git checkout -b feature/nuova-funzionalita

# Sviluppa e testa
# ...

# Push e crea PR
git push origin feature/nuova-funzionalita
```

---

## 🐛 Troubleshooting

### App Nativa

**❌ File non riconosciuto**
- ✅ Verifica formato HTML con struttura Instagram
- ✅ Controlla che i link contengano `instagram.com/username`
- ✅ Re-esporta da Instagram se necessario

**❌ Performance lente**
- ✅ File grandi (>10k followers) richiedono tempo
- ✅ Chiudi altre app durante elaborazione
- ✅ L'app mostra progress bar per operazioni lunghe

**❌ Dati incompleti**
- ✅ Instagram divide file grandi (followers_1.html, followers_2.html)
- ✅ Carica tutti i file separatamente
- ✅ Account privati potrebbero non essere nell'export

### Chrome Extension

**❌ Extension non funziona**
- ✅ Verifica di essere su instagram.com
- ✅ Ricarica pagina Instagram
- ✅ Controlla di essere loggato

**❌ Raccolta si ferma**
- ✅ Instagram potrebbe limitare richieste
- ✅ Attendi qualche minuto
- ✅ Scrolla più lentamente

**❌ Popup non si apre**
- ✅ Clicca destro sull'icona → "Controlla"
- ✅ Verifica permessi extension
- ✅ Ricarica extension da chrome://extensions/

---

## 📄 Licenza e Disclaimer

### Licenza
Questo progetto è rilasciato sotto **licenza MIT**. Vedi file LICENSE per dettagli.

### ⚖️ Disclaimer Legale
- Strumento fornito "così com'è" senza garanzie
- Utilizzo a proprio rischio e responsabilità
- Non affiliato con Instagram/Meta
- Rispetta sempre i Terms of Service di Instagram
- Per scopi educativi e di automazione personale

### 🤝 Supporto e Community
- 🐛 **Bug Reports**: Apri issue su GitHub
- 💡 **Feature Requests**: Discussioni nella sezione Issues
- 📧 **Supporto**: [il-tuo-email@example.com]
- 📖 **Wiki**: Documentazione estesa su GitHub Wiki

---

**🎯 Developed with ❤️ for Instagram power users who value privacy and control over their data.**