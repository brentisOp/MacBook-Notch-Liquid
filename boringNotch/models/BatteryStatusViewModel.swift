import Cocoa
import Defaults
import Foundation
import IOKit.ps
import SwiftUI

/// A view model that manages and monitors the battery status of the device
class BatteryStatusViewModel: ObservableObject {

    private var wasCharging: Bool = false
    private var lowBatteryNotificationSent: Bool = false
    private var fullChargeNotificationSent: Bool = false
    private var powerSourceChangedCallback: IOPowerSourceCallbackType?
    private var runLoopSource: Unmanaged<CFRunLoopSource>?

    @ObservedObject var coordinator = BoringViewCoordinator.shared

    @Published private(set) var levelBattery: Float = 0.0
    @Published private(set) var maxCapacity: Float = 0.0
    @Published private(set) var isPluggedIn: Bool = false
    @Published private(set) var isCharging: Bool = false
    @Published private(set) var isInLowPowerMode: Bool = false
    @Published private(set) var isInitial: Bool = false
    @Published private(set) var timeToFullCharge: Int = 0
    @Published private(set) var statusText: String = ""

    private let managerBattery = BatteryActivityManager.shared
    private var managerBatteryId: Int?

    static let shared = BatteryStatusViewModel()

    /// Initializes the view model with a given BoringViewModel instance
    /// - Parameter vm: The BoringViewModel instance
    private init() {
        setupPowerStatus()
        setupMonitor()
    }

    /// Sets up the initial power status by fetching battery information
    private func setupPowerStatus() {
        let batteryInfo = managerBattery.initializeBatteryInfo()
        updateBatteryInfo(batteryInfo)
    }

    /// Sets up the monitor to observe battery events
    private func setupMonitor() {
        managerBatteryId = managerBattery.addObserver { [weak self] event in
            guard let self = self else { return }
            self.handleBatteryEvent(event)
        }
    }

    /// Handles battery events and updates the corresponding properties
    /// - Parameter event: The battery event to handle
    private func handleBatteryEvent(_ event: BatteryActivityManager.BatteryEvent) {
        switch event {
        case .powerSourceChanged(let isPluggedIn):
            print("🔌 Power source: \(isPluggedIn ? "Connected" : "Disconnected")")
            withAnimation {
                self.isPluggedIn = isPluggedIn
                self.statusText = isPluggedIn ? "Plugged In" : "Unplugged"
                self.notifyImportanChangeStatus()
            }

        case .batteryLevelChanged(let level):
            print("🔋 Battery level: \(Int(level))%")
            withAnimation {
                self.levelBattery = level
            }
            self.postBatteryStatusNotificationIfNeeded(level: level)

        case .lowPowerModeChanged(let isEnabled):
            print("⚡ Low power mode: \(isEnabled ? "Enabled" : "Disabled")")
            self.notifyImportanChangeStatus()
            withAnimation {
                self.isInLowPowerMode = isEnabled
                self.statusText = "Low Power: \(self.isInLowPowerMode ? "On" : "Off")"
            }

        case .isChargingChanged(let isCharging):
            print("🔌 Charging: \(isCharging ? "Yes" : "No")")
            print("maxCapacity: \(self.maxCapacity)")
            print("levelBattery: \(self.levelBattery)")
            let previousChargingState = self.isCharging
            self.notifyImportanChangeStatus()
            withAnimation {
                self.isCharging = isCharging
                self.statusText =
                    isCharging
                    ? "Charging battery"
                    : (self.levelBattery < self.maxCapacity ? "Not charging" : "Full charge")
            }
            self.postChargingNotificationIfNeeded(isCharging: isCharging, previousChargingState: previousChargingState)
            self.postFullChargeNotificationIfNeeded()

        case .timeToFullChargeChanged(let time):
            print("🕒 Time to full charge: \(time) minutes")
            withAnimation {
                self.timeToFullCharge = time
            }

        case .maxCapacityChanged(let capacity):
            print("🔋 Max capacity: \(capacity)")
            withAnimation {
                self.maxCapacity = capacity
            }

        case .error(let description):
            print("⚠️ Error: \(description)")
        }
    }


