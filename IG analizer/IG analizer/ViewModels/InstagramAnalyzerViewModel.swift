//
//  InstagramAnalyzerViewModel.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import Foundation
import SwiftUI

@MainActor
class InstagramAnalyzerViewModel: ObservableObject {
    @Published var followers: [InstagramUser] = []
    @Published var following: [InstagramUser] = []
    
    @Published var analysis: FollowersAnalysis?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Published property for button state
    @Published var canAnalyze = false
    
    private func updateButtonState() {
        canAnalyze = !followers.isEmpty && !following.isEmpty
        print("🔍 Updated button state - canAnalyze: \(canAnalyze)")
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
    
    func performAnalysis() {
        guard canAnalyze else {
            errorMessage = "Carica sia il file followers che following per eseguire l'analisi"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🔍 Starting analysis with \(followers.count) followers and \(following.count) following")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let analysisResult = FileParser.analyzeFollowersVsFollowing(
                followers: self.followers,
                following: self.following
            )
            
            DispatchQueue.main.async {
                self.analysis = analysisResult
                self.isLoading = false
                
                print("✅ Analysis complete:")
                print("   - Non mutual following: \(analysisResult.nonMutualFollowingCount)")
                print("   - Non mutual followers: \(analysisResult.nonMutualFollowersCount)")
                print("   - Mutual follows: \(analysisResult.mutualFollowsCount)")
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
}