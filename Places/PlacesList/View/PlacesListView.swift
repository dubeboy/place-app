//
//  ContentView.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import SwiftUI

struct PlacesListView: View {

    // Can read these strings from Localizable
    struct Strings {
        let title: String = "Places"
        let errorTitle: String = "Error"
        let errorBody: String = "Something went wrong please try again."
        let retryButtonTitle: String = "Retry"
        let searchBarPrompt: String = "Search places"
    }

    let strings = Strings()
    @StateObject var viewModel: PlacesListViewModel = .init()

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loaded:
                mainView
            case .loading:
                ProgressView()
            case .failed:
                FailedToLoadErrorView(strings: strings) {
                    await viewModel.fetchPlacesList()
                }
            }
        }
        .task {
            await viewModel.fetchPlacesList()
        }
    }

    var mainView: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResult) { place in
                    PlaceItem(name: place.name) {
                        viewModel.didTapItem(place)
                    }
                }
            }
            .navigationTitle(strings.title)
            .searchable(text: $viewModel.searchQuery,
                        placement: .automatic,
                        prompt: strings.searchBarPrompt
            )
            .textInputAutocapitalization(.never)
        }
    }
}

struct PlaceItem: View {
    let name: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack { // Lat and Long are not useful information to humans in most cases
                Text(name)
            }
        }
    }
}

struct FailedToLoadErrorView: View {
    let strings: PlacesListView.Strings // Add this to environment
    let retryAction: () async -> Void

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.octagon")
                .imageScale(.large)
                .foregroundStyle(.red)
                .accessibilityLabel("exclamationmark octagon")
            Text(strings.errorTitle)
                .font(.headline)
            Text(strings.errorBody)
                .font(.subheadline)
            Button(strings.retryButtonTitle) {
                Task {
                    await retryAction()
                }
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PlacesListView()
}
