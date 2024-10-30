//
//  PlacesListViewModel.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import MapKit

class PlacesListViewModel: ObservableObject {

    struct Constants {
        static let noName = "Unknown-\(UUID().uuidString.prefix(3))" // to bypass the caching in the wikipedia app in case we have many `unknown` place
    }

    enum LoadedAndSearching {
        case searching, idle
    }

    enum State: Equatable {
        case loaded(LoadedAndSearching), loading, failed // we compose states so that we don't end up with too many boolean variables that are hard to trace
    }

    private var model: [PlacesListModel] = []
    @Published var searchResults: [PlacesListModel] = []
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
            self.model = placesListModel(response.locations)
            self.searchResults = model
            state = .loaded(.idle)
        } catch {
            state = .failed
        }
    }

    @discardableResult
    func didTapItem(_ place: PlacesListModel) -> URL? {
        guard let url = URL(string: "https://en.wikipedia.org/wiki/\(place.name)?WMFPage=Places&lat=\(place.lat)&lon=\(place.long)")
        else {
            return nil
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return url
    }

    private func observeSearchQuery() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self else { return }
                state = .loaded(.searching)
                if query.isEmpty {
                    self.searchResults = self.model
                    state = .loaded(.idle)
                    return
                }
                Task { [weak self] in
                    guard let self else { return }
                    let mapsSearchResults = await self.fetchUserCustomLocations(query: query)
                    await MainActor.run {
                        self.searchResults = mapsSearchResults
                        self.state = .loaded(.idle)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func fetchUserCustomLocations(query: String) async -> [PlacesListModel] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        guard let response = try? await search.start() else { return [] }
        return response.mapItems.map {
            PlacesListModel(name: $0.name ?? Constants.noName, lat: $0.placemark.coordinate.latitude, long: $0.placemark.coordinate.longitude)
        }
    }

    private func placesListModel(_ locations: [Location]) -> [PlacesListModel]  {
        locations.compactMap {
            guard let lat = $0.lat, let long = $0.long else { return nil }
            return .init(name: $0.name ?? Constants.noName, lat: lat, long: long)
        }
    }
}
