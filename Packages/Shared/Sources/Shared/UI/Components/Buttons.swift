import SwiftUI

// MARK: - Primary

public struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .commonButtonStyle(
                configuration: configuration,
                isEnabled: isEnabled,
                background: Capsule().fill(Color.semantic(.tintPrimary)),
                foregroundColor: .semantic(.backPrimary)
            )
    }
}

extension ButtonStyle where Self == PrimaryButton {
    public static var primary: Self {
        .init()
    }
}

// MARK: - Secondary

public struct SecondaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .commonButtonStyle(
                configuration: configuration,
                isEnabled: isEnabled,
                background: Capsule().strokeBorder(Color.semantic(.tintPrimary), lineWidth: 2),
                foregroundColor: .semantic(.tintPrimary)
            )
    }
}

extension ButtonStyle where Self == SecondaryButton {
    public static var secondary: Self {
        .init()
    }
}

// MARK: - Tertiary

public struct TertiaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .commonButtonStyle(
                configuration: configuration,
                isEnabled: isEnabled,
                background: Color.clear,
                foregroundColor: .semantic(.tintPrimary)
            )
            .underline()
    }
}

extension ButtonStyle where Self == TertiaryButton {
    public static var tertiary: Self {
        .init()
    }
}

// MARK: - Helpers

private extension View {
    func commonButtonStyle<T: View>(
        configuration: ButtonStyle.Configuration,
        isEnabled: Bool,
        background: T,
        foregroundColor: Color
    ) -> some View {
        font(.bold(18))
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(background)
            .foregroundColor(foregroundColor)
            .contentShape(Capsule())
            .opacity(configuration.resolveOpacity(isEnabled: isEnabled))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(
                configuration.isPressed ? .none : .default,
                value: configuration.isPressed
            )
    }
}

private extension ButtonStyleConfiguration {
    func resolveOpacity(isEnabled: Bool) -> CGFloat {
        if isEnabled {
            return isPressed ? 0.5 : 1
        } else {
            return 0.3
        }
    }
}

// MARK: - Previews

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            buttons
            Divider()
            buttons.disabled(true)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }

    static var buttons: some View {
        VStack(spacing: 20) {
            button.buttonStyle(.primary)
            button.buttonStyle(.secondary)
            button.buttonStyle(.tertiary)
        }
    }

    static var button: some View {
        Button(action: {}, label: {
            Text("Button Text")
                .frame(maxWidth: .infinity)
        })
    }
}
