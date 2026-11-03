//
//  BeaconApp.swift
//  Beacon
//
//  Created by  on 28/10/2025.
//

import SwiftUI
import SwiftData

@main
struct BeaconApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PlaceRating.self)
    }
}
