//
//  FolderCanvasView.swift
//  FolderStudio
//

import SwiftUI

// MARK: - Folder Geometry Shapes

struct FolderBackTabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // Native Apple folder proportions:
        // Tab covers ~39% of width, slopes down to shoulder at h * 0.15
        let tabWidth = w * 0.39
        let shoulderY = h * 0.15
        let cornerRadius = w * 0.045
        let shoulderRadius = w * 0.035
        
        // Start bottom-left
        path.move(to: CGPoint(x: 0, y: h))
        
        // Left edge up to tab corner
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        
        // Tab top horizontal edge
        path.addLine(to: CGPoint(x: tabWidth - cornerRadius, y: 0))
        
        // Tab right curve sloping down towards shoulder
        path.addCurve(
            to: CGPoint(x: tabWidth + shoulderRadius * 1.8, y: shoulderY),
            control1: CGPoint(x: tabWidth + shoulderRadius * 0.5, y: 0),
            control2: CGPoint(x: tabWidth + shoulderRadius * 0.9, y: shoulderY)
        )
        
        // Shoulder horizontal line to top-right
        path.addLine(to: CGPoint(x: w - cornerRadius, y: shoulderY))
        
        // Top-right corner
        path.addQuadCurve(
            to: CGPoint(x: w, y: shoulderY + cornerRadius),
            control: CGPoint(x: w, y: shoulderY)
        )
        
        // Right edge down to bottom
        path.addLine(to: CGPoint(x: w, y: h - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: w - cornerRadius, y: h),
            control: CGPoint(x: w, y: h)
        )
        
        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: h))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: h - cornerRadius),
            control: CGPoint(x: 0, y: h)
        )
        
        path.closeSubpath()
        return path
    }
}

struct FolderFrontFlapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let cornerRadius = w * 0.055
        
        path.addRoundedRect(
            in: CGRect(x: 0, y: 0, width: w, height: h),
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return path
    }
}

// MARK: - Main Folder Canvas View

