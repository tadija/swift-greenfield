#if canImport(SwiftUI)

import SwiftUI

public extension Color {
    init(hex: String) {
        let rgba = hex.hexColorToRGBA()
        self = .init(
            red: rgba.r,
            green: rgba.g,
            blue: rgba.b
        )
        .opacity(rgba.a)
    }

    var hexString: String {
        cgColor?.hexString ?? "#000000"
    }
}

public extension CGColor {
    var hexString: String {
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
}

// MARK: - Layout Helpers

public struct LayoutFill<T: View>: View {
    let color: Color
    let alignment: Alignment
    var content: T

    public init(
        _ color: Color = .clear,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> T
    ) {
        self.color = color
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        color.overlay(content, alignment: alignment)
    }
}

public struct LayoutCenter<T: View>: View {
    let axis: Axis
    var content: T

    public init(_ axis: Axis, @ViewBuilder content: () -> T) {
        self.axis = axis
        self.content = content()
    }

    public var body: some View {
        switch axis {
        case .horizontal:
            HStack(spacing: 0) { centeredContent }
        case .vertical:
            VStack(spacing: 0) { centeredContent }
        }
    }

    @ViewBuilder
    private var centeredContent: some View {
        Spacer()
        content
        Spacer()
    }
}

public struct LayoutHalf<T: View>: View {
    let edge: Edge
    var content: T

    public init(_ edge: Edge, @ViewBuilder content: () -> T) {
        self.edge = edge
        self.content = content()
    }

    public var body: some View {
        switch edge {
        case .top:
            VStack(spacing: 0) {
                content
                Color.clear
            }
        case .bottom:
            VStack(spacing: 0) {
                Color.clear
                content
            }
        case .leading:
            HStack(spacing: 0) {
                content
                Color.clear
            }
        case .trailing:
            HStack(spacing: 0) {
                Color.clear
                content
            }
        }
    }
}

public struct LayoutAlign<T: View>: View {
    let alignment: Alignment
    var content: T

    public init(_ alignment: Alignment, @ViewBuilder content: () -> T) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        switch alignment {
        case .top:
            Top { content }
        case .bottom:
            Bottom { content }
        case .leading:
            Leading { content }
        case .trailing:
            Trailing { content }
        case .topLeading:
            Top { Leading { content } }
        case .topTrailing:
            Top { Trailing { content } }
        case .bottomLeading:
            Bottom { Leading { content } }
        case .bottomTrailing:
            Bottom { Trailing { content } }
        default:
            fatalError("\(alignment) is not supported")
        }
    }

    private struct Top<T: View>: View {
        var content: () -> T
        var body: some View {
            VStack(spacing: 0) {
                content()
                Spacer()
            }
        }
    }

    private struct Bottom<T: View>: View {
        var content: () -> T
        var body: some View {
            VStack(spacing: 0) {
                Spacer()
                content()
            }
        }
    }

    private struct Leading<T: View>: View {
        var content: () -> T
        var body: some View {
            HStack(spacing: 0) {
                content()
                Spacer()
            }
        }
    }

    private struct Trailing<T: View>: View {
        var content: () -> T
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                content()
            }
        }
    }
}

// MARK: - View+Notifications

/// - See: https://twitter.com/tadija/status/1311263107247943680
public extension View {
    func onReceive(
        _ name: Notification.Name,
        center: NotificationCenter = .default,
        object: AnyObject? = nil,
        perform action: @escaping (Notification) -> Void
    ) -> some View {
        onReceive(
            center.publisher(for: name, object: object), perform: action
        )
    }
}

// MARK: - View+Condition

/// - See: https://fivestars.blog/swiftui/conditional-modifiers.html
public extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, modifier: (Self) -> T) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<T: View, F: View>(
        _ condition: Bool,
        if ifModifier: (Self) -> T,
        else elseModifier: (Self) -> F
    ) -> some View {
        if condition {
            ifModifier(self)
        } else {
            elseModifier(self)
        }
    }

    @ViewBuilder
    func ifLet<V, T: View>(_ value: V?, modifier: (Self, V) -> T) -> some View {
        if let value = value {
            modifier(self, value)
        } else {
            self
        }
    }
}

// MARK: - View+Debug

/// - See: https://www.swiftbysundell.com/articles/building-swiftui-debugging-utilities/
public extension View {
    func debugAction(_ closure: () -> Void) -> Self {
        #if DEBUG
        closure()
        #endif
        return self
    }

    func debugLog(_ value: Any) -> Self {
        debugAction {
            debugPrint(value)
        }
    }
}

