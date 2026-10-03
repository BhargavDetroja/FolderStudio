//
//  FolderThumbnailView.swift
//  FolderStudio
//

import SwiftUI

struct FolderThumbnailView: View {
    let design: IconDesign
    var size: CGFloat = 80
    var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            FolderCanvasView(design: design, showShadow: size > 48)
                .frame(width: size, height: size)
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.16)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}
