import SwiftUI
import MapKit
import SwiftData

struct PlaceDetailView: View {
    let place: Place
    
    var body: some View {
        ZStack {
            Color("BeaconOrange")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {

                switch place.category {
                case "catering.restaurant":
                    RestaurantCard(place: place)
                case "catering.cafe":
                    CafeCard(place: place)
                case "accommodation.hotel":
                    HotelCard(place: place)
                default:
                    Text("📍").font(.system(size: 80))
                }
                
                PlaceInfoView(place: place)
                
                Spacer()
                
                Button {
                    let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lon)
                    let placemark = MKPlacemark(coordinate: coordinate)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = place.name
                    mapItem.openInMaps(launchOptions: nil)
                } label: {
                    Text("Åpne i Apple Maps")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("DeepBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}


struct PlaceInfoView: View {
    
    let place: Place
    
    @Environment(\.modelContext) private var context
    @Query private var allRatings: [PlaceRating]
    
    @State private var selectedRating: Int = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var ratingsForPlace: [PlaceRating] {
        allRatings.filter { $0.placeId == place.placeId }
    }
    
    var averageRating: Double {
        guard !ratingsForPlace.isEmpty else { return 0.0 }
        let sum = ratingsForPlace.map { Double($0.rating) }.reduce(0, +)
        return (sum / Double(ratingsForPlace.count)).rounded()
    }
    
    func saveRating() {
        guard selectedRating > 0 else {
            alertMessage = "Du må vurdere mer enn 1 stjerne.🤕"
            showAlert = true
            return
        }
        
        let newRating = PlaceRating(placeId: place.placeId ?? "Unknown", rating: selectedRating)
        context.insert(newRating) 
        
        do {
            try context.save()
            alertMessage = "Du har nå vurdert dette stedet!🌟"
            showAlert = true
            selectedRating = 0
        } catch {
            alertMessage = "Kunne ikke lagre vurdering: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(place.name)
                .font(.title2)
                .bold()
                .foregroundColor(Color("DeepBlue"))
            
            if averageRating > 0 {
                HStack(spacing: 8) {
        
                    ZStack(alignment: .leading) {
                        Image(systemName: "star")
                            .font(.system(size: 30))
                            .foregroundColor(Color("DeepBlue").opacity(0.3))
                        Image(systemName: "star.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("DeepBlue"))
                            .mask(
                                Rectangle()
                                    .frame(width: CGFloat(averageRating / 5.0) * 30)
                            )
                    }
                    Text(String(format: "%.1f / 5", averageRating))
                        .font(.caption)
                        .foregroundColor(Color("DeepBlue"))
                }
            }
            
            Text(place.address)
                            .font(.subheadline)
                            .foregroundColor(Color("DeepBlue"))
            
            if let category = place.category {
                Text("Kategori: \(category)")
                    .font(.subheadline)
                    .foregroundColor(Color("DeepBlue"))
            }
            
            if let openingHours = place.openingHours {
                Text("Åpningstider: \(openingHours)")
                    .font(.subheadline)
                    .foregroundColor(Color("DeepBlue"))
            }
            
            if let phone = place.phone {
                Text("Telefon: \(phone)")
                    .font(.subheadline)
                    .foregroundColor(Color("DeepBlue"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Gi vurdering:")
                    .foregroundColor(Color("DeepBlue"))
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("DeepBlue"))
                            .opacity(selectedRating >= i ? 1.0 : 0.3)
                            .onTapGesture {
                                selectedRating = i
                            }
                    }
                    
                    Button(action: saveRating) {
                        Text("Vurder")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("DeepBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Informasjon"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct RestaurantCard: View {
    let place: Place
    @State private var rotateEmoji = false

    var body: some View {
        VStack(spacing: 20) {
            Text("🍽️")
                .font(.system(size: 80))
                .rotationEffect(.degrees(rotateEmoji ? 360 : 0))
                .onAppear {
                    withAnimation(.easeInOut(duration: 1)) {
                        rotateEmoji = true
                    }
                }

           
        }
    }
}

struct CafeCard: View {
    let place: Place
    
    @State private var steam1 = false
    @State private var steam2 = false
    @State private var steam3 = false
    
    var body : some View {
        VStack(spacing: 10){
            ZStack {
                
                Text("💨")
                    .rotationEffect(.degrees(-90))
                    .offset(x: -5, y: steam1 ? -50 : 10)
                    .opacity(steam1 ? 0 : 1)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false).delay(0.3), value: steam1)
                
                Text("💨")
                    .rotationEffect(.degrees(-90))
                    .offset(x: 0, y: steam2 ? -45 : 10)
                    .opacity(steam2 ? 0 : 1)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false).delay(0.6), value: steam2)
                
                Text("💨")
                    .rotationEffect(.degrees(-90))
                    .offset(x: 5, y: steam3 ? -55 : 10)
                    .opacity(steam3 ? 0 : 1)
                    .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: false), value: steam3)
                
                Text("☕️")
                    .font(.system(size: 80))
            }
            .frame(height: 80)
            

        }
        .onAppear {
            steam1 = true
            steam2 = true
            steam3 = true
        }
        
    }
}

struct HotelCard : View {
    
    let place: Place
    @State private var bounce = false
    
    var body : some View {
        VStack(spacing: 20){
            Text("🏨")
                .font(.system(size: 80))
                .scaleEffect(bounce ? 1.0 : 0.5)
                .animation(
                    .spring(response: 1, dampingFraction: 0.5, blendDuration: 0)
                    , value: bounce
                )
                .onAppear{
                    bounce = true
                }

        }
    }
}
