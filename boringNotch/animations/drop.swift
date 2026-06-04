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

    static var islandOpen: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.18)
            : .interpolatingSpring(mass: 0.85, stiffness: 210, damping: 22, initialVelocity: 0.35)
    }

    static var islandClose: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.14)
            : .interpolatingSpring(mass: 0.9, stiffness: 270, damping: 31, initialVelocity: 0)
    }

    static var glassHover: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.24, dampingFraction: 0.8, blendDuration: 0)
    }

    static var openShell: Animation {
        islandOpen
    }

    static var closeShell: Animation {
        islandClose
    }

    static var hoverLift: Animation {
        glassHover
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

    static var contentDisappear: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.1)
            : .easeOut(duration: 0.15)
    }

    static var contentRemoval: Animation {
        contentDisappear
    }

    static var contentAppear: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.12)
            : .smooth(duration: 0.24).delay(0.06)
    }

    static var notificationInsertion: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.12)
            : .smooth(duration: 0.22).delay(0.03)
    }

    static var notificationRemoval: Animation {
        reduceMotionEnabled
            ? .easeOut(duration: 0.1)
            : .easeOut(duration: 0.14)
    }
}
