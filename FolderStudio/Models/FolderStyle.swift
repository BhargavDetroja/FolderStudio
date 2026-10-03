//
//  FolderStyle.swift
//  FolderStudio
//

import SwiftUI

enum FolderStyle: String, CaseIterable, Identifiable, Codable {
    case minimal = "Minimal"
    case softPastel = "Soft Pastel"
    case dark = "Dark"
    case neon = "Neon"
    case glass = "Glass"
    case classic = "Classic macOS"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .minimal:
            return "Clean, modern design with flat accents and crisp contours."
        case .softPastel:
            return "Gentle, warm pastel aesthetics with soft diffused illumination."
        case .dark:
            return "Deep obsidian and slate tones with sleek edge highlights."
        case .neon:
            return "High-energy duo-tone gradients with luminous contrast."
        case .glass:
            return "Frosted translucent glass effect with glossy top specular shine."
        case .classic:
            return "Authentic Apple Aqua blue folder aesthetic."
        }
    }
    
    var iconName: String {
        switch self {
        case .minimal: return "square"
        case .softPastel: return "paintpalette"
        case .dark: return "moon.fill"
        case .neon: return "bolt.fill"
        case .glass: return "circle.hexagongrid.fill"
        case .classic: return "folder.fill"
        }
    }
    
    /// Default primary color for this style
    var defaultPrimaryHex: String {
        switch self {
        case .minimal: return "#3A82F6"
        case .softPastel: return "#F472B6"
        case .dark: return "#1E293B"
        case .neon: return "#8B5CF6"
        case .glass: return "#0EA5E9"
        case .classic: return "#2563EB"
        }
    }
    
    /// Default secondary color for this style
    var defaultSecondaryHex: String {
        switch self {
        case .minimal: return "#60A5FA"
        case .softPastel: return "#FBCFE8"
        case .dark: return "#0F172A"
        case .neon: return "#EC4899"
        case .glass: return "#38BDF8"
        case .classic: return "#1D4ED8"
        }
    }
}
