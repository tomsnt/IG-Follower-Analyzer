//
//  FileParser.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import Foundation

enum InstagramFileType {
    case followers
    case following
}

class FileParser {
    
    static func parseInstagramFile(_ content: String, fileType: InstagramFileType) -> [InstagramUser] {
        // Detect if it's CSV or HTML
        if content.contains("Username,Display Name,Profile URL") {
            return parseCSVContent(content)
        } else {
            return parseHTMLContent(content, fileType: fileType)
        }
    }
    
    // Parse CSV files (new Instagram export format)
    static func parseCSVContent(_ csvContent: String) -> [InstagramUser] {
        var users: [InstagramUser] = []
        
        print("🔍 Parsing CSV content of length: \(csvContent.count)")
        
        let lines = csvContent.components(separatedBy: .newlines)
        
        // Skip header line
        for (index, line) in lines.enumerated() {
            if index == 0 || line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            // Parse CSV line: "username","display_name","profile_url","pic_url","collected_at"
            let components = parseCSVLine(line)
            
            if components.count >= 3 {
                let username = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let profileURL = components[2].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                
                if !username.isEmpty && isLikelyUsername(username) {
                    let user = InstagramUser(
                        username: username,
                        profileURL: profileURL.isEmpty ? "https://www.instagram.com/\(username)" : profileURL,
                        timestamp: Date()
                    )
                    
                    if !users.contains(where: { $0.username == user.username }) {
                        users.append(user)
                        print("✅ Added user (CSV): \(username)")
                    }
                }
            }
        }
        
        print("🎯 CSV result: \(users.count) users parsed")
        return users
    }
    
