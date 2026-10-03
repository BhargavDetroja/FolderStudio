//
//  MyIconsView.swift
//  FolderStudio
//

import SwiftUI

struct MyIconsView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var iconToDelete: IconDesign? = nil
    @State private var showingDeleteAlert: Bool = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 170, maximum: 210), spacing: 20)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerBar
            
            Divider()
            
            // Content
            ScrollView {
                if appState.savedIcons.isEmpty {
                    emptyLibraryState
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(appState.savedIcons) { design in
                            myIconCard(design)
                        }
                    }
                    .padding(24)
                }
            }
        }
        .confirmationDialog(
            "Delete \"\(iconToDelete?.name ?? "Icon")\"?",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete Icon", role: .destructive) {
                if let design = iconToDelete {
                    appState.deleteSavedIcon(id: design.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This icon design will be permanently removed from your library.")
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("My Icons")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !appState.savedIcons.isEmpty {
                        Text("\(appState.savedIcons.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.15))
                            .foregroundColor(.secondary)
                            .cornerRadius(10)
                    }
                }
                
                Text("Your personal library of custom folder designs.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                appState.navigateToStudio(with: IconDesign.defaultDesign)
            } label: {
                Label("New Icon", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Icon Card
    
    private func myIconCard(_ design: IconDesign) -> some View {
        VStack(spacing: 12) {
            // Preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .frame(height: 130)
                
                FolderCanvasView(design: design, showShadow: true)
                    .frame(width: 96, height: 96)
            }
            
            // Info
            VStack(spacing: 3) {
                Text(design.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("Modified \(formattedDate(design.modifiedAt))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // Card Button Row
            HStack(spacing: 6) {
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
                .help("Apply this icon to a folder")
                
                Button {
                    appState.navigateToStudio(with: design)
                } label: {
                    Text("Edit")
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(NSColor.controlBackgroundColor))
                        .foregroundColor(.primary)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help("Edit this design in Icon Studio")
                
                Spacer()
                
                Menu {
                    Button {
                        appState.duplicateSavedIcon(design)
                    } label: {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    
                    Button {
                        IconRenderer.shared.exportPNG(design: design)
                    } label: {
                        Label("Export PNG...", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        let _ = IconRenderer.shared.copyToClipboard(design: design)
                        appState.showToast(message: "Icon copied to clipboard", type: .success)
                    } label: {
                        Label("Copy Image", systemImage: "doc.on.doc")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        iconToDelete = design
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete...", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 20)
            }
        }
        .padding(14)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - Empty State
    
    private var emptyLibraryState: some View {
        VStack(spacing: 18) {
            Image(systemName: "folder.fill")
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.7))
            
            Text("No Saved Icons Yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Create custom folder designs in Icon Studio or save any preset from Collections to build your personal icon catalog.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            
            HStack(spacing: 12) {
                Button {
                    appState.navigateToStudio(with: IconDesign.defaultDesign)
                } label: {
                    Label("Create an Icon", systemImage: "paintpalette.fill")
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    appState.selectedTab = .collections
                } label: {
                    Label("Browse Collections", systemImage: "square.grid.2x2")
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
