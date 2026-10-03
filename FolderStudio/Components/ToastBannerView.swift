//
//  ToastBannerView.swift
//  FolderStudio
//

import SwiftUI

struct ToastBannerView: View {
    let message: String
    let type: ToastType
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(type.color)
            
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Material.thin,
            in: Capsule()
        )
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
