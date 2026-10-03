//
//  CollectionsView.swift
//  FolderStudio
//

import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject var appState: AppState
    
    // Navigation & Selection State
    @State private var selectedCollectionId: String? = nil
    @State private var selectedCategoryFilter: String = "All"
    @State private var searchText: String = ""
    @State private var selectedDesignForDetail: IconDesign? = nil
    
    // Category tags available across collections
    private let categoryFilters = [
        "All",
        "Featured",
        "Gaming & Anime",
        "Developer & Tech",
        "Aesthetic",
        "Minimalist",
        "Emoji & Fun",
        "Lifestyle"
    ]
    
    // Adaptive grids
    private let iconColumns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 18)
    ]
    
    private let packColumns = [
        GridItem(.adaptive(minimum: 320, maximum: 420), spacing: 20)
    ]
    
    // Current Active Collection (if inside Pack Detail)
    private var activeCollection: IconCollection? {
        guard let id = selectedCollectionId, id != "all" else { return nil }
        return CollectionCatalog.allCollections.first(where: { $0.id == id })
    }
    
    // Featured Spotlight Collection (Pokémon Champions is always #1)
    private var spotlightCollection: IconCollection? {
        CollectionCatalog.allCollections.first(where: { $0.id == "pokemon_champions" })
    }
    
    // Other featured collections
    private var otherFeaturedCollections: [IconCollection] {
        CollectionCatalog.featuredCollections.filter { $0.id != "pokemon_champions" }
    }
    
    // Filtered Collections in Directory
    private var filteredCollections: [IconCollection] {
        var list = CollectionCatalog.allCollections
        
        if selectedCategoryFilter == "Featured" {
            list = list.filter { $0.isFeatured }
        } else if selectedCategoryFilter != "All" {
            list = list.filter { $0.categoryTag == selectedCategoryFilter }
        }
        
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter { coll in
                coll.name.lowercased().contains(q) ||
                coll.description.lowercased().contains(q) ||
                coll.categoryTag.lowercased().contains(q) ||
                coll.designs.contains(where: { $0.name.lowercased().contains(q) })
            }
        }
        
        return list
    }
    
    // Filtered icons within the active pack
    private var filteredPackDesigns: [IconDesign] {
        guard let coll = activeCollection else { return [] }
        if searchText.isEmpty {
            return coll.designs
        }
        let q = searchText.lowercased()
        return coll.designs.filter {
            $0.name.lowercased().contains(q) ||
            $0.folderStyle.rawValue.lowercased().contains(q) ||
            $0.symbolName.lowercased().contains(q) ||
            $0.customText.lowercased().contains(q)
        }
    }
    
    // Global matching icons when searching across directory
    private var globalMatchingIcons: [IconDesign] {
        guard !searchText.isEmpty else { return [] }
        let q = searchText.lowercased()
        return CollectionCatalog.allCollections.flatMap { $0.designs }.filter {
            $0.name.lowercased().contains(q) ||
            $0.folderStyle.rawValue.lowercased().contains(q) ||
            $0.symbolName.lowercased().contains(q) ||
            $0.customText.lowercased().contains(q)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation / Header
            headerBar
            
            Divider()
            
            // Main Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if let collection = activeCollection {
                        // Level 2: Inside a specific Pack
                        packDetailView(collection)
                    } else if !searchText.isEmpty {
                        // Search Mode across all packs & icons
                        globalSearchResultsView
                    } else {
                        // Level 1: Main Packs Directory (Spotlight + Categories + Pack Cards)
                        packsDirectoryView
                    }
                }
                .padding(24)
            }
        }
        .sheet(item: $selectedDesignForDetail) { design in
            collectionDetailSheet(design)
        }
        .onAppear {
            syncFromAppState()
        }
        .onValueChange(of: appState.selectedCollectionFilter) {
            syncFromAppState()
        }
    }
    
    private func syncFromAppState() {
        if appState.selectedCollectionFilter != "all" && !appState.selectedCollectionFilter.isEmpty {
            selectedCollectionId = appState.selectedCollectionFilter
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack(spacing: 16) {
            if let collection = activeCollection {
                // Back Button & Pack Breadcrumb
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCollectionId = nil
                        appState.selectedCollectionFilter = "all"
                        searchText = ""
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                        Text("All Packs")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .frame(height: 18)
                
                HStack(spacing: 8) {
                    Image(systemName: collection.iconName)
                        .foregroundColor(Color(hex: collection.accentColorHex))
                    Text(collection.name)
                        .font(.headline)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("\(collection.iconCount) Icons")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                // Main Catalog Header
                VStack(alignment: .leading, spacing: 2) {
                    Text("Icon Packs & Collections")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Curated thematic packs ready to apply to your Mac folders or customize in Studio.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Search Input
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                TextField(
                    activeCollection != nil ? "Search in pack..." : "Search packs & icons...",
                    text: $searchText
                )
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .frame(width: 190)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }
    
    // MARK: - Level 1: Packs Directory View
    
    private var packsDirectoryView: some View {
        VStack(alignment: .leading, spacing: 28) {
            // 1. Hero Spotlight: Pokémon Champions
            if let pokemon = spotlightCollection {
                spotlightHeroCard(pokemon)
            }
            
            // 2. Secondary Featured Packs Row (Emoji Express, Developer, Retro)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Featured Spotlight Packs")
                        .font(.headline)
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(otherFeaturedCollections) { coll in
                            secondaryFeaturedCard(coll)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // 3. Category Filter Chips
            categoryFilterBar
            
            // 4. All Packs Grid
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("\(selectedCategoryFilter == "All" ? "All Icon Packs" : selectedCategoryFilter) (\(filteredCollections.count))")
                        .font(.headline)
                    Spacer()
                }
                
                LazyVGrid(columns: packColumns, spacing: 20) {
                    ForEach(filteredCollections) { coll in
                        packCatalogCard(coll)
                    }
                }
            }
        }
    }
    
    // MARK: - Spotlight Hero Card (Pokémon Champions)
    
    private func spotlightHeroCard(_ collection: IconCollection) -> some View {
        Button {
            openCollection(collection.id)
        } label: {
            HStack(spacing: 24) {
                // Left Information
                VStack(alignment: .leading, spacing: 12) {
                    // Badge Pill
                    HStack(spacing: 6) {
                        Text(collection.badge ?? "FEATURED PACK")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: collection.accentColorHex).opacity(0.25))
                            .foregroundColor(Color(hex: collection.accentColorHex))
                            .cornerRadius(6)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(collection.iconCount) Icons")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(collection.priceText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collection.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(collection.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // CTA Button
                    HStack(spacing: 8) {
                        Text("Explore Pack (\(collection.iconCount) Icons)")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: collection.accentColorHex))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right Preview Showcase (4 distinct folders)
                HStack(spacing: -16) {
                    ForEach(Array(collection.designs.prefix(4).enumerated()), id: \.element.id) { index, design in
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(NSColor.windowBackgroundColor).opacity(0.85))
                                .frame(width: 96, height: 96)
                                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            
                            FolderCanvasView(design: design, showShadow: true)
                                .frame(width: 74, height: 74)
                        }
                        .zIndex(Double(4 - index))
                    }
                }
                .padding(.trailing, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: collection.accentColorHex).opacity(0.12),
                                Color(NSColor.controlBackgroundColor)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: collection.accentColorHex).opacity(0.35), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Secondary Featured Card
    
    private func secondaryFeaturedCard(_ collection: IconCollection) -> some View {
        Button {
            openCollection(collection.id)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(hex: collection.accentColorHex).opacity(0.18))
                            .frame(width: 32, height: 32)
                        Image(systemName: collection.iconName)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: collection.accentColorHex))
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(collection.name)
                            .font(.system(size: 14, weight: .bold))
                            .lineLimit(1)
                        Text("\(collection.iconCount) icons")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let badge = collection.badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(hex: collection.accentColorHex).opacity(0.15))
                            .foregroundColor(Color(hex: collection.accentColorHex))
                            .cornerRadius(5)
                    }
                }
                
                // Icon Preview Strip
                HStack(spacing: 8) {
                    ForEach(collection.designs.prefix(4)) { design in
                        FolderThumbnailView(design: design, size: 48)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 6)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
                .cornerRadius(10)
            }
            .padding(14)
            .frame(width: 260)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Category Filter Bar
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categoryFilters, id: \.self) { filter in
                    let isSelected = selectedCategoryFilter == filter
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategoryFilter = filter
                        }
                    } label: {
                        Text(filter)
                            .font(.caption)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    // MARK: - Pack Catalog Card
    
    private func packCatalogCard(_ collection: IconCollection) -> some View {
        Button {
            openCollection(collection.id)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                // Header: Icon + Name + Badge + Price
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: collection.accentColorHex).opacity(0.18))
                            .frame(width: 32, height: 32)
                        Image(systemName: collection.iconName)
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: collection.accentColorHex))
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(collection.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text(collection.categoryTag)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        if let badge = collection.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: collection.accentColorHex).opacity(0.15))
                                .foregroundColor(Color(hex: collection.accentColorHex))
                                .cornerRadius(4)
                        }
                        
                        Text(collection.priceText)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
                
                // 4-Icon Showcase Grid
                HStack(spacing: 8) {
                    ForEach(collection.designs.prefix(4)) { design in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.windowBackgroundColor).opacity(0.6))
                                .frame(height: 64)
                            FolderCanvasView(design: design, showShadow: true)
                                .frame(width: 48, height: 48)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Description
                Text(collection.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .topLeading)
                
                Divider()
                
                // Footer: Count + Author + Action
                HStack {
                    Text("\(collection.iconCount) folder icons")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("View Pack")
                            .font(.caption)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.accentColor)
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Level 2: Pack Detail View
    
    private func packDetailView(_ collection: IconCollection) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // Pack Detail Hero Banner
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: collection.accentColorHex).opacity(0.2))
                        .frame(width: 64, height: 64)
                    Image(systemName: collection.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: collection.accentColorHex))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(collection.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let badge = collection.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: collection.accentColorHex).opacity(0.18))
                                .foregroundColor(Color(hex: collection.accentColorHex))
                                .cornerRadius(6)
                        }
                        
                        Text(collection.priceText)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    Text(collection.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Label("\(collection.iconCount) Folder Icons", systemImage: "folder.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Label(collection.author, systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Pack Actions
                VStack(spacing: 8) {
                    Button {
                        if let first = collection.designs.first {
                            appState.openCustomizer(presetDesign: first)
                        }
                    } label: {
                        Label("Apply Pack Icon...", systemImage: "folder.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        if let first = collection.designs.first {
                            appState.navigateToStudio(with: first)
                        }
                    } label: {
                        Label("Customize in Studio", systemImage: "paintpalette")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: collection.accentColorHex).opacity(0.25), lineWidth: 1)
            )
            
            // Sub-header & Count
            HStack {
                Text("Pack Icons (\(filteredPackDesigns.count))")
                    .font(.headline)
                
                Spacer()
                
                if !searchText.isEmpty {
                    Button("Clear Search") {
                        searchText = ""
                    }
                    .font(.caption)
                }
            }
            
            // Icons Grid
            if filteredPackDesigns.isEmpty {
                emptySearchState
            } else {
                LazyVGrid(columns: iconColumns, spacing: 18) {
                    ForEach(filteredPackDesigns) { design in
                        collectionIconCard(design)
                    }
                }
            }
        }
    }
    
    // MARK: - Global Search Results View
    
    private var globalSearchResultsView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Search Results for \"\(searchText)\"")
                    .font(.headline)
                Spacer()
                Button("Clear Search") {
                    searchText = ""
                }
                .font(.caption)
            }
            
            // Matching Packs
            if !filteredCollections.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Matching Packs (\(filteredCollections.count))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: packColumns, spacing: 16) {
                        ForEach(filteredCollections) { coll in
                            packCatalogCard(coll)
                        }
                    }
                }
            }
            
            // Matching Icons
            if !globalMatchingIcons.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Matching Icons (\(globalMatchingIcons.count))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: iconColumns, spacing: 18) {
                        ForEach(globalMatchingIcons) { design in
                            collectionIconCard(design)
                        }
                    }
                }
            }
            
            if filteredCollections.isEmpty && globalMatchingIcons.isEmpty {
                emptySearchState
            }
        }
    }
    
    // MARK: - Open Collection Navigation
    
    private func openCollection(_ id: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedCollectionId = id
            appState.selectedCollectionFilter = id
            searchText = ""
        }
    }
    
    // MARK: - Icon Card
    
    private func collectionIconCard(_ design: IconDesign) -> some View {
        Button {
            selectedDesignForDetail = design
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.6))
                        .frame(height: 124)
                    
                    FolderCanvasView(design: design, showShadow: true)
                        .frame(width: 92, height: 92)
                }
                
                VStack(spacing: 3) {
                    Text(design.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(design.hasBundledImage ? "Custom Artwork" : design.folderStyle.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // Quick Action Bar
                HStack(spacing: 8) {
                    Button {
                        appState.openCustomizer(presetDesign: design)
                    } label: {
                        Text("Apply")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundColor(.accentColor)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        appState.navigateToStudio(with: design)
                    } label: {
                        Text("Edit")
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(NSColor.controlBackgroundColor))
                            .foregroundColor(.secondary)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                appState.openCustomizer(presetDesign: design)
            } label: {
                Label("Apply to Folder...", systemImage: "folder.fill")
            }
            
            Button {
                appState.navigateToStudio(with: design)
            } label: {
                Label("Open in Icon Studio", systemImage: "paintpalette")
            }
            
            Button {
                appState.saveDesignToLibrary(design)
            } label: {
                Label("Save to My Icons", systemImage: "bookmark")
            }
            
            Divider()
            
            Button {
                let _ = IconRenderer.shared.copyToClipboard(design: design)
                appState.showToast(message: "Icon copied to clipboard", type: .success)
            } label: {
                Label("Copy Image", systemImage: "doc.on.doc")
            }
            
            Button {
                IconRenderer.shared.exportPNG(design: design)
            } label: {
                Label("Export PNG...", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    // MARK: - Detail Sheet
    
    private func collectionDetailSheet(_ design: IconDesign) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(design.name)
                    .font(.headline)
                Spacer()
                Button("Done") {
                    selectedDesignForDetail = nil
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(20)
            
            Divider()
            
            VStack(spacing: 24) {
                // Large Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .frame(width: 220, height: 220)
                    
                    FolderCanvasView(design: design, showShadow: true)
                        .frame(width: 170, height: 170)
                }
                
                // Specs
                HStack(spacing: 20) {
                    VStack {
                        Text("Style")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(design.hasBundledImage ? "Artwork" : design.folderStyle.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    VStack {
                        Text(design.hasBundledImage ? "Type" : (design.overlayType == .symbol ? "Symbol" : (design.overlayType == .emoji ? "Emoji" : "Text")))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(design.hasBundledImage ? "Custom Artwork" : (design.overlayType == .symbol ? design.symbolName : design.customText))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    VStack {
                        Text("Colors")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Circle().fill(Color(hex: design.primaryColorHex)).frame(width: 12, height: 12)
                            if design.isGradient {
                                Circle().fill(Color(hex: design.secondaryColorHex)).frame(width: 12, height: 12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button {
                        selectedDesignForDetail = nil
                        appState.navigateToStudio(with: design)
                    } label: {
                        Label("Customize in Studio", systemImage: "paintpalette")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        appState.saveDesignToLibrary(design)
                        selectedDesignForDetail = nil
                    } label: {
                        Label("Save to My Icons", systemImage: "bookmark")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        selectedDesignForDetail = nil
                        appState.openCustomizer(presetDesign: design)
                    } label: {
                        Label("Apply to Folder...", systemImage: "folder.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(30)
            
            Spacer()
        }
        .frame(width: 520, height: 480)
    }
    
    // MARK: - Empty State
    
    private var emptySearchState: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("No Results Found")
                .font(.headline)
            Text("No icon packs or folders matched \"\(searchText)\". Try another search keyword or browse All Packs.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}
