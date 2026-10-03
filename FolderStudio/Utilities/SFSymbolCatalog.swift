//
//  SFSymbolCatalog.swift
//  FolderStudio
//

import Foundation

struct SymbolCategory: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let symbols: [String]
}

struct SFSymbolCatalog {
    static let categories: [SymbolCategory] = [
        SymbolCategory(
            id: "popular",
            name: "Popular",
            icon: "star.fill",
            symbols: [
                "folder.fill", "star.fill", "heart.fill", "sparkles",
                "briefcase.fill", "terminal.fill", "chevron.left.forwardslash.chevron.right",
                "cpu.fill", "camera.fill", "music.note", "paintpalette.fill",
                "book.fill", "archivebox.fill", "shield.fill", "globe.americas.fill",
                "leaf.fill", "flame.fill", "bolt.fill", "lock.fill", "tag.fill"
            ]
        ),
        SymbolCategory(
            id: "development",
            name: "Development",
            icon: "curlybraces",
            symbols: [
                "terminal.fill", "chevron.left.forwardslash.chevron.right", "curlybraces",
                "cpu.fill", "server.rack", "externaldrive.fill.badge.icloud",
                "network", "shippingbox.fill", "laptopcomputer", "ant.fill",
                "hammer.fill", "wrench.and.screwdriver.fill", "gearshape.2.fill",
                "tray.and.arrow.down.fill", "arrow.triangle.branch", "point.3.connected.trianglepath.dotted",
                "command", "memorychip", "cable.connector", "opticaldiscdrive.fill"
            ]
        ),
        SymbolCategory(
            id: "creative",
            name: "Creative & Media",
            icon: "paintpalette.fill",
            symbols: [
                "paintpalette.fill", "camera.fill", "film.fill", "music.note",
                "waveform", "pencil.and.outline", "photo.fill", "theatermasks.fill",
                "mic.fill", "paintbrush.fill", "eyeglasses", "sparkles",
                "wand.and.stars", "swatchpalette.fill", "headphones", "speaker.wave.3.fill",
                "video.fill", "slider.horizontal.3", "dial.low.fill", "eyedropper.halffull"
            ]
        ),
        SymbolCategory(
            id: "workspace",
            name: "Workspace & Office",
            icon: "briefcase.fill",
            symbols: [
                "briefcase.fill", "doc.text.fill", "doc.on.doc.fill", "chart.bar.fill",
                "chart.pie.fill", "calendar", "tray.full.fill", "archivebox.fill",
                "checklist", "bookmark.fill", "tag.fill", "person.2.fill",
                "building.2.fill", "newspaper.fill", "envelope.fill", "phone.fill",
                "signature", "paperclip", "bell.fill", "clock.fill"
            ]
        ),
        SymbolCategory(
            id: "commerce",
            name: "Finance & Commerce",
            icon: "creditcard.fill",
            symbols: [
                "banknote.fill", "creditcard.fill", "cart.fill", "bag.fill",
                "chart.line.uptrend.xyaxis", "dollarsign.circle.fill", "eurosign.circle.fill",
                "yensign.circle.fill", "bitcoinsign.circle.fill", "percent",
                "giftcard.fill", "shippingbox.and.arrow.backward.fill", "storefront.fill",
                "lock.square.fill", "chart.xyaxis.line"
            ]
        ),
        SymbolCategory(
            id: "nature",
            name: "Nature & Places",
            icon: "leaf.fill",
            symbols: [
                "leaf.fill", "flame.fill", "drop.fill", "sun.max.fill",
                "moon.stars.fill", "cloud.sun.fill", "cloud.rain.fill", "snow",
                "tree.fill", "mountain.2.fill", "globe.americas.fill", "airplane",
                "car.fill", "house.fill", "tent.fill", "pawprint.fill",
                "fish.fill", "bird.fill", "sunset.fill", "water.waves"
            ]
        ),
        SymbolCategory(
            id: "badges",
            name: "Badges & Badges",
            icon: "shield.fill",
            symbols: [
                "shield.fill", "checkmark.seal.fill", "rosette", "medal.fill",
                "flag.fill", "pin.fill", "target", "crown.fill",
                "key.fill", "lock.shield.fill", "exclamationmark.triangle.fill",
                "info.circle.fill", "questionmark.circle.fill", "hand.thumbsup.fill"
            ]
        )
    ]
    
    /// Flat list of all unique symbols
    static let allSymbols: [String] = {
        var set = Set<String>()
        var list: [String] = []
        for category in categories {
            for symbol in category.symbols {
                if !set.contains(symbol) {
                    set.insert(symbol)
                    list.append(symbol)
                }
            }
        }
        return list
    }()
    
    /// Search symbols matching query
    static func search(query: String) -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return allSymbols }
        
        // Return matching items from all catalog
        let matches = allSymbols.filter { $0.lowercased().contains(trimmed) }
        
        // Also if the query looks like a valid SF symbol name not in our catalog, include it first
        if !matches.contains(trimmed) && trimmed.contains(".") {
            return [trimmed] + matches
        }
        return matches
    }
}