public extension View {
    func debugModifier<T: View>(_ modifier: (Self) -> T) -> some View {
        #if DEBUG
        return modifier(self)
        #else
        return self
        #endif
    }

    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        debugModifier {
            $0.border(color, width: width)
        }
    }

    func debugBackground(_ color: Color = .red) -> some View {
        debugModifier {
            $0.background(color)
        }
    }

    func debugGesture<G: Gesture>(_ gesture: G) -> some View {
        debugModifier {
            $0.gesture(gesture)
        }
    }
}

// MARK: - View+AnimationCompletion

/// - See: https://www.avanderlee.com/swiftui/withanimation-completion-callback
/// An animatable modifier that is used for observing animations for a given animatable value.
public struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    /// While animating, SwiftUI changes the old input value to the new target value using this property.
    /// This value is set to the old value until the animation completes.
    public var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts.
    /// During animation, `animatableData` will hold the oldValue and is only updated to the target value
    /// once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        DispatchQueue.main.async {
            completion()
        }
    }

    public func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        content
    }
}

public extension View {
    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: VectorArithmetic>(
        for value: Value, completion: @escaping () -> Void
    ) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}

// MARK: - View+Effects

/// - See: https://www.hackingwithswift.com/plus/swiftui-special-effects/shadows-and-glows
public extension View {
    func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
        shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }

    func innerShadow<S: Shape>(
        using shape: S,
        angle: Angle = .degrees(0),
        color: Color = .black,
        width: CGFloat = 6,
        blur: CGFloat = 6
    ) -> some View {
        let finalX = CGFloat(cos(angle.radians - .pi / 2))
        let finalY = CGFloat(sin(angle.radians - .pi / 2))
        return overlay(
            shape
                .stroke(color, lineWidth: width)
                .offset(x: finalX * width * 0.6, y: finalY * width * 0.6)
                .blur(radius: blur)
                .mask(shape)
        )
    }
}

// MARK: - Geometry+Helpers

public extension GeometryProxy {
    var isPortrait: Bool {
        size.height > size.width
    }

    var isLandscape: Bool {
        size.width > size.height
    }
}

// MARK: - ButtonStyle

/// - See: https://stackoverflow.com/a/58176268/2165585
public struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 2

    var animationIn: Animation? = .none
    var animationOut: Animation? = .default

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(
                configuration.isPressed ? animationIn : animationOut,
                value: configuration.isPressed
            )
    }
}

// MARK: - PreferenceKey / CGSize

/// - See: https://stackoverflow.com/a/63305935/2165585
public protocol CGSizePreferenceKey: PreferenceKey where Value == CGSize {}

public extension CGSizePreferenceKey {
    static func reduce(value _: inout CGSize, nextValue: () -> CGSize) {
        _ = nextValue()
    }
}

public extension View {
    func onSizeChanged<Key: CGSizePreferenceKey>(
        _ key: Key.Type,
        perform action: @escaping (CGSize) -> Void
    ) -> some View {
        background(GeometryReader { geo in
            Color.clear
                .preference(key: Key.self, value: geo.size)
        })
        .onPreferenceChange(key) { value in
            action(value)
        }
    }
}

// MARK: - PreferenceKey / CGFloat

public protocol CGFloatPreferenceKey: PreferenceKey where Value == CGFloat {}

public extension CGFloatPreferenceKey {
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

public extension View {
    func changePreference<Key: CGFloatPreferenceKey>(
        _ key: Key.Type,
        using closure: @escaping (GeometryProxy) -> CGFloat
    ) -> some View {
        background(GeometryReader { geo in
            Color.clear
                .preference(key: Key.self, value: closure(geo))
        })
    }
}

// MARK: - StickyHeader

/// - See: https://trailingclosure.com/sticky-header
public struct StickyHeader<Content: View>: View {
    public var minHeight: CGFloat
    public var content: Content

    public init(
        minHeight: CGFloat = 200,
        @ViewBuilder content: () -> Content
    ) {
        self.minHeight = minHeight
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geo in
            if geo.frame(in: .global).minY <= 0 {
                content.frame(
                    width: geo.size.width,
                    height: geo.size.height,
                    alignment: .center
                )
            } else {
                content
                    .offset(y: -geo.frame(in: .global).minY)
                    .frame(
                        width: geo.size.width,
                        height: geo.size.height + geo.frame(in: .global).minY
                    )
            }
        }.frame(minHeight: minHeight)
    }
}

// MARK: - Placeholder

public struct Placeholder: View {
    var text: String

    public init(_ text: String = "placeholder") {
        self.text = text
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [10]))
                .foregroundColor(.secondary)
            Text(text)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - ImageName

