# Nuove Funzionalità - Instagram Analyzer

## 📊 Tooltip Interattivo sul Grafico

### Descrizione
Passando il mouse (hover) sul grafico dell'andamento followers, viene visualizzato un tooltip con informazioni dettagliate.

### Funzionalità
- **Data specifica**: Mostra la data esatta del punto selezionato
- **Numero Followers**: Visualizza il numero esatto di followers in quella data
- **Numero Following**: Visualizza il numero esatto di following in quella data
- **Differenza**: Calcola e mostra la differenza tra followers e following
- **Indicatore visivo**: Freccia verde (↑) se hai più followers che following, freccia rossa (↓) altrimenti

### Come usare
1. Apri l'applicazione e carica i file di Instagram
2. Clicca "Analizza" per generare uno snapshot
3. Nel grafico in alto a destra, passa il mouse sopra i punti
4. Verrà visualizzato un tooltip con tutti i dettagli

### Esempio Tooltip
```
📅 19 Ott 2025
● Followers: 1,234
● Following: 987
↑ Differenza: 247
```

---

## 📜 Storico Non Followers

### Descrizione
Una nuova finestra dedicata che permette di consultare lo storico completo di chi non ti segue nel tempo, con la possibilità di navigare tra le diverse date e vedere i dettagli.

### Funzionalità

#### 1. **Lista Cronologica degli Snapshot**
- Visualizza tutti gli snapshot salvati in ordine cronologico inverso (più recenti prima)
- Per ogni snapshot mostra:
  - Data e ora di creazione
  - Numero di non-followers in quel momento
  - Indicatore visivo se è lo snapshot selezionato

#### 2. **Ricerca Utenti**
- Campo di ricerca per filtrare gli utenti per username
- Ricerca case-insensitive
- Aggiornamento in tempo reale mentre digiti

#### 3. **Informazioni Dettagliate per Utente**
Per ogni utente che non ti segue, viene mostrato:
- **Avatar**: Iniziale del nome in un cerchio colorato
- **Username**: Nome utente Instagram
- **Giorni consecutivi**: "Non ti segue da X giorni" - calcola automaticamente da quanti giorni consecutivi questo utente non ti segue
- **Link al profilo**: Pulsante per aprire direttamente il profilo Instagram

#### 4. **Selezione Automatica**
- All'apertura, viene automaticamente selezionato l'ultimo snapshot disponibile
- Puoi navigare tra gli snapshot per confrontare diversi periodi

### Come usare

1. **Aprire lo Storico**:
   - Clicca sul pulsante "Storico" nella barra superiore dell'applicazione
   - Si aprirà una nuova finestra modale

2. **Navigare tra le Date**:
   - Nella colonna di sinistra, clicca su una data per visualizzare i non-followers di quel periodo
   - Lo snapshot selezionato sarà evidenziato in rosa

3. **Cercare un Utente**:
   - Usa la barra di ricerca in alto a destra
   - Digita l'username per filtrare la lista

4. **Visualizzare i Dettagli**:
   - Scorri la lista degli utenti
   - Ogni utente mostra da quanti giorni consecutivi non ti segue
   - Clicca su "Profilo" per aprire il profilo Instagram dell'utente

### Esempio di Utilizzo

**Scenario**: Vuoi vedere chi ha smesso di seguirti nell'ultima settimana

1. Apri lo "Storico"
2. Seleziona lo snapshot di 7 giorni fa nella lista a sinistra
3. Confronta mentalmente con lo snapshot di oggi
4. Gli utenti che compaiono oggi ma non 7 giorni fa sono quelli che hanno smesso di seguirti

**Scenario**: Vuoi trovare utenti che non ti seguono da molto tempo

1. Apri lo "Storico"
2. Seleziona l'ultimo snapshot
3. Guarda il campo "Non ti segue da X giorni"
4. Gli utenti con più giorni sono quelli che non ti seguono da più tempo

---

## 🔧 Miglioramenti Tecnici

### Modello FollowersHistory
Nuovi metodi aggiunti:

```swift
// Ottieni lo storico di chi non ti segue per ogni snapshot
func getNonFollowersHistory() -> [(date: Date, users: [InstagramUser])]

// Trova nuovi utenti che hanno smesso di seguirti tra due date
func getNewlyUnfollowed(from: Date, to: Date) -> [InstagramUser]

// Conta quanti giorni consecutivi un utente non ti segue
func getDaysUserNotFollowing(username: String) -> Int
```

### Vista FollowersChartView
Aggiornamenti:
- `@State private var selectedDate: Date?` - Traccia la data selezionata
- `@State private var selectedFollowers: Int?` - Traccia il numero di followers
- `@State private var selectedFollowing: Int?` - Traccia il numero di following
- `.chartAngleSelection(value: $selectedDate)` - Abilita la selezione interattiva
- `RuleMark` - Linea verticale che mostra il punto selezionato
- Tooltip animato con `.transition(.opacity)`

### Nuova Vista: NonFollowersHistoryView
- Layout a due colonne (date + dettagli)
- Ricerca in tempo reale
- Integrazione con il modello FollowersHistory
- Link diretti ai profili Instagram

---

## 📱 Interfaccia Utente

### Colori
- **Rosa Fucsia** (#EB3FCE): Accento principale, non-followers
- **Giallo Brillante** (#F5CC0C): Following, accenti secondari
- **Viola** (#8B5CF6): Pulsanti ausiliari
- **Grigio**: Sfondo e elementi neutri

### Icone
- 🕐 `clock.arrow.circlepath` - Storico
- 👤 `person.slash` - Non-followers
- 🔍 `magnifyingglass` - Ricerca
- ✋ `hand.tap` - Stato vuoto
- ⬆️ `arrow.up.right.square` - Link al profilo

---

## 💾 Persistenza Dati

Tutti gli snapshot vengono salvati automaticamente in:
- **Location**: `UserDefaults`
- **Key**: `"followers_history.json"`
- **Formato**: JSON Codable
- **Limite**: 30 snapshot (elimina automaticamente i più vecchi)

### Cosa viene salvato per ogni snapshot:
- Data e ora
- Lista completa followers
- Lista completa following
- Conteggi (followers, following, mutual, non-mutual)
- Analisi completa

---

## 🎯 Best Practices

### Per ottenere dati accurati:
1. **Esporta regolarmente** i dati da Instagram (es. ogni giorno o ogni settimana)
2. **Analizza sempre** dopo aver caricato nuovi file per creare uno snapshot
3. **Non eliminare la history** a meno che non sia necessario resettare tutto
4. **Consulta lo storico** prima di unfolloware utenti per vedere quanto tempo non ti seguono

### Limiti:
- Massimo 30 snapshot memorizzati
- I giorni consecutivi vengono calcolati solo se ci sono snapshot consecutivi
- La ricerca funziona solo sugli username, non sui nomi visualizzati

---

## 🚀 Prossimi Passi Suggeriti

1. Esportare lo storico in CSV per analisi esterne
2. Notifiche quando qualcuno smette di seguirti
3. Grafici comparativi tra diversi periodi
4. Export PDF dello storico
5. Filtri avanzati (es. solo utenti che non ti seguono da più di X giorni)

---

**Data ultimo aggiornamento**: 19 Ottobre 2025
**Versione**: 2.0
**Autore**: Tommy
