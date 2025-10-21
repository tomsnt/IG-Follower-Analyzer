//  SetupWizardView.swift
//  IG analizer
//  Created by Tommy on 16/10/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct SetupWizardView: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var selectedOperationMode: OperationMode?
    @State private var selectedInstallMethod: InstallMethod?
    @State private var isChromeInstalled = false
    @State private var showingFileDialog = false
    @Environment(\.dismiss) private var dismiss
    
    enum OperationMode: String, CaseIterable {
        case analyzeFollowers
        case compareFollowers
        case installExtension
        
        var isAvailable: Bool {
            switch self {
            case .analyzeFollowers, .compareFollowers:
                return true
            case .installExtension:
                return true
            }
        }
    }
    
    enum InstallMethod: CaseIterable {
        case webStore
        case manual
        case crxFile
        
        var isAvailable: Bool {
            switch self {
            case .webStore:
                return false // Not yet implemented
            case .manual, .crxFile:
                return true
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header and navigation can go here if needed
            if currentStep == 0 {
                WelcomeStepView()
            } else if currentStep == 1 {
                ChromeDetectionStepView(isChromeInstalled: $isChromeInstalled)
            } else if currentStep == 2 {
                OperationModeStepView(selectedMode: $selectedOperationMode)
            } else if currentStep == 3 {
                if selectedOperationMode == .installExtension {
                    InstallMethodStepView(selectedMethod: $selectedInstallMethod, isChromeInstalled: isChromeInstalled)
                } else if selectedOperationMode == .analyzeFollowers {
                    AnalysisModeView()
                } else if selectedOperationMode == .compareFollowers {
                    ComparisonModeView()
                }
            } else if currentStep == 4 {
                if selectedInstallMethod == .manual {
                    ManualInstallInstructionsView()
                } else if selectedInstallMethod == .crxFile {
                    CrxInstallInstructionsView(showingFileDialog: $showingFileDialog)
                } else {
                    WebStoreInstructionsView()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        // Navigation Buttons
        HStack(spacing: 12) {
            Spacer()
            let isDisabled = currentStep == 2 && (selectedOperationMode == nil || selectedOperationMode?.isAvailable == false)
            // Mostra il pulsante Avanti solo per i primi 3 step, non per l'ultimo
            if currentStep < 4 {
                Button("Next") {
                    currentStep += 1
                }
                .disabled(isDisabled)
                .buttonStyle(.borderedProminent)
            }
        }
        .onChange(of: selectedOperationMode) {
            // Navigazione automatica quando viene selezionato un metodo
            if let newValue = selectedOperationMode {
                if newValue == .installExtension {
                    // Per l'installazione dell'estensione, vai al passo successivo per scegliere il metodo
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        currentStep += 1
                    }
                } else {
                    // Per analisi e confronto, segna il setup come completato
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
                        UserDefaults.standard.set(newValue.rawValue, forKey: "selectedOperationMode")
                        dismiss()
                    }
                }
            }
        }
        .padding()
        .fixedSize(horizontal: false, vertical: false)
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

struct OperationModeStepView: View {
    @Binding var selectedMode: SetupWizardView.OperationMode?
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Cosa vuoi fare?")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Scegli la modalità di utilizzo dell'app")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(OperationMode.allCases, id: \.self) { mode in
                    OperationModeCard(
                        mode: mode,
                        isSelected: selectedMode == mode
                    ) {
                        selectedMode = mode
                    }
                }
            }
        }
    }
}

struct OperationModeCard: View {
    let mode: SetupWizardView.OperationMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconName(for: mode))
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(title(for: mode))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description(for: mode))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconName(for mode: SetupWizardView.OperationMode) -> String {
        switch mode {
        case .analyzeFollowers:
            return "chart.bar.fill"
        case .compareFollowers:
            return "arrow.left.arrow.right"
        case .installExtension:
            return "puzzlepiece.extension"
        }
    }
    
    private func title(for mode: SetupWizardView.OperationMode) -> String {
        switch mode {
        case .analyzeFollowers:
            return "Analizza Follower"
        case .compareFollowers:
            return "Confronta Follower"
        case .installExtension:
            return "Installa Estensione"
        }
    }
    
    private func description(for mode: SetupWizardView.OperationMode) -> String {
        switch mode {
        case .analyzeFollowers:
            return "Analizza i tuoi follower e following attuali per vedere chi non ti segue"
        case .compareFollowers:
            return "Confronta due liste di follower per vedere chi ha iniziato/smettuto di seguirti"
        case .installExtension:
            return "Installa l'estensione Chrome per esportare i dati da Instagram"
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
                Text("Choose Installation Method")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Select how you want to install the Instagram Analyzer extension")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(InstallMethod.allCases, id: \.self) { method in
                    let isMethodEnabled = method.isAvailable && isChromeInstalled
                    
                    InstallMethodCard(
                        method: method,
                        isSelected: selectedMethod == method,
                        isEnabled: isMethodEnabled
                    ) {
                        selectedMethod = method
                    }
                }
            }
            
            if let selected = selectedMethod, !selected.isAvailable {
                VStack(spacing: 8) {
                    Text("Method not yet available")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Text("Choose manual installation or .crx file to proceed")
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconName(for: method))
                        .font(.title2)
                        .foregroundColor(isEnabled ? .blue : .gray)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(title(for: method))
                    .font(.headline)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                Text(description(for: method))
                    .font(.subheadline)
                    .foregroundColor(isEnabled ? .secondary : .gray.opacity(0.5))
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
    
    private func iconName(for method: SetupWizardView.InstallMethod) -> String {
        switch method {
        case .webStore:
            return "globe"
        case .manual:
            return "doc.text"
        case .crxFile:
            return "arrow.down.doc"
        }
    }
    
    private func title(for method: SetupWizardView.InstallMethod) -> String {
        switch method {
        case .webStore:
            return "Chrome Web Store"
        case .manual:
            return "Manual Installation"
        case .crxFile:
            return "CRX File"
        }
    }
    
    private func description(for method: SetupWizardView.InstallMethod) -> String {
        switch method {
        case .webStore:
            return "Automatic installation from Chrome Web Store (coming soon)"
        case .manual:
            return "Manual installation by copying extension files"
        case .crxFile:
            return "Install using a .crx file generated from extension folder"
        }
    }
}

