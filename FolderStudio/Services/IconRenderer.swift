//
//  IconRenderer.swift
//  FolderStudio
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

final class IconRenderer {
    static let shared = IconRenderer()
    private init() {}
    
    // MARK: - Rendering
    
    /// Renders an IconDesign to a high-resolution NSImage (default 1024x1024)
    @MainActor
    func renderImage(from design: IconDesign, targetSize: CGFloat = 1024) -> NSImage? {
        if let bundledName = design.bundledImageName,
           let bundledImage = NSImage.loadBundledIcon(named: bundledName) {
            let image = NSImage(size: NSSize(width: targetSize, height: targetSize))
            image.lockFocus()
            NSGraphicsContext.current?.imageInterpolation = .high
            bundledImage.draw(
                in: NSRect(x: 0, y: 0, width: targetSize, height: targetSize),
                from: NSRect(x: 0, y: 0, width: bundledImage.size.width, height: bundledImage.size.height),
                operation: .copy,
                fraction: 1.0
            )
            image.unlockFocus()
            return image
        }
        
        let canvas = FolderCanvasView(design: design, showShadow: true)
            .frame(width: targetSize, height: targetSize)
        
        let renderer = ImageRenderer(content: canvas)
        renderer.scale = 1.0
        if let cgImage = renderer.cgImage {
            let rep = NSBitmapImageRep(cgImage: cgImage)
            rep.size = NSSize(width: targetSize, height: targetSize)
            let image = NSImage(size: NSSize(width: targetSize, height: targetSize))
            image.addRepresentation(rep)
            return image
        } else if let nsImage = renderer.nsImage {
            nsImage.size = NSSize(width: targetSize, height: targetSize)
            return nsImage
        }
        return nil
    }
    
    /// Generates clean icon for macOS folder customization
    @MainActor
    func renderMultiResolutionIcon(from design: IconDesign) -> NSImage? {
        guard let baseImage = renderImage(from: design, targetSize: 1024) else { return nil }
        
        // Ensure image has a clean, standard ImageIO-compatible representation
        if let pngData = baseImage.pngData(), let cleanImage = NSImage(data: pngData) {
            cleanImage.size = NSSize(width: 512, height: 512)
            return cleanImage
        }
        return baseImage
    }
    
    // MARK: - Export & Clipboard
    
    /// Copies rendered icon to the system clipboard
    @MainActor
    func copyToClipboard(design: IconDesign) -> Bool {
        guard let image = renderImage(from: design, targetSize: 1024) else { return false }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        return pasteboard.writeObjects([image])
    }
    
    /// Opens NSSavePanel and exports the icon as PNG
    @MainActor
    func exportPNG(design: IconDesign, defaultName: String? = nil) {
        let suggestedName = (defaultName ?? design.name)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased() + ".png"
        
        let panel = NSSavePanel()
        panel.title = "Export Folder Icon"
        panel.nameFieldStringValue = suggestedName
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.prompt = "Export"
        panel.message = "Export your custom icon as a high-resolution PNG image."
        
        if panel.runModal() == .OK, let url = panel.url {
            if let image = renderImage(from: design, targetSize: 1024),
               let pngData = image.pngData() {
                try? pngData.write(to: url)
            }
        }
    }
}
