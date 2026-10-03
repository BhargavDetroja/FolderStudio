//
//  ColorPickerSection.swift
//  FolderStudio
//

import SwiftUI

struct ColorPickerSection: View {
    @Binding var isGradient: Bool
    @Binding var primaryHex: String
    @Binding var secondaryHex: String
    @Binding var gradientDirection: GradientDirection
    
    var onColorChanged: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Mode Picker
            Picker("Fill Mode", selection: $isGradient) {
                Text("Solid").tag(false)
                Text("Gradient").tag(true)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            // Custom Color Pickers
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isGradient ? "Start Color" : "Base Color")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: primaryHex) },
                            set: { newColor in
                                primaryHex = newColor.toHex()
                                if !isGradient {
                                    secondaryHex = primaryHex
                                }
                                onColorChanged?()
                            }
                        ))
                        .labelsHidden()
                        .frame(width: 28, height: 24)
                        
                        Text(primaryHex)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                
                if isGradient {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("End Color")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ColorPicker("", selection: Binding(
                                get: { Color(hex: secondaryHex) },
                                set: { newColor in
                                    secondaryHex = newColor.toHex()
                                    onColorChanged?()
                                }
                            ))
                            .labelsHidden()
                            .frame(width: 28, height: 24)
                            
                            Text(secondaryHex)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Gradient Direction (if gradient)
            if isGradient {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Gradient Flow")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Picker("Direction", selection: $gradientDirection) {
                        ForEach(GradientDirection.allCases) { dir in
                            Label(dir.rawValue, systemImage: dir.iconName).tag(dir)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            // Preset Swatches
            VStack(alignment: .leading, spacing: 8) {
                Text(isGradient ? "Gradient Presets" : "Color Presets")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if isGradient {
                            ForEach(PaletteCatalog.gradients) { preset in
                                Button {
                                    primaryHex = preset.primaryHex
                                    secondaryHex = preset.secondaryHex
                                    onColorChanged?()
                                } label: {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: preset.primaryHex), Color(hex: preset.secondaryHex)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    primaryHex == preset.primaryHex && secondaryHex == preset.secondaryHex
                                                    ? Color.accentColor : Color.white.opacity(0.3),
                                                    lineWidth: primaryHex == preset.primaryHex ? 2.5 : 1
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                                .help(preset.name)
                            }
                        } else {
                            ForEach(PaletteCatalog.solids) { preset in
                                Button {
                                    primaryHex = preset.primaryHex
                                    secondaryHex = preset.primaryHex
                                    onColorChanged?()
                                } label: {
                                    Circle()
                                        .fill(Color(hex: preset.primaryHex))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    primaryHex == preset.primaryHex
                                                    ? Color.accentColor : Color.white.opacity(0.3),
                                                    lineWidth: primaryHex == preset.primaryHex ? 2.5 : 1
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                                .help(preset.name)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
}
