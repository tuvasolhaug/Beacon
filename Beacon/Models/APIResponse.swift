//
//  APIResponse.swift
//  Beacon
//

import Foundation

struct PlaceResponse: Codable {
    struct Feature: Codable {
        struct Properties: Codable {
            let place_id: String?
            let name: String?
            let address_line2: String?
            let lat: Double
            let lon: Double
        }
        let properties: Properties
    }
    let features: [Feature]
}

struct PlaceDetailsResponse: Codable {
    let features: [Feature]
    
    struct Feature: Codable {
        let properties: Properties
    }
    
    struct Properties: Codable {
        let place_id: String
        let name: String?
        let formatted: String?
        let lat: Double
        let lon: Double
        let categories: [String]?
        let opening_hours: String?
        let contact: Contact?
    }
    
    struct Contact: Codable {
        let phone: String?
        let website: String?
        
    }
    
}
