//
//  IconStudioView.swift
//  FolderStudio
//

import SwiftUI

enum CanvasBackground: String, CaseIterable, Identifiable {
    case checkerboard = "Checkerboard"
    case light = "Light"
    case dark = "Dark"
    case desktop = "Desktop"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .checkerboard: return "checkerboard.rectangle"
        case .light: return "sun.max"
        case .dark: return "moon"
        case .desktop: return "macwindow"
        }
    }
}

struct IconStudioView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var canvasBackground: CanvasBackground = .dark
    @State private var showingResetAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Three-Panel Editor Area
            HStack(spacing: 0) {
                // Left Panel: Tools & Base Folder
                StudioLeftToolbar(
                    design: $appState.activeStudioDesign,
                    onChange: {
                        appState.recordDesignChange(appState.activeStudioDesign)
                    }
                )
                .frame(minWidth: 260, idealWidth: 275, maxWidth: 290)
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                // Center Canvas & Scaling Preview
                VStack(spacing: 0) {
                    // Canvas Top Bar (Controls, Background, Undo/Redo)
                    canvasTopBar
                    
                    Divider()
                    
                    // Main Canvas
                    mainCanvasArea
                    
                    Divider()
                    
                    // Size Scaling Preview Dock
                    SizePreviewBar(design: appState.activeStudioDesign)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(NSColor.windowBackgroundColor))
                }
                .frame(minWidth: 420)
                
                Divider()
                
                // Right Panel: Properties Inspector
                StudioRightInspector(
                    design: $appState.activeStudioDesign,
                    onChange: {
                        appState.recordDesignChange(appState.activeStudioDesign)
                    }
                )
                .frame(minWidth: 300, idealWidth: 315, maxWidth: 335)
                .background(Color(NSColor.windowBackgroundColor))
            }
            
            Divider()
            
            // Bottom Action Bar
            bottomStudioBar
        }
        .confirmationDialog(
            "Reset Design?",
            isPresented: $showingResetAlert,
            titleVisibility: .visible
        ) {
            Button("Reset to Default", role: .destructive) {
                appState.resetActiveDesign()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will discard any unsaved changes to this icon design.")
        }
    }
    
    // MARK: - Canvas Top Bar
    
    private var canvasTopBar: some View {
        HStack(spacing: 12) {
            // Background switcher
            Picker("Background", selection: $canvasBackground) {
                ForEach(CanvasBackground.allCases) { bg in
                    Label(bg.rawValue, systemImage: bg.iconName).tag(bg)
                }
            }
            .pickerStyle(.segmented)
            .controlSize(.small)
            .frame(width: 240)
            
            Spacer()
            
            // Undo & Redo
            HStack(spacing: 4) {
                Button {
                    appState.undo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .buttonStyle(.borderless)
                .disabled(!appState.canUndo)
                .help("Undo (Cmd+Z)")
                
                Button {
                    appState.redo()
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .buttonStyle(.borderless)
                .disabled(!appState.canRedo)
                .help("Redo (Cmd+Shift+Z)")
            }
            
            // Reset Button
            Button {
                showingResetAlert = true
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .help("Reset to default folder template")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Main Canvas Area
    
    private var mainCanvasArea: some View {
        ZStack {
            // Background Fill
            canvasBackgroundView
            
            // Central Large Folder Canvas
            FolderCanvasView(design: appState.activeStudioDesign, showShadow: true)
                .frame(width: 280, height: 280)
                .padding(30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
    
    @ViewBuilder
    private var canvasBackgroundView: some View {
        switch canvasBackground {
        case .checkerboard:
            ZStack {
                Color(NSColor.underPageBackgroundColor)
                Image(systemName: "circle.grid.2x2")
                    .resizable(resizingMode: .tile)
                    .foregroundColor(Color.primary.opacity(0.04))
            }
        case .light:
            Color(NSColor.controlBackgroundColor)
        case .dark:
            Color(red: 0.11, green: 0.13, blue: 0.18)
        case .desktop:
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.45),
                    Color(red: 0.08, green: 0.12, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Bottom Studio Bar
    
    private var bottomStudioBar: some View {
        HStack(spacing: 12) {
            Button {
                let success = IconRenderer.shared.copyToClipboard(design: appState.activeStudioDesign)
                if success {
                    appState.showToast(message: "Icon copied to clipboard", type: .success)
                }
            } label: {
                Label("Copy Image", systemImage: "doc.on.doc")
            }
            .buttonStyle(.bordered)
            .help("Copy icon to clipboard to paste into Finder Get Info")
            
            Button {
                IconRenderer.shared.exportPNG(design: appState.activeStudioDesign)
            } label: {
                Label("Export PNG...", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
            .help("Export crisp 1024x1024 PNG file")
            
            Spacer()
            
            Button {
                appState.saveActiveDesignToLibrary()
            } label: {
                Label("Save to My Icons", systemImage: "bookmark")
            }
            .buttonStyle(.bordered)
            .help("Save design for future re-use")
            
            Button {
                appState.openCustomizer(presetDesign: appState.activeStudioDesign)
            } label: {
                Label("Apply to Folder...", systemImage: "folder.fill")
            }
            .buttonStyle(.borderedProminent)
            .help("Choose a folder to apply this custom icon")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
