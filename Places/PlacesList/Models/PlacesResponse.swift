//
//  PlacesResponse.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import Foundation

struct PlacesResponse: Decodable {
    let locations: [Location]
}

struct Location: Decodable {
    let name: String?
    // For resilience I like to keep my encodable properties nullable so that
    // we do not crash the whole app in the case on field is null
    // and swift forces us to handle this case
    let lat: Double?
    let long: Double?
}