public enum ImageName {
    case custom(String)
    case system(String)
}

public extension Image {
    init(_ imageName: ImageName) {
        switch imageName {
        case .custom(let name):
            self = Image(name)
        case .system(let name):
            self = Image(systemName: name)
        }
    }
}

// MARK: - Scalable Font

public extension Text {
    enum ScalableFont {
        case system
        case custom(String)
    }

    func scalableFont(
        _ scalableFont: ScalableFont = .system,
        padding: CGFloat = 0
    ) -> some View {
        font(resolveFont(for: scalableFont))
            .padding(padding)
            .minimumScaleFactor(0.01)
            .lineLimit(1)
    }

    private func resolveFont(for scalableFont: ScalableFont) -> Font {
        switch scalableFont {
        case .system:
            return .system(size: 500)
        case .custom(let name):
            return .custom(name, size: 500)
        }
    }
}

// MARK: - ObservableObject+Bind

public extension ObservableObject {
    func bind<T>(
        _ keyPath: ReferenceWritableKeyPath<Self, T>,
        animation: Animation? = .none
    ) -> Binding<T> {
        .init(
            get: {
                self[keyPath: keyPath]
            },
            set: { value in
                if let animation = animation {
                    withAnimation(animation) {
                        self[keyPath: keyPath] = value
                    }
                } else {
                    self[keyPath: keyPath] = value
                }
            }
        )
    }
}

// MARK: - Binding+Setter

/// - See: https://gist.github.com/Amzd/c3015c7e938076fc1e39319403c62950
public extension Binding {
    func didSet(_ didSet: @escaping ((newValue: Value, oldValue: Value)) -> Void) -> Binding<Value> {
        .init(
            get: {
                wrappedValue
            },
            set: { newValue in
                let oldValue = wrappedValue
                wrappedValue = newValue
                didSet((newValue, oldValue))
            }
        )
    }

    func willSet(_ willSet: @escaping ((newValue: Value, oldValue: Value)) -> Void) -> Binding<Value> {
        .init(
            get: {
                wrappedValue
            },
            set: { newValue in
                willSet((newValue, wrappedValue))
                wrappedValue = newValue
            }
        )
    }
}

// MARK: - ToggleAsync

public struct ToggleAsync<T: View>: View {
    @Binding var isOn: Bool
    var label: () -> T
    var onValueChanged: ((Bool) -> Void)?

    public init(
        isOn: Binding<Bool>,
        label: @escaping () -> T,
        onValueChanged: ((Bool) -> Void)? = nil
    ) {
        _isOn = isOn
        self.label = label
        self.onValueChanged = onValueChanged
    }

    public var body: some View {
        Toggle(
            isOn: $isOn
                .didSet { newValue, oldValue in
                    if newValue != oldValue {
                        onValueChanged?(newValue)
                    }
                },
            label: label
        )
    }
}

// MARK: - Line

public struct Line: Shape {
    public let x1: CGFloat
    public let y1: CGFloat
    public let x2: CGFloat
    public let y2: CGFloat

    public init(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        return path
    }
}

public struct LineTop: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

public struct LineLeft: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

public struct LineBottom: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

public struct LineRight: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

// MARK: - Pie

/// - See: https://cs193p.sites.stanford.edu
public struct Pie: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = false

    public init(startAngle: Angle, endAngle: Angle, clockwise: Bool) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.clockwise = clockwise
    }

    public var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(startAngle.radians, endAngle.radians)
        }
        set {
            startAngle = Angle.radians(newValue.first)
            endAngle = Angle.radians(newValue.second)
        }
    }

    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = CGPoint(
            x: center.x + radius * cos(CGFloat(startAngle.radians)),
            y: center.y + radius * sin(CGFloat(startAngle.radians))
        )

        var p = Path()
        p.move(to: center)
        p.addLine(to: start)
        p.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise
        )
        p.addLine(to: center)
        return p
    }
}

// MARK: - Polygon

/// - See: https://swiftui-lab.com/swiftui-animations-part1
public struct Polygon: Shape {
    var sides: Double
    var scale: Double
    var drawVertexLines: Bool

    public init(sides: Double, scale: Double, drawVertexLines: Bool = false) {
        self.sides = sides
        self.scale = scale
        self.drawVertexLines = drawVertexLines
    }