struct InstallationStepView: View {
    let method: SetupWizardView.InstallMethod
    @Binding var showingFileDialog: Bool
    
    var body: some View {
        VStack(spacing: 12) {
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
    @State private var showingInstallWindow = false
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Installazione Manuale")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 8)

            HStack(alignment: .top, spacing: 24) {
                StepCardView(
                    stepNumber: 1,
                    title: "Apri Chrome",
                    description: "Avvia Google Chrome per continuare.\n\nSe non lo hai installato, scaricalo dal sito ufficiale.",
                    icon: Image("chrome_icon"),
                    buttonTitle: "Apri",
                    buttonAction: {
                        #if os(macOS)
                        if let chromeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
                            NSWorkspace.shared.openApplication(at: chromeURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
                        }
                        #endif
                    }
                )

                StepCardView(
                    stepNumber: 2,
                    title: "Apri Extensions",
                    description: "Vai su chrome://extensions/ e attiva la modalità sviluppatore.",
                    icon: Image(systemName: "puzzlepiece.extension"),
                    buttonTitle: "Copia link",
                    buttonAction: {
                        ExtensionManager.shared.copyExtensionsURLToClipboard()
                        showingSuccessMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showingSuccessMessage = false
                        }
                    },
                    successMessage: showingSuccessMessage ? "URL copiato negli appunti!" : nil
                )

                StepCardView(
                    stepNumber: 3,
                    title: "Importa Cartella",
                    description: "Apri la cartella e trascina la cartella IGa_Plugin dentro Extensions.",
                    icon: Image(systemName: "folder.fill"),
                    buttonTitle: "Apri cartella",
                    buttonAction: {
                        #if os(macOS)
                        let fileManager = FileManager.default
                        let dmgPathRoot = fileManager.currentDirectoryPath + "/IGa_Plugin.dmg"
                        let dmgPathBundle = Bundle.main.resourceURL?.appendingPathComponent("IGa_Plugin.dmg").path
                        var found = false
                        if fileManager.fileExists(atPath: dmgPathRoot) {
                            let dmgURL = URL(fileURLWithPath: dmgPathRoot)
                            NSWorkspace.shared.open(dmgURL)
                            found = true
                        } else if let bundlePath = dmgPathBundle, fileManager.fileExists(atPath: bundlePath) {
                            let dmgURL = URL(fileURLWithPath: bundlePath)
                            NSWorkspace.shared.open(dmgURL)
                            found = true
                        }
                        if !found {
                            let alert = NSAlert()
                            alert.messageText = "File DMG non trovato"
                            alert.informativeText = "Assicurati che IGa_Plugin.dmg sia presente nella root del progetto o tra le risorse dell'applicazione."
                            alert.alertStyle = .warning
                            alert.runModal()
                        }
                        #endif
                    }
                )
            }
        }
    }
}

// StepCardView: card UI per ogni step

struct StepCardView: View {
    let stepNumber: Int
    let title: String
    let description: String
    let icon: Image
    let buttonTitle: String
    let buttonAction: () -> Void
    var successMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("Step \(stepNumber)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 8)
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundColor(.accentColor)
                .padding(.bottom, 4)
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button(buttonTitle, action: buttonAction)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            if let msg = successMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .transition(.opacity)
            }
        }
    .padding()
    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.windowBackgroundColor)).shadow(radius: 4))
    .frame(width: 260, height: 260)
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
struct AnalysisModeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("Modalità Analisi Follower")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Carica i tuoi file di follower e following per analizzare:")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "person.fill.xmark", title: "Chi non ti segue", description: "Utenti che segui ma non ti seguono")
                    FeatureRow(icon: "person.2.fill", title: "Follower reciproci", description: "Utenti che seguite a vicenda")
                    FeatureRow(icon: "person.fill.badge.plus", title: "Non seguiti", description: "Utenti che ti seguono ma non segui")
                }
            }
        }
    }
}

struct ComparisonModeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 16) {
                Text("Modalità Confronto Follower")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Confronta due liste di follower per vedere:")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "person.badge.plus", title: "Nuovi follower", description: "Utenti che hanno iniziato a seguirti")
                    FeatureRow(icon: "person.fill.badge.minus", title: "Follower persi", description: "Utenti che hanno smesso di seguirti")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Cambiamenti netti", description: "Analisi dell'andamento dei follower")
                }
            }
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