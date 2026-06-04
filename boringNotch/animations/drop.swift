//
//  drop.swift
//  boringNotch
//
//  Created by Harsh Vardhan  Goswami  on  04/08/24.
//

import Foundation
import SwiftUI
import AppKit

public class BoringAnimations {
    @Published var notchStyle: Style = .notch

    init() {
        self.notchStyle = .notch
    }

    var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            Animation.spring(.bouncy(duration: 0.4))
        } else {
            Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }
}

enum DynamicIslandAnimations {
    private static var reduceMotionEnabled: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    static var openShell: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.18)
            : .interpolatingSpring(mass: 0.85, stiffness: 210, damping: 22, initialVelocity: 0.4)
    }

    static var closeShell: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.14)
            : .interpolatingSpring(mass: 0.9, stiffness: 260, damping: 30, initialVelocity: 0)
    }

    static var hoverLift: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.24, dampingFraction: 0.78, blendDuration: 0)
    }

    static var gestureStretch: Animation {
        reduceMotionEnabled
            ? .linear(duration: 0.08)
            : .interactiveSpring(response: 0.18, dampingFraction: 0.86, blendDuration: 0)
    }

    static var contentInsertion: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.12)
            : .smooth(duration: 0.24).delay(0.06)
    }

    static var contentRemoval: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.1)
            : .easeOut(duration: 0.16)
    }

    static var notificationInsertion: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.12)
            : .smooth(duration: 0.22)
    }

    static var notificationRemoval: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.1)
            : .easeOut(duration: 0.14)
    }
}
