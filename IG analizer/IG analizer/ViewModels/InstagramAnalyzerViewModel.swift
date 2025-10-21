//
//  InstagramAnalyzerViewModel.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import Foundation
import SwiftUI

enum OperationMode: String {
    case analyzeFollowers
    case compareFollowers
}

@MainActor
class InstagramAnalyzerViewModel: ObservableObject {
    @Published var followers: [InstagramUser] = []
    @Published var following: [InstagramUser] = []
    
    @Published var analysis: FollowersAnalysis?
    @Published var followersHistory = FollowersHistory()
    
    // Comparison mode properties
    @Published var oldFollowers: [InstagramUser] = []
    @Published var newFollowers: [InstagramUser] = []
    @Published var comparison: FollowersComparison?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Published property for button state
    @Published var canAnalyze = false
    
    // Chrome installation state
    @Published var isChromeInstalled = true
    
    // Analysis state
    @Published var isAnalyzing = false
    @Published var analysisComplete = false
    
    // Operation mode
    @Published var operationMode: OperationMode = .analyzeFollowers {
        didSet {
            updateButtonState()
        }
    }
    
    // Computed properties for analysis results
    var followersLoaded: Bool { !followers.isEmpty }
    var followingLoaded: Bool { !following.isEmpty }
    var notFollowingBack: [InstagramUser] { analysis?.nonMutualFollowing ?? [] }
    var mutualFollowers: [InstagramUser] { analysis?.mutualFollows ?? [] }
    var notFollowing: [InstagramUser] { analysis?.nonMutualFollowers ?? [] }
    
    // Computed properties for comparison results
    var newFollowersList: [InstagramUser] { comparison?.newFollowers ?? [] }
    var lostFollowersList: [InstagramUser] { comparison?.lostFollowers ?? [] }
    var comparisonComplete: Bool { comparison != nil }
    
    init() {
        loadSavedHistory()
    }
    
    private func updateButtonState() {
        switch operationMode {
        case .analyzeFollowers:
            canAnalyze = !followers.isEmpty && !following.isEmpty
        case .compareFollowers:
            canAnalyze = !oldFollowers.isEmpty && !newFollowers.isEmpty
        }
        print("🔍 Updated button state for \(operationMode) - canAnalyze: \(canAnalyze)")
    }
    
    func loadFollowersFile(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        print("📁 Loading followers file from: \(url.lastPathComponent)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let fileContent = FileManager.loadInstagramFile(from: url) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Impossibile leggere il file"
                    self.isLoading = false
                }
                return
            }
            
            print("📄 File content loaded, length: \(fileContent.count) characters")
            
            let parsedFollowers = FileParser.parseInstagramFile(fileContent, fileType: .followers)
            
