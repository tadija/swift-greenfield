import Minions
import Shared
import SwiftUI

struct ChatView: View {

    @State private var vm: ChatViewModel

    public init(vm: ChatViewModel = .init()) {
        self.vm = vm
    }

    var body: some View {
        content
            .environment(vm)
            .navigationTitle(Route.chat.title)
    }

    @ViewBuilder
    private var content: some View {
        switch vm.context {
        case .chat:
            Chat()
        case .config:
            Config()
        }
    }

    private struct Chat: View {
        @Environment(ChatViewModel.self) private var vm

        var body: some View {
            VStack {
                messages.padding(8)

                Spacer()
                input
            }
        }

        private var messages: some View {
            ScrollView {
                ScrollViewReader { proxy in
                    ForEach(vm.messages) { message in
                        MessageView(message: message)
                            .environment(vm)
                            .id(message.id)
                    }
                    .onChange(of: vm.messages) { _, _ in
                        if let message = vm.messages.last {
                            withAnimation {
                                proxy.scrollTo(message.id)
                            }
                        }
                    }
                }
            }
        }

        struct MessageView: View {
            @Environment(ChatViewModel.self) private var vm

            let message: ChatMessage

            var body: some View {
                VStack(alignment: .leading) {
                    header

                    Text(message.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.custom(.body))
                .textSelection(.enabled)
                .padding(.bottom)
            }

            private var header: some View {
                HStack {
                    Button("Copy") {
                        vm.copyMessage(message)
                    }
                    .foregroundStyle(Color.orange)

                    Button("Delete") {
                        vm.deleteMessage(message)
                    }
                    .foregroundStyle(Color.gray)

                    Text("[\(message.dateFormatted)]")
                        .foregroundColor(.semantic(.tintPrimary))

                    Text(message.role.rawValue)
                }
                .buttonStyle(.plain)
                .font(.custom(.caption))
            }
        }

        @FocusState private var chatTextIsFocused: Bool

        private var input: some View {
            HStack(spacing: 0) {
                Button {
                    vm.context = .config
                } label: {
                    Image(systemName: "gearshape")
                        .padding()
                }
                .buttonStyle(.plain)

                TextField(
                    vm.chatTextPlaceholder,
                    text: Bindable(vm).chatText
                )
                .textFieldStyle(.plain)
                .font(.custom(.caption))
                .padding(.trailing)
                .focused($chatTextIsFocused)
                .onAppear {
                    chatTextIsFocused = true
                }

                if vm.isLoading {
                    ProgressView().padding(.horizontal)
                }

                Button {
                    chatTextIsFocused = false
                    Task {
                        await vm.send()
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .padding()
                }
                .disabled(vm.isSendDisabled)
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
            .frame(minHeight: 44)
            .background(Color.semantic(.backSecondary))
            .tint(.semantic(.tintPrimary))
        }
    }

    private struct Config: View {
        @Environment(ChatViewModel.self) private var vm

        var body: some View {
            @Bindable var vm = vm

            Form {
                HStack {
                    TextField("api key", text: $vm.config.apiKey ?? "")
                    PasteButton(payloadType: String.self) { strings in
                        vm.config.apiKey = strings.first
                    }
                }

                Picker("model", selection: $vm.config.model) {
                    ForEach(OpenAI.Config.Model.allCases, id: \.self) { model in
                        Text(model.rawValue)
                    }
                }

                TextField(
                    "instructions",
                    text: $vm.config.systemMessage ?? "",
                    axis: .vertical
                )

                Button("Close") {
                    vm.closeConfig()
                }
                .buttonStyle(.secondary())
            }
            .frame(maxWidth: 700)
            .padding()
        }
    }
}

@Observable
public final class ChatViewModel {

    enum Context {
        case chat, config
    }

    var context: Context

    var chatText: String = ""

    var messages: [ChatMessage] = []

    var isLoading: Bool = false

    fileprivate var config: OpenAI.Config

    public init() {
        if let existingConfig = OpenAI.config {
            config = existingConfig
            context = .chat
            messages.append(.init(.system, text: "chat initialized"))
        } else {
            config = .init()
            context = .config
        }
    }

    // MARK: API

    var chatTextPlaceholder: String {
        isLoading ? "loading..." : "type here..."
    }

    var isSendDisabled: Bool {
        chatText.isBlank
    }

    func send() async {
        let message = chatText

        await MainActor.run {
            messages.append(.init(.user, text: message))
            chatText = ""
            isLoading = true
        }

        await requestResponse(for: message)

        await MainActor.run {
            isLoading = false
        }
    }

