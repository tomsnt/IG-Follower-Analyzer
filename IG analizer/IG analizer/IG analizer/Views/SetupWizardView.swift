//
//  SetupWizardView.swift
//  IG analizer
//
//  Created by Tommy on 16/10/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct SetupWizardView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var selectedInstallMethod: InstallMethod?
    @State private var isChromeInstalled = false
    @State private var showingFileDialog = false
    @Environment(\.dismiss) private var dismiss
    
    enum InstallMethod: CaseIterable {
        case webStore
        case manual
        case crxFile
        
        var title: String {
            switch self {
            case .webStore:
                return "Chrome Web Store"
            case .manual:
                return "Installazione Manuale"
            case .crxFile:
                return "File .crx"
            }
        }
        
        var description: String {
            switch self {
            case .webStore:
                return "Installazione automatica dallo store ufficiale (Prossimamente)"
            case .manual:
                return "Installazione step-by-step in modalità sviluppatore"
            case .crxFile:
                return "Download e installazione del file di estensione"
            }
        }
        
        var icon: String {
            switch self {
            case .webStore:
                return "app.badge"
            case .manual:
                return "hammer"
            case .crxFile:
                return "doc.zipper"
            }
        }
        
        var isAvailable: Bool {
            switch self {
            case .webStore:
                return false // Prossimamente
            case .manual, .crxFile:
                return true
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    // Pulsante indietro con freccia in alto a sinistra
                    Button(action: {
                        if currentStep > 0 {
                            currentStep -= 1
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(currentStep == 0)
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Image(systemName: "puzzlepiece.extension")
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text("Setup Instagram Analyzer")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                ProgressView(value: Double(currentStep), total: 3.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 8)
                
                Text("Step \(currentStep + 1) di 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Content Area - flessibile per adattarsi al contenuto
            Group {
                switch currentStep {
                case 0:
                    WelcomeStepView()
                case 1:
                    ChromeDetectionStepView(isChromeInstalled: $isChromeInstalled)
                case 2:
                    InstallMethodStepView(selectedMethod: $selectedInstallMethod, isChromeInstalled: isChromeInstalled)
                case 3:
                    if let method = selectedInstallMethod {
                        InstallationStepView(method: method, showingFileDialog: $showingFileDialog)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            // Navigation Buttons
            HStack(spacing: 12) {
                Spacer()
                
                let isDisabled = currentStep == 2 && (selectedInstallMethod == nil || selectedInstallMethod?.isAvailable == false)
                
                VStack(alignment: .center, spacing: 12) {
                }
                
                // Mostra il pulsante Avanti solo per i primi 3 step, non per l'ultimo
                if currentStep < 3 {
                    Button("Avanti") {
                        currentStep += 1
                    }
                    .disabled(isDisabled)
                    .buttonStyle(.borderedProminent)
                }
            }
            .onChange(of: selectedInstallMethod) { newValue in
                // Navigazione automatica quando viene selezionato un metodo
                if currentStep == 2 && newValue != nil && newValue?.isAvailable == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        currentStep += 1
                        // Segna il setup come completato quando arriva all'ultimo step
                        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 600, idealWidth: 600, maxWidth: 800,
               minHeight: 500, maxHeight: .infinity)
    }
}

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.wave")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Benvenuto in Instagram Analyzer!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Per utilizzare questa app al massimo delle sue potenzialità, ti aiuteremo a installare l'estensione Chrome che ti permetterà di scaricare automaticamente i tuoi dati da Instagram.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                FeatureRow(icon: "arrow.down.circle", title: "Download Automatico", description: "Scarica followers e following direttamente da Instagram")
                FeatureRow(icon: "shield.checkered", title: "Sicuro e Privato", description: "I tuoi dati rimangono solo sul tuo computer")
                FeatureRow(icon: "speedometer", title: "Veloce e Efficiente", description: "Analisi rapida senza limitazioni")
            }
        }
    }
}

struct ChromeDetectionStepView: View {
    @Binding var isChromeInstalled: Bool
    @State private var isChecking = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Rilevamento Google Chrome")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if isChecking {
                    ProgressView("Controllo installazione Chrome...")
                        .font(.body)
                } else if isChromeInstalled {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Google Chrome trovato!")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        
                        Text("Perfetto! Puoi procedere con l'installazione dell'estensione.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Google Chrome non trovato")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        
                        Text("È necessario installare Google Chrome per utilizzare l'estensione.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Scarica Chrome") {
                            if let url = URL(string: "https://www.google.com/chrome/") {
                                #if os(macOS)
                                NSWorkspace.shared.open(url)
                                #endif
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            
            Button("Controlla di nuovo") {
                checkChromeInstallation()
            }
            .buttonStyle(.bordered)
        }
        .onAppear {
            checkChromeInstallation()
        }
    }
    
    private func checkChromeInstallation() {
        isChecking = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let chromeExists = ExtensionManager.shared.isChromeInstalled()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isChromeInstalled = chromeExists
                isChecking = false
            }
        }
    }
}

struct InstallMethodStepView: View {
    @Binding var selectedMethod: SetupWizardView.InstallMethod?
    let isChromeInstalled: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "puzzlepiece.extension")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Scegli il Metodo di Installazione")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Seleziona come preferisci installare l'estensione Instagram Analyzer")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(SetupWizardView.InstallMethod.allCases, id: \.self) { method in
                    let isMethodEnabled = method.isAvailable && isChromeInstalled
                    
                    VStack {
                        InstallMethodCard(
                            method: method,
                            isSelected: selectedMethod == method,
                            isEnabled: isMethodEnabled
                        ) {
                            selectedMethod = method
                        }
                    }
                }
            }
            
            if let selected = selectedMethod, !selected.isAvailable {
                VStack(spacing: 8) {
                    Text("Metodo non ancora disponibile")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("Scegli l'installazione manuale o file .crx per procedere")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

struct InstallMethodCard: View {
    let method: SetupWizardView.InstallMethod
    let isSelected: Bool
    let isEnabled: Bool
    let onSelect: () -> Void
    
    @State private var hasBeenSelected = false
    
    var body: some View {
        Button(action: {
            if isEnabled && !hasBeenSelected {
                hasBeenSelected = true
                onSelect()
                
                // Reset dopo un po' per permettere cambio selezione
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    hasBeenSelected = false
                }
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: method.icon)
                    .font(.title2)
                    .foregroundColor(isEnabled ? .blue : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(method.title)
                        .font(.headline)
                        .foregroundColor(isEnabled ? .primary : .gray)
                    
                    Text(method.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if !method.isAvailable {
                    Text("Presto")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.blue : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.blue.opacity(0.05) : Color.clear)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}

struct InstallationStepView: View {
    let method: SetupWizardView.InstallMethod
    @Binding var showingFileDialog: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gear")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Installazione \(method.title)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                switch method {
                case .webStore:
                    WebStoreInstructionsView()
                case .manual:
                    ManualInstallInstructionsView()
                case .crxFile:
                    CrxInstallInstructionsView(showingFileDialog: $showingFileDialog)
                }
            }
        }
    }
}

struct WebStoreInstructionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("L'estensione sarà presto disponibile sul Chrome Web Store ufficiale per un'installazione automatica e sicura.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Nel frattempo, puoi utilizzare l'installazione manuale.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Ti notificheremo quando sarà disponibile!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ManualInstallInstructionsView: View {
    @State private var showingSuccessMessage = false
    @State private var isOpeningChrome = false
    @State private var showFallbackHint = false
    @State private var folderErrorMessage: String?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Segui questi passaggi per installare l'estensione:")
                .font(.body)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionStep(number: 1, text: "Apri Google Chrome")
                InstructionStep(number: 2, text: "Vai su chrome://extensions/")
                InstructionStep(number: 3, text: "Attiva la 'Modalità sviluppatore' in alto a destra")
                InstructionStep(number: 4, text: "Clicca 'Carica estensione non pacchettizzata'")
                InstructionStep(number: 5, text: "Seleziona la cartella 'Instagram follower scraper'")
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    isOpeningChrome = true
                    
                    // Prova ad aprire direttamente
                    ExtensionManager.shared.openChromeExtensions()
                    
                    // Resetta lo stato e mostra hint se necessario
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        isOpeningChrome = false
                        showFallbackHint = true
                        
                        // Nascondi hint dopo un po'
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            showFallbackHint = false
                        }
                    }
                }) {
                    HStack {
                        if isOpeningChrome {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "globe")
                        }
                        Text(isOpeningChrome ? "Aprendo Chrome Extensions..." : "Apri Chrome Extensions")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isOpeningChrome)
                
                if showFallbackHint {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.orange)
                            Text("Chrome non ha navigato automaticamente?")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Usa i pulsanti qui sotto per copiare l'URL manualmente")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity)
                }
                
                HStack(spacing: 12) {
                    Button("Copia URL") {
                        ExtensionManager.shared.copyExtensionsURLToClipboard()
                        showingSuccessMessage = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showingSuccessMessage = false
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Cartella Estensione") {
                        folderErrorMessage = nil
                        
                        // Usa il metodo helper per trovare la cartella
                        #if os(macOS)
                        if let path = ExtensionManager.findExtensionFolder() {
                            print("🔧 Tentativo di aprire cartella: \(path)")
                            
                            // Prova diversi metodi per aprire la cartella
                            let success1 = NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
                            print("🔧 selectFile risultato: \(success1)")
                            
                            if !success1 {
                                // Prova metodo alternativo con URL
                                let url = URL(fileURLWithPath: path)
                                let success2 = NSWorkspace.shared.open(url)
                                print("🔧 open URL risultato: \(success2)")
                                
                                if !success2 {
                                    // Prova con activateFileViewerSelecting
                                    NSWorkspace.shared.activateFileViewerSelecting([url])
                                    print("🔧 Usato activateFileViewerSelecting - cartella aperta")
                                } else {
                                    print("🔧 Cartella aperta con successo tramite open URL")
                                }
                            } else {
                                print("🔧 Cartella aperta con selectFile")
                            }
                        } else {
                            // Se non trova automaticamente, mostra un dialog per selezionare manualmente
                            let dialog = NSOpenPanel()
                            dialog.title = "Seleziona la cartella dell'estensione"
                            dialog.message = "Cerca la cartella 'Instragram follower scraper' nel progetto"
                            dialog.canChooseDirectories = true
                            dialog.canChooseFiles = false
                            dialog.allowsMultipleSelection = false
                            dialog.directoryURL = URL(fileURLWithPath: "/Users/tommy/Documents/IG-Follower-Analyzer")
                            
                            if dialog.runModal() == .OK, let selectedURL = dialog.url {
                                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: selectedURL.path)
                            } else {
                                folderErrorMessage = "Cartella estensione non trovata"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    folderErrorMessage = nil
                                }
                            }
                        }
                        #endif
                    }
                    .buttonStyle(.bordered)
                }
                
                if showingSuccessMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("URL copiato negli appunti!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .transition(.opacity)
                }
                
                if let errorMessage = folderErrorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}