    private func postChargingNotificationIfNeeded(isCharging: Bool, previousChargingState: Bool) {
        guard Defaults[.enableDynamicIslandNotifications], Defaults[.enableChargingNotifications] else { return }
        guard previousChargingState != isCharging else { return }

        let percent = Int(levelBattery.rounded())
        postDynamicIslandNotification(
            DynamicIslandNotification(
                kind: .charging,
                title: isCharging ? "Charging" : "Not Charging",
                subtitle: "\(percent)%",
                iconSystemName: isCharging ? "battery.100.bolt" : batteryIconName(for: percent),
                duration: 2.5,
                batteryPercent: percent,
                isCharging: isCharging,
                batteryIconSystemName: isCharging ? "battery.100.bolt" : batteryIconName(for: percent)
            )
        )

        if isCharging {
            lowBatteryNotificationSent = false
            fullChargeNotificationSent = false
        }
    }

    private func postBatteryStatusNotificationIfNeeded(level: Float) {
        guard Defaults[.enableDynamicIslandNotifications], Defaults[.enableBatteryStatusNotifications] else { return }

        let percent = Int(level.rounded())
        if percent <= 20 && !isCharging && !isPluggedIn && !lowBatteryNotificationSent {
            lowBatteryNotificationSent = true
            postDynamicIslandNotification(
                DynamicIslandNotification(
                    kind: .battery,
                    title: "Battery Low",
                    subtitle: "\(percent)%",
                    iconSystemName: batteryIconName(for: percent),
                    duration: 3.0,
                    batteryPercent: percent,
                    isCharging: false,
                    batteryIconSystemName: batteryIconName(for: percent)
                )
            )
        } else if percent > 25 {
            lowBatteryNotificationSent = false
        }

        postFullChargeNotificationIfNeeded()
    }

    private func postFullChargeNotificationIfNeeded() {
        guard Defaults[.enableDynamicIslandNotifications], Defaults[.enableBatteryStatusNotifications] else { return }
        let percent = Int(levelBattery.rounded())
        let fullThreshold = max(95, Int(maxCapacity.rounded()))
        guard percent >= fullThreshold, isPluggedIn, !fullChargeNotificationSent else { return }

        fullChargeNotificationSent = true
        postDynamicIslandNotification(
            DynamicIslandNotification(
                kind: .battery,
                title: "Fully Charged",
                subtitle: "\(percent)%",
                iconSystemName: "battery.100",
                duration: 3.0,
                batteryPercent: percent,
                isCharging: isCharging,
                batteryIconSystemName: "battery.100",
                statusAccent: "green"
            )
        )
    }


    private func postDynamicIslandNotification(_ notification: DynamicIslandNotification) {
        Task { @MainActor in
            DynamicIslandNotificationManager.shared.post(notification)
        }
    }

    private func batteryIconName(for percent: Int) -> String {
        switch percent {
        case 0...20: return "battery.25"
        case 21...55: return "battery.50"
        case 56...85: return "battery.75"
        default: return "battery.100"
        }
    }

    /// Updates the battery information with the given BatteryInfo instance
    /// - Parameter batteryInfo: The BatteryInfo instance containing the battery data
    private func updateBatteryInfo(_ batteryInfo: BatteryInfo) {
        withAnimation {
            self.levelBattery = batteryInfo.currentCapacity
            self.isPluggedIn = batteryInfo.isPluggedIn
            self.isCharging = batteryInfo.isCharging
            self.isInLowPowerMode = batteryInfo.isInLowPowerMode
            self.timeToFullCharge = batteryInfo.timeToFullCharge
            self.maxCapacity = batteryInfo.maxCapacity
            self.statusText = batteryInfo.isPluggedIn ? "Plugged In" : "Unplugged"
        }
    }

    /// Notifies important changes in the battery status with an optional delay
    /// - Parameter delay: The delay before notifying the change, default is 0.0
    private func notifyImportanChangeStatus(delay: Double = 0.0) {
        Task {
            try? await Task.sleep(for: .seconds(delay))
            self.coordinator.toggleExpandingView(status: true, type: .battery)
        }
    }

    deinit {
        print("🔌 Cleaning up battery monitoring...")
        if let managerBatteryId: Int = managerBatteryId {
            managerBattery.removeObserver(byId: managerBatteryId)
        }
    }

}
