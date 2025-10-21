//
//  PluginInstallationWindowView.swift
//  IG analizer
//
//  Created by Tommy on 20/10/25.
//

import SwiftUI
import AppKit

struct PluginInstallationWindowView: View {
    @Environment(\.dismiss) private var dismiss
    let pluginFolderPath: String
    
    var body: some View {
        ZStack {
            // Instagram gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.99, green: 0.37, blue: 0.36), // rosso
                    Color(red: 0.99, green: 0.60, blue: 0.20), // arancio
                    Color(red: 0.56, green: 0.27, blue: 0.68), // viola
                    Color(red: 0.20, green: 0.60, blue: 0.86)  // blu
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "puzzlepiece.extension")
                        .font(.title)
                        .foregroundColor(Color(hex: "EB3FCE"))
                    Text("Installazione Plugin Chrome")
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
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.white.opacity(0.15))

                // Content - Stile DMG
                HStack(spacing: 40) {
                    // Cartella Plugin
                    VStack(spacing: 12) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        Text("IGa_plugin")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .fontWeight(.medium)
                        Button("Mostra Cartella") {
                            openDMG()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(width: 150)

                    // Freccia
                    VStack {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "EB3FCE"))
                        Text("Trascina →")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Chrome Extensions
                    VStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        Text("Chrome\nExtensions")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .fontWeight(.medium)
                        Button("Apri Chrome") {
                            openChrome()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                    .frame(width: 150)
                }
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                // Istruzioni
                VStack(alignment: .leading, spacing: 12) {
                    Text("Istruzioni:")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionRow(number: 1, text: "Clicca 'Mostra Cartella' per montare e aprire il DMG")
                        InstructionRow(number: 2, text: "Clicca 'Apri Chrome' per aprire Google Chrome")
                        InstructionRow(number: 3, text: "Attiva 'Modalità sviluppatore' in Chrome")
                        InstructionRow(number: 4, text: "Trascina la cartella del plugin nella finestra di Chrome")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white.opacity(0.10))
            }
            .frame(width: 600, height: 500)
        }
    }

    private func openDMG() {
        // Percorso assoluto del DMG nella root del progetto
        let dmgPath = (FileManager.default.currentDirectoryPath as NSString).appendingPathComponent("IGa_Plugin.dmg")
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [dmgPath]
        try? task.run()
    }

    private func openChrome() {
        #if os(macOS)
        if let chromeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
            NSWorkspace.shared.openApplication(at: chromeURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
        #endif
    }
    
    private func openPluginFolder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: pluginFolderPath)
    }
    
    private func openChromeExtensions() {
        if let url = URL(string: "chrome://extensions/") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color(hex: "EB3FCE")))
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PluginInstallationWindowView(pluginFolderPath: "/Users/tommy/Documents/IG-Follower-Analyzer/IG analizer/Instragram follower scraper")
}
