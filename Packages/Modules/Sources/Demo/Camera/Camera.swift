import AVFoundation
import Minions
import Shared
import SwiftUI

public struct CameraView: View {

    @State private var vm: CameraViewModel

    public init(vm: CameraViewModel = .init()) {
        self.vm = vm
    }

    public var body: some View {
        content
            .navigationTitle("Camera")
            .onAppear { Task { await vm.startCamera() } }
            .onDisappear { Task { await vm.stopCamera() } }
    }

    private var content: some View {
        VStack {
            placeholder

            mainControls

            #if os(iOS)
            flashZoomCameraControls
            #endif
        }
    }

    private var placeholder: some View {
        stateView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(12)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.semantic(.tintPrimary), lineWidth: 6)
            )
            .padding()
    }

    @ViewBuilder
    private var stateView: some View {
        switch vm.state {
        case .loading:
            ProgressView().tint(.semantic(.contentSecondary))
        case .unauthorized:
            makeUnauthorizedView()
        case .camera:
            Camera.CapturePreview().environment(vm.camera)
        case .photo(let image):
            image.resizable().scaledToFit()
        case .error(let error):
            makeErrorView(error)
        }
    }

    @ViewBuilder
    private func makeUnauthorizedView() -> some View {
        if let url = URL(string: vm.settingsURL) {
            VStack(spacing: 16) {
                Text("✋")
                    .font(.system(size: 64))

                Link("allow camera access in system settings", destination: url)
                    .buttonStyle(.plain)
                    .underline()
                    .multilineTextAlignment(.center)
                    .font(.custom(.callout))
            }
        }
    }

    private func makeErrorView(_ error: Error) -> some View {
        Text("❌ Error: \(error.localizedDescription)")
            .font(.custom(.caption))
            .multilineTextAlignment(.leading)
            .padding()
    }

    private var mainControls: some View {
        HStack {
            makeButton("RESET", task: vm.switchToCamera)
                .disabled(vm.state.isResetDisabled)
                .buttonStyle(.tertiary())

            if vm.state.isPhotoReady {
                makeButton("SAVE", task: vm.saveLastPhotoToDisk)
                    .buttonStyle(.secondary())
            } else {
                makeButton("CAPTURE", task: vm.takePhoto)
                    .disabled(vm.state.isCameraDisabled)
                    .buttonStyle(.primary())
            }
        }
        .padding([.horizontal, .bottom])
    }

    private func makeButton(_ title: String, task: @escaping () async -> Void) -> some View {
        Button(title) {
            Task { await task() }
        }
    }

    #if os(iOS)
    private var flashZoomCameraControls: some View {
        HStack(spacing: 0) {
            flashModeButton
            zoomSlider
            toggleCameraButton
        }
        .disabled(vm.state.isCameraDisabled)
    }

    private var flashModeButton: some View {
        Button(action: {
            vm.isFlashEnabled.toggle()
        }, label: {
            Image(systemName: vm.isFlashEnabled ? "bolt.fill" : "bolt.slash.fill")
                .imageScale(.large)
        })
        .buttonStyle(.tertiary(tint: .semantic(.contentSecondary)))
    }

    private var zoomSlider: some View {
        VStack {
            Text("zoom: \(vm.zoomFactor, specifier: "%.1f")x")
                .font(.custom(.callout))

            Slider(value: $vm.zoomFactor, in: 1...10, step: 0.1) {
                Text("Zoom Factor")
            } minimumValueLabel: {
                Text("-")
            } maximumValueLabel: {
                Text("+")
            }
            .font(.custom(.bold, fixed: 24))
            .tint(.semantic(.tintPrimary))
        }
        .foregroundColor(.semantic(.contentSecondary))
        .opacity(vm.state.isCameraDisabled ? 0.3 : 1)
    }

    private var toggleCameraButton: some View {
        Button(action: {
            Task { await vm.toggleCamera() }
        }, label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .imageScale(.large)
        })
        .buttonStyle(.tertiary(tint: .semantic(.contentSecondary)))
    }
    #endif
}

// MARK: - State

public enum CameraViewState {
    case loading
    case unauthorized
    case camera
    case photo(Image)
    case error(Error)
}

private extension CameraViewState {
    var isCameraDisabled: Bool {
        switch self {
        case .camera:
            false
        default:
            true
        }
    }

    var isResetDisabled: Bool {
        switch self {
        case .loading, .unauthorized, .camera:
            true
        default:
            false
        }
    }

    var isPhotoReady: Bool {
        switch self {
        case .photo:
            true
        default:
            false
        }
    }
}

// MARK: - Model

@Observable
public final class CameraViewModel {
    @ObservationIgnored
    @Dependency(\.camera) var camera

    @ObservationIgnored
    @Dependency(\.disk) var disk

