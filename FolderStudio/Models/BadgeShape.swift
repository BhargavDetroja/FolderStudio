//
//  BadgeShape.swift
//  FolderStudio
//

import SwiftUI

enum BadgeShape: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case circle = "Circle"
    case squircle = "Squircle"
    case roundedRect = "Rounded Rect"
    case diamond = "Diamond"
    case shield = "Shield"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .none: return "slash.circle"
        case .circle: return "circle.fill"
        case .squircle: return "app.fill"
        case .roundedRect: return "rectangle.roundedtop.fill"
        case .diamond: return "diamond.fill"
        case .shield: return "shield.fill"
        }
    }
}

// Custom Diamond Shape
struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// Custom Shield Shape
struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topRadius: CGFloat = rect.width * 0.1
        let bottomRadius: CGFloat = rect.width * 0.25
        
        path.move(to: CGPoint(x: rect.minX + topRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + topRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY - bottomRadius)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.minX, y: rect.maxY - bottomRadius)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}
