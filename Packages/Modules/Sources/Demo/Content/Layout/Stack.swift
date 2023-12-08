import Shared
import SwiftUI

public struct StackView: View {
    @Environment(Navigation.self) private var navigation

    public init() {}

    public var body: some View {
        NavigationStack(path: Bindable(navigation).stackPath) {
            content
                .navigationTitle("Stack")
                .navigationDestination(for: Route.self) {
                    $0.makeDestination()
                }
        }
        .tint(.semantic(.tintPrimary))
    }

    private var content: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(navigation.routes, id: \.self) { route in
                    Item(route: route)
                        .environment(navigation)
                }
            }
        }
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 3)
    }

    private struct Item: View {
        @Environment(Navigation.self) private var navigation

        let route: Route

        var body: some View {
            Button(action: {
                navigation.stackPath.append(route)
            }, label: {
                route.makeLabel()
                    .labelStyle(.vertical())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fill)
            })
            .onHover { _ in
                hovered.toggle()
            }
            .if(!hovered) { btn in
                btn.buttonStyle(.bordered)
            }
            .if(hovered) { btn in
                btn.buttonStyle(.borderedProminent)
            }
        }

        @State private var hovered = false
    }
}

// MARK: - Previews

#Preview {
    StackView()
        .environment(Navigation(layout: .stack))
    #if os(macOS)
        .frame(width: 600, height: 400)
    #endif
}
