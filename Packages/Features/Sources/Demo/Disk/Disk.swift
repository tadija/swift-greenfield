import Minions
import Shared
import SwiftUI

public struct DiskView: View {

    @ObservedObject var vm: DiskViewModel

    public init(vm: DiskViewModel = .init()) {
        self.vm = vm
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Disk Demo")
                .toolbar { ToolbarItem(content: makeToolbarItem) }
                .sheet(isPresented: $vm.state.error.isNotNil()) {
                    if let error = vm.state.error {
                        ErrorView(error: error)
                            .presentationDetents([.fraction(0.3)])
                    }
                }
                .task { await vm.loadContent() }
        }
        .environmentObject(vm)
        .tint(.semantic(.tintPrimary))
    }

    @ViewBuilder
    private func makeToolbarItem() -> some View {
        if vm.state.isLoading {
            ProgressView().tint(.semantic(.contentSecondary))
        }
    }

    @ViewBuilder
    private var content: some View {
        if vm.state.content.isEmpty {
            Text(vm.state.emptyContentText)
                .font(.custom(.title3))
                .foregroundColor(.semantic(.contentSecondary))
        } else {
            ImageList().navigationDestination(for: URL.self) { url in
                ImageView(imageURL: url)
            }
        }
    }

    private struct ImageList: View {
        @EnvironmentObject var vm: DiskViewModel

        var body: some View {
            List {
                ForEach(Array(vm.state.content.enumerated()), id: \.element) { index, url in
                    NavigationLink(value: url) {
                        ImageRow(url: url)
                    }
                    #if os(macOS)
                    .listRowSeparator(.visible)
                    .contextMenu {
                        Button(action: {
                            Task { await vm.deleteItems(at: IndexSet(integer: index)) }
                        }, label: {
                            Text("Delete Item")
                        })
                    }
                    #endif
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 16))
                }
                .onDelete { offsets in
                    Task {
                        try await Task.sleep(for: .seconds(0.25))
                        await vm.deleteItems(at: offsets)
                    }
                }
            }
            #if os(iOS)
            .listStyle(.grouped)
            .toolbar { EditButton() }
            #endif
        }
    }

    private struct ImageRow: View {
        @EnvironmentObject var vm: DiskViewModel

        var url: URL

        var body: some View {
            HStack(spacing: 0) {
                icon.padding(.horizontal)
                details
            }
            .padding(.vertical)
        }

        private var icon: some View {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "photo")
            }
            .frame(width: 64, height: 64)
            .cornerRadius(6)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.semantic(.tintPrimary), lineWidth: 3)
            )
        }

        private var details: some View {
            VStack(alignment: .leading) {
                Text(url.lastPathComponent)
                    .font(.custom(.caption))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundColor(.semantic(.contentPrimary))

                Text(vm.makeDetails(for: url))
                    .font(.custom(.footnote))
                    .foregroundColor(.semantic(.contentSecondary))
            }
        }
    }

    private struct ImageView: View {
        @EnvironmentObject var vm: DiskViewModel

        var imageURL: URL

        @State private var image: Image?

        var body: some View {
            content
                .navigationTitle(vm.makeTitle(for: imageURL))
                .toolbar {
                    if let image {
                        ShareLink(item: image, preview: .init("Share item"))
                    }
                }
                .task {
                    image = try? await vm.loadImage(at: imageURL)
                }
        }

        @ViewBuilder
        private var content: some View {
            if let image {
                image.resizable().scaledToFill()
            } else {
                ProgressView().tint(.semantic(.contentSecondary))
            }
        }
    }

    private struct ErrorView: View {
        @EnvironmentObject var vm: DiskViewModel

        var error: Error

        var body: some View {
            VStack {
                Text("❌ Error")
                    .font(.custom(.title2))

                Text(error.localizedDescription)
                    .font(.custom(.body))
                    .padding()

                reloadButton.padding(.vertical)
            }
            .padding()
        }

        private var reloadButton: some View {
            Button(action: { Task {
                await vm.loadContent()
            }}, label: {
                Text("RELOAD")
            })
            .buttonStyle(.primary(tint: .orange))
        }
    }
}

// MARK: - State

public struct DiskViewState {
    public init() {}

    public var isLoading: Bool = false
    public var content: [URL] = []
    public var error: Error?

    var emptyContentText: String {
        if isLoading {
            return "Loading..."
        } else {
            if error == nil {
                return "Nothing here yet."
            } else {
                return ""
            }
        }
    }
}

public extension DiskViewState {
    mutating func switchToLoading() {
        error = nil
        isLoading = true
    }

    mutating func switchToContent(_ content: [URL]) {
        self.content = content
        error = nil
        isLoading = false
    }

    mutating func switchToError(_ error: Error) {
        self.error = error
        isLoading = false
    }
}

extension DiskViewState {
    static func mockLoading() -> Self {
        var state = DiskViewState()
        state.switchToLoading()
        return state
    }

    static func mockContent(_ content: [URL]) -> Self {
        var state = DiskViewState()
        state.switchToContent(content)
        return state
    }