    func copyMessage(_ message: ChatMessage) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.prepareForNewContents()
        pasteboard.setString(message.text, forType: .string)
        #else
        UIPasteboard.general.string = message.text
        #endif
    }

    func deleteMessage(_ message: ChatMessage) {
        messages.removeAll {
            $0.id == message.id
        }
    }

    func closeConfig() {
        OpenAI.config = config
        context = .chat
    }

    // MARK: Helpers

    private func requestResponse(for message: String) async {
        do {
            let response = try await api.aiReplyTo(message)
            await MainActor.run {
                messages.append(response)
            }
        } catch RestAPIError.badStatus(let code) {
            await sendErrorMessage("Request failed. Status Code: \(code)")
        } catch {
            await sendErrorMessage(error.localizedDescription)
        }
    }

    private func sendErrorMessage(_ text: String) async {
        await MainActor.run {
            messages.append(ChatMessage(.system, text: text))
        }
    }

    @ObservationIgnored
    @Dependency(\.api) private var api: API

}

struct ChatMessage: Identifiable, Hashable {

    enum Role: String {
        case system = "👾"
        case user = "👤"
        case ai = "🤖"
    }

    let id = UUID()
    let date = Date()

    let role: Role
    let text: String

    init(_ role: Role, text: String) {
        self.role = role
        self.text = text
    }

    var dateFormatted: String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

// MARK: - Factory

private struct API {
    var aiReplyTo: (String) async throws -> ChatMessage
}

extension API: DependencyKey {
    static var liveValue: Self = .init { message in
        try await OpenAI()
            .completeChat(message)
            .asChatMessage()
    }

    static var previewValue: Self = .init { _ in
        ChatMessage(.ai, text: "ai mock message")
    }

    static var testValue: Self = previewValue
}

extension Dependencies {
    fileprivate var api: API {
        get { Self[API.self] }
        set { Self[API.self] = newValue }
    }
}

// MARK: - OpenAI

private struct OpenAI {
    let api = RestAPI("https://api.openai.com/v1")

    struct Config: Codable {
        var apiKey: String?
        var model: Model = .gpt35turbo
        var systemMessage: String?

        enum Model: String, Codable, CaseIterable {
            case gpt35turbo = "gpt-3.5-turbo"
            case gpt4 = "gpt-4"
        }
    }

    @DefaultsCodable(key: "OpenAI.Config")
    static var config: Config?

    func completeChat(_ message: String) async throws -> Response {
        let request = ChatCompletion(message: message)
        let response = try await api.fetch(request)
        return try await response.decode(as: Response.self)
    }
}

// MARK: - API Request

private struct ChatCompletion: RestAPIRequest {
    var method: URLRequest.Method {
        .post
    }

    var path: String {
        "chat/completions"
    }

    var headers: [String: String]? {
        var result = [String: String]()
        result["Content-Type"] = "application/json"
        if let apiKey = OpenAI.config?.apiKey {
            result["Authorization"] = "Bearer \(apiKey)"
        }
        return result
    }

    var message: String

    var bodyParameters: [String: Any]? {
        var result = [String: Any]()

        if let model = OpenAI.config?.model.rawValue {
            result["model"] = model
        }

        var messages = [[String: String]]()

        if let systemMessage = OpenAI.config?.systemMessage {
            messages.append([
                "role": "system",
                "content": systemMessage
            ])
        }

        messages.append([
            "role": "user",
            "content": message
        ])

        result["messages"] = messages

        return result
    }
}

// MARK: - API Response

private struct Response: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]

    struct Choice: Codable {
        let index: Int
        let message: Message

        struct Message: Codable {
            let role: String
            let content: String
        }
    }

    func asChatMessage() -> ChatMessage {
        .init(.ai, text: choices.last?.message.content ?? "n/a")
    }
}

// MARK: - Previews

#Preview("Chat") {
    let vm = ChatViewModel()
    vm.context = .chat
    vm.messages = [
        .init(.system, text: "sytem message"),
        .init(.ai, text: "ai message"),
        .init(.user, text: "user message"),
    ]
    return ChatView(vm: vm)
}

#Preview("Loading") {
    let vm = ChatViewModel()
    vm.context = .chat
    vm.isLoading = true
    return ChatView(vm: vm)
}

#Preview("Config") {
    let vm = ChatViewModel()
    vm.context = .config
    return ChatView(vm: vm)
}
