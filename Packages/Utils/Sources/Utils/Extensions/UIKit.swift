#if os(iOS) || os(tvOS)

import UIKit

// MARK: - Auto Layout Helpers

extension UIView: Anchorable {}
extension UILayoutGuide: Anchorable {}

public protocol Anchorable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

public extension Anchorable {
    var leading: NSLayoutXAxisAnchor { leadingAnchor }
    var trailing: NSLayoutXAxisAnchor { trailingAnchor }
    var left: NSLayoutXAxisAnchor { leftAnchor }
    var right: NSLayoutXAxisAnchor { rightAnchor }
    var top: NSLayoutYAxisAnchor { topAnchor }
    var bottom: NSLayoutYAxisAnchor { bottomAnchor }
    var width: NSLayoutDimension { widthAnchor }
    var height: NSLayoutDimension { heightAnchor }
    var centerX: NSLayoutXAxisAnchor { centerXAnchor }
    var centerY: NSLayoutYAxisAnchor { centerYAnchor }

    func constrainHorizontally<T: Anchorable>(
        to anchor: T,
        leadingInset: CGFloat = 0,
        trailingInset: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        [
            leading.constraint(equalTo: anchor.leading, constant: leadingInset),
            anchor.trailing.constraint(equalTo: trailing, constant: trailingInset)
        ]
    }

    func constrainVertically<T: Anchorable>(
        to anchor: T,
        topInset: CGFloat = 0,
        bottomInset: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        [
            top.constraint(equalTo: anchor.top, constant: topInset),
            anchor.bottom.constraint(equalTo: bottom, constant: bottomInset)
        ]
    }

    func constrainEdges<T: Anchorable>(
        to anchor: T,
        insets: UIEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        let h = constrainHorizontally(
            to: anchor,
            leadingInset: insets.left,
            trailingInset: insets.right
        )
        let v = constrainVertically(
            to: anchor,
            topInset: insets.top,
            bottomInset: insets.bottom
        )
        return h + v
    }

    func constrainCenter<T: Anchorable>(to anchor: T) -> [NSLayoutConstraint] {
        [
            centerX.constraint(equalTo: anchor.centerX),
            centerY.constraint(equalTo: anchor.centerY)
        ]
    }

    func constrainSize(to size: CGSize) -> [NSLayoutConstraint] {
        [
            width.constraint(equalToConstant: size.width),
            height.constraint(equalToConstant: size.height)
        ]
    }
}

public extension UIView {
    func addSubview(_ view: UIView, constraints: NSLayoutConstraint...) {
        addSubview(view, constraints: Array(constraints))
    }

    func addSubview(_ view: UIView, constraints: [NSLayoutConstraint]) {
        addSubview(view)
        view.activateConstraints(constraints)
    }

    func addSubviews(_ constraints: [UIView: [NSLayoutConstraint]]) {
        constraints.keys.forEach { addSubview($0) }
        constraints.forEach { $0.activateConstraints($1) }
    }

    func activateConstraints(_ constraints: NSLayoutConstraint...) {
        activateConstraints(Array(constraints))
    }

    func activateConstraints(_ constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}

public extension UIView {
    func embedToEdges(_ view: UIView, insets: UIEdgeInsets = .zero) {
        addSubview(view, constraints: view.constrainEdges(to: self, insets: insets))
    }

    func embedAtCenter(_ view: UIView) {
        addSubview(view, constraints: view.constrainCenter(to: self))
    }

    func makeCircle() {
        layer.cornerRadius = bounds.width / 2
        clipsToBounds = true
    }
}

public extension NSLayoutConstraint {
    func prioritized(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

public extension UIEdgeInsets {
    init(_ size: CGFloat) {
        self.init(top: size, left: size, bottom: size, right: size)
    }
}

public extension UIStackView {
    func addArrangedSubview(_ view: UIView, constraints: NSLayoutConstraint...) {
        addArrangedSubview(view, constraints: Array(constraints))
    }

    func addArrangedSubview(_ view: UIView, constraints: [NSLayoutConstraint]) {
        addArrangedSubview(view)
        view.activateConstraints(constraints)
    }

    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }

    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }

    func reverseArrangedSubviews() {
        let reversed: [UIView] = arrangedSubviews.reversed()
        arrangedSubviews.forEach({ removeArrangedSubview($0) })
        addArrangedSubviews(reversed)
    }

