//
//  FileDropView.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import SwiftUI
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

struct FileDropView: View {
    let title: String
    let description: String
    let icon: String
    let onFileDrop: (URL) -> Void
    
    @State private var isDragOver = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(isDragOver ? .blue : .secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Seleziona File") {
                selectFile()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isDragOver ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isDragOver ? Color.blue : Color.clear,
                            style: StrokeStyle(lineWidth: 2, dash: [8])
                        )
                )
        )
        .onDrop(of: [UTType.html, UTType.fileURL], isTargeted: $isDragOver) { providers in
            return handleDrop(providers: providers)
        }
    }
    
    private func selectFile() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.html]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            onFileDrop(url)
        }
        #else
        // For iOS, you would implement document picker
        // This is a placeholder for iOS implementation
        #endif
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    if let data = item as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            onFileDrop(url)
                        }
                    }
                }
                return true
            }
        }
        return false
    }
}

#Preview {
    FileDropView(
        title: "Drop HTML File",
        description: "Drag and drop your Instagram HTML file here",
        icon: "doc.on.doc",
        onFileDrop: { _ in }
    )
}