    static func mockError(_ error: Error) -> Self {
        var state = DiskViewState()
        state.switchToError(error)
        return state
    }
}

// MARK: - Model

public final class DiskViewModel: ObservableObject {
    @Dependency(\.dataSource) private var dataSource

    @Published var state: DiskViewState

    public init(_ state: DiskViewState = .init()) {
        self.state = state
    }

    var _skipLoad: Bool = false

    // MARK: API

    public var workDirectory: URL {
        .documentsDirectory
    }

    public func loadContent() async {
        guard !_skipLoad else { return }

        await MainActor.run { state.switchToLoading() }
        do {
            let urls = try await dataSource.listDirectory(workDirectory)
                .sorted(by: {
                    guard let date1 = $0.creationDate, let date2 = $1.creationDate else {
                        return false
                    }
                    return date1.compare(date2) == .orderedDescending
                })
            await MainActor.run { state.switchToContent(urls) }
        } catch {
            await MainActor.run { state.switchToError(error) }
        }
    }

    public func makeDetails(for url: URL) -> String {
        let values = dataSource.formattedValues(url)
        let date = values[.creationDateKey] ?? "n/a"
        let size = values[.fileSizeKey] ?? "n/a"
        return "\(date) - \(size)"
    }

    public func makeTitle(for url: URL) -> String {
        dataSource.formattedValues(url)[.creationDateKey] ?? "n/a"
    }

    public func loadImage(at url: URL) async throws -> Image {
        try await Image(imageData: dataSource.loadItem(url))
    }

    public func deleteItems(at offsets: IndexSet) async {
        await MainActor.run { state.switchToLoading() }

        let urlsToDelete = offsets.map { state.content[$0] }

        await MainActor.run { state.content.remove(atOffsets: offsets) }

        await withTaskGroup(of: Void.self) { group in
            urlsToDelete.forEach { url in
                group.addTask {
                    do {
                        try await self.dataSource.deleteItem(url)
                    } catch {
                        await MainActor.run { self.state.switchToError(error) }
                    }
                }
            }
        }

        await MainActor.run { state.isLoading = false }
    }
}

private extension URL {
    var creationDate: Date? {
        values?.creationDate
    }

    var fileSize: Int? {
        values?.fileSize
    }

    private var values: URLResourceValues? {
        try? resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
    }
}

// MARK: - Factory

private struct DataSource {
    var listDirectory: (URL) async throws -> [URL]
    var formattedValues: (URL) -> [URLResourceKey: String]
    var loadItem: (URL) async throws -> Data
    var deleteItem: (URL) async throws -> Void
}

extension DataSource: DependencyKey {

    static let disk = Dependencies[\.disk]

    static var liveValue: Self = .init(
        listDirectory: { url in
            logWrite("list: \(url)")
            return try await disk.contentsOfDirectory(
                at: url,
                including: [.creationDateKey, .fileSizeKey]
            )
        },
        formattedValues: { url in
            [
                .creationDateKey: url.creationDate?.formatted() ?? "n/a",
                .fileSizeKey: url.fileSize?.formatted(.byteCount(style: .file)) ?? "n/a"
            ]
        },
        loadItem: { url in
            logWrite("read: \(url)")
            return try await disk.read(from: url)
        },
        deleteItem: { url in
            logWrite("delete: \(url)")
            return try await disk.delete(at: url)
        }
    )

    static var previewValue: Self = .init(
        listDirectory: { _ in mockURLS() },
        formattedValues: { _ in mockValues() },
        loadItem: { _ in Asset.minion.image.dataRepresentation() },
        deleteItem: { _ in }
    )

    static var testValue: Self = previewValue

    static var simulatorValue: Self = previewValue
}

extension DataSource {
    static func mockURLS() -> [URL] {[
        .documentsDirectory.appending(path: mockFilename()),
        .documentsDirectory.appending(path: mockFilename()),
        .documentsDirectory.appending(path: mockFilename())
    ]}

    static func mockFilename() -> String {
        "Filename_\(mockTimestamp().formatted(.customTimestamp)).jpg"
    }

    static func mockValues() -> [URLResourceKey: String] {[
        .creationDateKey: mockTimestamp().formatted(),
        .fileSizeKey: "2.1 MB"
    ]}

    private static func mockTimestamp() -> Date {
        Date().addingTimeInterval(.random(in: -10.0...10.0))
    }
}

extension Dependencies {
    fileprivate var dataSource: DataSource {
        get { Self[DataSource.self] }
        set { Self[DataSource.self] = newValue }
    }
}

// MARK: - Previews

struct DiskView_Previews: PreviewProvider {
    static var previews: some View {
        make(.mockContent(DataSource.mockURLS()))
            .previewDisplayName("Content")

        make(.mockContent([]))
            .previewDisplayName("Empty")

        make(.mockLoading())
            .previewDisplayName("Loading")

        make(.mockError("preview test error"))
            .previewDisplayName("Error")
    }

    static func make(_ state: DiskViewState) -> some View {
        let vm = DiskViewModel(state)
        vm._skipLoad = true
        return DiskView(vm: vm)
    }
}
