//
//  SavedPlace.swift
//  Beacon
import SwiftData
import Foundation

@Model
class SavedPlace {
    @Attribute(.unique) var placeId: String
    var name: String
    var address: String
    var lat: Double
    var lon: Double

    init(placeId: String, name: String, address: String, lat: Double, lon: Double) {
        self.placeId = placeId
        self.name = name
        self.address = address
        self.lat = lat
        self.lon = lon
    }
}
