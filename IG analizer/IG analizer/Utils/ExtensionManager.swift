//
//  ExtensionManager.swift
//  IG analizer
//
//  Created by Tommy on 16/10/25.
//

import Foundation
#if os(macOS)
import AppKit
#endif

class ExtensionManager {
    static let shared = ExtensionManager()
    
    private init() {}
    
    private var extensionPath: String {
        // 1. Cerca prima nel bundle dell'app
        if let bundlePath = Bundle.main.path(forResource: "Instragram follower scraper", ofType: nil) {
            return bundlePath
        }
        
        if let bundlePath = Bundle.main.path(forResource: "Instagram follower scraper", ofType: nil) {
            return bundlePath
        }
        
        // 2. Cerca nella cartella Resources del bundle
        if let bundleResourcePath = Bundle.main.resourcePath {
            let possibleBundlePaths = [
                bundleResourcePath + "/Instragram follower scraper",
                bundleResourcePath + "/Instagram follower scraper",
                bundleResourcePath + "/extension"
            ]
            
            for path in possibleBundlePaths {
                if FileManager.default.fileExists(atPath: path) {
                    return path
                }
            }
        }
        
        // 3. Cerca nella directory Documents dell'utente
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
        let projectPath = documentsPath + "/IG-Follower-Analyzer"
        let currentDir = FileManager.default.currentDirectoryPath

        // Prova diversi nomi possibili per la cartella dell'estensione
        let possibleNames = [
            "IGscraper_Plugin",
            "Instragram follower scraper",
            "Instagram follower scraper", 
            "chrome-extension",
            "extension"
        ]

        // Cerca sia in Documents/IG-Follower-Analyzer che nella dir corrente
        for name in possibleNames {
            let fullPath1 = projectPath + "/" + name
            if FileManager.default.fileExists(atPath: fullPath1) {
                return fullPath1
            }
            let fullPath2 = currentDir + "/" + name
            if FileManager.default.fileExists(atPath: fullPath2) {
                return fullPath2
            }
        }
        
        // 4. Fallback al path relativo dalla posizione del progetto
        let bundle = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let fallbackPath = bundle.appendingPathComponent("Instragram follower scraper").path
        if FileManager.default.fileExists(atPath: fallbackPath) {
            return fallbackPath
        }
        
        // 5. Ultimo fallback
        return "/Users/tommy/Documents/IG-Follower-Analyzer/Instragram follower scraper"
    }
    
