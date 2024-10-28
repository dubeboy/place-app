//
//  PlacesListViewModel.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import Foundation
import Combine
import UIKit

class PlacesListViewModel: ObservableObject {

    struct Constants {
        static let noName = "Unknown"
    }

    enum State {
        case loaded, loading, failed
    }

    private var locationResponse: PlacesResponse?
    private var model: [PlacesListModel] = []
    @Published var searchResult: [PlacesListModel] = []
    @Published var state: State = .loading
    @Published var searchQuery: String = ""

    private let usecase: PlacesListUseCase
    private var cancellables = Set<AnyCancellable>()

    init(usecase: PlacesListUseCase = PlacesListUseCase()) {
        self.usecase = usecase
        observeSearchQuery()
    }

    @MainActor
    func fetchPlacesList() async {
        state = .loading
        do {
            let response = try await usecase.fetchPlacesList()
            self.model = placesListModel(response)
            self.searchResult = model
            state = .loaded
        } catch {
            state = .failed
        }
    }

    func didTapItem(_ place: PlacesListModel) {
        if let url = URL(string: "https://en.wikipedia.org/wiki/\(place.name)?WMFPage=Places&lat=\(place.lat)&lon=\(place.long)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