struct CrxInstallInstructionsView: View {
    @Binding var showingFileDialog: Bool
    @State private var isGenerating = false
    @State private var generationResult: Result<URL, Error>?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Installazione tramite file .crx")
                .font(.body)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionStep(number: 1, text: "Genera il file .crx dell'estensione")
                InstructionStep(number: 2, text: "Trascina il file .crx in Chrome")
                InstructionStep(number: 3, text: "Conferma l'installazione")
            }
            
            if isGenerating {
                ProgressView("Generando file .crx...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button("Genera File .crx") {
                    generateCrxFile()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if let result = generationResult {
                switch result {
                case .success(let url):
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("File .crx creato con successo!")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        Text("Salvato: \(url.lastPathComponent)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Button("Mostra File") {
                            #if os(macOS)
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                            #endif
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                case .failure(let error):
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("Errore: \(error.localizedDescription)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Text("Nota: Chrome potrebbe mostrare un avviso per estensioni non verificate")
                .font(.caption)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
        }
    }
    
    private func generateCrxFile() {
        // Prima chiedi all'utente di selezionare la cartella dell'estensione
        #if os(macOS)
        let openPanel = NSOpenPanel()
        openPanel.title = "Seleziona la cartella dell'estensione"
        openPanel.message = "Seleziona la cartella 'Instragram follower scraper' per creare il file .crx"
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        
        // Prova a navigare automaticamente alla cartella giusta
        let possiblePath = "/Users/tommy/Documents/IG-Follower-Analyzer/IG analizer"
        if FileManager.default.fileExists(atPath: possiblePath) {
            openPanel.directoryURL = URL(fileURLWithPath: possiblePath)
        }
        
        let response = openPanel.runModal()
        
        if response == .OK, let selectedURL = openPanel.url {
            // Verifica che sia la cartella dell'estensione (deve contenere manifest.json)
            let manifestPath = selectedURL.appendingPathComponent("manifest.json")
            guard FileManager.default.fileExists(atPath: manifestPath.path) else {
                // Mostra errore
                let alert = NSAlert()
                alert.messageText = "Cartella Non Valida"
                alert.informativeText = "La cartella selezionata non sembra essere un'estensione Chrome valida. Assicurati di selezionare la cartella 'Instragram follower scraper'."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
                return
            }
            
            // Chiedi dove salvare il file .crx
            let savePanel = NSSavePanel()
            savePanel.title = "Salva file .crx"
            savePanel.message = "Scegli dove salvare il file dell'estensione"
            savePanel.nameFieldStringValue = "InstagramAnalyzer.crx"
            savePanel.allowedContentTypes = [.init(filenameExtension: "crx")!]
            
            // Imposta desktop come default
            if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
                savePanel.directoryURL = desktopURL
            }
            
            let saveResponse = savePanel.runModal()
            
            if saveResponse == .OK, let crxURL = savePanel.url {
                // Ora genera il file .crx
                isGenerating = true
                generationResult = nil
                
                print("🔧 Inizio generazione .crx da: \(selectedURL.path) verso: \(crxURL.path)")
                
                ExtensionManager.shared.generateCrxFileFromURL(from: selectedURL, to: crxURL) { result in
                    DispatchQueue.main.async {
                        self.isGenerating = false
                        self.generationResult = result
                        
                        switch result {
                        case .success(let url):
                            print("✅ Generazione .crx completata: \(url.path)")
                        case .failure(let error):
                            print("❌ Errore generazione .crx: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        #endif
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}