struct FolderCanvasView: View {
    let design: IconDesign
    var showShadow: Bool = true
    
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            
            if let imageName = design.bundledImageName,
               let bundledImage = NSImage.loadBundledIcon(named: imageName) {
                Image(nsImage: bundledImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .if(showShadow) { view in
                        view.shadow(color: Color.black.opacity(0.18), radius: size * 0.02, x: 0, y: size * 0.01)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
            } else {
                // macOS standard folder proportions (94% width, 74% height)
                let folderWidth = size * 0.94
                let folderHeight = size * 0.74
                let frontFlapHeight = folderHeight * 0.85
                
                // Visual vertical positioning
                // Base shift gives room for drop shadow at bottom
                let baseShiftY = -size * 0.008
                // Front flap center is 7.5% of folder height below folder midpoint
                let frontFlapCenterY = baseShiftY + (folderHeight * 0.075)
                
                // Linear user offsets scaled to canvas size
                let userOffsetX = design.symbolOffsetX * (size / 300.0)
                let userOffsetY = design.symbolOffsetY * (size / 300.0)
                let overlayX = userOffsetX
                let overlayY = frontFlapCenterY + userOffsetY
                
                ZStack {
                    // Folder Back Tab
                    backPlate(width: folderWidth, height: folderHeight, canvasSize: size)
                        .offset(y: baseShiftY)
                    
                    // Folder Front Flap
                    frontFlap(width: folderWidth, height: frontFlapHeight, canvasSize: size)
                        .offset(y: frontFlapCenterY)
                    
                    // Badge Layer (optional)
                    if design.badgeShape != .none {
                        badgeView(canvasSize: size)
                            .offset(x: overlayX, y: overlayY)
                    }
                    
                    // Symbol / Text / Emoji Overlay
                    overlayContent(canvasSize: size)
                        .offset(x: overlayX, y: overlayY)
                        .rotationEffect(.degrees(design.symbolRotation))
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func backPlate(width: CGFloat, height: CGFloat, canvasSize: CGFloat) -> some View {
        let baseColor = Color(hex: design.primaryColorHex)
        let darkShade = baseColor.opacity(0.85)
        
        FolderBackTabShape()
            .fill(
                LinearGradient(
                    colors: [baseColor, darkShade],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: height)
            .overlay(
                FolderBackTabShape()
                    .stroke(Color.white.opacity(0.18), lineWidth: max(1, canvasSize * 0.003))
            )
            .if(showShadow) { view in
                view.shadow(color: Color.black.opacity(0.15), radius: canvasSize * 0.02, x: 0, y: canvasSize * 0.01)
            }
    }
    
    @ViewBuilder
    private func frontFlap(width: CGFloat, height: CGFloat, canvasSize: CGFloat) -> some View {
        let primary = Color(hex: design.primaryColorHex)
        let secondary = Color(hex: design.secondaryColorHex)
        
        ZStack {
            // Main Base Fill
            switch design.folderStyle {
            case .minimal:
                FolderFrontFlapShape()
                    .fill(
                        design.isGradient
                        ? gradientFill(primary: primary, secondary: secondary)
                        : LinearGradient(colors: [primary, primary.opacity(0.92)], startPoint: .top, endPoint: .bottom)
                    )
            case .softPastel:
                FolderFrontFlapShape()
                    .fill(
                        design.isGradient
                        ? gradientFill(primary: primary, secondary: secondary)
                        : LinearGradient(colors: [primary, primary.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        FolderFrontFlapShape()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.25), Color.clear],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: width * 0.7
                                )
                            )
                    )
            case .dark:
                FolderFrontFlapShape()
                    .fill(
                        design.isGradient
                        ? gradientFill(primary: primary, secondary: secondary)
                        : LinearGradient(colors: [primary, secondary], startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        FolderFrontFlapShape()
                            .stroke(primary.opacity(0.5), lineWidth: max(1, canvasSize * 0.004))
                    )
            case .neon:
                FolderFrontFlapShape()
                    .fill(
                        gradientFill(primary: primary, secondary: secondary)
                    )
                    .overlay(
                        FolderFrontFlapShape()
                            .stroke(
                                LinearGradient(colors: [secondary, primary], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: max(1.5, canvasSize * 0.006)
                            )
                    )
            case .glass:
                FolderFrontFlapShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                primary.opacity(0.65),
                                secondary.opacity(0.40)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        // Specular diagonal reflection line
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                        .clipShape(FolderFrontFlapShape())
                    )
                    .overlay(
                        FolderFrontFlapShape()
                            .stroke(Color.white.opacity(0.4), lineWidth: max(1, canvasSize * 0.004))
                    )
            case .classic:
                FolderFrontFlapShape()
                    .fill(
                        design.isGradient
                        ? gradientFill(primary: primary, secondary: secondary)
                        : LinearGradient(
                            colors: [
                                primary.opacity(0.98),
                                primary,
                                secondary.opacity(0.95)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        FolderFrontFlapShape()
                            .stroke(Color.white.opacity(0.18), lineWidth: max(1, canvasSize * 0.003))
                    )
            }
            
            // Top Rim Specular 3D Highlight Bevel (Apple signature)
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: max(1.2, canvasSize * 0.0035))
                    .padding(.horizontal, width * 0.04)
                    .padding(.top, max(1, canvasSize * 0.003))
                Spacer()
            }
            .clipShape(FolderFrontFlapShape())
        }
        .frame(width: width, height: height)
        .if(showShadow) { view in
            view
                .shadow(color: Color.black.opacity(0.18), radius: canvasSize * 0.025, x: 0, y: canvasSize * 0.012)
                .shadow(color: Color.black.opacity(0.06), radius: canvasSize * 0.006, x: 0, y: canvasSize * 0.003)
        }
    }
    
    // MARK: - Gradient Builder
    
    private func gradientFill(primary: Color, secondary: Color) -> LinearGradient {
        switch design.gradientDirection {
        case .topToBottom:
            return LinearGradient(colors: [primary, secondary], startPoint: .top, endPoint: .bottom)
        case .diagonal:
            return LinearGradient(colors: [primary, secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .horizontal:
            return LinearGradient(colors: [primary, secondary], startPoint: .leading, endPoint: .trailing)
        case .radial:
            // Linear approximation for shape fill
            return LinearGradient(colors: [primary, secondary], startPoint: .center, endPoint: .bottomTrailing)
        }
    }
    
    // MARK: - Badge View
    
    @ViewBuilder
    private func badgeView(canvasSize: CGFloat) -> some View {
        let badgeSize = canvasSize * 0.50 * design.badgeScale
        let badgeColor = Color(hex: design.badgeColorHex).opacity(design.badgeOpacity)
        
        Group {
            switch design.badgeShape {
            case .none:
                EmptyView()
            case .circle:
                Circle().fill(badgeColor)
            case .squircle:
                RoundedRectangle(cornerRadius: badgeSize * 0.28).fill(badgeColor)
            case .roundedRect:
                RoundedRectangle(cornerRadius: badgeSize * 0.16).fill(badgeColor)
            case .diamond:
                DiamondShape().fill(badgeColor)
            case .shield:
                ShieldShape().fill(badgeColor)
            }
        }
        .frame(width: badgeSize, height: badgeSize)
    }
    
    // MARK: - Overlay Content (Symbol / Emoji / Text)
    
    @ViewBuilder
    private func overlayContent(canvasSize: CGFloat) -> some View {
        let overlaySize = canvasSize * 0.50 * design.symbolScale
        let symbolColor = Color(hex: design.symbolColorHex)
        
        Group {
            switch design.overlayType {
            case .symbol:
                Image(systemName: design.symbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .if(design.symbolColorMode == .monochrome) { img in
                        img.foregroundColor(symbolColor)
                    }
                    .if(design.symbolColorMode == .hierarchical) { img in
                        img.symbolRenderingMode(.hierarchical).foregroundStyle(symbolColor)
                    }
                    .if(design.symbolColorMode == .multicolor) { img in
                        img.symbolRenderingMode(.multicolor)
                    }
                    .frame(width: overlaySize, height: overlaySize)
                    .shadow(color: Color.black.opacity(0.18), radius: max(1, canvasSize * 0.008), x: 0, y: max(1, canvasSize * 0.004))
                
            case .emoji:
                Text(design.customText.isEmpty ? "📁" : design.customText)
                    .font(.system(size: overlaySize * 0.82))
                    .frame(width: overlaySize, height: overlaySize)
                
            case .text:
                Text(design.customText)
                    .font(.system(size: overlaySize * 0.45 * (design.textSize / 28.0), weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: design.textColorHex))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(maxWidth: canvasSize * 0.60)
                    .shadow(color: Color.black.opacity(0.25), radius: max(1, canvasSize * 0.006), x: 0, y: max(1, canvasSize * 0.003))
            }
        }
    }
}
