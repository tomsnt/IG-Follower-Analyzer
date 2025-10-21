//
//  FollowersHistory.swift
//  IG analizer
//
//  Created by Tommy on 19/10/25.
//

import Foundation

struct FollowersSnapshot: Codable, Identifiable {
    let id: UUID
    let date: Date
    let followersCount: Int
    let followingCount: Int
    let mutualFollowsCount: Int
    let nonMutualFollowingCount: Int
    let nonMutualFollowersCount: Int
    let followers: [InstagramUser]
    let following: [InstagramUser]
    
    init(date: Date, followers: [InstagramUser], following: [InstagramUser], analysis: FollowersAnalysis) {
        self.id = UUID()
        self.date = date
        self.followers = followers
        self.following = following
        self.followersCount = followers.count
        self.followingCount = following.count
        self.mutualFollowsCount = analysis.mutualFollowsCount
        self.nonMutualFollowingCount = analysis.nonMutualFollowingCount
        self.nonMutualFollowersCount = analysis.nonMutualFollowersCount
    }
}

struct FollowersHistory: Codable {
    var snapshots: [FollowersSnapshot]
    
    init() {
        self.snapshots = []
    }
    
    mutating func addSnapshot(_ snapshot: FollowersSnapshot) {
        snapshots.append(snapshot)
        // Mantieni solo gli ultimi 30 snapshot per performance
        if snapshots.count > 30 {
            snapshots = Array(snapshots.suffix(30))
        }
        // Ordina per data
        snapshots.sort { $0.date < $1.date }
    }
    
    func getLatestSnapshot() -> FollowersSnapshot? {
        return snapshots.last
    }
    
    func getSnapshotsBetween(startDate: Date, endDate: Date) -> [FollowersSnapshot] {
        return snapshots.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    func getGrowthRate() -> Double? {
        guard snapshots.count >= 2 else { return nil }
        
        let oldest = snapshots.first!
        let newest = snapshots.last!
        
        let daysDifference = Calendar.current.dateComponents([.day], from: oldest.date, to: newest.date).day ?? 1
        let followersChange = newest.followersCount - oldest.followersCount
        
        return Double(followersChange) / Double(max(daysDifference, 1))
    }
    
    func getChartData() -> [(date: Date, followers: Int, following: Int)] {
        return snapshots.map { (date: $0.date, followers: $0.followersCount, following: $0.followingCount) }
    }
    
    // Storico di chi non ti segue nel tempo
    func getNonFollowersHistory() -> [(date: Date, users: [InstagramUser])] {
        return snapshots.map { snapshot in
            let followersSet = Set(snapshot.followers.map { $0.username })
            let nonFollowers = snapshot.following.filter { !followersSet.contains($0.username) }
            return (date: snapshot.date, users: nonFollowers)
        }
    }
    
    // Trova nuovi utenti che hanno smesso di seguirti
    func getNewlyUnfollowed(from previousDate: Date, to currentDate: Date) -> [InstagramUser] {
        guard let previousSnapshot = snapshots.first(where: { Calendar.current.isDate($0.date, inSameDayAs: previousDate) }),
              let currentSnapshot = snapshots.first(where: { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) else {
            return []
        }
        
        let previousNonFollowersSet = Set(previousSnapshot.following.map { $0.username }).subtracting(Set(previousSnapshot.followers.map { $0.username }))
        let currentNonFollowersSet = Set(currentSnapshot.following.map { $0.username }).subtracting(Set(currentSnapshot.followers.map { $0.username }))
        
        let newlyUnfollowed = currentNonFollowersSet.subtracting(previousNonFollowersSet)
        
        return currentSnapshot.following.filter { newlyUnfollowed.contains($0.username) }
    }
    
    // Conta quanti giorni un utente non ti segue
    func getDaysUserNotFollowing(username: String) -> Int {
        var consecutiveDays = 0
        
        for snapshot in snapshots.reversed() {
            let followersSet = Set(snapshot.followers.map { $0.username })
            let followingSet = Set(snapshot.following.map { $0.username })
            
            if followingSet.contains(username) && !followersSet.contains(username) {
                consecutiveDays += 1
            } else {
                break
            }
        }
        
        return consecutiveDays
    }
}