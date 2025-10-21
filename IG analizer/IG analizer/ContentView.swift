import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = InstagramAnalyzerViewModel()
    @State private var showHistoryView = false
    @State private var showSetupWizard = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            Divider()

            // Main Content: Two Columns
            HStack(spacing: 0) {
                // Left Column: Controls & File Upload
                leftColumn
                    .frame(maxWidth: 400)

                Divider()

                // Right Column: Chart & Results
                rightColumn
                    .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showSetupWizard) {
            SetupWizardView(isPresented: $showSetupWizard)
        }
        .sheet(isPresented: $showHistoryView) {
            NonFollowersHistoryView(history: viewModel.followersHistory)
        }
        .onAppear {
            viewModel.checkChromeInstallation()
            // Load operation mode from UserDefaults
            if let savedMode = UserDefaults.standard.string(forKey: "operationMode"),
               let mode = OperationMode(rawValue: savedMode) {
                viewModel.operationMode = mode
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.title2)
                    .foregroundColor(Color(hex: "EB3FCE"))

                Text("Instagram Analyzer")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                // Operation Mode Picker
                Picker("Modalità", selection: $viewModel.operationMode) {
                    Text("Analisi").tag(OperationMode.analyzeFollowers)
                    Text("Confronto").tag(OperationMode.compareFollowers)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                .onChange(of: viewModel.operationMode) { oldValue, newValue in
                    // Save to UserDefaults
                    UserDefaults.standard.set(newValue.rawValue, forKey: "operationMode")
                    // Reset state when switching modes
                    viewModel.resetForModeChange()
                }

                Button("Storico") {
                    showHistoryView = true
                }
                .buttonStyle(.bordered)
                .tint(Color(hex: "8B5CF6"))

                Button(action: {
                    showSetupWizard = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "puzzlepiece.extension")
                        Text("Chrome Plugin")
                    }
                }
                .buttonStyle(.bordered)
                .tint(Color(hex: "EB3FCE"))
            }

            if viewModel.isAnalyzing {
                ProgressView(viewModel.operationMode == .analyzeFollowers ? "Analizzando..." : "Confrontando...")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
    
    // MARK: - Left Column
    private var leftColumn: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(viewModel.operationMode == .analyzeFollowers ? "Carica i File" : "Confronta Follower")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Chrome Installation Check
                if !viewModel.isChromeInstalled {
                    chromeWarning
                }
                
                // File Upload Sections based on mode
                if viewModel.operationMode == .analyzeFollowers {
                    analysisModeControls
                } else {
                    comparisonModeControls
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Mode Controls
    private var analysisModeControls: some View {
        VStack(spacing: 16) {
            FileDropView(
                title: "Follower",
                description: "Trascina il file CSV o HTML",
                icon: "person.2"
            ) { url in
                viewModel.loadFollowersFile(from: url)
            }
            
            if viewModel.followersLoaded {
                statusBadge(text: "✓ Follower caricati", color: .green)
            }
            
            FileDropView(
                title: "Following",
                description: "Trascina il file CSV o HTML",
                icon: "person.badge.plus"
            ) { url in
                viewModel.loadFollowingFile(from: url)
            }
            
            if viewModel.followingLoaded {
                statusBadge(text: "✓ Following caricati", color: .green)
            }
            
            // Analyze Button
            if viewModel.followersLoaded && viewModel.followingLoaded {
                Button(action: {
                    viewModel.analyzeFollowers()
                }) {
                    HStack {
                        if viewModel.isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "chart.bar.fill")
                        }
                        Text(viewModel.isAnalyzing ? "Analizzando..." : "Avvia Analisi")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "EB3FCE"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isAnalyzing)
            }
        }
    }
    
    private var comparisonModeControls: some View {
        VStack(spacing: 16) {
            FileDropView(
                title: "Follower Vecchi",
                description: "File precedente dei follower",
                icon: "clock.arrow.circlepath"
            ) { url in
                viewModel.loadOldFollowersFile(from: url)
            }
            
            if !viewModel.oldFollowers.isEmpty {
                statusBadge(text: "✓ \(viewModel.oldFollowers.count) follower vecchi", color: .blue)
            }
            
            FileDropView(
                title: "Follower Nuovi",
                description: "File aggiornato dei follower",
                icon: "arrow.up.circle"
            ) { url in
                viewModel.loadNewFollowersFile(from: url)
            }
            
            if !viewModel.newFollowers.isEmpty {
                statusBadge(text: "✓ \(viewModel.newFollowers.count) follower nuovi", color: .green)
            }
            
            // Compare Button
            if viewModel.canAnalyze {
                Button(action: {
                    viewModel.performComparison()
                }) {
                    HStack {
                        if viewModel.isAnalyzing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.left.arrow.right")
                        }
                        Text(viewModel.isAnalyzing ? "Confrontando..." : "Confronta")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "EB3FCE"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isAnalyzing)
            }
        }
    }
    private var rightColumn: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Chart sempre visibile (anche senza dati)
                FollowersChartView(history: viewModel.followersHistory)
                    .frame(height: 300)
                
                // Results Section based on mode
                if viewModel.operationMode == .analyzeFollowers {
                    analysisResultsView
                } else {
                    comparisonResultsView
                }
            }
            .padding()
        }
    }
    
    // MARK: - Results Views
    private var analysisResultsView: some View {
        Group {
            if viewModel.analysisComplete {
                Divider()
                
                Text("Risultati Analisi")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Analysis Cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    AnalysisCard(
                        title: "Non ti seguono",
                        count: viewModel.notFollowingBack.count,
                        color: Color(hex: "EB3FCE"),
                        icon: "person.fill.xmark"
                    )
                    
                    AnalysisCard(
                        title: "Mutual",
                        count: viewModel.mutualFollowers.count,
                        color: Color(hex: "F5CC0C"),
                        icon: "person.2.fill"
                    )
                    
                    AnalysisCard(
                        title: "Non segui",
                        count: viewModel.notFollowing.count,
                        color: Color(hex: "8B5CF6"),
                        icon: "person.fill.badge.plus"
                    )
                }
                
                // User Lists
                VStack(spacing: 16) {
                    if !viewModel.notFollowingBack.isEmpty {
                        UserListView(
                            users: viewModel.notFollowingBack,
                            title: "Non ti seguono"
                        )
                    }
                    
                    if !viewModel.mutualFollowers.isEmpty {
                        UserListView(
                            users: viewModel.mutualFollowers,
                            title: "Mutual"
                        )
                    }
                    
                    if !viewModel.notFollowing.isEmpty {
                        UserListView(
                            users: viewModel.notFollowing,
                            title: "Non segui"
                        )
                    }
                }
            }
        }
    }
    
    private var comparisonResultsView: some View {
        Group {
            if viewModel.analysisComplete, let comparison = viewModel.comparison {
                Divider()
                
                Text("Risultati Confronto")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Comparison Summary
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("\(comparison.newFollowersCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Nuovi follower")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(comparison.lostFollowersCount)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("Follower persi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(comparison.netChange)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(comparison.netChange >= 0 ? .green : .red)
                            Text("Variazione netta")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // User Lists
                VStack(spacing: 16) {
                    if !comparison.newFollowers.isEmpty {
                        UserListView(
                            users: comparison.newFollowers,
                            title: "Nuovi Follower"
                        )
                    }
                    
                    if !comparison.lostFollowers.isEmpty {
                        UserListView(
                            users: comparison.lostFollowers,
                            title: "Follower Persi"
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private var chromeWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Chrome non installato")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Installa l'estensione per esportare i dati")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func statusBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .cornerRadius(8)
            .frame(maxWidth: .infinity, alignment: .leading)
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
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}