    func embedWithRelativeMargins(_ view: UIView, padding: UIEdgeInsets? = nil) {
        isLayoutMarginsRelativeArrangement = true
        addArrangedSubview(view)
        if let padding = padding {
            layoutMargins = padding
        }
    }
}

public extension UIViewController {
    @discardableResult
    func embed<T: UIViewController>(_ child: T) -> T {
        add(child, constraints: child.view.constrainEdges(to: view))
    }

    /// - See: https://www.swiftbysundell.com/posts/using-child-view-controllers-as-plugins-in-swift
    @discardableResult
    func add<T: UIViewController>(
        _ child: T,
        into container: UIView? = nil,
        constraints: [NSLayoutConstraint]? = nil
    ) -> T {
        let parentView = container ?? view ?? UIView()
        addChild(child)
        parentView.addSubview(child.view)
        if let constraints = constraints {
            child.view.activateConstraints(constraints)
        }
        child.didMove(toParent: self)
        return child
    }

    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

// MARK: - Nib & Storyboard Helpers

/// - See: https://github.com/alisoftware/Reusable
extension UIView {
    public static func loadFromNib() -> Self {
        guard let view = nib
            .instantiate(withOwner: nil, options: nil)
            .first as? Self
        else {
            fatalError("Failed to load view from nib: \(nibName)")
        }
        return view
    }

    public func loadFromNib() {
        guard let view = Self.nib
            .instantiate(withOwner: self, options: nil)
            .first as? UIView
        else {
            fatalError("Failed to load view from nib: \(Self.nibName)")
        }
        embedToEdges(view)
    }

    public static var typeName: String {
        String(describing: self)
    }

    @objc
    open class var nibName: String {
        typeName
    }

    @objc
    open class var nib: UINib {
        UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}

extension UIViewController {
    public static func loadFromStoryboard() -> Self {
        let vc: UIViewController?
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
        if let identifier = storyboardIdentifier {
            vc = storyboard.instantiateViewController(withIdentifier: identifier)
        } else {
            vc = storyboard.instantiateInitialViewController()
        }
        guard let storyboardVC = vc as? Self else {
            fatalError("Failed to load from storyboard: \(String(describing: self))")
        }
        return storyboardVC
    }

    @objc
    open class var storyboardName: String {
        String(describing: self)
    }

    @objc
    open class var storyboardIdentifier: String? {
        nil
    }
}

// MARK: - CALayer Helpers

public extension CALayer {
    @discardableResult
    func drawLine(
        from start: CGPoint,
        to end: CGPoint,
        color: UIColor = .white,
        width: CGFloat = 1,
        pattern: [NSNumber]? = nil
    ) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let line = UIBezierPath()
        line.move(to: start)
        line.addLine(to: end)
        layer.path = line.cgPath
        layer.lineWidth = width
        layer.strokeColor = color.cgColor
        layer.fillColor = nil
        layer.lineDashPattern = pattern
        layer.contentsScale = UIScreen.main.scale
        insertSublayer(layer, at: 0)
        return layer
    }

    @discardableResult
    func drawText(
        _ text: String,
        in frame: CGRect,
        font: UIFont,
        color: UIColor = .white
    ) -> CATextLayer {
        let layer = CATextLayer()
        layer.frame = frame
        layer.font = font
        layer.fontSize = font.fontDescriptor.pointSize
        layer.foregroundColor = color.cgColor
        layer.alignmentMode = .center
        layer.string = text
        layer.contentsScale = UIScreen.main.scale
        addSublayer(layer)
        return layer
    }

    @discardableResult
    func drawImage(_ image: UIImage?, in frame: CGRect) -> CALayer {
        let layer = CALayer()
        layer.frame = frame
        layer.contents = image?.cgImage
        layer.contentsScale = UIScreen.main.scale
        addSublayer(layer)
        return layer
    }

    @discardableResult
    func drawShape(
        _ shape: Shape,
        in frame: CGRect,
        color: UIColor = .white
    ) -> CAShapeLayer {
        let layer = CAShapeLayer()
        switch shape {
        case .rect:
            layer.path = UIBezierPath(rect: frame).cgPath
        case .oval:
            layer.path = UIBezierPath(ovalIn: frame).cgPath
        }
        layer.fillColor = color.cgColor
        layer.contentsScale = UIScreen.main.scale
        addSublayer(layer)
        return layer
    }

    enum Shape {
        case rect, oval
    }
}

// MARK: - String Helpers

/// - See: https://stackoverflow.com/a/30450559/2165585
// swiftformat:disable redundantSelf
public extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return boundingBox.height
    }

    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return boundingBox.width
    }
}
// swiftformat:enable redundantSelf

// MARK: - UIAccessibility Helpers

