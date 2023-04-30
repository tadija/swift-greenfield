#if canImport(Combine)

import Combine
import Foundation

public extension Publisher {
    func sink() -> AnyCancellable {
        sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
        )
    }

    func sinkVoid(to completion: ((Result<Void, Error>) -> Void)?) -> AnyCancellable {
        sink(
            receiveCompletion: {
                switch $0 {
                case .finished:
                    completion?(.success(()))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }, receiveValue: { _ in }
        )
    }

    func sinkValue<T>(to completion: @escaping (Result<T, Error>) -> Void) -> AnyCancellable {
        sink(
            receiveCompletion: { result in
                if case .failure(let error) = result {
                    completion(.failure(error))
                }
            }, receiveValue: { value in
                guard let value = value as? T else {
                    fatalError("value must be of type: \(type(of: T.self))")
                }
                completion(.success(value))
            }
        )
    }
}

public extension Publisher {
    func mapToVoid() -> AnyPublisher<Void, Self.Failure> {
        map { _ in () }
            .eraseToAnyPublisher()
    }
}

public extension Publisher {
    func mapToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}

/// - See: https://www.swiftbysundell.com/articles/combine-self-cancellable-memory-management
public extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}

/// - See: https://www.swiftbysundell.com/articles/connecting-and-merging-combine-publishers-in-swift
public extension Publisher where Output: Sequence {
    typealias Sorter = (Output.Element, Output.Element) -> Bool

    func sort(
        by sorter: @escaping Sorter
    ) -> Publishers.Map<Self, [Output.Element]> {
        map { sequence in
            sequence.sorted(by: sorter)
        }
    }
}

/// - See: https://www.swiftbysundell.com/articles/extending-combine-with-convenience-apis
public extension Publisher where Output == Data {
    func decode<T: Decodable>(
        as type: T.Type = T.self,
        using decoder: JSONDecoder = .init()
    ) -> Publishers.Decode<Self, T, JSONDecoder> {
        decode(type: type, decoder: decoder)
    }
}

public extension Publisher where Output: Encodable {
    func encode(
        using encoder: JSONEncoder = .init()
    ) -> Publishers.Encode<Self, JSONEncoder> {
        encode(encoder: encoder)
    }
}

public extension Publisher {
    func validate(
        using validator: @escaping (Output) throws -> Void
    ) -> Publishers.TryMap<Self, Output> {
        tryMap { output in
            try validator(output)
            return output
        }
    }
}

public extension Publisher {
    func unwrap<T>(
        orThrow error: @escaping @autoclosure () -> Failure
    ) -> Publishers.TryMap<Self, T> where Output == T? {
        tryMap { output in
            switch output {
            case .some(let value):
                return value
            case nil:
                throw error()
            }
        }
    }
}

public extension AnyPublisher {
    static func just(_ output: Output) -> Self {
        Just(output)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

    static func fail(with error: Failure) -> Self {
        Fail(error: error).eraseToAnyPublisher()
    }
}

#endif
