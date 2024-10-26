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
        NavigationStack {
            List {
                ForEach(viewModel.searchResult) { place in
                    PlaceItem(name: place.name)
                }
            }
            .navigationTitle(strings.title)
            .searchable(text: $viewModel.searchQuery,
                        placement: .automatic,
                        prompt: strings.searchBarPrompt
            )
            .textInputAutocapitalization(.never)
        }
        .task {
            await viewModel.fetchPlacesList()
        }
    }
}

struct PlaceItem: View {
    let name: String
    var body: some View {
        VStack {
            Text(name)
        }
    }
}

struct FailedToLoadErrorView: View {
    let strings: PlacesListView.Strings // Add this to environment
    let retryAction: () -> Void

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.octagon")
                .imageScale(.large)
                .foregroundStyle(.red)
            Text(strings.errorTitle)
                .font(.headline)
            Text(strings.errorBody)
                .font(.subheadline)
            Button(strings.retryButtonTitle) {
                retryAction()
            }
        }
        .padding()
    }
}

#Preview {
    PlacesListView()
}
