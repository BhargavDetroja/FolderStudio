//
//  AppState.swift
//  FolderStudio
//

import SwiftUI
import Combine

enum NavigationTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case studio = "Icon Studio"
    case collections = "Collections"
    case myIcons = "My Icons"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .studio: return "paintpalette.fill"
        case .collections: return "square.grid.2x2.fill"
        case .myIcons: return "folder.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

enum ToastType {
    case info
    case success
    case error
    
    var color: Color {
        switch self {
        case .info: return .blue
        case .success: return .green
        case .error: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}

final class AppState: ObservableObject {
    @Published var selectedTab: NavigationTab = .home
    @Published var selectedCollectionFilter: String = "all"
    
    // Active Studio Design & History
    @Published var activeStudioDesign: IconDesign = IconDesign.defaultDesign
    @Published private(set) var undoStack: [IconDesign] = []
    @Published private(set) var redoStack: [IconDesign] = []
    
    // Stored Library
    @Published var savedIcons: [IconDesign] = []
    @Published var recentFolders: [RecentFolder] = []
    
    // Folder Customizer Presentation Sheet
    @Published var isFolderPickerPresented: Bool = false
    @Published var isCustomizerPresented: Bool = false
    @Published var customizerTargetFolder: URL? = nil
    @Published var customizerPresetDesign: IconDesign? = nil
    
    // Toast Feedback
    @Published var toastMessage: String? = nil
    @Published var toastType: ToastType = .info
    private var toastTask: Task<Void, Never>? = nil
    
    init() {
        loadData()
    }
    
    func loadData() {
        self.savedIcons = IconStorageService.shared.loadSavedIcons()
        self.recentFolders = IconStorageService.shared.loadRecentFolders()
    }
    
    // MARK: - Navigation Helpers
    
    func triggerFolderPicker() {
        DispatchQueue.main.async {
            self.isFolderPickerPresented = true
        }
    }
    
    func navigateToStudio(with design: IconDesign? = nil) {
        DispatchQueue.main.async {
            if let design = design {
                self.activeStudioDesign = design
                self.undoStack.removeAll()
                self.redoStack.removeAll()
            }
            self.selectedTab = .studio
        }
    }
    
    func navigateToCollection(_ collectionId: String = "all") {
        DispatchQueue.main.async {
            self.selectedCollectionFilter = collectionId
            self.selectedTab = .collections
        }
    }
    
    func openCustomizer(folderURL: URL? = nil, presetDesign: IconDesign? = nil) {
        DispatchQueue.main.async {
            self.customizerTargetFolder = folderURL
            self.customizerPresetDesign = presetDesign
            self.isCustomizerPresented = true
        }
    }
    
    // MARK: - Undo & Redo for Icon Studio
    
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    
    func recordDesignChange(_ newDesign: IconDesign) {
        guard newDesign != activeStudioDesign else { return }
        undoStack.append(activeStudioDesign)
        if undoStack.count > 30 {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
        activeStudioDesign = newDesign
    }
    
    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(activeStudioDesign)
        activeStudioDesign = previous
    }
    
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(activeStudioDesign)
        activeStudioDesign = next
    }
    
    func resetActiveDesign() {
        recordDesignChange(IconDesign.defaultDesign)
    }
    
    // MARK: - Library Operations
    
    func saveActiveDesignToLibrary() {
        IconStorageService.shared.saveIcon(activeStudioDesign)
        self.savedIcons = IconStorageService.shared.loadSavedIcons()
        showToast(message: "Saved \"\(activeStudioDesign.name)\" to My Icons", type: .success)
    }
    
    func saveDesignToLibrary(_ design: IconDesign) {
        IconStorageService.shared.saveIcon(design)
        self.savedIcons = IconStorageService.shared.loadSavedIcons()
        showToast(message: "Saved \"\(design.name)\" to My Icons", type: .success)
    }
    
    func deleteSavedIcon(id: UUID) {
        IconStorageService.shared.deleteIcon(id: id)
        self.savedIcons = IconStorageService.shared.loadSavedIcons()
        showToast(message: "Icon deleted from library", type: .info)
    }
    
    func duplicateSavedIcon(_ design: IconDesign) {
        var copy = design
        copy.id = UUID()
        copy.name = "\(design.name) Copy"
        copy.modifiedAt = Date()
        IconStorageService.shared.saveIcon(copy)
        self.savedIcons = IconStorageService.shared.loadSavedIcons()
        showToast(message: "Duplicated \"\(design.name)\"", type: .success)
    }
    
    func reloadRecents() {
        self.recentFolders = IconStorageService.shared.loadRecentFolders()
    }
    
    func clearRecents() {
        IconStorageService.shared.clearRecents()
        self.recentFolders = []
        showToast(message: "Recent activity cleared", type: .info)
    }
    
    // MARK: - Toast Notifications
    
    func showToast(message: String, type: ToastType = .info) {
        toastTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.toastMessage = message
            self.toastType = type
        }
        toastTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if !Task.isCancelled {
                withAnimation(.easeOut(duration: 0.25)) {
                    self.toastMessage = nil
                }
            }
        }
    }
}
