//
//  DynamicIslandNotificationView.swift
//  boringNotch
//
//  Created by OpenAI on 2026. 06. 04..
//

import AppKit
import Defaults
import SwiftUI

enum DynamicIslandNotificationPresentationMode {
    case compact
    case rich
}

struct DynamicIslandNotificationView: View {
    let notification: DynamicIslandNotification
    var isOpen: Bool
    var presentationMode: DynamicIslandNotificationPresentationMode = .compact

    @Default(.liquidGlassDynamicIsland) private var liquidGlassDynamicIsland
    @State private var contentVisible = false
    @State private var replyVisible = false

    private var isRich: Bool {
        presentationMode == .rich
    }

    private var notificationShape: NotchShape {
        NotchShape(
            topCornerRadius: isRich ? 28 : 18,
            bottomCornerRadius: isRich ? 28 : 18
        )
    }

    private var reduceMotionEnabled: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    var body: some View {
        Group {
            if isRich {
                richBody
            } else {
                compactBody
            }
        }
        .background(notificationBackground)
        .clipShape(notificationShape)
        .overlay(rimOverlay)
        .shadow(color: .black.opacity(isRich ? 0.34 : isOpen ? 0.30 : 0.22), radius: isRich ? 24 : isOpen ? 16 : 10, y: isRich ? 14 : isOpen ? 8 : 4)
        .accessibilityElement(children: .combine)
        .onAppear { stageAppearance() }
        .onChange(of: notification.id) { _, _ in stageAppearance() }
    }

    private var compactBody: some View {
        HStack(spacing: 10) {
            Image(systemName: notification.iconSystemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(iconForegroundColor)
                .frame(width: 30, height: 30)
                .background(iconBackground(size: 30))

            VStack(alignment: .leading, spacing: 2) {
                if let appName = notification.appName, !appName.isEmpty {
                    Text(appName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(secondaryTextColor.opacity(0.82))
                        .lineLimit(1)
                }

                Text(notification.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(1)

                if let subtitle = notification.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(secondaryTextColor)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, notification.subtitle == nil && notification.appName == nil ? 8 : 9)
        .frame(minHeight: 42)
    }

    private var richBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                avatarView
                    .scaleEffect(contentVisible ? 1 : 0.92)
                    .opacity(contentVisible ? 1 : 0)
                    .animation(DynamicIslandAnimations.notificationContentAppear, value: contentVisible)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(notification.senderName ?? notification.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(primaryTextColor)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        if let timestampText = notification.timestampText, !timestampText.isEmpty {
                            Text(timestampText)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(secondaryTextColor.opacity(0.72))
                                .lineLimit(1)
                        }
                    }

                    Text(notification.message ?? notification.subtitle ?? "")
                        .font(.system(size: 13.5, weight: .regular, design: .rounded))
                        .foregroundStyle(secondaryTextColor)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .opacity(contentVisible ? 1 : 0)
                .scaleEffect(contentVisible ? 1 : 0.97, anchor: .topLeading)
                .animation(DynamicIslandAnimations.notificationContentAppear, value: contentVisible)
            }

            if notification.showsReplyField || notification.showsEmojiButton {
                replyRow
                    .opacity(replyVisible ? 1 : 0)
                    .scaleEffect(replyVisible ? 1 : 0.98, anchor: .top)
                    .offset(y: replyVisible ? 0 : -4)
                    .animation(DynamicIslandAnimations.notificationReplyAppear, value: replyVisible)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(minHeight: 132)
    }

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let avatarImageName = notification.avatarImageName, !avatarImageName.isEmpty {
                    Image(avatarImageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: notification.avatarSystemName ?? "person.crop.circle.fill")
                        .resizable()
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.white.opacity(0.92), Color.white.opacity(0.35))
                        .padding(7)
                }
            }
            .frame(width: 54, height: 54)
            .background(avatarBackground)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(liquidGlassDynamicIsland ? 0.28 : 0.12), lineWidth: 1))

            if let badge = notification.appBadgeSystemName, !badge.isEmpty {
                Image(systemName: badge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(badgeColor))
                    .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 1.2))
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var replyRow: some View {
        HStack(spacing: 8) {
            if notification.showsReplyField {
                HStack(spacing: 6) {
                    Text(notification.replyPlaceholder ?? "Reply")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(secondaryTextColor.opacity(0.72))
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(replyFieldBackground)
                .clipShape(Capsule(style: .continuous))
                .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(liquidGlassDynamicIsland ? 0.16 : 0.08), lineWidth: 0.8))
            }

            if notification.showsEmojiButton {
                Image(systemName: "face.smiling")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(primaryTextColor.opacity(0.86))
                    .frame(width: 34, height: 34)
                    .background(replyFieldBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(liquidGlassDynamicIsland ? 0.16 : 0.08), lineWidth: 0.8))
            }
        }
    }

    @ViewBuilder
    private var notificationBackground: some View {
        if liquidGlassDynamicIsland {
            LiquidGlassDynamicIslandBackground(
                shape: notificationShape,
                isOpen: isOpen || isRich,
                isHovered: true,
                isNotificationVisible: true
            )
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.055, green: 0.056, blue: 0.064).opacity(0.98),
                        Color(red: 0.018, green: 0.019, blue: 0.024).opacity(0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                LinearGradient(
                    colors: [Color.white.opacity(0.08), .clear, Color.black.opacity(0.28)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }

    private var rimOverlay: some View {
        notificationShape
            .stroke(
                liquidGlassDynamicIsland
                    ? Color.white.opacity(isRich ? 0.32 : isOpen ? 0.30 : 0.24)
                    : Color.white.opacity(isRich ? 0.12 : 0.08),
                lineWidth: liquidGlassDynamicIsland ? 1.0 : 0.75
            )
    }

    @ViewBuilder
    private func iconBackground(size: CGFloat) -> some View {
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

    private var avatarBackground: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(liquidGlassDynamicIsland ? 0.22 : 0.16),
                        Color.gray.opacity(liquidGlassDynamicIsland ? 0.20 : 0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var replyFieldBackground: some View {
        Capsule(style: .continuous)
            .fill(liquidGlassDynamicIsland ? Color.white.opacity(0.09) : Color.white.opacity(0.06))
            .background {
                if liquidGlassDynamicIsland {
                    Capsule(style: .continuous).fill(.ultraThinMaterial)
                }
            }
    }

    private var primaryTextColor: Color {
        liquidGlassDynamicIsland ? Color.white.opacity(0.92) : Color.white.opacity(0.95)
    }

    private var secondaryTextColor: Color {
        liquidGlassDynamicIsland ? Color.white.opacity(0.74) : Color.white.opacity(0.68)
    }

    private var badgeColor: Color {
        switch notification.appName?.lowercased() {
        case let appName? where appName.contains("whatsapp"):
            return Color.green
        default:
            return iconForegroundColor
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

    private func stageAppearance() {
        contentVisible = false
        replyVisible = false

        let contentDelay: Duration = reduceMotionEnabled ? .milliseconds(20) : .milliseconds(60)
        let replyDelay: Duration = reduceMotionEnabled ? .milliseconds(40) : .milliseconds(130)

        Task { @MainActor in
            try? await Task.sleep(for: contentDelay)
            withAnimation(DynamicIslandAnimations.notificationContentAppear) {
                contentVisible = true
            }

            try? await Task.sleep(for: replyDelay)
            withAnimation(DynamicIslandAnimations.notificationReplyAppear) {
                replyVisible = true
            }
        }
    }
}
