import SwiftUI

// MARK: - Primary

public struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var tint: Color

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .commonButtonStyle(
                configuration: configuration,
                isEnabled: isEnabled,
                background: Capsule().fill(tint),
                foregroundColor: .semantic(.backPrimary)
            )
    }
}

extension ButtonStyle where Self == PrimaryButton {
    public static func primary(tint: Color = .semantic(.tintPrimary)) -> Self {
        .init(tint: tint)
    }
}

// MARK: - Secondary

public struct SecondaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var tint: Color

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .commonButtonStyle(
                configuration: configuration,
                isEnabled: isEnabled,
                background: Capsule().strokeBorder(tint, lineWidth: 2),
                foregroundColor: tint
            )
    }
}

extension ButtonStyle where Self == SecondaryButton {
    public static func secondary(tint: Color = .semantic(.tintPrimary)) -> Self {
        .init(tint: tint)
    }
}

// MARK: - Tertiary

public struct TertiaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var tint: Color

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .commonButtonStyle(
                configuration: configuration,
                isEnabled: isEnabled,
                background: Color.clear,
                foregroundColor: tint
            )
            .underline()
    }
}

extension ButtonStyle where Self == TertiaryButton {
    public static func tertiary(tint: Color = .semantic(.tintPrimary)) -> Self {
        .init(tint: tint)
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
        font(.custom(.bold, 21))
            .fixedSize()
            .padding()
            .padding(.horizontal)
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

public struct ButtonStyles_Previews: PreviewProvider {
    public static var previews: some View {
        NavigationStack {
            content
        }
        .previewLayout(.sizeThatFits)
    }

    public static var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Enabled")
                buttons

                Divider()

                Text("Disabled")
                buttons.disabled(true)
            }
            .font(.custom(.headline))
            .padding()
        }
        .navigationTitle("Buttons")
    }

    static var buttons: some View {
        VStack(alignment: .center, spacing: 20) {
            button.buttonStyle(.primary())
            button.buttonStyle(.secondary())
            button.buttonStyle(.tertiary())
        }
        .frame(maxWidth: .infinity)
    }

    static var button: some View {
        Button(action: {}, label: {
            Text("Button Text")
                .frame(maxWidth: .infinity)
        })
    }
}
