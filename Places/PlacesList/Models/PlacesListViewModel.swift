//
//  PlacesListViewModel.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import Foundation
import Combine

class PlacesListViewModel: ObservableObject {

    struct Constants {
        static let noName = "---NO NAME---"
    }

    enum State {
        case loaded, loading, failed
    }

    private var locationResponse: PlacesResponse?
    private var model: [PlacesListModel] = []
    @Published var searchResult: [PlacesListModel] = []
    @Published var state: State = .loading
    @Published var searchQuery: String = ""

    private let usecase = PlacesListUseCase()
    private var cancellables = Set<AnyCancellable>()

    init() {
        observeSearchQuery()
    }

    @MainActor
    func fetchPlacesList() async {
        do {
            let response = try await usecase.fetchPlacesList()
            self.model = placesListModel(response)
            self.searchResult = model
            state = .loaded
        } catch {
            state = .failed
        }
    }

    private func observeSearchQuery() {
        $searchQuery
            .sink { [weak self] query in
                guard let self else { return }

                if query.isEmpty { return self.searchResult = self.model }
                self.searchResult = model.filter { place in
                    place.name.lowercased().contains(query.lowercased())
                }
            }
            .store(in: &cancellables)
    }

    private func placesListModel(_ response: PlacesResponse) -> [PlacesListModel]  {
        response.locations.compactMap {
            guard let lat = $0.lat, let long = $0.long else { return nil }
            return .init(name: $0.name ?? Constants.noName, lat: lat, long: long)
        }
    }
}
