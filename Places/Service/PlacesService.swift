//
//  PlacesService.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

protocol EndpointProtocol {
    var path: String { get }
    var method: HTTPMethod { get }
    // Not needed for our case but added it to be complete , we also do not need any query parameters
    var body: Encodable? { get }
}

/// App wide service
final class PlacesService {

    private static let baseURL = URL(string: "https://raw.githubusercontent.com/")
    static let shared = PlacesService()

    private init() {

    }

    func makeRequest<T: Decodable>(_ endpoint: EndpointProtocol, for response: T.Type) async throws -> T {
        let request = makeRequest(for: endpoint)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(response.self, from: data)
    }

    // MARK: - Private Helper functions

    private func makeRequest(for endpoint: EndpointProtocol) -> URLRequest {
        guard let url = Self.baseURL?.appendingPathComponent(endpoint.path) else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        return request
    }
}
