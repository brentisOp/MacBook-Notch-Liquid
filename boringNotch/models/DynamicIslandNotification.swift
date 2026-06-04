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

    init(
        id: UUID = UUID(),
        kind: DynamicIslandNotificationKind = .info,
        title: String,
        subtitle: String? = nil,
        appName: String? = nil,
        iconSystemName: String = "bell.fill",
        duration: TimeInterval = 3.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.appName = appName
        self.iconSystemName = iconSystemName
        self.duration = duration
        self.createdAt = createdAt
    }
}