    // Parse HTML files (old Instagram export format)
    static func parseHTMLContent(_ htmlContent: String, fileType: InstagramFileType) -> [InstagramUser] {
        var users: [InstagramUser] = []
        
        print("🔍 Parsing HTML content of length: \(htmlContent.count)")
        
        let range = NSRange(location: 0, length: htmlContent.utf16.count)
        
        if fileType == .following {
            // Pattern for following.html format: <h2 class="_3-95 _2pim _a6-h _a6-i">USERNAME</h2>
            let h2Pattern = #"<h2\s+class="_3-95\s+_2pim\s+_a6-h\s+_a6-i">([^<]+)</h2>"#
            let h2Regex = try! NSRegularExpression(pattern: h2Pattern, options: [.dotMatchesLineSeparators])
            let h2Matches = h2Regex.matches(in: htmlContent, options: [], range: range)
            
            print("🔍 Found \(h2Matches.count) matches with H2 pattern (following)")
            
            for match in h2Matches {
                if match.numberOfRanges >= 2 {
                    let usernameRange = Range(match.range(at: 1), in: htmlContent)
                    
                    if let usernameRange = usernameRange {
                        let username = String(htmlContent[usernameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !username.isEmpty && isLikelyUsername(username) {
                            let user = InstagramUser(
                                username: username,
                                profileURL: "https://www.instagram.com/\(username)",
                                timestamp: Date()
                            )
                            
                            if !users.contains(where: { $0.username == user.username }) {
                                users.append(user)
                                print("✅ Added user (following): \(username)")
                            }
                        }
                    }
                }
            }
        } else {
            // Pattern for followers.html format: <a target="_blank" href="https://www.instagram.com/USERNAME">USERNAME</a>
            let linkPattern = #"<a\s+target="_blank"\s+href="https://www\.instagram\.com/([^"]+)">([^<]+)</a>"#
            let linkRegex = try! NSRegularExpression(pattern: linkPattern, options: [.dotMatchesLineSeparators])
            let linkMatches = linkRegex.matches(in: htmlContent, options: [], range: range)
            
            print("🔍 Found \(linkMatches.count) matches with direct link pattern (followers)")
            
            for match in linkMatches {
                if match.numberOfRanges >= 3 {
                    let urlUsernameRange = Range(match.range(at: 1), in: htmlContent)
                    let displayUsernameRange = Range(match.range(at: 2), in: htmlContent)
                    
                    if let urlUsernameRange = urlUsernameRange,
                       let displayUsernameRange = displayUsernameRange {
                        let urlUsername = String(htmlContent[urlUsernameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                        let displayUsername = String(htmlContent[displayUsernameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        let finalUsername = displayUsername.isEmpty ? urlUsername : displayUsername
                        
                        if !finalUsername.isEmpty && isLikelyUsername(finalUsername) {
                            let user = InstagramUser(
                                username: finalUsername,
                                profileURL: "https://www.instagram.com/\(finalUsername)",
                                timestamp: Date()
                            )
                            
                            if !users.contains(where: { $0.username == user.username }) {
                                users.append(user)
                                print("✅ Added user (followers): \(finalUsername)")
                            }
                        }
                    }
                }
            }
        }
        
        print("🎯 HTML result: \(users.count) users parsed")
        return users
    }
    
    // Helper function to parse CSV line correctly handling quotes and commas
    static func parseCSVLine(_ line: String) -> [String] {
        var components: [String] = []
        var currentComponent = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                components.append(currentComponent)
                currentComponent = ""
            } else {
                currentComponent.append(char)
            }
            
            i = line.index(after: i)
        }
        
        // Add the last component
        components.append(currentComponent)
        
        return components
    }
    
    static func analyzeFollowersVsFollowing(followers: [InstagramUser], following: [InstagramUser]) -> FollowersAnalysis {
        let followersSet = Set(followers.map { $0.username })
        let followingSet = Set(following.map { $0.username })
        
        let nonMutualFollowing = following.filter { !followersSet.contains($0.username) }
        let nonMutualFollowers = followers.filter { !followingSet.contains($0.username) }
        let mutualUsernames = followersSet.intersection(followingSet)
        let mutualFollows = followers.filter { mutualUsernames.contains($0.username) }
        
        return FollowersAnalysis(
            nonMutualFollowing: nonMutualFollowing,
            nonMutualFollowers: nonMutualFollowers,
            mutualFollows: mutualFollows
        )
    }
    
    static func compareFollowersList(current: [InstagramUser], previous: [InstagramUser]) -> FollowersComparison {
        let currentSet = Set(current.map { $0.username })
        let previousSet = Set(previous.map { $0.username })
        
        let newFollowerUsernames = currentSet.subtracting(previousSet)
        let lostFollowerUsernames = previousSet.subtracting(currentSet)
        
        let newFollowers = current.filter { newFollowerUsernames.contains($0.username) }
        let lostFollowers = previous.filter { lostFollowerUsernames.contains($0.username) }
        
        return FollowersComparison(
            newFollowers: newFollowers,
            lostFollowers: lostFollowers,
            currentFollowers: current,
            previousFollowers: previous
        )
    }
    
    private static func isLikelyUsername(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty && 
              trimmed.count >= 1 && 
              trimmed.count <= 30 else {
            return false
        }
        
        guard !trimmed.contains(" ") && 
              !trimmed.contains("\n") && 
              !trimmed.contains("\t") else {
            return false
        }
        
        let lowercased = trimmed.lowercased()
        let excludedWords = [
            "instagram", "facebook", "following", "followers", "follow",
            "http", "https", ".com", ".html", ".net", ".org",
            "www", "profile", "user", "account", "data", "export",
            "connections", "and", "the", "of", "in", "to", "for", "_u",
            "username", "display", "name", "url", "collected", "at"
        ]
        
        for word in excludedWords {
            if lowercased.contains(word) {
                return false
            }
        }
        
        guard !trimmed.hasPrefix(".") && !trimmed.hasSuffix(".") else {
            return false
        }
        
        guard trimmed.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil else {
            return false
        }
        
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._"))
        guard trimmed.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
            return false
        }
        
        return true
    }
}