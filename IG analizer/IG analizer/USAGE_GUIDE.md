# Guida Dettagliata - Instagram Analyzer

## Panoramica dell'App

Instagram Analyzer è un'applicazione per macOS/iOS che ti permette di:

1. **Analizzare i rapporti di follow** - Scopri chi segui ma non ti segue indietro
2. **Monitorare i cambiamenti dei followers** - Confronta diversi export per vedere chi hai guadagnato/perso
3. **Gestire i tuoi social** - Prendi decisioni informate su chi seguire/smettere di seguire

## Interfaccia dell'App

### Tab 1: File Upload
- **Area Followers**: Carica i tuoi file followers (followers_1.html)
- **Area Following**: Carica i file delle persone che segui (following.html)  
- **Area Confronto**: Carica file followers precedenti per analisi temporali
- **Riassunto**: Mostra quanti dati sono stati caricati

### Tab 2: Analisi Follow
- **Carte Riassuntive**: Statistiche rapide sui tuoi rapporti di follow
- **Non ti seguono**: Lista dettagliata di chi non ricambia il follow
- **Non segui**: Persone che ti seguono ma che tu non segui
- **Follow mutui**: Lista delle persone con cui hai rapporti reciproci

### Tab 3: Confronto Temporale
- **Crescita/Perdita**: Statistiche sui cambiamenti dei followers
- **Nuovi Followers**: Chi ha iniziato a seguirti
- **Followers Persi**: Chi ha smesso di seguirti
- **Timeline**: Cronologia dei cambiamenti

## Esempi Pratici

### Scenario 1: Pulizia Following
**Obiettivo**: Ridurre il numero di account che segui

1. Carica `followers_1.html` e `following.html`
2. Vai al tab "Analisi Follow"
3. Guarda la sezione "Non ti seguono"
4. Decidi quali account smettere di seguire

### Scenario 2: Crescita Account
**Obiettivo**: Monitorare la crescita del tuo account

1. Carica un file followers recente
2. Carica un file followers di 1 mese fa
3. Vai al tab "Confronto Temporale"
4. Analizza tendenze di crescita/perdita

### Scenario 3: Engagement Analysis
**Obiettivo**: Trovare nuovi account da seguire

1. Carica `followers_1.html` e `following.html`
2. Vai al tab "Analisi Follow"
3. Guarda la sezione "Non segui"
4. Considera di seguire questi account

## Interpretazione dei Risultati

### Carte Colorate
- **🔴 Rosso**: Aspetti che potrebbero richiedere attenzione (non-mutual follows)
- **🟠 Arancione**: Opportunità (persone che potresti seguire)
- **🟢 Verde**: Relazioni positive (mutual follows, nuovi followers)

### Liste Dettagliate
Ogni utente nella lista mostra:
- **Username**: Handle Instagram (@username)
- **Data**: Quando è stato aggiunto ai tuoi dati
- **Link**: Pulsante per aprire il profilo Instagram

### Suggerimenti di Azione
- **Non ti seguono**: Considera di fare unfollow se non sono importanti
- **Non segui**: Potrebbe essere interessante seguirli se li conosci
- **Nuovi followers**: Considera di seguirli indietro per engagement

## Tips e Best Practices

### Frequenza di Export
- **Settimanale**: Per monitoraggio attivo della crescita
- **Mensile**: Per analisi delle tendenze
- **Dopo eventi**: Post importanti, collaborazioni, etc.

### Gestione dei File
- Rinomina i file con la data: `followers_2024-10-15.html`
- Mantieni una cartella organizzata per i tuoi export
- L'app salva automaticamente i dati per confronti futuri

### Privacy e Sicurezza
- I file vengono processati solo localmente
- Nessun dato viene inviato online
- Puoi eliminare i file dopo l'import se vuoi

### Ottimizzazione delle Performance
- File grandi (>10k followers) potrebbero richiedere tempo
- Chiudi altre app durante l'elaborazione di file molto grandi
- L'app mostra indicatori di progresso per operazioni lunghe

## Risoluzione Problemi Avanzata

### File Non Parsificato Correttamente
```html
<!-- Struttura attesa -->
<a href="https://www.instagram.com/username">Display Name</a>
```

Se l'app non riconosce i tuoi file:
1. Verifica che siano in formato HTML
2. Apri il file in un editor di testo per controllare la struttura
3. Re-esporta da Instagram se necessario

### Dati Mancanti o Incompleti
- Instagram potrebbe dividere file grandi in più parti
- Controlla se hai file come `followers_2.html`, `followers_3.html`
- Carica tutti i file separatamente e confronta i risultati

### Risultati Inaspettati
- Account privati potrebbero non essere visibili nell'export
- Account sospesi/eliminati potrebbero apparire nei dati ma non essere accessibili
- I dati Instagram potrebbero avere qualche ora di ritardo

## Estensioni Future

L'app è progettata per essere estendibile. Funzionalità future potrebbero includere:

- Support per file CSV
- Export dei risultati
- Grafici e visualizzazioni avanzate
- Notifiche per cambiamenti significativi
- Integrazione con API di Instagram (se disponibile)

## Supporto

Per problemi o suggerimenti:
1. Verifica di seguire correttamente la guida
2. Controlla che i file siano nel formato corretto
3. Prova con i file di esempio inclusi per testare l'app