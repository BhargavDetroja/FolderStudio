//
//  FolderStudioApp.swift
//  FolderStudio
//

import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        updateDockIcon()
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        updateDockIcon()
    }
    
    private func updateDockIcon() {
        if let icon = NSImage(named: "AppIcon") ?? NSImage(named: "app_icon") {
            NSApplication.shared.applicationIconImage = icon
        }
    }
}

@main
struct FolderStudioApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1120, height: 720)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Customize Folder...") {
                    appState.triggerFolderPicker()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("New Icon Design") {
                    appState.navigateToStudio(with: IconDesign.defaultDesign)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(replacing: .undoRedo) {
                Button("Undo") {
                    appState.undo()
                }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(!appState.canUndo)
                
                Button("Redo") {
                    appState.redo()
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(!appState.canRedo)
            }
        }
    }
}
