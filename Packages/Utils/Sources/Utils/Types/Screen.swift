#if os(iOS)

import SwiftUI

/// Provides screen size in inches + other screen related helpers.
public struct Screen {

    public let ui: UIScreen
    public let app: UIApplication

    public let inchSize: Double

    public init(ui: UIScreen = .main, app: UIApplication = .shared) {
        self.ui = ui
        self.app = app
        inchSize = Device().determineScreenSize(for: ui.nativeBounds)
    }

    public var isZoomed: Bool {
        ui.scale < ui.nativeScale
    }

    public func disableAutoLock(_ disable: Bool) {
        app.isIdleTimerDisabled = disable
    }

    public func makeSnapshot() -> UIImage? {
        UIWindow.keyWindow?
            .rootViewController?.view
            .renderLayer()
    }

}

// MARK: - Helpers

private extension Device {

    /// - See: https://ios-resolution.com
    func determineScreenSize(for bounds: CGRect) -> Double {

        switch max(bounds.width, bounds.height) {

            /// - Note: iPhones

        case 480, 960:
            /// 1st, 3G, 3GS, 4, 4s
            /// iPod Touch (1, 2, 3, 4)
            return 3.5
        case 1136:
            /// 5, 5s, 5c, SE
            /// iPod Touch (5, 6)
            return 4
        case 1334:
            /// 6, 6s, 7, 8, SE2
            return 4.7
        case 2340:
            /// 12 Mini, 13 Mini
            return 5.4
        case 2208:
            /// 6+, 6s+, 7+, 8+
            return 5.5
        case 2436:
            /// X, Xs, 11 Pro
            return 5.8
        case 1792:
            /// XR, 11
            return 6.1
        case 2532:
            /// 12, 12 Pro, 13, 13 Pro, 14
            return 6.06
        case 2556:
            /// 14 Pro
            return 6.1
        case 2688:
            /// Xs Max, 11 Pro Max
            return 6.5
        case 2778:
            /// 12 Pro Max, 13 Pro Max, 14 Plus
            return 6.7
        case 2796:
            /// 14 Pro Max
            return 6.7

            /// - Note: iPads

        case 1024:
            /// 1st, 2, Mini
            return iPadMinis.contains(model) ? 7.9 : 9.7
        case 2048:
            /// 3, 4, Air, Pro, Mini (2, 3, 4, 5)
            return iPadMinis.contains(model) ? 7.9 : 9.7
        case 2266:
            /// Mini 6
            return 8.3
        case 2160:
            /// 7, 8, 9
            return 10.2
        case 2224:
            /// Air 3, Pro 2
            return 10.5
        case 2360:
            /// Air 4, 10
            return 10.86
        case 2388:
            /// Pro 11 (3, 4, 5, 6)
            return 11
        case 2732:
            /// Pro 12.9 (1, 2, 3, 4, 5, 6)
            return 12.9

            /// - Note: Unknown

        default:
            print("❌ unsupported screen size")

            switch kind {
            case .iPhone:
                return 6
            case .iPad:
                return 10
            case .iPod:
                return 4
            case .watch, .mac, .tv, .unknown:
                return 0
            }
        }

    }

    /// - See: https://github.com/Ekhoo/Device
    private var iPadMinis: [String] {[
        "iPad2,5", "iPad2,6", "iPad2,7",
        "iPad4,4", "iPad4,5", "iPad4,6",
        "iPad4,7", "iPad4,8", "iPad4,9",
        "iPad5,1", "iPad5,2"
    ]}

}

#endif
