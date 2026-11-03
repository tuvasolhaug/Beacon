//
//  PlaceListView.swift
//  Beacon
//
import SwiftUI
import MapKit

struct PlaceListView : View {
    
    let places: [Place]
    @Binding var region: MKCoordinateRegion
    @Binding var showList: Bool
    
    var body : some View {
        
        VStack {
            HStack {
                Spacer()
                Button{
                    withAnimation{showList = false}
                } label: {
                    HStack{
                        Image(systemName: "map.fill")
                        Text("Vis kart")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color("BeaconOrange"))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
            }
            .padding()
            
            if places.isEmpty {
                Spacer()
                Text("Ingen steder funnet.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                List(places, id: \.name) { place in
                    VStack(alignment: .leading, spacing: 4){
                        Text(place.name)
                            .font(.headline)
                        Text(place.address)
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .onTapGesture{
                        withAnimation {
                            region.center = place.coordinate
                            showList = false
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}



