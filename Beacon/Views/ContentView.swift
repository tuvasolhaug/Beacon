//
//  ContentView.swift
//  Beacon
//
//  Created by  on 08/10/2025.
//
import SwiftUI

struct ContentView: View {
   
    var body: some View {
        TabView {
            ExploreView()
                .tabItem{
                    Label("Utforsk", systemImage: "map")
                }
            
            SavedPlacesView()
                .tabItem{
                    Label("Lagrede steder", systemImage: "book")
                }
  
        }
    }
}

#Preview {
    ContentView()
}

