//
//  DynamicIslandNotification.swift
//  boringNotch
//
//  Created by OpenAI on 2026. 06. 04..
//

import Foundation

enum DynamicIslandNotificationKind: String, Codable, Equatable {
    case info
    case success
    case warning
    case error
    case battery
    case charging
    case focus
    case status
    case download
    case calendar
    case music
    case shortcut
}

struct DynamicIslandNotification: Identifiable, Equatable {
    let id: UUID
    var kind: DynamicIslandNotificationKind
    var title: String
    var subtitle: String?
    var appName: String?
    var iconSystemName: String
    var duration: TimeInterval
    var createdAt: Date
    var senderName: String?
    var message: String?
    var timestampText: String?
    var avatarImageName: String?
    var avatarSystemName: String?
    var appBadgeSystemName: String?
    var showsReplyField: Bool
    var replyPlaceholder: String?
    var showsEmojiButton: Bool
    var batteryPercent: Int?
    var isCharging: Bool?
    var batteryIconSystemName: String?
    var focusModeName: String?
    var isFocusEnabled: Bool?
    var statusAccent: String?

    init(
        id: UUID = UUID(),
        kind: DynamicIslandNotificationKind = .info,
        title: String,
        subtitle: String? = nil,
        appName: String? = nil,
        iconSystemName: String = "bell.fill",
        duration: TimeInterval = 3.0,
        createdAt: Date = Date(),
        senderName: String? = nil,
        message: String? = nil,
        timestampText: String? = nil,
        avatarImageName: String? = nil,
        avatarSystemName: String? = nil,
        appBadgeSystemName: String? = nil,
        showsReplyField: Bool = false,
        replyPlaceholder: String? = nil,
        showsEmojiButton: Bool = false,
        batteryPercent: Int? = nil,
        isCharging: Bool? = nil,
        batteryIconSystemName: String? = nil,
        focusModeName: String? = nil,
        isFocusEnabled: Bool? = nil,
        statusAccent: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.appName = appName
        self.iconSystemName = iconSystemName
        self.duration = duration
        self.createdAt = createdAt
        self.senderName = senderName
        self.message = message
        self.timestampText = timestampText
        self.avatarImageName = avatarImageName
        self.avatarSystemName = avatarSystemName
        self.appBadgeSystemName = appBadgeSystemName
        self.showsReplyField = showsReplyField
        self.replyPlaceholder = replyPlaceholder
        self.showsEmojiButton = showsEmojiButton
        self.batteryPercent = batteryPercent
        self.isCharging = isCharging
        self.batteryIconSystemName = batteryIconSystemName
        self.focusModeName = focusModeName
        self.isFocusEnabled = isFocusEnabled
        self.statusAccent = statusAccent
    }
}
