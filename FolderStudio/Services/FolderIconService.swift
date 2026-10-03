//
//  FolderIconService.swift
//  FolderStudio
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum FolderCustomizationError: LocalizedError {
    case notWritable(String)
    case setIconFailed(String)
    case restoreFailed(String)
    case permissionDenied(String)
    case folderNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .notWritable(let path):
            return "Folder is write-protected: \(path). Check permissions in Finder Get Info."
        case .setIconFailed(let path):
            return "Failed to set icon for folder: \(path). The filesystem or system permissions may be restricting changes."
        case .restoreFailed(let path):
            return "Failed to restore original icon for folder: \(path)."
        case .permissionDenied(let path):
            return "Access denied to folder: \(path). Please re-select the folder using the Choose Folder dialog."
        case .folderNotFound(let path):
            return "Folder could not be found at path: \(path)."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notWritable:
            return "Ensure you have read and write permissions to the selected folder, or choose a folder in your user home directory."
        case .setIconFailed, .restoreFailed:
            return "Try unlocking the folder in Finder (Cmd+I) or verifying that it is on an APFS or Mac OS Extended formatted volume."
        case .permissionDenied:
            return "macOS requires explicit authorization via the system file picker to modify folders outside of the app's sandbox."
        case .folderNotFound:
            return "The folder may have been moved or deleted."
        }
    }
}

final class FolderIconService {
    static let shared = FolderIconService()
    private init() {}
    
    // MARK: - Native Open Panels
    
    /// Presents a native macOS folder picker dialog
    @MainActor
    func selectFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Select Folder to Customize"
        panel.prompt = "Choose Folder"
        panel.message = "Choose a folder on your Mac to customize its icon."
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.showsHiddenFiles = false
        
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        let response = panel.runModal()
        return response == .OK ? panel.url : nil
    }
    
    /// Presents a native macOS file picker for custom icon images
    @MainActor
    func selectCustomImage() -> NSImage? {
        let panel = NSOpenPanel()
        panel.title = "Select Custom Icon Image"
        panel.prompt = "Select Image"
        panel.message = "Choose an image file (PNG, ICNS, JPEG, TIFF) to use as the icon."
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.png, .icns, .jpeg, .tiff, .image]
        
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        let response = panel.runModal()
        if response == .OK, let url = panel.url {
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            return NSImage(contentsOf: url)
        }
        return nil
    }
    
    // MARK: - Folder Inspection
    
    /// Checks whether the folder has write permissions
    func isWritable(url: URL) -> Bool {
        return FileManager.default.isWritableFile(atPath: url.path)
    }
    
    /// Checks if the folder currently has a custom icon set
    func hasCustomIcon(for url: URL) -> Bool {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        if let values = try? url.resourceValues(forKeys: [.customIconKey]), values.customIcon != nil {
            return true
        }
        let iconPath = url.appendingPathComponent("Icon\r").path
        return FileManager.default.fileExists(atPath: iconPath)
    }
    
    /// Gets the current displayed icon for the folder
    func getCurrentIcon(for url: URL) -> NSImage {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
    
    /// Generates a security-scoped bookmark to retain access
    func createBookmark(for url: URL) -> Data? {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        return try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
    
    // MARK: - Apply & Restore
    
    /// Sets a custom icon for the specified folder URL
    @discardableResult
    func applyCustomIcon(_ image: NSImage, to url: URL) throws -> Bool {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let path = url.path
        guard FileManager.default.fileExists(atPath: path) else {
            throw FolderCustomizationError.folderNotFound(path)
        }
        guard isWritable(url: url) else {
            throw FolderCustomizationError.notWritable(path)
        }
        
        // Prepare clean icon image compatible with macOS IconServices
        let preparedImage = prepareIconForWorkspace(from: image)
        
        // Call macOS NSWorkspace API to set the icon
        let success = NSWorkspace.shared.setIcon(preparedImage, forFile: path, options: [])
        guard success else {
            throw FolderCustomizationError.setIconFailed(path)
        }
        
        // Notify Finder and trigger cache refresh
        refreshFinderCache(for: url)
        return true
    }
    
    /// Restores the original macOS folder icon
    @discardableResult
    func restoreOriginalIcon(for url: URL) throws -> Bool {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        
        let path = url.path
        guard FileManager.default.fileExists(atPath: path) else {
            throw FolderCustomizationError.folderNotFound(path)
        }
        guard isWritable(url: url) else {
            throw FolderCustomizationError.notWritable(path)
        }
        
        // Passing nil to setIcon removes the custom icon and restores original
        let success = NSWorkspace.shared.setIcon(nil, forFile: path, options: [])
        
        // Additional cleanup: Remove Icon\r file if left behind
        let iconFile = url.appendingPathComponent("Icon\r")
        if FileManager.default.fileExists(atPath: iconFile.path) {
            try? FileManager.default.removeItem(at: iconFile)
        }
        
        guard success || !hasCustomIcon(for: url) else {
            throw FolderCustomizationError.restoreFailed(path)
        }
        
        // Notify Finder and trigger cache refresh
        refreshFinderCache(for: url)
        return true
    }
    
    /// Reveals the folder in macOS Finder
    func revealInFinder(url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    // MARK: - Private Helpers
    
    private func refreshFinderCache(for url: URL) {
        // 1. Notify workspace of file system change
        NSWorkspace.shared.noteFileSystemChanged(url.path)
        
        // 2. Touch modification date to invalidate Finder's thumbnail cache
        try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
    }
    
    /// Normalizes any input image into an ImageIO-compliant PNG representation for NSWorkspace
    private func prepareIconForWorkspace(from image: NSImage) -> NSImage {
        if let pngData = image.pngData(), let cleanImage = NSImage(data: pngData) {
            cleanImage.size = NSSize(width: 512, height: 512)
            return cleanImage
        }
        return image.resized(to: NSSize(width: 512, height: 512))
    }
}