    @ObservationIgnored
    @Dependency(\.haptics) var haptics

    private(set) var state: CameraViewState

    #if os(iOS)
    public var isFlashEnabled: Bool = false {
        didSet {
            if isFlashEnabled != oldValue {
                haptics.signal(.light)
            }
        }
    }

    public var zoomFactor: CGFloat = 1.0 {
        didSet {
            if zoomFactor != oldValue {
                haptics.signal(.selection)
                try? updateZoomFactor()
            }
        }
    }
    #endif

    public var settingsURL: String {
        #if os(iOS)
        UIApplication.openSettingsURLString
        #else
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera"
        #endif
    }

    public init(_ state: CameraViewState = .loading) {
        self.state = state

        setupCamera()
    }

    fileprivate var _skipStart: Bool = ProcessInfo.isXcodePreview

    // MARK: - API

    public func startCamera() async {
        guard !_skipStart else { return }

        #if targetEnvironment(simulator)
        await updateState(to: .camera)
        #else
        do {
            try await camera.start()
            try updateZoomFactor()
            await updateState(to: .camera)
        } catch {
            switch error {
            case CameraError.permissionFailure:
                await updateState(to: .unauthorized)
            default:
                await updateState(to: .error(error))
            }
        }
        #endif
    }

    public func stopCamera() async {
        await camera.stop()
    }

    public func switchToCamera() async {
        haptics.signal(.light)
        await updateState(to: .camera)
    }

    public func toggleCamera() async {
        #if !targetEnvironment(simulator)
        haptics.signal(.light)
        do {
            try await camera.updateDevice()
            try updateZoomFactor()
        } catch {
            await updateState(to: .error(error))
        }
        #endif
    }

    public func takePhoto() async {
        #if targetEnvironment(simulator)
        await updateState(to: .photo(Asset.minion.swiftUIImage))
        #else
        haptics.signal(.medium)
        await updateState(to: .loading)
        do {
            let settings = try makePhotoSettings()
            let photo = try await camera.takePhoto(using: settings)
            let image = try photo.toImage()
            lastPhoto = photo
            await updateState(to: .photo(image))
            haptics.signal(.success)
        } catch {
            await updateState(to: .error(error))
            haptics.signal(.error)
        }
        #endif
    }

    public func saveLastPhotoToDisk() async {
        #if targetEnvironment(simulator)
        await updateState(to: .camera)
        #else
        haptics.signal(.medium)
        await updateState(to: .loading)
        do {
            try await saveLastPhoto()
            await updateState(to: .camera)
        } catch {
            await updateState(to: .error(error))
        }
        #endif
    }

    // MARK: Helpers

    @MainActor
    private func updateState(to newState: CameraViewState) {
        state = newState
    }

    private func updateZoomFactor() throws {
        #if os(iOS)
        guard zoomFactor != camera.zoomFactor else { return }
        try camera.setZoomFactor(zoomFactor)
        #endif
    }

    private func setupCamera() {
        camera.customSessionConfiguration = { session in
            session.sessionPreset = .photo
        }
    }

    private func makePhotoSettings() throws -> AVCapturePhotoSettings {
        guard let device = camera.device else {
            throw CameraError.captureDeviceFailure
        }

        let format = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        let settings = AVCapturePhotoSettings(format: format)
        settings.photoQualityPrioritization = .balanced

        #if os(iOS)
        if isFlashEnabled, device.hasFlash, device.isFlashAvailable {
            settings.flashMode = .on
        }
        if let value = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: value]
        }
        #endif

        return settings
    }

    private func saveLastPhoto() async throws {
        guard let imageData = lastPhoto?.fileDataRepresentation() else {
            throw CameraError.invalidImage
        }

        let timestamp = Date().formatted(.customTimestamp)
        let filename = "Camera_\(timestamp).jpg"
        let url = disk.documents.appending(path: filename)

        try await disk.write(imageData, to: url)

        logWrite("saved photo: \(url)")
    }

    private var lastPhoto: AVCapturePhoto?

}

// MARK: - Factory

extension Camera: DependencyKey {
    public static var liveValue = Camera()
}

extension Dependencies {
    var camera: Camera {
        get { Self[Camera.self] }
        set { Self[Camera.self] = newValue }
    }
}

// MARK: - Previews

#Preview("Camera") {
    CameraView(vm: .init(.camera))
}

#Preview("Photo") {
    CameraView(vm: .init(.photo(Asset.minion.swiftUIImage)))
}

#Preview("Loading") {
    CameraView(vm: .init(.loading))
}

#Preview("Unauthorized") {
    CameraView(vm: .init(.unauthorized))
}

#Preview("Error") {
    CameraView(vm: .init(.error(CameraError.captureDeviceFailure)))
}
