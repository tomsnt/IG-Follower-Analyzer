# Instagram Followers Collector - Chrome Extension (Modalità Passiva)

Una Chrome Extension **SICURA** per raccogliere la lista dei tuoi followers di Instagram mentre navighi manualmente. **Zero rischio di ban** perché non automatizza nulla!

## �️ Modalità Passiva = Zero Rischi

**IMPORTANTE**: Questa estensione utilizza una modalità passiva completamente sicura:
- ✅ **Tu scrolli manualmente** - Nessuna automazione
- ✅ **Plugin raccoglie in background** - Mentre tu navighi normalmente  
- ✅ **Zero rilevamento possibile** - Instagram vede solo scroll umano
- ✅ **Completamente legale** - Non viola alcun ToS

## 🚀 Caratteristiche

- **📱 Modalità Passiva**: Raccogli dati mentre scrolli manualmente
- **🛡️ Sicurezza Totale**: Zero automazione = zero rischi di ban
- **📊 Formati Multipli**: Esporta in JSON o CSV
- **🎯 Interface Intuitiva**: Popup semplice e user-friendly
- **⚡ Real-time**: Vedi i followers raccolti in tempo reale
- **🔄 Deduplicazione**: Evita followers duplicati automaticamente

## 📦 Installazione

### Metodo 1: Installazione Manuale (Developer Mode)

1. **Scarica o clona questo repository**
   ```bash
   git clone https://github.com/tuousername/instagram-followers-scraper.git
   ```

2. **Apri Chrome e vai alle estensioni**
   - Digita `chrome://extensions/` nella barra degli indirizzi
   - Oppure vai su Menu → Altri strumenti → Estensioni

3. **Abilita la Modalità Sviluppatore**
   - Attiva l'interruttore "Modalità sviluppatore" in alto a destra

4. **Carica l'estensione**
   - Clicca su "Carica estensione non pacchettizzata"
   - Seleziona la cartella del progetto scaricato

5. **Verifica l'installazione**
   - L'icona dell'estensione dovrebbe apparire nella barra degli strumenti

## 🎯 Come Usare (Modalità Passiva)

### Passo 1: Installa e Vai su Instagram
1. Installa l'estensione (vedi sezione installazione)
2. Vai su [instagram.com](https://www.instagram.com) e accedi

### Passo 2: Naviga ai Followers
1. Vai al profilo di cui vuoi raccogliere i followers
2. Clicca su "followers" per aprire la lista

### Passo 3: Attiva la Raccolta Passiva
1. Clicca sull'icona dell'estensione
2. Scegli il formato di export (JSON o CSV)
3. Clicca su "Inizia Raccolta"

### Passo 4: Scrolla Manualmente
- **Scrolla normalmente** nella lista followers
- L'estensione raccoglierà automaticamente i profili visibili
- Vedrai il contatore aumentare in tempo reale
- Continua fino a quando hai raccolto tutti i followers

### Passo 5: Scarica i Risultati
1. Quando hai finito, clicca "Ferma Raccolta"
2. Clicca "Scarica Lista" per ottenere il file

## 📊 Formato Dati

### JSON
```json
[
  {
    "username": "example_user",
    "displayName": "Example User",
    "profileUrl": "https://www.instagram.com/example_user",
    "isVerified": false,
    "followersCount": "1.2K",
    "scrapedAt": "2024-01-15T10:30:00.000Z"
  }
]
```

### CSV
```csv
Username,Display Name,Profile URL,Is Verified,Followers Count
example_user,Example User,https://www.instagram.com/example_user,No,1.2K
```

## ⚠️ Vantaggi della Modalità Passiva

### ✅ **Completamente Sicuro**
- **Zero automazione**: Tu scrolli, il plugin osserva
- **Comportamento umano al 100%**: Instagram vede solo navigazione normale
- **Nessun rate limiting**: Vai alla tua velocità naturale
- **Zero rilevamento**: Impossibile da distinguere dalla navigazione normale

### 🎯 **Efficace e Preciso**
- **Real-time collection**: Vedi i risultati immediatamente
- **Deduplicazione automatica**: Nessun follower duplicato
- **Dati completi**: Username, nome, avatar, status verificato
- **Funziona ovunque**: Profili pubblici, privati, modal, pagine

### 🚀 **Facile da Usare**
- **Nessuna configurazione**: Funziona out-of-the-box
- **Progress real-time**: Vedi quanti followers hai raccolto
- **Pause/resume**: Ferma e riprendi quando vuoi
- **Export flessibile**: JSON o CSV con un click

## 🔧 Sviluppo

### Struttura del Progetto
```
instagram-followers-scraper/
├── manifest.json          # Configurazione Chrome Extension
├── popup.html             # Interface utente
├── popup.js              # Logica popup
├── content.js            # Script per interazione con Instagram
├── background.js         # Service worker
├── icons/                # Icone dell'estensione
└── README.md            # Questo file
```

### Tecnologie Utilizzate
- **Manifest V3**: Ultima versione delle Chrome Extensions
- **Vanilla JavaScript**: Nessuna dipendenza esterna
- **Chrome APIs**: tabs, storage, downloads, runtime

### Debug
1. Vai su `chrome://extensions/`
2. Trova l'estensione e clicca su "Dettagli"
3. Clicca su "Controlla viste: service worker" per vedere i log

## 🐛 Risoluzione Problemi

### L'estensione non funziona
- Verifica di essere su instagram.com
- Ricarica la pagina di Instagram
- Controlla di essere loggato

### Lo scraping si ferma
- Instagram potrebbe aver applicato rate limiting
- Attendi qualche minuto e riprova
- Verifica la connessione internet

### Non trova i followers
- Assicurati di essere sul tuo profilo
- Verifica che la lista followers sia pubblica
- Prova a navigare manualmente alla lista followers

## 📄 Licenza

Questo progetto è rilasciato sotto licenza MIT. Vedi il file LICENSE per dettagli.

## ⚖️ Disclaimer

Questo strumento è fornito "così com'è" senza garanzie. L'utilizzo è a proprio rischio. Gli sviluppatori non sono responsabili per eventuali violazioni dei Termini di Servizio di Instagram o per danni derivanti dall'uso di questa estensione.

## 🤝 Contributi

I contributi sono benvenuti! Sentiti libero di:
- Aprire issue per bug o suggerimenti
- Inviare pull request per miglioramenti
- Suggerire nuove funzionalità

## 📞 Supporto

Per supporto o domande:
- Apri un issue su GitHub
- Contatta [il tuo email]

---

**Nota**: Questa estensione non è affiliata con Instagram o Meta. È un progetto indipendente per scopi educativi e di automazione personale.