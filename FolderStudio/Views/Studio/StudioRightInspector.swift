//
//  StudioRightInspector.swift
//  FolderStudio
//

import SwiftUI

struct StudioRightInspector: View {
    @Binding var design: IconDesign
    var onChange: () -> Void
    
    @State private var isShowingSymbolPicker: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Overlay Mode Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Overlay Type")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Picker("Overlay", selection: Binding(
                        get: { design.overlayType },
                        set: { design.overlayType = $0; onChange() }
                    )) {
                        ForEach(OverlayType.allCases) { type in
                            Label(type == .symbol ? "Symbol" : type.rawValue, systemImage: type.iconName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                
                Divider()
                
                // Specific Overlay Controls
                switch design.overlayType {
                case .symbol:
                    symbolControls
                case .emoji:
                    emojiControls
                case .text:
                    textControls
                }
                
                // Badge Shape Inspector (if enabled)
                if design.badgeShape != .none {
                    Divider()
                    badgeControls
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $isShowingSymbolPicker) {
            SymbolPickerSheet(
                selectedSymbol: Binding(
                    get: { design.symbolName },
                    set: { design.symbolName = $0; onChange() }
                )
            )
        }
    }
    
    // MARK: - Symbol Controls
    
    private var symbolControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SF Symbol")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // Symbol preview & picker button
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: design.symbolName)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: design.symbolColorHex))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(design.symbolName)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .lineLimit(1)
                    
                    Button("Choose Symbol...") {
                        isShowingSymbolPicker = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            // Rendering Mode
            VStack(alignment: .leading, spacing: 4) {
                Text("Color Mode")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Picker("Mode", selection: Binding(
                    get: { design.symbolColorMode },
                    set: { design.symbolColorMode = $0; onChange() }
                )) {
                    ForEach(SymbolColorMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            
            // Symbol Color
            if design.symbolColorMode != .multicolor {
                HStack {
                    Text("Symbol Color")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ColorPicker("", selection: Binding(
                        get: { Color(hex: design.symbolColorHex) },
                        set: { design.symbolColorHex = $0.toHex(); onChange() }
                    ))
                    .labelsHidden()
                    .frame(width: 28, height: 24)
                    .padding(.trailing, 2)
                }
            }
            
            // Symbol Scale
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Size Scale")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(design.symbolScale * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.symbolScale },
                    set: { design.symbolScale = $0; onChange() }
                ), in: 0.25...0.85)
            }
            
            // Offset Y (Vertical Position)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Vertical Position")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    if design.symbolOffsetY != 0 {
                        Button("Center") {
                            design.symbolOffsetY = 0
                            onChange()
                        }
                        .buttonStyle(.plain)
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                    }
                    Text("\(Int(design.symbolOffsetY))pt")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.symbolOffsetY },
                    set: { design.symbolOffsetY = $0; onChange() }
                ), in: -35...35)
            }
            
            // Offset X (Horizontal Position)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Horizontal Position")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    if design.symbolOffsetX != 0 {
                        Button("Center") {
                            design.symbolOffsetX = 0
                            onChange()
                        }
                        .buttonStyle(.plain)
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                    }
                    Text("\(Int(design.symbolOffsetX))pt")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.symbolOffsetX },
                    set: { design.symbolOffsetX = $0; onChange() }
                ), in: -35...35)
            }
            
            // Rotation
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Rotation")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(design.symbolRotation))°")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.symbolRotation },
                    set: { design.symbolRotation = $0; onChange() }
                ), in: -180...180)
            }
        }
    }
    
    // MARK: - Emoji Controls
    
    private var emojiControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Emoji Overlay")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            TextField("Emoji (e.g. 🚀, 📁, 🎨)", text: Binding(
                get: { design.customText },
                set: { design.customText = $0; onChange() }
            ))
            .textFieldStyle(.roundedBorder)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Size Scale")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(design.symbolScale * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.symbolScale },
                    set: { design.symbolScale = $0; onChange() }
                ), in: 0.25...0.85)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Vertical Position")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    if design.symbolOffsetY != 0 {
                        Button("Center") {
                            design.symbolOffsetY = 0
                            onChange()
                        }
                        .buttonStyle(.plain)
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                    }
                    Text("\(Int(design.symbolOffsetY))pt")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.symbolOffsetY },
                    set: { design.symbolOffsetY = $0; onChange() }
                ), in: -35...35)
            }
        }
    }
    
    // MARK: - Text Controls
    
    private var textControls: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Text / Monogram")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            TextField("Text (e.g. DEV, 2026, WIP)", text: Binding(
                get: { design.customText },
                set: { design.customText = $0; onChange() }
            ))
            .textFieldStyle(.roundedBorder)
            
            HStack {
                Text("Text Color")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                ColorPicker("", selection: Binding(
                    get: { Color(hex: design.textColorHex) },
                    set: { design.textColorHex = $0.toHex(); onChange() }
                ))
                .labelsHidden()
                .frame(width: 28, height: 24)
                .padding(.trailing, 2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Font Size")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(design.textSize))pt")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.textSize },
                    set: { design.textSize = $0; onChange() }
                ), in: 16...48)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Vertical Position")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    if design.symbolOffsetY != 0 {
                        Button("Center") {
                            design.symbolOffsetY = 0
                            onChange()
                        }
                        .buttonStyle(.plain)
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                    }
                    Text("\(Int(design.symbolOffsetY))pt")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.symbolOffsetY },
                    set: { design.symbolOffsetY = $0; onChange() }
                ), in: -35...35)
            }
        }
    }
    
    // MARK: - Badge Controls
    
    private var badgeControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Badge Properties")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Badge Color")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                ColorPicker("", selection: Binding(
                    get: { Color(hex: design.badgeColorHex) },
                    set: { design.badgeColorHex = $0.toHex(); onChange() }
                ))
                .labelsHidden()
                .frame(width: 28, height: 24)
                .padding(.trailing, 2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Badge Opacity")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(design.badgeOpacity * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.badgeOpacity },
                    set: { design.badgeOpacity = $0; onChange() }
                ), in: 0.05...1.0)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Badge Scale")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(design.badgeScale * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { design.badgeScale },
                    set: { design.badgeScale = $0; onChange() }
                ), in: 0.3...1.0)
            }
        }
    }
}
