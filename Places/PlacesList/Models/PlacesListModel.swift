//
//  PlacesListModel.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import Foundation

struct PlacesListModel: Identifiable, Hashable {
    var id: String {
        "\(lat),\(long)" // the most true representation of a place is latitude and longitude
    }

    let name: String
    let lat: Double
    let long: Double
}


