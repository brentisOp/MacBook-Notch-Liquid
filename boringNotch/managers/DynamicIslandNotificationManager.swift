//
//  DynamicIslandNotificationManager.swift
//  boringNotch
//
//  Created by OpenAI on 2026. 06. 04..
//

import Combine
import Defaults
import Foundation

final class DynamicIslandNotificationManager: ObservableObject {
    static let shared = DynamicIslandNotificationManager()

    @Published private(set) var currentNotification: DynamicIslandNotification?
    @Published private(set) var pendingNotifications: [DynamicIslandNotification] = []

    var shouldDeferPresentation: () -> Bool = { false }

    private var dismissWorkItem: DispatchWorkItem?
    private var transitionWorkItem: DispatchWorkItem?
    private var deferredPresentationWorkItem: DispatchWorkItem?
    private var cancellables: Set<AnyCancellable> = []

    private let duplicateCoalescingInterval: TimeInterval = 2.0
    private let transitionSettleDelay: TimeInterval = 0.18
    private let deferredRetryDelay: TimeInterval = 0.50

    private init() {
        Defaults.publisher(.enableDynamicIslandNotifications)
            .sink { [weak self] change in
                DispatchQueue.main.async {
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
        DispatchQueue.main.async { [weak self] in
            self?.postOnMain(notification)
        }
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
        DispatchQueue.main.async { [weak self] in
            self?.dismissCurrentOnMain()
        }
    }

    func clearQueue() {
        DispatchQueue.main.async { [weak self] in
            self?.pendingNotifications.removeAll()
        }
    }

    func resumePresentationIfPossible() {
        DispatchQueue.main.async { [weak self] in
            self?.presentNextIfPossibleOnMain()
        }
    }

    private func postOnMain(_ notification: DynamicIslandNotification) {
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

        presentNextIfPossibleOnMain()
    }

    private func dismissCurrentOnMain() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        guard currentNotification != nil else {
            presentNextIfPossibleOnMain()
            return
        }

        currentNotification = nil
        scheduleNextAfterTransition()
    }

    private func presentNextIfPossibleOnMain() {
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

        deferredPresentationWorkItem?.cancel()
        deferredPresentationWorkItem = nil

        let nextNotification = pendingNotifications.removeFirst()
        currentNotification = nextNotification
        scheduleDismiss(for: nextNotification)
    }

    private func scheduleDismiss(for notification: DynamicIslandNotification) {
        dismissWorkItem?.cancel()

        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.currentNotification?.id == notification.id else { return }
            self.dismissCurrentOnMain()
        }

        dismissWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + max(0.1, notification.duration), execute: item)
    }

    private func scheduleNextAfterTransition() {
        transitionWorkItem?.cancel()

        let item = DispatchWorkItem { [weak self] in
            self?.presentNextIfPossibleOnMain()
        }

        transitionWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionSettleDelay, execute: item)
    }

    private func scheduleDeferredPresentationRetry() {
        guard deferredPresentationWorkItem == nil else { return }

        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.deferredPresentationWorkItem = nil
            self.presentNextIfPossibleOnMain()
        }

        deferredPresentationWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + deferredRetryDelay, execute: item)
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
