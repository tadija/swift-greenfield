#if os(iOS)

import SwiftUI

/// Triggers haptic feedback.
///
/// Usage example:
///
///     let haptics = Haptics()
///     haptics.trigger(.success)
///
public struct Haptics {

    public enum Signal {
        case success, warning, error
        case light, medium, heavy
        case selection
    }

    public init() {}

    public func trigger(_ signal: Signal) {
        switch signal {
        case .success:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        case .warning:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.warning)
        case .error:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
        case .light:
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        case .medium:
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
        case .heavy:
            let feedback = UIImpactFeedbackGenerator(style: .heavy)
            feedback.impactOccurred()
        case .selection:
            let feedback = UISelectionFeedbackGenerator()
            feedback.selectionChanged()
        }
    }

}

#endif
