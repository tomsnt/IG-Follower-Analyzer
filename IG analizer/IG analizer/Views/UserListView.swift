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
                    .foregroundColor(Color(red: 0.918, green: 0.247, blue: 0.808)) // Fucsia principale
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(users.count) utenti totali")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.961, green: 0.800, blue: 0.047)) // Giallo brillante
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
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.918, green: 0.247, blue: 0.808).opacity(0.05), // Fucsia molto trasparente
                    Color(red: 0.545, green: 0.361, blue: 0.965).opacity(0.03)  // Viola ancora più trasparente
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

struct UserRowView: View {
    let user: InstagramUser
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .foregroundColor(Color(red: 0.545, green: 0.361, blue: 0.965)) // Viola secondario
            
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(user.username)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
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