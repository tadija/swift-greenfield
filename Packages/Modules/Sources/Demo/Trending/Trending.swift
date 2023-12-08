import Minions
import Shared
import SwiftUI

// MARK: - View

public struct TrendingView: View {
    @Environment(\.openURL) var openURL

    @State private var vm: TrendingViewModel

    public init(vm: TrendingViewModel = .init()) {
        _vm = State(initialValue: vm)
    }

    public var body: some View {
        content
            .navigationTitle(Route.trending.title)
            .toolbar { ToolbarItem(content: makeToolbarItem) }
            .task { await vm.load() }
            .tint(.semantic(.tintPrimary))
    }

    @ViewBuilder
    private func makeToolbarItem() -> some View {
        if vm.state.isLoading {
            ProgressView().tint(.semantic(.contentSecondary))
        } else {
            Picker("Language", selection: $vm.state.language) {
                ForEach(vm.languages, id: \.self) { language in
                    Text(language.capitalized)
                }
            }
            .pickerStyle(.menu)
        }
    }

    @ViewBuilder
    private var content: some View {
        makeList(vm.state.items)
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

    private func makeList(_ items: [TrendingViewState.Item]) -> some View {
        List {
            ForEach(items.indices, id: \.self) { i in
                Button(action: {
                    if let url = items[i].url {
                        #if os(iOS)
                        presentedURL = url
                        #else
                        openURL(url)
                        #endif
                    }
                }, label: {
                    Row(item: items[i])
                })
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowBackground(rowColor(i, rowsCount: items.count))
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
        var item: TrendingViewState.Item

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
                Text(item.ownerUsername)
                    .font(.custom(.callout))

                Spacer()

                Text(item.repoUpdateDate)
                    .font(.custom(.caption))
                    .foregroundColor(.secondary)
            }
        }

        private var content: some View {
            HStack(alignment: .top) {
                ownerImage

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.repoName)
                        .font(.custom(.headline))

                    if let repoDescription = item.repoDescription {
                        Text(repoDescription)
                            .font(.custom(.body))
                            .lineLimit(3)
                    }

                    counters
                }
            }
        }

        private var ownerImage: some View {
            AsyncImage(url: item.ownerImageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "photo")
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
        }

        private var counters: some View {
            HStack {
                Text("⋔ \(item.forksCount)")
                Text("★ \(item.starsCount)")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(.secondary)
            .font(.custom(.footnote))
        }
    }
}

// MARK: - State

public struct TrendingViewState {
    public init() {}

    public var isLoading: Bool = false
    public var language: String = "swift"
    public var items: [Item] = []
    public var error: Error?

    public struct Item: Identifiable {
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

extension TrendingViewState {
    static func mockError(_ error: Error) -> Self {
        var state = TrendingViewState()
        state.error = error
        return state
    }
}

extension TrendingViewState.Item {
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
public final class TrendingViewModel {
    @ObservationIgnored
    @Dependency(\.api) private var api: API

    var state: TrendingViewState {
        didSet {
            if state.language != oldValue.language {
                Task {
                    await load()
                }
            }
        }
    }

    public init(_ state: TrendingViewState = .init()) {
        self.state = state
    }

    // MARK: API

    var languages: [String] = [
        "swift", "objective-c", "bash", "c++", "c#", "rust",
        "kotlin", "java", "php", "ruby", "python", "html", "css"
    ]

    @Sendable
    func load() async {
        await MainActor.run { state.isLoading = true }

        do {
            let items = try await api.fetch(state.language)
            await updateState(to: .success(items))
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
    private func updateState(to result: Result<[TrendingViewState.Item], Error>) {
        defer { state.isLoading = false }
        switch result {
        case .success(let items):
            state.items = items
        case .failure(let error):
            state.error = error
        }
    }
}

// MARK: - Factory

private struct API {
    var fetch: (String) async throws -> [TrendingViewState.Item]
}

extension API: DependencyKey {
    static var liveValue: Self = .init(fetch: { language in
        try await GithubAPI()
            .fetchTrendingRepos(for: language).items
            .map { TrendingViewState.Item($0) }
    })

    static var previewValue: Self = .init(fetch: { _ in
        [.mock(), .mock(), .mock()]
    })

    static var testValue: Self = previewValue
}

extension Dependencies {
    fileprivate var api: API {
        get { Self[API.self] }
        set { Self[API.self] = newValue }
    }
}

// MARK: - Github API

private struct GithubAPI {
    let github = RestAPI("https://api.github.com")

    func fetchTrendingRepos(for language: String) async throws -> Response {
        let request = TrendingRepos(
            language: language,
            minPushDate: lastWeekDate
        )

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

private struct TrendingRepos: RestAPIRequest {
    var method: URLRequest.Method {
        .get
    }

    var path: String {
        "search/repositories"
    }

    var urlParameters: [String: Any]? {
        var result = [String: Any]()
        result["q"] = "pushed:>=\(minPushDate) language:\(language)"
        result["sort"] = "stars"
        result["order"] = "desc"
        return result
    }

    var language: String
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

private extension TrendingViewState.Item {
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
    TrendingView()
}

#Preview("Error") {
    TrendingView(vm: .init(.mockError("preview test error")))
}

#Preview("Row") {
    TrendingView.Row(item: .mock())
        .debugBorder(.green)
        .previewLayout(.sizeThatFits)
}
