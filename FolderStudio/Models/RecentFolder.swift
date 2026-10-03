//
//  RecentFolder.swift
//  FolderStudio
//

import Foundation

struct RecentFolder: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var path: String
    var displayName: String
    var bookmarkData: Data?
    var customizedAt: Date = Date()
    var hasCustomIcon: Bool = true
    var appliedDesignName: String?
    
    /// Resolves folder URL, trying security-scoped bookmark first, falling back to file path
    func resolveURL() -> URL? {
        if let bookmarkData = bookmarkData {
            var isStale = false
            if let resolved = try? URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            ) {
                return resolved
            }
        }
        let url = URL(fileURLWithPath: path)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}
