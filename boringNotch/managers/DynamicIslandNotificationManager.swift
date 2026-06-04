//
//  DynamicIslandNotificationManager.swift
//  boringNotch
//
//  Created by OpenAI on 2026. 06. 04..
//

import Combine
import Defaults
import Foundation

@MainActor
final class DynamicIslandNotificationManager: ObservableObject {
    static let shared = DynamicIslandNotificationManager()

    @Published private(set) var currentNotification: DynamicIslandNotification?
    @Published private(set) var pendingNotifications: [DynamicIslandNotification] = []

    var shouldDeferPresentation: () -> Bool = { false }

    private var dismissTask: Task<Void, Never>?
    private var deferredPresentationTask: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []

    private let duplicateCoalescingInterval: TimeInterval = 2.0
    private let transitionSettleDelay: Duration = .milliseconds(180)
    private let deferredRetryDelay: Duration = .milliseconds(500)

    private init() {
        Defaults.publisher(.enableDynamicIslandNotifications)
            .sink { [weak self] change in
                Task { @MainActor in
                    guard let self else { return }
                    if !change.newValue {
                        self.dismissCurrent()
                        self.clearQueue()
                    }
                }
            }
            .store(in: &cancellables)
    }

    func post(_ notification: DynamicIslandNotification) {
        guard Defaults[.enableDynamicIslandNotifications] else { return }

        if shouldCoalesce(with: currentNotification, incoming: notification) {
            currentNotification = notification
            scheduleDismiss(for: notification)
            return
        }

        if let lastIndex = pendingNotifications.indices.last,
           shouldCoalesce(with: pendingNotifications[lastIndex], incoming: notification)
        {
            pendingNotifications[lastIndex] = notification
        } else {
            pendingNotifications.append(notification)
        }

        presentNextIfPossible()
    }


    func postFocusStatus(modeName: String, isEnabled: Bool, duration: TimeInterval = 2.5) {
        guard Defaults[.enableFocusNotifications] else { return }
        post(
            DynamicIslandNotification(
                kind: .focus,
                title: isEnabled ? "Focus On" : "Focus Off",
                subtitle: isEnabled ? modeName : "Notifications resumed",
                iconSystemName: isEnabled ? "moon.fill" : "moon",
                duration: duration,
                focusModeName: modeName,
                isFocusEnabled: isEnabled
            )
        )
    }

    func postStatus(
        title: String,
        subtitle: String? = nil,
        iconSystemName: String = "info.circle.fill",
        accent: String? = nil,
        duration: TimeInterval = 2.5
    ) {
        post(
            DynamicIslandNotification(
                kind: .status,
                title: title,
                subtitle: subtitle,
                iconSystemName: iconSystemName,
                duration: duration,
                statusAccent: accent
            )
        )
    }

    func dismissCurrent() {
        dismissTask?.cancel()
        dismissTask = nil

        guard currentNotification != nil else {
            presentNextIfPossible()
            return
        }

        currentNotification = nil
        scheduleNextAfterTransition()
    }

    func clearQueue() {
        pendingNotifications.removeAll()
    }

    func resumePresentationIfPossible() {
        presentNextIfPossible()
    }

    private func presentNextIfPossible() {
        guard Defaults[.enableDynamicIslandNotifications] else {
            currentNotification = nil
            pendingNotifications.removeAll()
            return
        }

        guard currentNotification == nil, !pendingNotifications.isEmpty else { return }

        if shouldDeferPresentation() {
            scheduleDeferredPresentationRetry()
            return
        }

        deferredPresentationTask?.cancel()
        deferredPresentationTask = nil

        let nextNotification = pendingNotifications.removeFirst()
        currentNotification = nextNotification
        scheduleDismiss(for: nextNotification)
    }

    private func scheduleDismiss(for notification: DynamicIslandNotification) {
        dismissTask?.cancel()
        dismissTask = Task { [weak self] in
            let duration = max(0.1, notification.duration)
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard self?.currentNotification?.id == notification.id else { return }
                self?.dismissCurrent()
            }
        }
    }

    private func scheduleNextAfterTransition() {
        let delay = transitionSettleDelay
        deferredPresentationTask?.cancel()
        deferredPresentationTask = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.presentNextIfPossible()
            }
        }
    }

    private func scheduleDeferredPresentationRetry() {
        let delay = deferredRetryDelay
        guard deferredPresentationTask == nil else { return }

        deferredPresentationTask = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.deferredPresentationTask = nil
                self?.presentNextIfPossible()
            }
        }
    }

    private func shouldCoalesce(
        with existingNotification: DynamicIslandNotification?,
        incoming notification: DynamicIslandNotification
    ) -> Bool {
        guard let existingNotification else { return false }
        return shouldCoalesce(with: existingNotification, incoming: notification)
    }

    private func shouldCoalesce(
        with existingNotification: DynamicIslandNotification,
        incoming notification: DynamicIslandNotification
    ) -> Bool {
        existingNotification.kind == notification.kind
            && existingNotification.title == notification.title
            && abs(notification.createdAt.timeIntervalSince(existingNotification.createdAt)) <= duplicateCoalescingInterval
    }
}
