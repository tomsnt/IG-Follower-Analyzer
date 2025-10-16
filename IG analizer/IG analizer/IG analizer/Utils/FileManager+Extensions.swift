//
//  FileManager+Extensions.swift
//  IG analizer
//
//  Created by Tommy on 15/10/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension FileManager {
    static func loadInstagramFile(from url: URL) -> String? {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content
        } catch {
            print("Error loading file: \(error)")
            return nil
        }
    }
    
    // Deprecated: Use loadInstagramFile instead
    static func loadHTMLFile(from url: URL) -> String? {
        return loadInstagramFile(from: url)
    }
    
    static func saveFollowersData(_ followers: [InstagramUser], to fileName: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("\(fileName).json")
        
        do {
            let data = try JSONEncoder().encode(followers)
            try data.write(to: fileURL)
        } catch {
            print("Error saving followers data: \(error)")
        }
    }
    
    static func loadFollowersData(from fileName: String) -> [InstagramUser]? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("\(fileName).json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let followers = try JSONDecoder().decode([InstagramUser].self, from: data)
            return followers
        } catch {
            print("Error loading followers data: \(error)")
            return nil
        }
    }
}