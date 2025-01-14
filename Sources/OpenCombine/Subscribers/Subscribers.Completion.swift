//
//  Subscribers.Completion.swift
//  
//
//  Created by Sergej Jaskiewicz on 11.06.2019.
//

extension Subscribers {

    /// A signal that a publisher doesn’t produce additional elements, either due
    /// to normal completion or an error.
    ///
    /// - `finished`: The publisher finished normally.
    /// - `failure`: The publisher stopped publishing due to the indicated error.
    public enum Completion<Failure: Error> {

        case finished

        case failure(Failure)
    }
}

extension Subscribers.Completion: Equatable where Failure: Equatable {}

extension Subscribers.Completion: Hashable where Failure: Hashable {}

extension Subscribers.Completion: Codable where Failure: Decodable, Failure: Encodable {

    private enum CodingKeys: String, CodingKey {
        case success = "success"
        case error = "error"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let success = try container.decode(Bool.self, forKey: .success)
        if success {
            self = .finished
        } else {
            let error = try container.decode(Failure.self, forKey: .error)
            self = .failure(error)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .finished:
            try container.encode(true, forKey: .success)
        case .failure(let error):
            try container.encode(false, forKey: .success)
            try container.encode(error, forKey: .error)
        }
    }
}

extension Subscribers.Completion {

    /// Erases the `Failure` type to `Swift.Error`. This function exists
    /// because in Swift user-defined generic types are always
    /// [invariant](https://en.wikipedia.org/wiki/Covariance_and_contravariance_(computer_science)).
    internal func eraseError() -> Subscribers.Completion<Error> {
        switch self {
        case .finished:
            return .finished
        case .failure(let error):
            return .failure(error)
        }
    }
}
