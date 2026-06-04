//
//  DynamicIslandNotificationView.swift
//  boringNotch
//
//  Created by OpenAI on 2026. 06. 04..
//

import Defaults
import SwiftUI

struct DynamicIslandNotificationView: View {
    let notification: DynamicIslandNotification
    var isOpen: Bool

    @Default(.liquidGlassDynamicIsland) private var liquidGlassDynamicIsland

    private var notificationShape: NotchShape {
        NotchShape(topCornerRadius: 18, bottomCornerRadius: 18)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: notification.iconSystemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(iconForegroundColor)
                .frame(width: 30, height: 30)
                .background(iconBackground)

            VStack(alignment: .leading, spacing: 2) {
                if let appName = notification.appName, !appName.isEmpty {
                    Text(appName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(liquidGlassDynamicIsland ? Color.white.opacity(0.60) : Color.white.opacity(0.58))
                        .lineLimit(1)
                }

                Text(notification.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(liquidGlassDynamicIsland ? Color.white.opacity(0.92) : .white)
                    .lineLimit(1)

                if let subtitle = notification.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(liquidGlassDynamicIsland ? Color.white.opacity(0.74) : Color.white.opacity(0.72))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, notification.subtitle == nil && notification.appName == nil ? 8 : 9)
        .frame(minHeight: 42)
        .background(notificationBackground)
        .clipShape(notificationShape)
        .overlay {
            notificationShape
                .stroke(
                    liquidGlassDynamicIsland
                        ? Color.white.opacity(isOpen ? 0.30 : 0.24)
                        : Color.white.opacity(0.08),
                    lineWidth: liquidGlassDynamicIsland ? 1.0 : 0.75
                )
        }
        .shadow(color: .black.opacity(isOpen ? 0.30 : 0.22), radius: isOpen ? 16 : 10, y: isOpen ? 8 : 4)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var notificationBackground: some View {
        if liquidGlassDynamicIsland {
            LiquidGlassDynamicIslandBackground(
                shape: notificationShape,
                isOpen: isOpen,
                isHovered: true,
                isNotificationVisible: true
            )
        } else {
            LinearGradient(
                colors: [
                    Color.black.opacity(0.98),
                    Color.black.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    @ViewBuilder
    private var iconBackground: some View {
        if liquidGlassDynamicIsland {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().fill(Color.black.opacity(0.20)))
                .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 0.8))
                .shadow(color: iconForegroundColor.opacity(0.22), radius: 6)
        } else {
            Circle()
                .fill(iconBackgroundColor)
        }
    }

    private var iconForegroundColor: Color {
        switch notification.kind {
        case .success:
            return .green
        case .warning:
            return .yellow
        case .error:
            return .red
        case .battery:
            return .green
        case .download:
            return .blue
        case .calendar:
            return .orange
        case .music:
            return .pink
        case .shortcut:
            return .purple
        case .info:
            return liquidGlassDynamicIsland ? Color.white.opacity(0.92) : .white
        }
    }

    private var iconBackgroundColor: Color {
        switch notification.kind {
        case .info:
            return Color.white.opacity(0.14)
        default:
            return iconForegroundColor.opacity(0.18)
        }
    }
}
