//
//  StudioLeftToolbar.swift
//  FolderStudio
//

import SwiftUI

struct StudioLeftToolbar: View {
    @Binding var design: IconDesign
    var onChange: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Design Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Design Name")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    TextField("Folder Name", text: Binding(
                        get: { design.name },
                        set: { design.name = $0; onChange() }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
                
                Divider()
                
                // Folder Base Style
                VStack(alignment: .leading, spacing: 10) {
                    Text("Folder Base Style")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 6) {
                        ForEach(FolderStyle.allCases) { style in
                            Button {
                                design.folderStyle = style
                                // If switching style, apply sensible defaults if user hasn't heavily customized
                                if !design.isGradient {
                                    design.primaryColorHex = style.defaultPrimaryHex
                                    design.secondaryColorHex = style.defaultSecondaryHex
                                }
                                onChange()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: style.iconName)
                                        .font(.system(size: 13, weight: .medium))
                                        .frame(width: 18)
                                        .foregroundColor(design.folderStyle == style ? .white : .primary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(style.rawValue)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(design.folderStyle == style ? .white : .primary)
                                        
                                        Text(style.description)
                                            .font(.system(size: 10))
                                            .foregroundColor(design.folderStyle == style ? .white.opacity(0.8) : .secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(design.folderStyle == style ? Color.accentColor : Color(NSColor.controlBackgroundColor).opacity(0.5))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Divider()
                
                // Color & Gradient Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Color & Fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ColorPickerSection(
                        isGradient: Binding(get: { design.isGradient }, set: { design.isGradient = $0; onChange() }),
                        primaryHex: Binding(get: { design.primaryColorHex }, set: { design.primaryColorHex = $0; onChange() }),
                        secondaryHex: Binding(get: { design.secondaryColorHex }, set: { design.secondaryColorHex = $0; onChange() }),
                        gradientDirection: Binding(get: { design.gradientDirection }, set: { design.gradientDirection = $0; onChange() }),
                        onColorChanged: onChange
                    )
                }
                
                Divider()
                
                // Badge Container Shape
                VStack(alignment: .leading, spacing: 10) {
                    Text("Badge Container")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Picker("Badge Shape", selection: Binding(
                        get: { design.badgeShape },
                        set: { design.badgeShape = $0; onChange() }
                    )) {
                        ForEach(BadgeShape.allCases) { shape in
                            Label(shape.rawValue, systemImage: shape.iconName).tag(shape)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(16)
        }
    }
}
