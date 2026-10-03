//
//  FolderCustomizerView.swift
//  FolderStudio
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum CustomizerIconSource: String, CaseIterable, Identifiable {
    case studioDesign = "Studio Design"
    case presets = "Presets"
    case customFile = "Custom Image"
    case quickColor = "Color Tint"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .studioDesign: return "paintpalette.fill"
        case .presets: return "square.grid.2x2.fill"
        case .customFile: return "photo.fill"
        case .quickColor: return "eyedropper.halffull"
        }
    }
}

struct FolderCustomizerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var initialFolderURL: URL?
    var initialDesign: IconDesign?
    
    @State private var folderURL: URL? = nil
    @State private var currentFolderIcon: NSImage? = nil
    @State private var hasCustomIcon: Bool = false
    
    // Icon Source Selection
    @State private var selectedSource: CustomizerIconSource = .studioDesign
    @State private var activeDesign: IconDesign = .defaultDesign
    @State private var customFileImage: NSImage? = nil
    @State private var customFileName: String? = nil
    
    // Quick Tint State
    @State private var tintColorHex: String = "#3892F3"
    
    // Status & Error handling
    @State private var isApplying: Bool = false
    @State private var errorMessage: String? = nil
    @State private var isSuccess: Bool = false
    
    // File Picker States
    @State private var isShowingFolderPicker: Bool = false
    @State private var isShowingImagePicker: Bool = false
    
    init(initialFolderURL: URL? = nil, initialDesign: IconDesign? = nil) {
        self.initialFolderURL = initialFolderURL
        self.initialDesign = initialDesign
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sheet Header
            headerBar
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Folder Selector / Information Card
                    folderInfoCard
                    
                    if folderURL != nil {
                        // Live Comparison Card (Current vs New)
                        liveComparisonCard
                        
                        // Icon Selection Section
                        iconSourceSection
                    } else {
                        // Empty / Call to Action State
                        folderPickerCTA
                    }
                    
                    if let error = errorMessage {
                        errorMessageBanner(error)
                    }
                }
                .padding(24)
            }
            
            Divider()
            
            // Bottom Action Bar
            bottomActionBar
        }
        .frame(width: 720, height: 640)
        .fileImporter(
            isPresented: $isShowingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                DispatchQueue.main.async {
                    self.setFolder(url)
                }
            }
        }
        .fileImporter(
            isPresented: $isShowingImagePicker,
            allowedContentTypes: [.png, .icns, .jpeg, .tiff, .image],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                if let image = NSImage(contentsOf: url) {
                    DispatchQueue.main.async {
                        setCustomImage(image, name: url.lastPathComponent)
                    }
                }
            }
        }
        .onAppear {
            initializeView()
        }
    }
    
    // MARK: - Header
    
    private var headerBar: some View {
        HStack {
            Image(systemName: "folder.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
            
            Text("Folder Customizer")
                .font(.headline)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    // MARK: - Folder Info Card
    
    private var folderInfoCard: some View {
        HStack(spacing: 16) {
            if let folderURL = folderURL {
                Image(nsImage: currentFolderIcon ?? NSWorkspace.shared.icon(forFile: folderURL.path))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(folderURL.lastPathComponent)
                            .font(.headline)
                        
                        if hasCustomIcon {
                            Text("Custom Icon")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundColor(.accentColor)
                                .cornerRadius(4)
                        } else {
                            Text("Standard macOS Icon")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.12))
                                .foregroundColor(.secondary)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(folderURL.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                Button("Change...") {
                    pickFolder()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                HStack {
                    Image(systemName: "folder")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No Folder Selected")
                            .font(.headline)
                        Text("Select a folder to view its current icon and customize it.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Select Folder...") {
                        pickFolder()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    // MARK: - Live Comparison Preview
    
    private var liveComparisonCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon Preview")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 32) {
                // Current Icon
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(NSColor.windowBackgroundColor))
                            .frame(width: 130, height: 130)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                        
                        if let currentIcon = currentFolderIcon {
                            Image(nsImage: currentIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 105, height: 105)
                        }
                    }
                    
                    Text("Current Icon")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.secondary.opacity(0.6))
                
                // New Icon Live Preview
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(NSColor.windowBackgroundColor))
                            .frame(width: 130, height: 130)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.accentColor.opacity(0.4), lineWidth: 1.5)
                            )
                        
                        switch selectedSource {
                        case .studioDesign, .presets, .quickColor:
                            FolderCanvasView(design: activeDesign, showShadow: true)
                                .frame(width: 105, height: 105)
                        case .customFile:
                            if let customImage = customFileImage {
                                Image(nsImage: customImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 105, height: 105)
                            } else {
                                VStack(spacing: 6) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 28))
                                        .foregroundColor(.secondary)
                                    Text("Choose Image")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Text("New Preview")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Icon Source Section
    
    private var iconSourceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Icon Source", selection: $selectedSource) {
                ForEach(CustomizerIconSource.allCases) { source in
                    Label(source.rawValue, systemImage: source.iconName).tag(source)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            Group {
                switch selectedSource {
                case .studioDesign:
                    studioDesignView
                case .presets:
                    presetsGridView
                case .customFile:
                    customFileView
                case .quickColor:
                    quickColorView
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
        }
    }
    
    private var studioDesignView: some View {
        HStack(spacing: 16) {
            FolderCanvasView(design: activeDesign, showShadow: true)
                .frame(width: 64, height: 64)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activeDesign.name)
                    .font(.headline)
                Text("Style: \(activeDesign.folderStyle.rawValue) • Symbol: \(activeDesign.symbolName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Edit in Studio") {
                appState.navigateToStudio(with: activeDesign)
                dismiss()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
    }
    
    private var presetsGridView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose from Curated Presets")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(allPresetDesigns.prefix(16)) { preset in
                        Button {
                            activeDesign = preset
                        } label: {
                            VStack(spacing: 4) {
                                FolderThumbnailView(design: preset, size: 54, isSelected: activeDesign.name == preset.name)
                                Text(preset.name)
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                                    .frame(width: 60)
                            }
                            .padding(6)
                            .background(activeDesign.name == preset.name ? Color.accentColor.opacity(0.12) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var customFileView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                if let customImage = customFileImage {
                    Image(nsImage: customImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 54, height: 54)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(customFileName ?? "Custom Image")
                            .font(.headline)
                        Text("Custom image will be formatted as a high-res macOS folder icon.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    Text("Select any PNG, ICNS, or JPEG image from your disk.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(customFileImage == nil ? "Choose Image..." : "Change Image...") {
                    pickCustomImage()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var quickColorView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pick a Solid Color Tint")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(PaletteCatalog.solids.prefix(10)) { preset in
                    Button {
                        tintColorHex = preset.primaryHex
                        activeDesign.primaryColorHex = preset.primaryHex
                        activeDesign.secondaryColorHex = preset.primaryHex
                        activeDesign.isGradient = false
                    } label: {
                        Circle()
                            .fill(Color(hex: preset.primaryHex))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(tintColorHex == preset.primaryHex ? Color.accentColor : Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                ColorPicker("", selection: Binding(
                    get: { Color(hex: tintColorHex) },
                    set: { color in
                        tintColorHex = color.toHex()
                        activeDesign.primaryColorHex = tintColorHex
                        activeDesign.secondaryColorHex = tintColorHex
                        activeDesign.isGradient = false
                    }
                ))
                .labelsHidden()
                .frame(width: 28, height: 28)
            }
        }
    }
    
    // MARK: - Empty / Call To Action
    
    private var folderPickerCTA: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("Choose a Folder to Begin")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Select any folder from your Mac to preview, customize, or restore its icon.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            Button("Select Folder...") {
                pickFolder()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Error Banner
    
    private func errorMessageBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.12))
        .cornerRadius(8)
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            if let folderURL = folderURL {
                Button("Reveal in Finder") {
                    FolderIconService.shared.revealInFinder(url: folderURL)
                }
                .buttonStyle(.bordered)
                .help("Show the folder in macOS Finder")
                
                if hasCustomIcon {
                    Button("Restore Original") {
                        restoreIcon()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .help("Remove custom icon and revert to system standard folder")
                }
            }
            
            Spacer()
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            
            Button {
                applyIcon()
            } label: {
                if isApplying {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Apply Icon")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(folderURL == nil || isApplying)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    // MARK: - Actions
    
    private func initializeView() {
        if let initialDesign = initialDesign {
            self.activeDesign = initialDesign
        }
        if let initialFolderURL = initialFolderURL {
            setFolder(initialFolderURL)
        }
    }
    
    private func setCustomImage(_ image: NSImage, name: String) {
        self.customFileImage = image
        self.customFileName = name
        self.selectedSource = .customFile
    }
    
    private func pickFolder() {
        isShowingFolderPicker = true
    }
    
    private func setFolder(_ url: URL) {
        self.folderURL = url
        self.currentFolderIcon = FolderIconService.shared.getCurrentIcon(for: url)
        self.hasCustomIcon = FolderIconService.shared.hasCustomIcon(for: url)
        self.errorMessage = nil
    }
    
    private func pickCustomImage() {
        isShowingImagePicker = true
    }
    
    private func applyIcon() {
        guard let folderURL = folderURL else { return }
        isApplying = true
        errorMessage = nil
        
        Task { @MainActor in
            defer { isApplying = false }
            
            let iconToApply: NSImage?
            switch selectedSource {
            case .studioDesign, .presets, .quickColor:
                iconToApply = IconRenderer.shared.renderMultiResolutionIcon(from: activeDesign)
            case .customFile:
                iconToApply = customFileImage
            }
            
            guard let finalIcon = iconToApply else {
                errorMessage = "Could not render icon image."
                return
            }
            
            do {
                try FolderIconService.shared.applyCustomIcon(finalIcon, to: folderURL)
                
                // Update local status
                self.currentFolderIcon = FolderIconService.shared.getCurrentIcon(for: folderURL)
                self.hasCustomIcon = true
                self.isSuccess = true
                
                // Add to recent folders
                let designName = selectedSource == .customFile ? "Custom Image" : activeDesign.name
                IconStorageService.shared.addRecentFolder(url: folderURL, appliedDesignName: designName)
                appState.reloadRecents()
                
                appState.showToast(message: "Applied icon to \"\(folderURL.lastPathComponent)\"", type: .success)
            } catch {
                errorMessage = error.localizedDescription
                appState.showToast(message: error.localizedDescription, type: .error)
            }
        }
    }
    
    private func restoreIcon() {
        guard let folderURL = folderURL else { return }
        isApplying = true
        errorMessage = nil
        
        Task { @MainActor in
            defer { isApplying = false }
            do {
                try FolderIconService.shared.restoreOriginalIcon(for: folderURL)
                self.currentFolderIcon = FolderIconService.shared.getCurrentIcon(for: folderURL)
                self.hasCustomIcon = false
                
                IconStorageService.shared.updateRecentFolderStatus(path: folderURL.path, hasCustomIcon: false)
                appState.reloadRecents()
                
                appState.showToast(message: "Restored original icon for \"\(folderURL.lastPathComponent)\"", type: .info)
            } catch {
                errorMessage = error.localizedDescription
                appState.showToast(message: error.localizedDescription, type: .error)
            }
        }
    }
    
    private var allPresetDesigns: [IconDesign] {
        CollectionCatalog.allCollections.flatMap { $0.designs }
    }
}
