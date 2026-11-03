//
//  Rating.swift
//  Beacon
//
import Foundation
import SwiftData

@Model
class PlaceRating {
    var id: UUID
    var placeId: String
    var rating: Int
    var date: Date
    
    init(placeId: String, rating: Int, date: Date = Date()){
        self.id = UUID()
        self.placeId = placeId
        self.rating = rating
        self.date = date
    }
}

