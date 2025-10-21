//
//  NonFollowersHistoryView.swift
//  IG analizer
//
//  Created by Tommy on 19/10/25.
//

import SwiftUI

struct NonFollowersHistoryView: View {
    let history: FollowersHistory
    @State private var selectedSnapshot: FollowersSnapshot?
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    var nonFollowersHistory: [(date: Date, users: [InstagramUser])] {
        history.getNonFollowersHistory()
    }
    
    var filteredUsers: [InstagramUser] {
        guard let snapshot = selectedSnapshot else { 
            return [] 
        }
        
        // Step 1: Get followers usernames
        let followersUsernames = Set(snapshot.followers.map(\.username))
        
        // Step 2: Find non-followers
        let allNonFollowers = snapshot.following.filter { user in
            !followersUsernames.contains(user.username)
        }
        
        // Step 3: Apply search filter if needed
        guard !searchText.isEmpty else {
            return allNonFollowers
        }
        
        // Step 4: Filter by search text
        let searchTextLower = searchText.lowercased()
        return allNonFollowers.filter { user in
            user.username.lowercased().contains(searchTextLower)
        }
    }
    
    var body: some View {
        mainContent
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            headerSection
            Divider()
            contentArea
        }
        .frame(minWidth: 700, minHeight: 400)
        .onAppear {
            selectedSnapshot = history.snapshots.last
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(Color(hex: "EB3FCE"))
                
                Text("Storico Non Followers")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Close Button
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
            }
            
            Text("Consulta lo storico di chi non ti segue nel tempo")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
    }
    
    private var contentArea: some View {
        HStack(spacing: 0) {
            snapshotListSection
            Divider()
            userDetailsSection
        }
    }
    
    private var snapshotListSection: some View {
        VStack(spacing: 0) {
            Text("Date Snapshot")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.05))
            
            Divider()
            
            if history.snapshots.isEmpty {
                emptySnapshotsView
            } else {
                snapshotsList
            }
        }
        .frame(width: 220)
    }
    
    private var emptySnapshotsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Nessuno snapshot")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var snapshotsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(history.snapshots.reversed()) { snapshot in
                    snapshotRow(snapshot)
                    Divider()
                }
            }
        }
    }
    
    private func snapshotRow(_ snapshot: FollowersSnapshot) -> some View {
        Button(action: {
            selectedSnapshot = snapshot
        }) {
            VStack(alignment: .leading, spacing: 4) {
                Text(snapshot.date, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(snapshot.date, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.slash")
                        .font(.caption2)
                    Text("\(snapshot.nonMutualFollowingCount) non followers")
                        .font(.caption2)
                }
                .foregroundColor(Color(hex: "EB3FCE"))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedSnapshot?.id == snapshot.id ? Color(hex: "EB3FCE").opacity(0.15) : Color.clear)
        }
        .buttonStyle(.plain)
    }
    
    private var userDetailsSection: some View {
        VStack(spacing: 0) {
            if let snapshot = selectedSnapshot {
                userDetailsContent(for: snapshot)
            } else {
                emptySelectionView
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func userDetailsContent(for snapshot: FollowersSnapshot) -> some View {
        VStack(spacing: 0) {
            userDetailsHeader(for: snapshot)
            Divider()
            usersList
        }
    }
    
    private func userDetailsHeader(for snapshot: FollowersSnapshot) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Non Followers del \(snapshot.date, format: .dateTime.day().month().year())")
                    .font(.headline)
                
                Spacer()
                
                Text("\(filteredUsers.count) utenti")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            searchBar
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Cerca username...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var usersList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredUsers) { user in
                    userRow(user)
                    Divider()
                }
            }
        }
    }
    
    private func userRow(_ user: InstagramUser) -> some View {
        HStack(spacing: 12) {
            userAvatar(for: user)
            userInfo(for: user)
            Spacer()
            profileLink(for: user)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
    
    private func userAvatar(for user: InstagramUser) -> some View {
        Circle()
            .fill(Color(hex: "EB3FCE").opacity(0.2))
            .frame(width: 40, height: 40)
            .overlay(
                Text(String(user.username.prefix(1)).uppercased())
                    .font(.headline)
                    .foregroundColor(Color(hex: "EB3FCE"))
            )
    }
    
    private func userInfo(for user: InstagramUser) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(user.username)
                .font(.subheadline)
                .fontWeight(.medium)
            
            let days = history.getDaysUserNotFollowing(username: user.username)
            if days > 0 {
                Text("Non ti segue da \(days) giorn\(days == 1 ? "o" : "i")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func profileLink(for user: InstagramUser) -> some View {
        Group {
            if let profileURL = user.profileURL, let url = URL(string: profileURL) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text("Profilo")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                // Fallback: link diretto usando username
                Link(destination: URL(string: "https://instagram.com/\(user.username)")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text("Profilo")
                    }
                    .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
    
    private var emptySelectionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Seleziona una data")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Scegli uno snapshot dalla lista a sinistra per vedere chi non ti seguiva in quella data")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let sampleHistory = FollowersHistory()
    return NonFollowersHistoryView(history: sampleHistory)
}
