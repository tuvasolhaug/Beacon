//
//  Places.swift
//  Beacon
//
//  Created by on 31/10/2025.
//
import SwiftUI
import MapKit
import CoreLocation

struct Place: Identifiable, Hashable {
    let id = UUID()
    let placeId: String?
    let name: String
    let address: String
    let lat: Double
    let lon: Double
    let category: String?
    let openingHours: String?
    let phone: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
