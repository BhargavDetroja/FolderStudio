//
//  IconStorageService.swift
//  FolderStudio
//

import Foundation

final class IconStorageService {
    static let shared = IconStorageService()
    
    private let fileManager = FileManager.default
    private let appSupportDirectory: URL
    private let iconsFileURL: URL
    private let recentsFileURL: URL
    
    private init() {
        let baseAppSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = baseAppSupport.appendingPathComponent("com.bhargavdetroja.FolderStudio", isDirectory: true)
        self.appSupportDirectory = appDir
        self.iconsFileURL = appDir.appendingPathComponent("saved_icons.json")
        self.recentsFileURL = appDir.appendingPathComponent("recent_folders.json")
        
        createDirectoryIfNeeded()
    }
    
    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: appSupportDirectory.path) {
            try? fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Saved Icons Persistence
    
    func loadSavedIcons() -> [IconDesign] {
        guard fileManager.fileExists(atPath: iconsFileURL.path),
              let data = try? Data(contentsOf: iconsFileURL) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([IconDesign].self, from: data)) ?? []
    }
    
    func saveIcons(_ icons: [IconDesign]) {
        createDirectoryIfNeeded()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(icons) {
            try? data.write(to: iconsFileURL, options: .atomic)
        }
    }
    
    func saveIcon(_ design: IconDesign) {
        var icons = loadSavedIcons()
        if let index = icons.firstIndex(where: { $0.id == design.id }) {
            icons[index] = design
            icons[index].modifiedAt = Date()
        } else {
            var newDesign = design
            newDesign.modifiedAt = Date()
            icons.insert(newDesign, at: 0)
        }
        saveIcons(icons)
    }
    
    func deleteIcon(id: UUID) {
        var icons = loadSavedIcons()
        icons.removeAll(where: { $0.id == id })
        saveIcons(icons)
    }
    
    // MARK: - Recent Folders Persistence
    
    func loadRecentFolders() -> [RecentFolder] {
        guard fileManager.fileExists(atPath: recentsFileURL.path),
              let data = try? Data(contentsOf: recentsFileURL) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([RecentFolder].self, from: data)) ?? []
    }
    
    func saveRecentFolders(_ recents: [RecentFolder]) {
        createDirectoryIfNeeded()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(recents) {
            try? data.write(to: recentsFileURL, options: .atomic)
        }
    }
    
    func addRecentFolder(url: URL, appliedDesignName: String?) {
        var recents = loadRecentFolders()
        let path = url.path
        let displayName = url.lastPathComponent
        let bookmark = FolderIconService.shared.createBookmark(for: url)
        
        // Remove existing duplicate if present
        recents.removeAll(where: { $0.path == path })
        
        let recent = RecentFolder(
            id: UUID(),
            path: path,
            displayName: displayName,
            bookmarkData: bookmark,
            customizedAt: Date(),
            hasCustomIcon: true,
            appliedDesignName: appliedDesignName
        )
        recents.insert(recent, at: 0)
        
        // Keep top 20 recents
        if recents.count > 20 {
            recents = Array(recents.prefix(20))
        }
        saveRecentFolders(recents)
    }
    
    func updateRecentFolderStatus(path: String, hasCustomIcon: Bool) {
        var recents = loadRecentFolders()
        if let index = recents.firstIndex(where: { $0.path == path }) {
            recents[index].hasCustomIcon = hasCustomIcon
            saveRecentFolders(recents)
        }
    }
    
    func clearRecents() {
        saveRecentFolders([])
    }
}
