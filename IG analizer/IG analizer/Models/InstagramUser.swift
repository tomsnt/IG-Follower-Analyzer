//
//  InstagramUser.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import Foundation

struct InstagramUser: Identifiable, Hashable, Codable {
    let id: UUID
    let username: String
    let profileURL: String?
    let timestamp: Date?
    
    init(username: String, profileURL: String? = nil, timestamp: Date? = nil) {
        self.id = UUID()
        self.username = username
        self.profileURL = profileURL
        self.timestamp = timestamp
    }
}

struct FollowersAnalysis {
    let nonMutualFollowing: [InstagramUser] // People you follow who don't follow you back
    let nonMutualFollowers: [InstagramUser] // People who follow you but you don't follow back
    let mutualFollows: [InstagramUser] // Mutual connections
    
    var nonMutualFollowingCount: Int { nonMutualFollowing.count }
    var nonMutualFollowersCount: Int { nonMutualFollowers.count }
    var mutualFollowsCount: Int { mutualFollows.count }
}

struct FollowersComparison {
    let newFollowers: [InstagramUser] // New followers since last check
    let lostFollowers: [InstagramUser] // Lost followers since last check
    let currentFollowers: [InstagramUser] // Current followers
    let previousFollowers: [InstagramUser] // Previous followers
    
    var newFollowersCount: Int { newFollowers.count }
    var lostFollowersCount: Int { lostFollowers.count }
    var currentFollowersCount: Int { currentFollowers.count }
    var previousFollowersCount: Int { previousFollowers.count }
    var netChange: Int { newFollowersCount - lostFollowersCount }
}