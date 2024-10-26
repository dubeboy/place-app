//
//  PlasesUseCase.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

final class PlacesListService {
    enum PlacesListEndpoint: EndpointProtocol {
        case placesList

        var path: String {
            "abnamrocoesd/assignment-ios/main/locations.json"
        }
        var method: HTTPMethod { .get }
        var body: Encodable? { nil }
    }

    let service = PlacesService.shared
    static let shared = PlacesListService()
    private init() {}

    func fetchPlacesList() async throws -> PlacesResponse {
        try await service.makeRequest(PlacesListEndpoint.placesList, for: PlacesResponse.self)
    }
}

// In the use case we can cache and decide
// if we are going to fetch the data from network or from local storage like core data
final class PlacesListUseCase {
    let service = PlacesListService.shared

    func fetchPlacesList() async throws -> PlacesResponse {
        try await service.fetchPlacesList()
    }
}