public extension UIAccessibility {
    static func updateLayout() {
        post(notification: .layoutChanged, argument: nil)
    }

    static func updateScreen() {
        post(notification: .screenChanged, argument: nil)
    }

    static func announce(_ message: String) {
        if isVoiceOverRunning {
            post(notification: .announcement, argument: message)
        }
    }
}

public extension UIColor {
    convenience init(hex: String) {
        let rgba = hex.hexColorToRGBA()
        self.init(
            red: rgba.r,
            green: rgba.g,
            blue: rgba.b,
            alpha: rgba.a
        )
    }

    var hexString: String {
        cgColor.hexString
    }
}

// MARK: - UIImage Helpers

/// - See: https://developer.apple.com/videos/play/wwdc2018/219
public extension UIImage {

    /// Downsampling large images for display at smaller size
    ///
    /// - Parameters:
    ///   - size: image size on screen
    ///   - scale: screen scale
    /// - Returns: Downsampled image
    func downsampled(
        to size: CGSize,
        scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        guard let data = pngData() as CFData? else {
            return nil
        }
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(data, imageSourceOptions)
        guard let imageSource else {
            return nil
        }
        return UIImage.downsampled(imageSource, to: size, scale: scale)
    }

    /// Downsampling large images for display at smaller size
    ///
    /// - Parameters:
    ///   - imageURL: image file URL
    ///   - size: image size on screen
    ///   - scale: screen scale
    /// - Returns: Downsampled image
    static func downsample(
        imageAt imageURL: URL,
        to size: CGSize,
        scale: CGFloat = UIScreen.main.scale
    ) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(
            imageURL as CFURL, imageSourceOptions
        )
        guard let imageSource else {
            return nil
        }
        return downsampled(imageSource, to: size, scale: scale)
    }

    // MARK: Helpers

    private static func downsampled(
        _ imageSource: CGImageSource,
        to size: CGSize,
        scale: CGFloat
    ) -> UIImage? {
        let maxDimensionInPixels = max(size.width, size.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as [CFString: Any] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(
            imageSource, 0, downsampleOptions
        )
        guard let downsampledImage else {
            return nil
        }
        return UIImage(cgImage: downsampledImage)
    }

}

// swiftlint:disable force_unwrapping
public extension UIImage {
    func flipped(_ orientation: UIImage.Orientation) -> UIImage {
        UIImage(cgImage: cgImage!, scale: scale, orientation: orientation)
    }
}
// swiftlint:enable force_unwrapping

/// - See: https://gist.github.com/ppamorim/cc79170422236d027b2b
public extension UIImage {
    func withInsets(_ insets: UIEdgeInsets) -> UIImage? {
        let newSize = CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        draw(at: origin)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()?
            .withRenderingMode(renderingMode)
        UIGraphicsEndImageContext()
        return newImage
    }
}

/// - See: https://stackoverflow.com/a/39748919/2165585
public extension UIImage {
    static func createLocalFile(forImageNamed name: String) -> URL? {
        UIImage(named: name)?
            .createLocalFile(name: name)
    }

    func createLocalFile(name: String) -> URL? {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory
            .appendingPathComponent("\(name).png")

        guard fileManager.fileExists(atPath: url.path) else {
            guard let data = pngData() else {
                return nil
            }
            fileManager.createFile(
                atPath: url.path,
                contents: data,
                attributes: nil
            )
            return url
        }

        return url
    }
}

public extension UIImage {
    func resize(maxLength: CGFloat) -> UIImage {
        let height = size.height
        let width = size.width

        var newSize: CGSize
        if height > width {
            guard height > maxLength else {
                return self
            }
            let calculatedNewLength = ceil(width * maxLength / height)
            let widthRatio = calculatedNewLength / width
            newSize = CGSize(
                width: ceil(width * widthRatio),
                height: ceil(height * widthRatio)
            )
        } else {
            guard width > maxLength else {
                return self
            }
            let calculatedNewLength = ceil(height * maxLength / width)
            let heightRatio = calculatedNewLength / height
            newSize = CGSize(
                width: ceil(width * heightRatio),
                height: ceil(height * heightRatio)
            )
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        draw(in: rect)

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }

        UIGraphicsEndImageContext()
        return newImage
    }
}

