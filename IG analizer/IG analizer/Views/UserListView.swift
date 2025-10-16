//
//  UserListView.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct UserListView: View {
    let users: [InstagramUser]
    let title: String
    let subtitle: String?
    
    init(users: [InstagramUser], title: String, subtitle: String? = nil) {
        self.users = users
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(users.count) utenti totali")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
            
            if users.isEmpty {
                Text("Nessun utente trovato")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(users) { user in
                            UserRowView(user: user)
                        }
                    }
                }
                .frame(minHeight: 200, maxHeight: .infinity)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct UserRowView: View {
    let user: InstagramUser
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(user.username)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let timestamp = user.timestamp {
                    Text(timestamp, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let profileURL = user.profileURL {
                Button(action: {
                    if let url = URL(string: profileURL) {
                        #if os(macOS)
                        NSWorkspace.shared.open(url)
                        #elseif os(iOS)
                        UIApplication.shared.open(url)
                        #endif
                    }
                }) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    UserListView(
        users: [
            InstagramUser(username: "test_user1", profileURL: "https://instagram.com/test_user1"),
            InstagramUser(username: "test_user2", profileURL: "https://instagram.com/test_user2")
        ],
        title: "Test Users",
        subtitle: "Sample user list"
    )
}