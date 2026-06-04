//
//  LiquidGlassDynamicIslandBackground.swift
//  boringNotch
//
//  Created by OpenAI on 2026. 06. 04..
//

import SwiftUI

struct LiquidGlassDynamicIslandBackground: View {
    let isOpen: Bool
    let isHovered: Bool

    private var isEmphasized: Bool { isOpen || isHovered }

    private var darkTintOpacity: Double {
        isOpen ? 0.44 : 0.56
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(max(0.35, darkTintOpacity - 0.08)),
                            Color.black.opacity(darkTintOpacity),
                            Color.black.opacity(min(0.68, darkTintOpacity + 0.08))
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isEmphasized ? 0.22 : 0.13),
                            Color.white.opacity(isEmphasized ? 0.07 : 0.035),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.45)
                    )
                )
                .blendMode(.screen)

            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: Color.white.opacity(isEmphasized ? 0.16 : 0.08), location: 0.18),
                            .init(color: Color.white.opacity(isEmphasized ? 0.07 : 0.03), location: 0.28),
                            .init(color: .clear, location: 0.58)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: isEmphasized ? 8 : 12)
                .opacity(isEmphasized ? 0.9 : 0.55)
                .blendMode(.screen)

            Rectangle()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isEmphasized ? 0.32 : 0.2),
                            Color.white.opacity(0.07),
                            Color.black.opacity(0.28)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: isEmphasized ? 1.0 : 0.75
                )
        }
        .shadow(
            color: Color.black.opacity(isOpen ? 0.38 : isHovered ? 0.24 : 0.12),
            radius: isOpen ? 18 : isHovered ? 10 : 4,
            y: isOpen ? 10 : 3
        )
    }
}
