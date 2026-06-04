//
//  LiquidGlassDynamicIslandBackground.swift
//  boringNotch
//
//  Created by OpenAI on 2026. 06. 04..
//

import SwiftUI

struct LiquidGlassDynamicIslandBackground: View {
    let shape: NotchShape
    let isOpen: Bool
    let isHovered: Bool
    let isNotificationVisible: Bool

    private var isEmphasized: Bool { isOpen || isHovered || isNotificationVisible }

    private var darkTintOpacity: Double {
        if isNotificationVisible { return 0.34 }
        if isOpen { return 0.32 }
        if isHovered { return 0.44 }
        return 0.50
    }

    private var rimOpacity: Double {
        if isNotificationVisible { return 0.36 }
        if isOpen { return 0.30 }
        if isHovered { return 0.28 }
        return 0.20
    }

    private var shineOpacity: Double {
        if isNotificationVisible { return 0.42 }
        if isOpen { return 0.34 }
        if isHovered { return 0.28 }
        return 0.18
    }

    var body: some View {
        shape
            .fill(.ultraThinMaterial)
            .overlay(colorBleedLayer)
            .overlay(darkReadabilityTint)
            .overlay(topEdgeShine)
            .overlay(specularBloom)
            .overlay(innerRefraction)
            .overlay(rimHighlight)
            .overlay(textureLayer)
            .clipShape(shape)
            .shadow(
                color: Color.black.opacity(isOpen ? 0.32 : isHovered ? 0.22 : 0.16),
                radius: isOpen ? 24 : isHovered ? 15 : 9,
                y: isOpen ? 14 : isHovered ? 8 : 4
            )
            .animation(DynamicIslandAnimations.glassHover, value: isOpen)
            .animation(DynamicIslandAnimations.glassHover, value: isHovered)
            .animation(DynamicIslandAnimations.glassHover, value: isNotificationVisible)
    }

    private var colorBleedLayer: some View {
        shape
            .fill(
                AngularGradient(
                    colors: [
                        Color.white.opacity(0.10),
                        Color.blue.opacity(isOpen ? 0.12 : 0.06),
                        Color.purple.opacity(isEmphasized ? 0.10 : 0.04),
                        Color.orange.opacity(isNotificationVisible ? 0.12 : 0.06),
                        Color.white.opacity(0.08)
                    ],
                    center: .center,
                    startAngle: .degrees(-35),
                    endAngle: .degrees(325)
                )
            )
            .blur(radius: isOpen ? 18 : 10)
            .opacity(isOpen ? 0.82 : isHovered ? 0.66 : 0.48)
            .blendMode(.screen)
    }

    private var darkReadabilityTint: some View {
        shape
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(max(0.22, darkTintOpacity - 0.14)),
                        Color.black.opacity(darkTintOpacity),
                        Color(red: 0.02, green: 0.022, blue: 0.028).opacity(min(0.58, darkTintOpacity + 0.08))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var topEdgeShine: some View {
        shape
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(shineOpacity), location: 0.0),
                        .init(color: Color(red: 1.0, green: 0.92, blue: 0.78).opacity(shineOpacity * 0.34), location: 0.12),
                        .init(color: Color.white.opacity(shineOpacity * 0.12), location: 0.28),
                        .init(color: .clear, location: 0.62)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.screen)
    }

    private var specularBloom: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .topLeading) {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(isEmphasized ? 0.22 : 0.10),
                                Color(red: 1.0, green: 0.88, blue: 0.68).opacity(isEmphasized ? 0.12 : 0.05),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: max(width, height) * 0.52
                        )
                    )
                    .frame(width: width * 0.54, height: max(28, height * 0.74))
                    .offset(x: width * 0.05, y: -height * 0.25)
                    .blur(radius: isOpen ? 10 : 7)

                Capsule()
                    .fill(Color.white.opacity(isNotificationVisible ? 0.18 : isOpen ? 0.12 : 0.07))
                    .frame(width: width * 0.36, height: 1.2)
                    .offset(x: width * 0.32, y: max(1, height * 0.10))
                    .blur(radius: 0.6)
            }
            .blendMode(.screen)
            .clipShape(shape)
        }
    }

    private var innerRefraction: some View {
        shape
            .stroke(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(isOpen ? 0.18 : 0.24),
                        Color.black.opacity(isNotificationVisible ? 0.22 : 0.30)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isOpen ? 3.0 : 2.2
            )
            .blur(radius: 1.3)
            .opacity(0.72)
            .clipShape(shape)
    }

    private var rimHighlight: some View {
        ZStack {
            shape
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(rimOpacity),
                            Color(red: 1.0, green: 0.92, blue: 0.76).opacity(rimOpacity * 0.56),
                            Color.white.opacity(rimOpacity * 0.18),
                            Color.black.opacity(0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isNotificationVisible ? 1.15 : 0.9
                )

            shape
                .stroke(Color.white.opacity(isEmphasized ? 0.08 : 0.035), lineWidth: 3)
                .blur(radius: 3)
                .blendMode(.screen)
        }
    }

    private var textureLayer: some View {
        shape
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.018),
                        Color.clear,
                        Color.white.opacity(0.012),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.overlay)
    }
}
