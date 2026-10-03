//
//  IconDesign.swift
//  FolderStudio
//

import SwiftUI

enum OverlayType: String, CaseIterable, Identifiable, Codable {
    case symbol = "SF Symbol"
    case emoji = "Emoji"
    case text = "Text"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .symbol: return "star.fill"
        case .emoji: return "face.smiling.inverse"
        case .text: return "textformat"
        }
    }
}

enum SymbolColorMode: String, CaseIterable, Identifiable, Codable {
    case monochrome = "Monochrome"
    case hierarchical = "Hierarchical"
    case multicolor = "Multicolor"
    
    var id: String { rawValue }
}

struct IconDesign: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String = "Untitled Folder"
    var folderStyle: FolderStyle = .classic
    
    // Background & Colors
    var primaryColorHex: String = "#3892F3"
    var secondaryColorHex: String = "#1E70D0"
    var isGradient: Bool = false
    var gradientDirection: GradientDirection = .topToBottom
    
    // Overlay mode
    var overlayType: OverlayType = .symbol
    
    // Symbol properties
    var symbolName: String = "folder.fill"
    var symbolColorMode: SymbolColorMode = .monochrome
    var symbolColorHex: String = "#FFFFFF"
    var symbolScale: Double = 0.52
    var symbolOffsetX: Double = 0.0
    var symbolOffsetY: Double = 0.0
    var symbolRotation: Double = 0.0
    
    // Text / Emoji properties
    var customText: String = "DOCS"
    var textColorHex: String = "#FFFFFF"
    var textSize: Double = 28.0
    
    // Badge Container properties
    var badgeShape: BadgeShape = .none
    var badgeColorHex: String = "#000000"
    var badgeOpacity: Double = 0.25
    var badgeScale: Double = 0.65
    
    // Bundled Artwork Image (e.g. custom character face folder icons)
    var bundledImageName: String? = nil
    
    var hasBundledImage: Bool {
        bundledImageName != nil
    }
    
    // Timestamps
    var createdAt: Date = Date()
    var modifiedAt: Date = Date()
    
    // Default starting design
    static var defaultDesign: IconDesign {
        IconDesign(
            id: UUID(),
            name: "Developer Folder",
            folderStyle: .classic,
            primaryColorHex: "#3892F3",
            secondaryColorHex: "#1E70D0",
            isGradient: false,
            gradientDirection: .topToBottom,
            overlayType: .symbol,
            symbolName: "terminal.fill",
            symbolColorMode: .monochrome,
            symbolColorHex: "#FFFFFF",
            symbolScale: 0.50,
            symbolOffsetX: 0.0,
            symbolOffsetY: 0.0,
            symbolRotation: 0.0,
            customText: "DEV",
            textColorHex: "#FFFFFF",
            textSize: 28.0,
            badgeShape: .none,
            badgeColorHex: "#000000",
            badgeOpacity: 0.25,
            badgeScale: 0.65,
            createdAt: Date(),
            modifiedAt: Date()
        )
    }
}
