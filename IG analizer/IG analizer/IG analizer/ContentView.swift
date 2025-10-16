//
//  ContentView.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = InstagramAnalyzerViewModel()
    @State private var showSetupWizard = false
    @State private var hasCompletedSetup = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Instagram Analyzer")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("Setup Estensione") {
                        showSetupWizard = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Reset") {
                        viewModel.clearAllData()
                    }
                    .buttonStyle(.bordered)
                }
                
                if viewModel.isLoading {
                    ProgressView("Analizzando file...")
                        .font(.caption)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // Main Content Area with Two Columns
            HStack(spacing: 0) {
                // Left Column - File Upload & Controls
                VStack(spacing: 12) {
                    // File Upload Section
                    VStack(spacing: 10) {
                        HStack {
                            Text("Carica i file di Instagram")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showSetupWizard = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "puzzlepiece.extension")
                                        .font(.caption)
                                    Text("Estensione")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        
                        VStack(spacing: 12) {
                            // Followers Upload
                            FileDropView(
                                title: "Followers",
                                description: "Trascina il file followers CSV o HTML qui",
                                icon: "person.2.fill"
                            ) { url in
                                viewModel.loadFollowersFile(from: url)
                            }
                            
                            // Following Upload
                            FileDropView(
                                title: "Following",
                                description: "Trascina il file following CSV o HTML qui",
                                icon: "person.badge.plus"
                            ) { url in
                                viewModel.loadFollowingFile(from: url)
                            }
                        }
                        
                        // Status
                        VStack(spacing: 8) {
                            HStack {
                                Text("Followers:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(viewModel.followers.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(viewModel.followers.isEmpty ? .secondary : .green)
                            }
                            
                            HStack {
                                Text("Following:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(viewModel.following.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(viewModel.following.isEmpty ? .secondary : .green)
                            }
                        }
                        
                        // Extension Status Indicator
                        if ExtensionManager.shared.isChromeInstalled() {
                            HStack(spacing: 8) {
                                Image(systemName: "puzzlepiece.extension")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("Estensione disponibile")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Button("Setup") {
                                    showSetupWizard = true
                                }
                                .font(.caption)
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                            }
                            .padding(.horizontal)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Text("Chrome non installato")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Button("Setup") {
                                    showSetupWizard = true
                                }
                                .font(.caption)
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Analysis Button
                    VStack(spacing: 10) {
                        Button(action: {
                            viewModel.performAnalysis()
                        }) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("Analizza")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canAnalyze ? Color.blue : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(!viewModel.canAnalyze)
                        
                        Text("Carica entrambi i file per analizzare")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(maxWidth: 350)
                .padding()
                .background(Color.gray.opacity(0.02))
                
                // Vertical Divider
                Divider()
                
                // Right Column - Analysis Results
                ScrollView {
                    if let analysis = viewModel.analysis {
                        VStack(spacing: 12) {
                            VStack(spacing: 10) {
                                Text("Risultati Analisi")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 15) {
                                    AnalysisCard(
                                        title: "Non ti seguono",
                                        count: analysis.nonMutualFollowingCount,
                                        color: .red,
                                        icon: "person.slash"
                                    )
                                    
                                    AnalysisCard(
                                        title: "Non segui",
                                        count: analysis.nonMutualFollowersCount,
                                        color: .orange,
                                        icon: "person.badge.minus"
                                    )
                                    
                                    AnalysisCard(
                                        title: "Mutual",
                                        count: analysis.mutualFollowsCount,
                                        color: .green,
                                        icon: "person.2.fill"
                                    )
                                }
                            }
                            .padding(.top)
                            
                            // Details Lists
                            VStack(spacing: 12) {
                                if !analysis.nonMutualFollowing.isEmpty {
                                    UserListView(
                                        users: analysis.nonMutualFollowing,
                                        title: "Non ti seguono (\(analysis.nonMutualFollowingCount))",
                                        subtitle: "Li segui ma non ti seguono"
                                    )
                                }
                                
                                if !analysis.nonMutualFollowers.isEmpty {
                                    UserListView(
                                        users: analysis.nonMutualFollowers,
                                        title: "Non segui (\(analysis.nonMutualFollowersCount))",
                                        subtitle: "Ti seguono ma non li segui"
                                    )
                                }
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 12) {
                            Spacer()
                            
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            VStack(spacing: 8) {
                                Text("Nessuna analisi disponibile")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text("Carica i file followers e following, poi clicca \"Analizza\" per vedere i risultati qui")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            viewModel.loadSavedData()
            
            // Mostra il wizard setup al primo avvio
            if !hasCompletedSetup {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSetupWizard = true
                }
            }
        }
        .frame(minWidth: 800, minHeight: 500)
        .sheet(isPresented: $showSetupWizard) {
            SetupWizardView(isPresented: $showSetupWizard)
                .onDisappear {
                    hasCompletedSetup = true
                    UserDefaults.standard.set(true, forKey: "hasCompletedSetup")
                }
        }
    }
}

struct AnalysisCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
