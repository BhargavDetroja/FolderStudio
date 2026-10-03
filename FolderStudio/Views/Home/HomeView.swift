//
//  HomeView.swift
//  FolderStudio
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var isDropTargeted: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Hero Section
                heroSection
                
                // Quick Folder Drop & Select Zone
                quickFolderDropZone
                
                // Getting Started Guide
                usageGuideSection
                
                // Recently Customized Folders Section
                recentFoldersSection
                
                // Featured Collections Section
                featuredCollectionsSection
            }
            .padding(28)
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                Text("Foldero for macOS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.12))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Give your folders a new look.")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                
                Text("Beautiful icon packs and a simple way to customize your macOS folders. Personalize your workspace in seconds.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 580)
            }
            
            // Primary & Secondary Actions
            HStack(spacing: 14) {
                Button {
                    chooseFolder()
                } label: {
                    Label("Choose Folder to Customize...", systemImage: "folder.fill")
                        .font(.headline)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button {
                    appState.navigateToStudio(with: IconDesign.defaultDesign)
                } label: {
                    Label("Create an Icon", systemImage: "paintpalette.fill")
                        .font(.headline)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.08),
                    Color(NSColor.controlBackgroundColor).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accentColor.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Drop Zone & Quick Selector
    
    private var quickFolderDropZone: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(isDropTargeted ? 0.25 : 0.10))
                    .frame(width: 58, height: 58)
                
                Image(systemName: isDropTargeted ? "arrow.down.folder.fill" : "folder.fill.badge.plus")
                    .font(.system(size: 26))
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 4) {
                Text(isDropTargeted ? "Drop Folder to Customize" : "Drag and drop any folder here")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("or select a folder from your Mac to customize its icon immediately")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                chooseFolder()
            } label: {
                Label("Browse Folder...", systemImage: "folder.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    isDropTargeted ? Color.accentColor : Color.accentColor.opacity(0.35),
                    style: StrokeStyle(lineWidth: isDropTargeted ? 2.5 : 1.5, dash: [6, 4])
                )
        )
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleFolderDrop(providers: providers)
        }
    }
    
    // MARK: - Usage Guide
    
    private var usageGuideSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How It Works")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Button {
                    chooseFolder()
                } label: {
                    guideCard(
                        step: "1",
                        title: "Select a Folder",
                        description: "Pick any folder on your Mac using the native file picker.",
                        iconName: "folder.fill.badge.plus",
                        tint: .blue
                    )
                }
                .buttonStyle(.plain)
                
                guideCard(
                    step: "2",
                    title: "Style Your Icon",
                    description: "Choose colors, gradients, and SF Symbols in the Studio or pick a preset.",
                    iconName: "paintpalette.fill",
                    tint: .purple
                )
                
                guideCard(
                    step: "3",
                    title: "Apply Instantly",
                    description: "Set the custom icon in one click. Revert to original anytime.",
                    iconName: "sparkles",
                    tint: .green
                )
            }
        }
    }
    
    private func guideCard(step: String, title: String, description: String, iconName: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(tint)
                }
                
                Spacer()
                
                Text(step)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
    
    // MARK: - Recently Customized Folders
    
    private var recentFoldersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recently Customized")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !appState.recentFolders.isEmpty {
                    Button("View in Settings") {
                        appState.selectedTab = .settings
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }
            
            if appState.recentFolders.isEmpty {
                HStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No customized folders yet")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Folders you customize with FolderStudio will appear here for easy access and restoration.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Customize a Folder") {
                        chooseFolder()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(18)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(appState.recentFolders.prefix(6)) { recent in
                            recentFolderCard(recent)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
    
    private func recentFolderCard(_ recent: RecentFolder) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                if let url = recent.resolveURL() {
                    Image(nsImage: FolderIconService.shared.getCurrentIcon(for: url))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: "folder.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(recent.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    
                    if let designName = recent.appliedDesignName {
                        Text(designName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Text(recent.path)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            HStack(spacing: 8) {
                if let url = recent.resolveURL() {
                    Button("Customize") {
                        appState.openCustomizer(folderURL: url)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    
                    Button("Restore") {
                        restoreRecent(recent, url: url)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    
                    Spacer()
                    
                    Button {
                        FolderIconService.shared.revealInFinder(url: url)
                    } label: {
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .help("Reveal in Finder")
                }
            }
        }
        .padding(14)
        .frame(width: 220)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func restoreRecent(_ recent: RecentFolder, url: URL) {
        do {
            try FolderIconService.shared.restoreOriginalIcon(for: url)
            IconStorageService.shared.updateRecentFolderStatus(path: recent.path, hasCustomIcon: false)
            appState.reloadRecents()
            appState.showToast(message: "Restored \"\(recent.displayName)\" icon", type: .info)
        } catch {
            appState.showToast(message: error.localizedDescription, type: .error)
        }
    }
    
    // MARK: - Featured Collections
    
    private var featuredCollectionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Featured Collections")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Browse All (\(CollectionCatalog.allCollections.count) Packs)") {
                    appState.navigateToCollection("all")
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            HStack(spacing: 16) {
                ForEach(CollectionCatalog.featuredCollections) { collection in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: collection.accentColorHex).opacity(0.2))
                                    .frame(width: 36, height: 36)
                                Image(systemName: collection.iconName)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: collection.accentColorHex))
                            }
                            
                            Spacer()
                            
                            Text("\(collection.designs.count) Icons")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(collection.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(collection.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        // Icon preview strip
                        HStack(spacing: 6) {
                            ForEach(collection.designs.prefix(4)) { design in
                                FolderThumbnailView(design: design, size: 36)
                            }
                        }
                        .padding(.top, 4)
                        
                        Button("Explore Pack") {
                            appState.navigateToCollection(collection.id)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func chooseFolder() {
        appState.triggerFolderPicker()
    }
    
    private func handleFolderDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first,
              provider.canLoadObject(ofClass: URL.self) else { return false }
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            guard let url = url,
                  (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true else {
                return
            }
            DispatchQueue.main.async {
                appState.openCustomizer(folderURL: url)
            }
        }
        return true
    }
}
