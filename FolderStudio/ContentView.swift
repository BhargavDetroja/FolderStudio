//
//  ContentView.swift
//  FolderStudio
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    
    @State private var isDropTargeted: Bool = false
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $appState.selectedTab) {
                ForEach(NavigationTab.allCases) { tab in
                    HStack {
                        Label(tab.rawValue, systemImage: tab.iconName)
                        
                        Spacer()
                        
                        if tab == .myIcons && !appState.savedIcons.isEmpty {
                            Text("\(appState.savedIcons.count)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.12))
                                .cornerRadius(8)
                        }
                    }
                    .tag(tab)
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 190, ideal: 210, max: 250)
        } detail: {
            // Detail Content
            ZStack(alignment: .top) {
                Group {
                    switch appState.selectedTab {
                    case .home:
                        HomeView()
                    case .studio:
                        IconStudioView()
                    case .collections:
                        CollectionsView()
                    case .myIcons:
                        MyIconsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating Toast Notification Banner
                if let toast = appState.toastMessage {
                    ToastBannerView(message: toast, type: appState.toastType)
                        .padding(.top, 16)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button {
                        appState.triggerFolderPicker()
                    } label: {
                        Label("Customize Folder", systemImage: "folder.fill")
                    }
                    .help("Select a folder on your Mac to customize")
                }
            }
        }
        .frame(minWidth: 980, minHeight: 640)
        .preferredColorScheme(colorScheme)
        .fileImporter(
            isPresented: $appState.isFolderPickerPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                appState.openCustomizer(folderURL: url)
            }
        }
        .sheet(
            isPresented: $appState.isCustomizerPresented,
            onDismiss: {
                DispatchQueue.main.async {
                    appState.customizerTargetFolder = nil
                    appState.customizerPresetDesign = nil
                }
            }
        ) {
            FolderCustomizerView(
                initialFolderURL: appState.customizerTargetFolder,
                initialDesign: appState.customizerPresetDesign ?? appState.activeStudioDesign
            )
            .id(appState.customizerTargetFolder?.path ?? "customizer")
            .environmentObject(appState)
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleFolderDrop(providers: providers)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appAppearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
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

#Preview {
    ContentView()
        .environmentObject(AppState())
}