            DispatchQueue.main.async {
                self.followers = parsedFollowers
                FileManager.saveFollowersData(parsedFollowers, to: "current_followers")
                
                print("✅ Loaded \(parsedFollowers.count) followers")
                
                self.updateButtonState()
                self.isLoading = false
            }
        }
    }
    
    func loadFollowingFile(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        print("📁 Loading following file from: \(url.lastPathComponent)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let fileContent = FileManager.loadInstagramFile(from: url) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Impossibile leggere il file"
                    self.isLoading = false
                }
                return
            }
            
            print("📄 File content loaded, length: \(fileContent.count) characters")
            
            let parsedFollowing = FileParser.parseInstagramFile(fileContent, fileType: .following)
            
            DispatchQueue.main.async {
                self.following = parsedFollowing
                FileManager.saveFollowersData(parsedFollowing, to: "current_following")
                
                print("✅ Loaded \(parsedFollowing.count) following")
                
                self.updateButtonState()
                self.isLoading = false
            }
        }
    }
    
    func loadOldFollowersFile(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        print("📁 Loading old followers file from: \(url.lastPathComponent)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let fileContent = FileManager.loadInstagramFile(from: url) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Impossibile leggere il file"
                    self.isLoading = false
                }
                return
            }
            
            print("📄 File content loaded, length: \(fileContent.count) characters")
            
            let parsedFollowers = FileParser.parseInstagramFile(fileContent, fileType: .followers)
            
            DispatchQueue.main.async {
                self.oldFollowers = parsedFollowers
                FileManager.saveFollowersData(parsedFollowers, to: "old_followers")
                
                print("✅ Loaded \(parsedFollowers.count) old followers")
                
                self.updateButtonState()
                self.isLoading = false
            }
        }
    }
    
    func loadNewFollowersFile(from url: URL) {
        isLoading = true
        errorMessage = nil
        
        print("📁 Loading new followers file from: \(url.lastPathComponent)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let fileContent = FileManager.loadInstagramFile(from: url) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Impossibile leggere il file"
                    self.isLoading = false
                }
                return
            }
            
            print("📄 File content loaded, length: \(fileContent.count) characters")
            
            let parsedFollowers = FileParser.parseInstagramFile(fileContent, fileType: .followers)
            
            DispatchQueue.main.async {
                self.newFollowers = parsedFollowers
                FileManager.saveFollowersData(parsedFollowers, to: "new_followers")
                
                print("✅ Loaded \(parsedFollowers.count) new followers")
                
                self.updateButtonState()
                self.isLoading = false
            }
        }
    }
    
    func performComparison() {
        guard canAnalyze else {
            errorMessage = "Carica sia il file dei follower vecchi che quello nuovo per eseguire il confronto"
            return
        }
        
        isAnalyzing = true
        analysisComplete = false
        errorMessage = nil
        
        print("🔍 Starting comparison with \(oldFollowers.count) old followers and \(newFollowers.count) new followers")

        Task {
            let oldFollowersCopy = await self.oldFollowers
            let newFollowersCopy = await self.newFollowers

            let comparisonResult = FileParser.compareFollowersList(current: newFollowersCopy, previous: oldFollowersCopy)

            await MainActor.run {
                self.comparison = comparisonResult
                self.isAnalyzing = false
                self.analysisComplete = true

                print("✅ Comparison complete:")
                print("   - New followers: \(comparisonResult.newFollowersCount)")
                print("   - Lost followers: \(comparisonResult.lostFollowersCount)")
                print("   - Net change: \(comparisonResult.netChange)")
            }
        }
    }
    
    func resetForModeChange() {
        // Reset all data and states
        followers = []
        following = []
        oldFollowers = []
        newFollowers = []
        analysis = nil
        comparison = nil
        isLoading = false
        errorMessage = nil
        canAnalyze = false
        isAnalyzing = false
        analysisComplete = false
        
        print("🔄 Reset state for mode change")
        
        updateButtonState()
    }
    
    func checkChromeInstallation() {
        // Per ora assumiamo che Chrome sia sempre disponibile
        // In futuro si può implementare una verifica reale
        isChromeInstalled = true
    }
    
    func analyzeFollowers() {
        performAnalysis()
    }
    
    func performAnalysis() {
        guard canAnalyze else {
            errorMessage = "Carica sia il file followers che following per eseguire l'analisi"
            return
        }
        
        isAnalyzing = true
        analysisComplete = false
        errorMessage = nil
        
        print("🔍 Starting analysis with \(followers.count) followers and \(following.count) following")

        Task {
            // Accedi alle proprietà isolando su MainActor
            let followersCopy = await self.followers
            let followingCopy = await self.following

            let analysisResult = FileParser.analyzeFollowersVsFollowing(
                followers: followersCopy,
                following: followingCopy
            )

            await MainActor.run {
                self.analysis = analysisResult

                // Crea e salva uno snapshot della situazione attuale
                let snapshotDate = self.getMostRecentFileDate()
                let snapshot = FollowersSnapshot(
                    date: snapshotDate,
                    followers: followersCopy,
                    following: followingCopy,
                    analysis: analysisResult
                )

                self.followersHistory.addSnapshot(snapshot)
                self.saveHistory()

                self.isAnalyzing = false
                self.analysisComplete = true

                print("✅ Analysis complete:")
                print("   - Non mutual following: \(analysisResult.nonMutualFollowingCount)")
                print("   - Non mutual followers: \(analysisResult.nonMutualFollowersCount)")
                print("   - Mutual follows: \(analysisResult.mutualFollowsCount)")
                print("📊 History updated with \(self.followersHistory.snapshots.count) total snapshots")
            }
        }
    }
    
    func loadSavedData() {
        if let savedFollowers = FileManager.loadFollowersData(from: "current_followers") {
            followers = savedFollowers
        }
        
        if let savedFollowing = FileManager.loadFollowersData(from: "current_following") {
            following = savedFollowing
        }
        
        updateButtonState()
    }
    
    func clearAllData() {
        followers = []
        following = []
        analysis = nil
        errorMessage = nil
        updateButtonState()
    }
    
    // MARK: - History Management
    
    private func loadSavedHistory() {
        if let savedHistory = FileManager.loadFollowersHistory() {
            followersHistory = savedHistory
            print("📊 Loaded history with \(savedHistory.snapshots.count) snapshots")
        }
    }
    
    private func saveHistory() {
        FileManager.saveFollowersHistory(followersHistory)
    }
    
    // Trova la data più recente dai file CSV caricati
    private func getMostRecentFileDate() -> Date {
        var dates: [Date] = []
        
        // Raccogli tutte le date dai followers
        for follower in followers {
            if let timestamp = follower.timestamp {
                dates.append(timestamp)
            }
        }
        
        // Raccogli tutte le date dai following
        for following in following {
            if let timestamp = following.timestamp {
                dates.append(timestamp)
            }
        }
        
        // Se non ci sono date nei file, usa la data corrente
        guard !dates.isEmpty else {
            print("⚠️ Nessuna data trovata nei file CSV, uso data corrente")
            return Date()
        }
        
        // Restituisci la data più recente
        let mostRecentDate = dates.max() ?? Date()
        print("📅 Data più recente dai file CSV: \(mostRecentDate)")
        return mostRecentDate
    }
    
    func clearHistory() {
        followersHistory = FollowersHistory()
        saveHistory()
        print("🗑️ History cleared")
    }
}