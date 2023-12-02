import Minions
import Shared
import SwiftUI

// MARK: - View

public struct NetworkingView: View {
    @Environment(\.openURL) var openURL

    @State private var vm: NetworkingViewModel

    public init(vm: NetworkingViewModel = .init()) {
        _vm = State(initialValue: vm)
    }

    public var body: some View {
        content
            .navigationTitle("Networking")
            .toolbar { ToolbarItem(content: makeToolbarItem) }
            .task { await vm.load() }
            .tint(.semantic(.tintPrimary))
    }

    @ViewBuilder
    private func makeToolbarItem() -> some View {
        if vm.state.isLoading {
            ProgressView().tint(.semantic(.contentSecondary))
        } else {
            #if os(iOS)
            Button(action: {
                Task { await vm.load() }
            }, label: {
                Image(systemName: "arrow.clockwise")
            })
            #endif
        }
    }

    @ViewBuilder
    private var content: some View {
        makeList(vm.state.rows)
            .alert(
                "Oops, something went wrong.",
                isPresented: $vm.state.error.isNotNil(),
                presenting: vm.state.error,
                actions: { _ in
                    Button("OK") {}
                    Button("Retry") {
                        Task { await vm.load() }
                    }
                },
                message: { error in
                    Text(error.localizedDescription)
                }
            )
    }

    @State private var presentedURL: URL?

