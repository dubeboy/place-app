//
//  PlacesTests.swift
//  PlacesTests
//
//  Created by Divine Dube on 26/10/2024.
//


import XCTest
import Combine
@testable import Places

final class PlacesListViewModelTests: XCTestCase {
    var viewModel: PlacesListViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = PlacesListViewModel(usecase: MockPlacesListUseCase())
        cancellables = []
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertTrue(viewModel.searchResult.isEmpty)
        XCTAssertEqual(viewModel.searchQuery, "")
    }

    func testFetchPlacesListSuccess() async {
        let mockPlaces = [
            PlacesListModel(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            PlacesListModel(name: "Rotterdam", lat: 51.9225, long: 4.4792)
        ]

        await viewModel.fetchPlacesList()

        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.searchResult, mockPlaces)
    }

    func testFetchPlacesListFailure() async {
        let viewModel = PlacesListViewModel(usecase: MockPlacesListUseCase(shouldFail: true))

        await viewModel.fetchPlacesList()

        XCTAssertEqual(viewModel.state, .failed)
        XCTAssertTrue(viewModel.searchResult.isEmpty)
    }

    func testDidTapItemURLFormation() {
        let place = PlacesListModel(name: "Amsterdam", lat: 52.3676, long: 4.9041)
        let expectedURL = viewModel.didTapItem(place)

        XCTAssertEqual(expectedURL?.absoluteString, "https://en.wikipedia.org/wiki/Amsterdam?WMFPage=Places&lat=52.3676&lon=4.9041")
    }
}

final class MockPlacesListUseCase: PlacesListUseCase {
    private var shouldFail: Bool

    enum TestError: Error {
        case testFail
    }

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    override func fetchPlacesList() async throws -> PlacesResponse {
        if shouldFail {
            throw TestError.testFail
        }
        return PlacesResponse(locations: [
            Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            Location(name: "Rotterdam", lat: 51.9225, long: 4.4792)
        ])
    }
}

extension PlacesListModel: @retroactive Equatable {
    public static func == (lhs: PlacesListModel, rhs: PlacesListModel) -> Bool {
        return lhs.name == rhs.name && lhs.lat == rhs.lat && lhs.long == rhs.long
    }
}

