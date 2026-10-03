//
//  Extensions.swift
//  FolderStudio
//

import SwiftUI
import AppKit

// MARK: - Color Hex Extensions
extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255) // Default Apple Blue fallback
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
    
    func toHex() -> String {
        guard let components = NSColor(self).usingColorSpace(.sRGB) else {
            return "#007AFF"
        }
        let r = Int(components.redComponent * 255.0)
        let g = Int(components.greenComponent * 255.0)
        let b = Int(components.blueComponent * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - NSImage Extensions
extension NSImage {
    /// Converts NSImage to PNG data representation
    func pngData() -> Data? {
        if let tiffRepresentation = self.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffRepresentation),
           let png = bitmapImage.representation(using: .png, properties: [:]) {
            return png
        }
        var rect = NSRect(origin: .zero, size: self.size)
        if let cgImage = self.cgImage(forProposedRect: &rect, context: nil, hints: nil) {
            let bitmapImage = NSBitmapImageRep(cgImage: cgImage)
            return bitmapImage.representation(using: .png, properties: [:])
        }
        return nil
    }
    
    /// Returns a resized copy of the NSImage using CoreGraphics bitmap context
    func resized(to newSize: NSSize) -> NSImage {
        let width = Int(newSize.width)
        let height = Int(newSize.height)
        guard width > 0 && height > 0 else { return self }
        
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return self
        }
        
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        self.draw(in: NSRect(origin: .zero, size: newSize),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        if let cgImage = context.makeImage() {
            let rep = NSBitmapImageRep(cgImage: cgImage)
            rep.size = newSize
            let result = NSImage(size: newSize)
            result.addRepresentation(rep)
            return result
        }
        return self
    }
    
    /// Safely loads a bundled or asset catalog icon image
    static func loadBundledIcon(named name: String) -> NSImage? {
        if let image = NSImage(named: NSImage.Name(name)) {
            return image
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "png") {
            return NSImage(contentsOf: url)
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "PokemonIcons") {
            return NSImage(contentsOf: url)
        }
        return nil
    }
}

// MARK: - View Helpers
extension View {
    /// Applies conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Backwards-compatible value change observer supporting macOS 13, 14, and newer
    @ViewBuilder
    func onValueChange<V: Equatable>(of value: V, perform action: @escaping () -> Void) -> some View {
        if #available(macOS 14.0, *) {
            self.onChange(of: value) {
                action()
            }
        } else {
            self.onChange(of: value) { _ in
                action()
            }
        }
    }
}
