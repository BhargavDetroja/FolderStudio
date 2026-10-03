//
//  GradientConfig.swift
//  FolderStudio
//

import SwiftUI

enum GradientDirection: String, CaseIterable, Identifiable, Codable {
    case topToBottom = "Vertical"
    case diagonal = "Diagonal"
    case horizontal = "Horizontal"
    case radial = "Radial"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .topToBottom: return "arrow.down"
        case .diagonal: return "arrow.down.right"
        case .horizontal: return "arrow.right"
        case .radial: return "circle"
        }
    }
}

struct ColorPalettePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let primaryHex: String
    let secondaryHex: String
    let isGradient: Bool
}

struct PaletteCatalog {
    /// Curated solid colors
    static let solids: [ColorPalettePreset] = [
        ColorPalettePreset(id: "apple_blue", name: "Apple Blue", primaryHex: "#007AFF", secondaryHex: "#007AFF", isGradient: false),
        ColorPalettePreset(id: "indigo", name: "Indigo", primaryHex: "#5856D6", secondaryHex: "#5856D6", isGradient: false),
        ColorPalettePreset(id: "purple", name: "Royal Purple", primaryHex: "#AF52DE", secondaryHex: "#AF52DE", isGradient: false),
        ColorPalettePreset(id: "pink", name: "Hot Pink", primaryHex: "#FF2D55", secondaryHex: "#FF2D55", isGradient: false),
        ColorPalettePreset(id: "rose", name: "Dusty Rose", primaryHex: "#E11D48", secondaryHex: "#E11D48", isGradient: false),
        ColorPalettePreset(id: "coral", name: "Coral", primaryHex: "#FB7185", secondaryHex: "#FB7185", isGradient: false),
        ColorPalettePreset(id: "orange", name: "Tangerine", primaryHex: "#FF9500", secondaryHex: "#FF9500", isGradient: false),
        ColorPalettePreset(id: "amber", name: "Amber", primaryHex: "#F59E0B", secondaryHex: "#F59E0B", isGradient: false),
        ColorPalettePreset(id: "mint", name: "Mint", primaryHex: "#00C7BE", secondaryHex: "#00C7BE", isGradient: false),
        ColorPalettePreset(id: "emerald", name: "Emerald", primaryHex: "#10B981", secondaryHex: "#10B981", isGradient: false),
        ColorPalettePreset(id: "teal", name: "Teal", primaryHex: "#30B0C7", secondaryHex: "#30B0C7", isGradient: false),
        ColorPalettePreset(id: "cyan", name: "Cyan", primaryHex: "#06B6D4", secondaryHex: "#06B6D4", isGradient: false),
        ColorPalettePreset(id: "slate", name: "Slate", primaryHex: "#64748B", secondaryHex: "#64748B", isGradient: false),
        ColorPalettePreset(id: "charcoal", name: "Charcoal", primaryHex: "#334155", secondaryHex: "#334155", isGradient: false),
        ColorPalettePreset(id: "obsidian", name: "Obsidian", primaryHex: "#0F172A", secondaryHex: "#0F172A", isGradient: false),
        ColorPalettePreset(id: "classic_folder", name: "macOS Folder", primaryHex: "#3892F3", secondaryHex: "#1E70D0", isGradient: false)
    ]
    
    /// Curated rich gradient pairings
    static let gradients: [ColorPalettePreset] = [
        ColorPalettePreset(id: "sunset", name: "Sunset Glow", primaryHex: "#F43F5E", secondaryHex: "#FB923C", isGradient: true),
        ColorPalettePreset(id: "ocean", name: "Ocean Breeze", primaryHex: "#0284C7", secondaryHex: "#38BDF8", isGradient: true),
        ColorPalettePreset(id: "aurora", name: "Aurora", primaryHex: "#8B5CF6", secondaryHex: "#06B6D4", isGradient: true),
        ColorPalettePreset(id: "cyberpunk", name: "Cyberpunk", primaryHex: "#D946EF", secondaryHex: "#06B6D4", isGradient: true),
        ColorPalettePreset(id: "forest", name: "Evergreen", primaryHex: "#059669", secondaryHex: "#34D399", isGradient: true),
        ColorPalettePreset(id: "sorbet", name: "Peach Sorbet", primaryHex: "#FB7185", secondaryHex: "#FDE047", isGradient: true),
        ColorPalettePreset(id: "berry", name: "Midnight Berry", primaryHex: "#4C1D95", secondaryHex: "#BE185D", isGradient: true),
        ColorPalettePreset(id: "deep_space", name: "Deep Space", primaryHex: "#0F172A", secondaryHex: "#312E81", isGradient: true),
        ColorPalettePreset(id: "neon_lime", name: "Electric Lime", primaryHex: "#10B981", secondaryHex: "#84CC16", isGradient: true),
        ColorPalettePreset(id: "cotton_candy", name: "Cotton Candy", primaryHex: "#F472B6", secondaryHex: "#38BDF8", isGradient: true),
        ColorPalettePreset(id: "lavender_mist", name: "Lavender Mist", primaryHex: "#C084FC", secondaryHex: "#DDD6FE", isGradient: true),
        ColorPalettePreset(id: "golden_hour", name: "Golden Hour", primaryHex: "#D97706", secondaryHex: "#FDE68A", isGradient: true)
    ]
}
