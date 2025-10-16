# Setup Estensione Chrome nel Bundle

Per includere l'estensione Chrome nel bundle dell'app:

## Opzione 1: Xcode (Raccomandata)

1. Apri il progetto in Xcode
2. Clicca destro sulla cartella principale "IG analizer" nel navigator
3. Seleziona "Add Files to 'IG analizer'"
4. Naviga alla cartella "Instragram follower scraper"
5. Seleziona l'intera cartella
6. **IMPORTANTE**: Assicurati che "Create folder references" sia selezionato (non "Create groups")
7. Clicca "Add"

## Opzione 2: Manuale

1. Nella cartella del progetto, crea: `IG analizer/IG analizer/Resources/`
2. Copia la cartella "Instragram follower scraper" dentro Resources
3. In Xcode, aggiungi la cartella Resources al target

## Verifica

L'estensione dovrebbe apparire nel bundle come risorsa blu (folder reference) non come gruppo giallo.

## Benefici

- ✅ L'estensione è sempre disponibile
- ✅ Non dipende da path esterni
- ✅ Distribuzione più facile
- ✅ Funziona su qualsiasi Mac