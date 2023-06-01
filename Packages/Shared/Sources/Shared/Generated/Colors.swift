// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
import AppKit.NSColor
internal typealias PlatformColor = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit.UIColor
internal typealias PlatformColor = UIColor
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Colors

// swiftlint:disable identifier_name line_length type_body_length
internal struct PaletteColor {
    internal let rgbaValue: UInt32
    internal var color: PlatformColor { PlatformColor(named: self) }

    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
    /// Alpha: 100% <br/> (0x000000ff)
    internal static let black = PaletteColor(rgbaValue: 0x000000ff)
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f2f2f7"></span>
    /// Alpha: 100% <br/> (0xf2f2f7ff)
    internal static let gray10 = PaletteColor(rgbaValue: 0xf2f2f7ff)
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#c6c6cd"></span>
    /// Alpha: 100% <br/> (0xc6c6cdff)
    internal static let gray20 = PaletteColor(rgbaValue: 0xc6c6cdff)
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#5d5d63"></span>
    /// Alpha: 100% <br/> (0x5d5d63ff)
    internal static let gray60 = PaletteColor(rgbaValue: 0x5d5d63ff)
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#1c1c1e"></span>
    /// Alpha: 100% <br/> (0x1c1c1eff)
    internal static let gray90 = PaletteColor(rgbaValue: 0x1c1c1eff)
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#2ed258"></span>
    /// Alpha: 100% <br/> (0x2ed258ff)
    internal static let greenDark = PaletteColor(rgbaValue: 0x2ed258ff)
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#34c759"></span>
    /// Alpha: 100% <br/> (0x34c759ff)
    internal static let greenLight = PaletteColor(rgbaValue: 0x34c759ff)
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
    /// Alpha: 100% <br/> (0xffffffff)
    internal static let white = PaletteColor(rgbaValue: 0xffffffff)
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal extension PlatformColor {
    convenience init(rgbaValue: UInt32) {
        let components = RGBAComponents(rgbaValue: rgbaValue).normalized
        self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}

private struct RGBAComponents {
    let rgbaValue: UInt32

    private var shifts: [UInt32] {
        [
            rgbaValue >> 24, // red
            rgbaValue >> 16, // green
            rgbaValue >> 8, // blue
            rgbaValue // alpha
        ]
    }

    private var components: [CGFloat] {
        shifts.map { CGFloat($0 & 0xff) }
    }

    var normalized: [CGFloat] {
        components.map { $0 / 255.0 }
    }
}

internal extension PlatformColor {
    convenience init(named color: PaletteColor) {
        self.init(rgbaValue: color.rgbaValue)
    }
}
