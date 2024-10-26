//
//  PlacesListModel.swift
//  Places
//
//  Created by Divine Dube on 26/10/2024.
//

import Foundation

struct PlacesListModel: Identifiable {
    let id: UUID = UUID()

    let name: String
    let lat: Double
    let long: Double
}


