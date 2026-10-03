//
//  SettingsView.swift
//  FolderStudio
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    @AppStorage("defaultExportFormat") private var defaultExportFormat: String = "PNG"
    @AppStorage("defaultIconSize") private var defaultIconSize: Int = 1024
    
    @State private var showingClearRecentsAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Title
                VStack(alignment: .leading, spacing: 2) {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Customize appearance, export defaults, and folder history.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 1. Appearance
                settingsCard(title: "Appearance", icon: "circle.lefthalf.filled") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Theme Mode", selection: $appAppearance) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 280)
                        
                        Text("Matches your macOS System Settings or enforces Light/Dark appearance within FolderStudio.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 2. Export Defaults
                settingsCard(title: "Export & Resolution Defaults", icon: "square.and.arrow.up") {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Default Export Size")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Size", selection: $defaultIconSize) {
                                    Text("512 × 512 px").tag(512)
                                    Text("1024 × 1024 px (Retina)").tag(1024)
                                }
                                .pickerStyle(.menu)
                                .frame(width: 200)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Export Format")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Format", selection: $defaultExportFormat) {
                                    Text("PNG Image").tag("PNG")
                                }
                                .pickerStyle(.menu)
                                .frame(width: 160)
                            }
                        }
                        
                        Text("Icons are rendered at standard Apple icon specifications with multi-resolution representations.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 3. Recently Customized Folders
                settingsCard(title: "Folder Activity History", icon: "clock.arrow.circlepath") {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tracked Folders: \(appState.recentFolders.count)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("FolderStudio remembers security bookmarks for folders you customize so you can easily restore them.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(role: .destructive) {
                                showingClearRecentsAlert = true
                            } label: {
                                Text("Clear History")
                            }
                            .buttonStyle(.bordered)
                            .disabled(appState.recentFolders.isEmpty)
                        }
                        
                        if !appState.recentFolders.isEmpty {
                            Divider()
                            
                            VStack(spacing: 8) {
                                ForEach(appState.recentFolders) { recent in
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.accentColor)
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(recent.displayName)
                                                .font(.system(size: 13, weight: .medium))
                                            Text(recent.path)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                        }
                                        
                                        Spacer()
                                        
                                        if let url = recent.resolveURL() {
                                            Button("Restore") {
                                                _ = try? FolderIconService.shared.restoreOriginalIcon(for: url)
                                                IconStorageService.shared.updateRecentFolderStatus(path: recent.path, hasCustomIcon: false)
                                                appState.reloadRecents()
                                                appState.showToast(message: "Restored \"\(recent.displayName)\"", type: .info)
                                            }
                                            .buttonStyle(.bordered)
                                            .controlSize(.small)
                                            
                                            Button {
                                                FolderIconService.shared.revealInFinder(url: url)
                                            } label: {
                                                Image(systemName: "arrow.up.right.square")
                                            }
                                            .buttonStyle(.plain)
                                            .help("Reveal in Finder")
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                
                // 4. Permissions & Sandboxing
                settingsCard(title: "Security & Permissions", icon: "lock.shield") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("App Sandbox Active")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Text("FolderStudio runs in the secure macOS App Sandbox. It only accesses folders explicitly selected by you through standard macOS file pickers. Your documents, photos, and files are never read, collected, or transmitted.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 5. About Box
                settingsCard(title: "About Foldero", icon: "info.circle") {
                    HStack(spacing: 16) {
                        Image("app_icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Foldero")
                                .font(.headline)
                            Text("Version 1.0 (Build 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Give your folders a new look. Beautiful icon packs and custom folder designs for macOS.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(28)
        }
        .confirmationDialog(
            "Clear Recent Activity?",
            isPresented: $showingClearRecentsAlert,
            titleVisibility: .visible
        ) {
            Button("Clear History", role: .destructive) {
                appState.clearRecents()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears your recent folder history in FolderStudio. Any custom folder icons already applied to your Mac will remain active.")
        }
    }
    
    private func settingsCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
            }
            
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
