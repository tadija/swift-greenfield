import Foundation

/// Simple wrapper around `FileManager`.
///
/// Read / write files using Combine. Usage example:
///
///     struct Example: Codable {
///         let id: Int
///         let title: String
///     }
///
///     struct ExampleStorage {
///         let files = Files()
///
///         var fileURL: URL {
///             files.documents.appendingPathComponent("example.json")
///         }
///
///         func load() -> AnyPublisher<Example, Error> {
///             files.read(from: fileURL)
///         }
///
///         func save(_ example: Example) -> AnyPublisher<Void, Error> {
///             files.write(example, to: fileURL)
///         }
///     }
///
public struct Files {

    public let fm: FileManager

    public init(fm: FileManager = .default) {
        self.fm = fm
    }

    public var documents: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    public var appSupport: URL {
        fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    public var caches: URL {
        fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

}

#if canImport(Combine)

import Combine

public extension Files {
    func read(from url: URL) -> Future<Data, Error> {
        Future { promise in
            do {
                let data = try Data(contentsOf: url)
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func write(_ data: Data, to url: URL) -> Future<Void, Error> {
        Future { promise in
            do {
                try createPathIfNeeded(for: url)
                try data.write(to: url)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
    }

    func delete(at url: URL) -> Future<Void, Error> {
        Future { promise in
            do {
                try fm.removeItem(at: url)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
    }

    private func createPathIfNeeded(for url: URL) throws {
        let directoryURL = url.deletingLastPathComponent()
        try fm.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
}

public extension Files {
    func read<T: Decodable>(
        from url: URL,
        using decoder: JSONDecoder = .init()
    ) -> AnyPublisher<T, Error> {
        read(from: url)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func write<T: Encodable>(
        _ object: T,
        to url: URL,
        using encoder: JSONEncoder = .init()
    ) -> AnyPublisher<Void, Error> {
        Just(object)
            .encode(encoder: encoder)
            .flatMap {
                write($0, to: url)
            }
            .eraseToAnyPublisher()
    }
}

#endif
