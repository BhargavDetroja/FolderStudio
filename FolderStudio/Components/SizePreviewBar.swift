//
//  SizePreviewBar.swift
//  FolderStudio
//

import SwiftUI

struct SizePreviewBar: View {
    let design: IconDesign
    
    private let previewSizes: [CGFloat] = [128, 64, 48, 32, 16]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Icon Scaling Preview")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Standard macOS Sizes")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(previewSizes, id: \.self) { size in
                    VStack(spacing: 6) {
                        ZStack {
                            FolderCanvasView(design: design, showShadow: size >= 48)
                                .frame(width: size, height: size)
                        }
                        .frame(width: max(size, 36), height: max(size, 36))
                        
                        Text("\(Int(size))px")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
            .cornerRadius(10)
        }
    }
}
