# Instagram Analyzer

Un'app per analizzare i tuoi dati di Instagram e confrontare followers e following.

## Funzionalità

### 1. Analisi Follow/Following
- **Non ti seguono**: Persone che segui ma che non ti seguono indietro
- **Non segui**: Persone che ti seguono ma che tu non segui
- **Follow mutui**: Persone con cui hai un follow reciproco

### 2. Confronto Temporale
- **Nuovi followers**: Persone che hanno iniziato a seguirti
- **Followers persi**: Persone che hanno smesso di seguirti
- **Statistiche di crescita**: Confronto tra diversi periodi

## Come Utilizzare

### Step 1: Esportare i Dati da Instagram

1. Vai su Instagram Web (instagram.com)
2. Accedi al tuo account
3. Vai a **Impostazioni** > **Privacy e sicurezza** > **Scarica i tuoi dati**
4. Richiedi il download dei tuoi dati in formato HTML
5. Attendi l'email di conferma e scarica il file ZIP

### Step 2: Estrarre i File

1. Estrai il file ZIP scaricato
2. Naviga alla cartella: `connections/followers_and_following/`
3. Troverai questi file:
   - `followers_1.html` (o `followers.html`) - I tuoi followers
   - `following.html` - Le persone che segui

### Step 3: Usare l'App

1. **Tab "File Upload"**:
   - Trascina e rilascia il file `followers_1.html` nella sezione "File Followers"
   - Trascina e rilascia il file `following.html` nella sezione "File Following"
   - Opzionale: Carica un file followers precedente per confronti temporali

2. **Tab "Analisi Follow"**:
   - Visualizza chi non ti segue indietro
   - Visualizza chi potresti voler seguire
   - Vedi i tuoi follow mutui

3. **Tab "Confronto Temporale"**:
   - Confronta diversi file followers nel tempo
   - Vedi chi hai guadagnato/perso come follower

## Struttura dei File Instagram

I file HTML di Instagram hanno questa struttura tipica:

```html
<!DOCTYPE html>
<html>
<head><title>Following</title></head>
<body>
  <div>
    <a href="https://www.instagram.com/username1">Display Name</a>
  </div>
  <div>
    <a href="https://www.instagram.com/username2">Display Name</a>
  </div>
</body>
</html>
```

L'app parsifica automaticamente questi link per estrarre gli username.

## File di Test Inclusi

Nella cartella del progetto troverai:
- `sample_followers.html` - File di esempio per i followers
- `sample_following.html` - File di esempio per i following

Puoi usare questi file per testare l'app prima di caricare i tuoi dati reali.

## Funzionalità Avanzate

### Salvataggio Automatico
- I dati vengono salvati automaticamente sul dispositivo
- I confronti precedenti vengono mantenuti per analisi future

### Esportazione
- Tutti i dati possono essere visualizzati e copiati
- I link diretti ai profili Instagram sono disponibili per ogni utente

### Privacy
- Tutti i dati vengono elaborati localmente sul tuo dispositivo
- Nessun dato viene inviato a server esterni
- I file vengono processati solo nella memoria dell'app

## Risoluzione Problemi

### File non riconosciuto
- Assicurati che il file sia in formato HTML
- Verifica che il file contenga la struttura corretta di Instagram
- Prova a riesportare i dati da Instagram se il file sembra corrotto

### Dati incompleti
- Instagram potrebbe limitare l'esportazione per account con molti followers
- Alcuni file potrebbero essere divisi in più parti (followers_1.html, followers_2.html, etc.)
- L'app attualmente supporta un file alla volta

### Performance
- File molto grandi potrebbero richiedere qualche secondo per essere processati
- L'app mostrerà un indicatore di caricamento durante l'elaborazione

## Requisiti

- macOS 12.0+ o iOS 15.0+
- Xcode 14.0+ per compilare dall'origine
- File HTML esportati da Instagram

## Note sulla Privacy

Questa app è progettata per mantenere la tua privacy:
- Elaborazione completamente locale
- Nessun tracciamento
- Nessun invio di dati a server esterni
- I tuoi dati Instagram rimangono sul tuo dispositivo