    private func makeList(_ rows: [NetworkingViewState.Row]) -> some View {
        List {
            ForEach(rows.indices, id: \.self) { i in
                Button(action: {
                    if let url = rows[i].url {
                        #if os(iOS)
                        presentedURL = url
                        #else
                        openURL(url)
                        #endif
                    }
                }, label: {
                    Row(state: rows[i])
                })
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowBackground(rowColor(i, rowsCount: rows.count))
            }
        }
        #if os(iOS)
        .listStyle(.grouped)
        .sheet(item: $presentedURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        #endif
    }

    private func rowColor(_ currentRowIndex: Int, rowsCount: Int) -> Color {
        Color.semantic(.tintPrimary)
            .opacity(
                Double(currentRowIndex)
                    .convertRange(
                        oldMin: 0,
                        oldMax: Double(rowsCount),
                        newMin: 0,
                        newMax: 0.75
                    )
            )
    }

    struct Row: View {
        var state: NetworkingViewState.Row

        var body: some View {
            VStack(alignment: .leading) {
                header
                content
            }
            .padding()
            .contentShape(Rectangle())
        }

        private var header: some View {
            HStack {
                Text(state.ownerUsername)
                    .font(.custom(.callout))

                Spacer()

                Text(state.repoUpdateDate)
                    .font(.custom(.caption))
                    .foregroundColor(.secondary)
            }
        }

        private var content: some View {
            HStack(alignment: .top) {
                ownerImage

                VStack(alignment: .leading, spacing: 6) {
                    Text(state.repoName)
                        .font(.custom(.headline))

                    if let repoDescription = state.repoDescription {
                        Text(repoDescription)
                            .font(.custom(.body))
                            .lineLimit(3)
                    }

                    counters
                }
            }
        }

        private var ownerImage: some View {
            AsyncImage(url: state.ownerImageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "photo")
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
        }

        private var counters: some View {
            HStack {
                Text("⋔ \(state.forksCount)")
                Text("★ \(state.starsCount)")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(.secondary)
            .font(.custom(.footnote))
        }
    }
}

// MARK: - State

public struct NetworkingViewState {
    public init() {}

    public var isLoading: Bool = false
    public var rows: [Row] = []
    public var error: Error?

    public struct Row: Identifiable {
        public var id: Int
        public var url: URL?
        public var ownerImageURL: URL?
        public var ownerUsername: String
        public var repoUpdateDate: String
        public var repoName: String
        public var repoDescription: String?
        public var forksCount: Int
        public var starsCount: Int
    }
}

extension NetworkingViewState {
    static func mockError(_ error: Error) -> Self {
        var state = NetworkingViewState()
        state.error = error
        return state
    }
}

extension NetworkingViewState.Row {
    static func mock(
        id: Int = UUID().hashValue,
        url: URL? = "https://github.com/tadija/swift-greenfield",
        ownerImageURL: URL = "https://avatars.githubusercontent.com/u/2762374?v=4",
        ownerUsername: String = "@tadija",
        repoUpdateDate: String = "just recently",
        repoName: String = "swift-greenfield",
        repoDescription: String? = "greenfield swift app project",
        forksCount: Int = 123,
        starsCount: Int = 321
    ) -> Self {
        .init(
            id: id,
            url: url,
            ownerImageURL: ownerImageURL,
            ownerUsername: ownerUsername,
            repoUpdateDate: repoUpdateDate,
            repoName: repoName,
            repoDescription: repoDescription,
            forksCount: forksCount,
            starsCount: starsCount
        )
    }
}

// MARK: - Model

@Observable
public final class NetworkingViewModel {
    @ObservationIgnored
    @Dependency(\.dataSource) private var dataSource: DataSource

    var state: NetworkingViewState

    public init(_ state: NetworkingViewState = .init()) {
        self.state = state
    }

    // MARK: API

    @Sendable
    func load() async {
        await MainActor.run { state.isLoading = true }

        do {
            let rows = try await dataSource.fetch()
            await updateState(to: .success(rows))
        } catch {
            if (error as NSError).code == -999 {
                logWrite("loading task cancelled")
                await MainActor.run { state.isLoading = false }
            } else {
                await updateState(to: .failure(error))
            }
        }
    }

    // MARK: Helpers

    @MainActor
    private func updateState(to result: Result<[NetworkingViewState.Row], Error>) {
        defer { state.isLoading = false }
        switch result {
        case .success(let rows):
            state.rows = rows
        case .failure(let error):
            state.error = error
        }
    }
}

// MARK: - Factory

private struct DataSource {
    var fetch: () async throws -> [NetworkingViewState.Row]
}

extension DataSource: DependencyKey {
    static var liveValue: Self = .init(fetch: {
        try await GithubAPI()
            .fetchTrendingSwiftRepos().items
            .map { NetworkingViewState.Row($0) }
    })

    static var previewValue: Self = .init(fetch: {
        [.mock(), .mock(), .mock()]
    })

    static var testValue: Self = previewValue
}

extension Dependencies {
    fileprivate var dataSource: DataSource {
        get { Self[DataSource.self] }
        set { Self[DataSource.self] = newValue }
    }
}

// MARK: - Github API

private struct GithubAPI {
    let github = RestAPI("https://api.github.com")

    func fetchTrendingSwiftRepos() async throws -> Response {
        let request = TrendingSwiftRepos(minPushDate: lastWeekDate)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try await github.fetch(request)
            .decode(as: Response.self, using: decoder)
    }

    private var lastWeekDate: String {
        guard let lastWeekDate = Calendar.current
            .date(byAdding: .weekOfYear, value: -1, to: Date())
        else {
            return "n/a"
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: lastWeekDate)
    }
}

// MARK: - API Request

private struct TrendingSwiftRepos: RestAPIRequest {
    var method: URLRequest.Method {
        .get
    }

    var path: String {
        "search/repositories"
    }

    var urlParameters: [String: Any]? {
        var result = [String: Any]()
        result["q"] = "pushed:>=\(minPushDate) language:swift"
        result["sort"] = "stars"
        result["order"] = "desc"
        return result
    }

    var minPushDate: String
}

// MARK: - API Response

private struct Response: Codable {
    let items: [Repo]

    struct Repo {
        let id: Int
        let url: String
        let name: String
        let description: String?
        let updated: Date
        let forksCount: Int
        let starsCount: Int
        let owner: Owner
    }

    struct Owner {
        let username: String
        let avatarURL: String
    }
}

extension Response.Repo: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case url = "html_url"
        case name
        case description
        case updated = "updated_at"
        case forksCount = "forks_count"
        case starsCount = "stargazers_count"
        case owner
    }
}

extension Response.Owner: Codable {
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case avatarURL = "avatar_url"
    }
}

// MARK: - Helpers

extension Response.Repo {
    var ownerImageURL: URL? {
        let avatarURL = owner.avatarURL
            .replacingOccurrences(of: "?v=3", with: "")
        return URL(string: avatarURL)
    }

    var updatedFormatted: String {
        Self.dateFormatter.string(from: updated)
    }

    private static let dateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}

private extension NetworkingViewState.Row {
    init(_ repo: Response.Repo) {
        id = repo.id
        url = URL(string: repo.url)
        ownerImageURL = repo.ownerImageURL
        ownerUsername = "@\(repo.owner.username)"
        repoUpdateDate = repo.updatedFormatted
        repoName = repo.name
        repoDescription = repo.description
        forksCount = repo.forksCount
        starsCount = repo.starsCount
    }
}

// MARK: - Previews

#Preview("Loaded") {
    NetworkingView()
}

#Preview("Error") {
    NetworkingView(vm: .init(.mockError("preview test error")))
}

#Preview("Row") {
    NetworkingView.Row(state: .mock())
        .debugBorder(.green)
        .previewLayout(.sizeThatFits)
}