    func generateCrxFile(to destinationURL: URL? = nil, completion: @escaping (Result<URL, Error>) -> Void) {
        #if os(macOS)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("🔍 Inizio generazione file .crx...")
                
                // Usa il metodo helper per trovare la cartella dell'estensione
                guard let sourcePath = ExtensionManager.findExtensionFolder() else {
                    print("❌ Cartella estensione non trovata!")
                    DispatchQueue.main.async {
                        completion(.failure(ExtensionError.extensionNotFound))
                    }
                    return
                }
                
                print("✅ Cartella estensione trovata: \(sourcePath)")
                
                // Usa il percorso specificato o default alla scrivania
                let crxPath = destinationURL ?? FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!.appendingPathComponent("InstagramAnalyzer.crx")
                
                print("🔧 Creazione .crx da: \(sourcePath)")
                print("🔧 File finale .crx: \(crxPath.path)")
                
                // Rimuovi file precedenti se esistono
                if FileManager.default.fileExists(atPath: crxPath.path) {
                    try FileManager.default.removeItem(at: crxPath)
                }
                
                // Usa Archive per creare il .crx direttamente senza file temporaneo
                try self.createZipFile(from: sourcePath, to: crxPath)
                
                print("✅ File .crx creato: \(crxPath.path)")
                
                DispatchQueue.main.async {
                    completion(.success(crxPath))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        #else
        completion(.failure(ExtensionError.platformNotSupported))
        #endif
    }
    
    func openExtensionFolder() -> Bool {
        #if os(macOS)
        let path = extensionPath
        print("Tentativo di aprire: \(path)")
        
        // Verifica che la cartella esista
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
            print("Cartella aperta con successo: \(path)")
            return true
        } else {
            print("Cartella estensione non trovata: \(path)")
            
            // Prova diversi path possibili
            let possiblePaths = [
                "/Users/tommy/Documents/IG-Follower-Analyzer",
                NSHomeDirectory() + "/Documents/IG-Follower-Analyzer",
                FileManager.default.currentDirectoryPath + "/Instragram follower scraper",
                FileManager.default.currentDirectoryPath + "/../Instragram follower scraper"
            ]
            
            for testPath in possiblePaths {
                print("Testando path: \(testPath)")
                if FileManager.default.fileExists(atPath: testPath) {
                    print("Path trovato: \(testPath)")
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: testPath)
                    return true
                }
            }
            
            // Ultimo tentativo: apri la directory corrente
            let currentDir = FileManager.default.currentDirectoryPath
            print("Ultimo tentativo con directory corrente: \(currentDir)")
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: currentDir)
            return false
        }
        #else
        return false
        #endif
    }
    
    func openProjectFolder() {
        #if os(macOS)
        // Apri la cartella principale del progetto
        let projectPaths = [
            "/Users/tommy/Documents/IG-Follower-Analyzer",
            NSHomeDirectory() + "/Documents/IG-Follower-Analyzer",
            FileManager.default.currentDirectoryPath
        ]
        
        for path in projectPaths {
            if FileManager.default.fileExists(atPath: path) {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
                return
            }
        }
        
        // Fallback: apri Documents
        let documentsPath = NSHomeDirectory() + "/Documents"
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: documentsPath)
        #endif
    }
    
    func openChromeExtensions() {
        #if os(macOS)
        // Metodo 1: Prova il link diretto (alcuni sistemi lo supportano)
        if let url = URL(string: "chrome://extensions/") {
            if NSWorkspace.shared.open(url) {
                return // Successo!
            }
        }
        
        // Metodo 2: Comando diretto con open
        let process = Process()
        process.launchPath = "/usr/bin/open"
        process.arguments = ["chrome://extensions/"]
        
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                return // Successo
            }
        } catch {
            print("Comando open fallito: \(error)")
        }
        
        // Metodo 3: AppleScript semplice e diretto
        let appleScript = """
        tell application "Google Chrome"
            activate
            delay 0.5
            if not (exists window 1) then
                make new window
            end if
            set URL of active tab of window 1 to "chrome://extensions/"
        end tell
        """
        
        if let script = NSAppleScript(source: appleScript) {
            var errorInfo: NSDictionary?
            script.executeAndReturnError(&errorInfo)
            
            if errorInfo == nil {
                return // Successo con AppleScript
            }
        }
        
        // Metodo 4: Apri Chrome e naviga dopo un delay
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "Google Chrome"]
        
        do {
            try task.run()
            // Aspetta che Chrome si apra e poi naviga
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let delayedScript = """
                tell application "Google Chrome"
                    set URL of active tab of window 1 to "chrome://extensions/"
                end tell
                """
                
                if let script = NSAppleScript(source: delayedScript) {
                    var errorInfo: NSDictionary?
                    script.executeAndReturnError(&errorInfo)
                }
            }
        } catch {
            print("Errore nell'aprire Chrome: \(error)")
            // Come ultimo resort, copia l'URL
            copyExtensionsURLToClipboard()
        }
        #endif
    }
    
    func copyExtensionsURLToClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString("chrome://extensions/", forType: .string)
        #endif
    }
    
    func showExtensionsInstructions() {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = "Apertura Chrome Extensions"
        alert.informativeText = "1. Apri Google Chrome\n2. Nella barra degli indirizzi, digita: chrome://extensions/\n3. Premi Invio\n\nL'URL è stato copiato negli appunti per comodità!"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Copia URL")
        
        copyExtensionsURLToClipboard()
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            copyExtensionsURLToClipboard()
        }
        #endif
    }
    
    func isChromeInstalled() -> Bool {
        #if os(macOS)
        return FileManager.default.fileExists(atPath: "/Applications/Google Chrome.app")
        #else
        return false
        #endif
    }
    
    func extensionFolderExists() -> Bool {
        return FileManager.default.fileExists(atPath: extensionPath)
    }
    
    func getExtensionPath() -> String {
        return extensionPath
    }
    
    // Metodo helper per trovare la cartella dell'estensione
    static func findExtensionFolder() -> String? {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        
        print("🔍 Bundle.main.resourcePath: \(Bundle.main.resourcePath ?? "nil")")
        print("🔍 currentDirectory: \(currentDirectory)")
        
        let possiblePaths = [
            // Percorso CORRETTO: dentro la cartella IG analizer (PRIMO DA TESTARE)
            "/Users/tommy/Documents/IG-Follower-Analyzer/IG analizer/Instragram follower scraper",
            // Percorso nel bundle dell'app (se esiste)
            (Bundle.main.resourcePath ?? "") + "/Instragram follower scraper",
            // Percorso relativo dal progetto principale  
            "/Users/tommy/Documents/IG-Follower-Analyzer/Instragram follower scraper",
            // Percorsi relativi dalla directory corrente
            "\(currentDirectory)/Instragram follower scraper",
            "\(currentDirectory)/../Instragram follower scraper",
            "\(currentDirectory)/../../Instragram follower scraper",
            // Percorso nella home dell'utente
            NSHomeDirectory() + "/Documents/IG-Follower-Analyzer/IG analizer/Instragram follower scraper",
            NSHomeDirectory() + "/Documents/IG-Follower-Analyzer/Instragram follower scraper",
            // Percorso nel desktop
            NSHomeDirectory() + "/Desktop/IG-Follower-Analyzer/IG analizer/Instragram follower scraper",
            NSHomeDirectory() + "/Desktop/IG-Follower-Analyzer/Instragram follower scraper",
            // Percorso nel Downloads
            NSHomeDirectory() + "/Downloads/IG-Follower-Analyzer/IG analizer/Instragram follower scraper",
            NSHomeDirectory() + "/Downloads/IG-Follower-Analyzer/Instragram follower scraper"
        ]
        
        for path in possiblePaths {
            print("🔍 Controllo percorso: \(path)")
            if fileManager.fileExists(atPath: path) {
                print("✅ Cartella estensione trovata: \(path)")
                
                // Verifica che sia effettivamente una directory
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        print("✅ Confermato che è una directory")
                        return path
                    } else {
                        print("❌ Trovato ma non è una directory")
                    }
                }
            } else {
                print("❌ Non esiste: \(path)")
            }
        }
        
        print("❌ Cartella estensione non trovata in nessuno dei percorsi: \(possiblePaths)")
        return nil
    }
    
    func copyExtensionToDocuments() -> Bool {
        #if os(macOS)
        // Cerca l'estensione nel bundle
        guard let bundlePath = Bundle.main.path(forResource: "Instragram follower scraper", ofType: nil) ??
              Bundle.main.path(forResource: "Instagram follower scraper", ofType: nil) else {
            return false
        }
        
        // Crea la cartella di destinazione
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let projectPath = documentsPath.appendingPathComponent("IG-Follower-Analyzer")
        let destinationPath = projectPath.appendingPathComponent("Instragram follower scraper")
        
        do {
            // Crea la cartella progetto se non esiste
            try FileManager.default.createDirectory(at: projectPath, withIntermediateDirectories: true)
            
            // Rimuovi destinazione se esiste già
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                try FileManager.default.removeItem(at: destinationPath)
            }
            
            // Copia l'estensione
            try FileManager.default.copyItem(atPath: bundlePath, toPath: destinationPath.path)
            return true
        } catch {
            print("Errore nella copia dell'estensione: \(error)")
            return false
        }
        #else
        return false
        #endif
    }
    
    // Metodo helper per creare un file zip usando le API native di Swift
    private func createZipFile(from sourcePath: String, to destinationURL: URL) throws {
        print("🔧 Creazione zip da \(sourcePath) a \(destinationURL.path)")
        
        // Prima verifica che ci siano file nella cartella sorgente
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: sourcePath)
        print("🔧 File trovati nella cartella estensione: \(contents)")
        
        guard !contents.isEmpty else {
            print("❌ Cartella estensione vuota!")
            throw ExtensionError.extensionNotFound
        }
        
        // Usa il comando zip con percorso assoluto e mantieni la struttura
        let process = Process()
        process.launchPath = "/usr/bin/zip"
        process.arguments = [
            "-r", // ricorsivo
            destinationURL.path, // file di destinazione
            "." // tutto nella directory corrente
        ]
        process.currentDirectoryPath = sourcePath // cambia directory di lavoro
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.launch()
        process.waitUntilExit()
        
        // Leggi sempre l'output per debugging
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        if !outputString.isEmpty {
            print("🔧 Output zip: \(outputString)")
        }
        
        if process.terminationStatus != 0 {
            print("❌ Errore zip con codice: \(process.terminationStatus)")
            throw ExtensionError.compressionFailed
        }
        
        // Verifica che il file sia stato effettivamente creato
        if fileManager.fileExists(atPath: destinationURL.path) {
            let fileSize = try fileManager.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64 ?? 0
            print("✅ Zip creato con successo - Dimensione: \(fileSize) bytes")
        } else {
            print("❌ File zip non creato")
            throw ExtensionError.compressionFailed
        }
    }
    
    // Nuovo metodo che usa URL per evitare problemi di sandboxing
    func generateCrxFileFromURL(from sourceURL: URL, to destinationURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        #if os(macOS)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("🔍 Inizio generazione file .crx da URL...")
                print("🔧 Sorgente: \(sourceURL.path)")
                print("🔧 Destinazione: \(destinationURL.path)")
                
                let fileManager = FileManager.default
                
                // Verifica che la cartella sorgente esista e contenga file
                guard fileManager.fileExists(atPath: sourceURL.path) else {
                    DispatchQueue.main.async {
                        completion(.failure(ExtensionError.extensionNotFound))
                    }
                    return
                }
                
                let contents = try fileManager.contentsOfDirectory(atPath: sourceURL.path)
                print("🔧 File trovati: \(contents)")
                
                guard !contents.isEmpty else {
                    DispatchQueue.main.async {
                        completion(.failure(ExtensionError.extensionNotFound))
                    }
                    return
                }
                
                // Rimuovi il file di destinazione se esiste
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                
                // Crea il file zip usando il comando zip
                let process = Process()
                process.launchPath = "/usr/bin/zip"
                process.arguments = [
                    "-r", // ricorsivo
                    destinationURL.path, // file di destinazione
                    "." // tutto nella directory corrente
                ]
                process.currentDirectoryPath = sourceURL.path
                
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                
                process.launch()
                process.waitUntilExit()
                
                // Leggi l'output
                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                let outputString = String(data: outputData, encoding: .utf8) ?? ""
                if !outputString.isEmpty {
                    print("🔧 Output zip: \(outputString)")
                }
                
                if process.terminationStatus != 0 {
                    print("❌ Errore zip con codice: \(process.terminationStatus)")
                    DispatchQueue.main.async {
                        completion(.failure(ExtensionError.compressionFailed))
                    }
                    return
                }
                
                // Verifica che il file sia stato creato
                if fileManager.fileExists(atPath: destinationURL.path) {
                    let fileSize = try fileManager.attributesOfItem(atPath: destinationURL.path)[.size] as? Int64 ?? 0
                    print("✅ File .crx creato con successo - Dimensione: \(fileSize) bytes")
                    
                    DispatchQueue.main.async {
                        completion(.success(destinationURL))
                    }
                } else {
                    print("❌ File .crx non creato")
                    DispatchQueue.main.async {
                        completion(.failure(ExtensionError.compressionFailed))
                    }
                }
                
            } catch {
                print("❌ Errore durante la generazione: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        #else
        completion(.failure(ExtensionError.platformNotSupported))
        #endif
    }
}

enum ExtensionError: LocalizedError {
    case compressionFailed
    case platformNotSupported
    case extensionNotFound
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Errore durante la creazione del file .crx"
        case .platformNotSupported:
            return "Funzionalità non supportata su questa piattaforma"
        case .extensionNotFound:
            return "Cartella dell'estensione non trovata"
        }
    }
}