    public var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(sides, scale)
        }
        set {
            sides = newValue.first
            scale = newValue.second
        }
    }

    public func path(in rect: CGRect) -> Path {
        let hypotenuse = Double(min(rect.size.width, rect.size.height)) / 2.0 * scale
        let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)

        var path = Path()

        let extra: Int = sides != Double(Int(sides)) ? 1 : 0

        var vertex: [CGPoint] = []

        for i in 0..<Int(sides) + extra {
            let angle = (Double(i) * (360.0 / sides)) * (Double.pi / 180)

            // calculate vertex
            let pt = CGPoint(
                x: center.x + CGFloat(cos(angle) * hypotenuse),
                y: center.y + CGFloat(sin(angle) * hypotenuse)
            )

            vertex.append(pt)

            if i == 0 {
                path.move(to: pt) // move to first vertex
            } else {
                path.addLine(to: pt) // draw line to next vertex
            }
        }

        path.closeSubpath()

        if drawVertexLines {
            drawVertexLines(path: &path, vertex: vertex, n: 0)
        }

        return path
    }

    private func drawVertexLines(path: inout Path, vertex: [CGPoint], n: Int) {
        if (vertex.count - n) < 3 { return }

        for i in (n + 2)..<min(n + (vertex.count - 1), vertex.count) {
            path.move(to: vertex[n])
            path.addLine(to: vertex[i])
        }

        drawVertexLines(path: &path, vertex: vertex, n: n + 1)
    }
}

// MARK: - iOS Specific

#if os(iOS)

import Combine
import UIKit

// MARK: - SafeAreaView

struct SafeAreaView<T: View>: View {
    var edges: Edge.Set
    var content: () -> T

    @State private var safeArea: UIEdgeInsets = UIWindow.safeArea

    var body: some View {
        content()
            .padding(.top, edges.contains(.top) ? safeArea.top : 0)
            .padding(.bottom, edges.contains(.bottom) ? safeArea.bottom : 0)
            .padding(.leading, edges.contains(.leading) ? safeArea.left : 0)
            .padding(.trailing, edges.contains(.trailing) ? safeArea.right : 0)

            .onReceive(UIDevice.orientationDidChangeNotification) { _ in
                safeArea = UIWindow.safeArea
            }
    }
}

struct SafeAreaViewModifier: ViewModifier {
    var edges: Edge.Set

    func body(content: Content) -> some View {
        SafeAreaView(edges: edges) {
            content
        }
    }
}

public extension View {
    func edgesRespectingSafeArea(_ edges: Edge.Set) -> some View {
        modifier(SafeAreaViewModifier(edges: edges))
    }
}

public extension Edge.Set {
    static let none: Edge.Set = []
}

// MARK: - KeyboardAdaptive

/// - See: https://gist.github.com/scottmatthewman/722987c9ad40f852e2b6a185f390f88d
public struct KeyboardAdaptive: ViewModifier {
    @State private var currentHeight: CGFloat = 0

    public func body(content: Content) -> some View {
        content
            .padding(.bottom, currentHeight)
            .edgesIgnoringSafeArea(currentHeight == 0 ? [] : .bottom)
            .onAppear(perform: subscribeToKeyboardEvents)
    }

    private func subscribeToKeyboardEvents() {
        NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillShowNotification
        ).compactMap { notification in
            notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        }.map { rect in
            rect.height
        }.subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))

        NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillHideNotification
        ).compactMap { _ in
            CGFloat.zero
        }.subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
    }
}

public extension View {
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptive())
    }
}

// MARK: - CornerRadius

/// - See: https://stackoverflow.com/a/58606176/2165585
public struct RoundedCorner: Shape {
    public var radius: CGFloat
    public var corners: UIRectCorner

    public init(
        radius: CGFloat = .infinity,
        corners: UIRectCorner = .allCorners
    ) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Share Sheet

/// - See: https://developer.apple.com/forums/thread/123951
public struct ShareSheet: UIViewControllerRepresentable {
    public typealias Callback = (
        _ activityType: UIActivity.ActivityType?,
        _ completed: Bool,
        _ returnedItems: [Any]?,
        _ error: Error?
    ) -> Void

    public let activityItems: [Any]
    public let applicationActivities: [UIActivity]?
    public let excludedActivityTypes: [UIActivity.ActivityType]?
    public let callback: Callback?

    public init(
        activityItems: [Any],
        applicationActivities: [UIActivity]? = nil,
        excludedActivityTypes: [UIActivity.ActivityType]? = nil,
        callback: Callback? = nil
    ) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.callback = callback
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - List+Helpers

public extension List {
    func hideSeparators() -> some View {
        onAppear {
            UITableView.appearance().separatorStyle = .none
        }
        .onDisappear {
            UITableView.appearance().separatorStyle = .singleLine
        }
    }
}

#endif

#endif