public extension UIImage {
    func rotated(by degrees: CGFloat) -> UIImage? {
        let width = size.width
        let height = size.height
        let angle = degrees * .pi / 180
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.translateBy(x: width / 2, y: height / 2)
        context.rotate(by: angle)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

/// - See: https://stackoverflow.com/a/36591030/2165585
public extension UIImage {
    func tinted(_ color: UIColor) -> UIImage? {
        guard let maskImage = cgImage else {
            return nil
        }

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(
            rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        guard let cgImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - UIScrollView Helpers

public extension UIScrollView {
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: -safeAreaInsets.left, y: -safeAreaInsets.top)
        setContentOffset(topOffset, animated: animated)
    }

    func scrollToBottom(animated: Bool) {
        let bottomOffsetY = contentSize.height - bounds.size.height
        let bottomOffset = CGPoint(x: 0, y: bottomOffsetY)
        setContentOffset(bottomOffset, animated: animated)
    }
}

// MARK: - UILabel Helpers

/// - See: https://stackoverflow.com/a/47140975/2165585
public extension UITapGestureRecognizer {
    func didTapRange(_ targetRange: NSRange, in label: UILabel) -> Bool {
        guard let attrString = label.attributedText else {
            return false
        }

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attrString)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        let locationOfTouchInLabel = location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let centerX = (labelSize.width - textBoundingBox.size.width) * 0.5
        let centerY = (labelSize.height - textBoundingBox.size.height) * 0.5
        let textContainerOffsetX = centerX - textBoundingBox.origin.x
        let textContainerOffsetY = centerY - textBoundingBox.origin.y
        let textContainerOffset = CGPoint(x: textContainerOffsetX, y: textContainerOffsetY)
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

// MARK: - UIView Helpers

public extension UIView {
    convenience init(_ color: UIColor?) {
        self.init()
        backgroundColor = color
    }
}

public extension UIView {
    /// Fade in a view
    /// - Parameter duration: fade in animation duration
    func fadeIn(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }

    /// Fade out a view
    /// - Parameter duration: fade out animation duration
    func fadeOut(withDuration duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}

public extension UIView {
    /// - See: https://www.hackingwithswift.com/example-code/media/how-to-render-a-uiview-to-a-uiimage
    func drawHierarchy(_ format: UIGraphicsImageRendererFormat = .init()) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }

    /// - See: http://stackoverflow.com/a/41288197/2165585
    func renderLayer(_ format: UIGraphicsImageRendererFormat = .init()) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

// MARK: - UIWindow+Helpers

public extension UIWindow {
    static var keyWindow: UIWindow? {
        scene?.windows
            .first(where: { $0.isKeyWindow })
    }

    static var safeArea: UIEdgeInsets {
        keyWindow?.safeAreaInsets ?? .zero
    }

    static var isPortrait: Bool {
        #if os(tvOS)
        false
        #else
        scene?.interfaceOrientation.isPortrait ?? true
        #endif
    }

    static var isLandscape: Bool {
        #if os(tvOS)
        true
        #else
        scene?.interfaceOrientation.isLandscape ?? false
        #endif
    }

    static var isSplitOrSlideOver: Bool {
        guard let window = keyWindow else {
            return false
        }
        return !window.frame.equalTo(window.screen.bounds)
    }

    static var statusBarHeight: CGFloat {
        #if os(tvOS)
        0
        #else
        scene?.statusBarManager?.statusBarFrame.height ?? 0
        #endif
    }

    static var navigationBarHeight: CGFloat {
        topViewController?.navigationController?.navigationBar.bounds.height ?? 0
    }

    static var topViewController: UIViewController? {
        topViewController(keyWindow?.rootViewController)
    }

    // MARK: Helpers

    private class func topViewController(_ vc: UIViewController?) -> UIViewController? {
        if let nav = vc as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = vc as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = vc?.presentedViewController {
            return topViewController(presented)
        }
        return vc
    }

    private static var statusBarFrame: CGRect? {
        #if os(tvOS)
            .zero
        #else
        scene?.statusBarManager?.statusBarFrame
        #endif
    }

    private static var scene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first
    }
}

// MARK: - Custom Types

#if os(iOS)
open class UIActivityItem: NSObject, UIActivityItemSource {
    let item: Any?
    let enabledTypes: [UIActivity.ActivityType]?

    public init(_ item: Any?, enabledTypes: [UIActivity.ActivityType]? = nil) {
        self.item = item
        self.enabledTypes = enabledTypes
    }

    open func activityViewControllerPlaceholderItem(
        _ activityViewController: UIActivityViewController
    ) -> Any {
        item ?? ""
    }

    open func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        guard let enabledTypes = enabledTypes, let activityType = activityType else {
            return item
        }
        guard enabledTypes.contains(activityType) else {
            return nil
        }
        return item
    }
}
#endif

#endif
