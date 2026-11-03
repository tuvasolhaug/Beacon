import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI
import Combine

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastLocation: CLLocationCoordinate2D? = nil
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.lastLocation = location.coordinate
        }
    }
}

struct ExploreView: View {
    
    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "GEOAPIFY_API_KEY") as? String
    }
    
    @State private var places: [Place] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showList = false
    @State private var selectedCategory: String = "catering.restaurant"
    @State private var selectedPlace: Place? = nil
    @State private var showDetailSheet = false
    @State private var searchText: String = ""
    @State private var debouncedText: String = ""
    @State private var region: MKCoordinateRegion
    @State private var debounceCancellable: AnyCancellable?
    @State private var selectedSort: String = "distance"
    @State private var hasFetched = false
    
    @StateObject private var locationDelegate = LocationDelegate()
    
    @AppStorage("searchRadius") private var searchRadius: Double = 5.0
    @AppStorage("savedLatitude") private var savedLatitude: Double = 59.9111
    @AppStorage("savedLongitude") private var savedLongitude: Double = 10.7503
    
    let categories = [
        "Kafeer": "catering.cafe",
        "Restauranter": "catering.restaurant",
        "Hotell": "accommodation.hotel"
    ]
    
    init() {
        let lat = UserDefaults.standard.double(forKey: "savedLatitude")
        let lon = UserDefaults.standard.double(forKey: "savedLongitude")
        let latitude = lat == 0 ? 59.9111 : lat
        let longitude = lon == 0 ? 10.7503 : lon
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }
    
    private func debounceSearch(_ text: String) {
        debounceCancellable?.cancel()
        debounceCancellable = Just(text)
            .delay(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { value in
                debouncedText = value
            }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
     
            if showList {
                PlaceListView(
                    places: places,
                    region: $region,
                    showList: $showList
                )
            } else {
                Map(coordinateRegion: $region, annotationItems: places) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        Button{
                            Task {
                                isLoading = true
                                selectedPlace = await fetchDetails(for: place)
                                isLoading = false
                                showDetailSheet = true
                            }
                        } label: {
                            Image("pin1")
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                    }
                }
                .ignoresSafeArea()

                .onChange(of: region.center.latitude) { _ in saveRegionCenter() }
                .onChange(of: region.center.longitude) { _ in saveRegionCenter() }
    
                VStack {
                    Picker("Kategori", selection: $selectedCategory) {
                        Text("Restauranter").tag("catering.restaurant")
                        Text("Kafeer").tag("catering.cafe")
                        Text("Hoteller").tag("accommodation.hotel")
                    }
                    .pickerStyle(.segmented)
                    .accentColor(Color("BeaconOrange"))
                    
                    TextField("Søk etter steder...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                        .onChange(of: searchText) { newValue in
                            debounceSearch(newValue)
                        }
                        .onChange(of: debouncedText) { newValue in
                            Task {
                                await fetchPlaces(for: selectedCategory)
                            }
                        }
                    VStack {
                        Slider(value: $searchRadius, in: 1...10, step: 1)
                            .accentColor(Color("BeaconOrange"))
                        
                        HStack {
                            Text("Søkeradius: \(Int(searchRadius)) km")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            
                            Button("Fjern søk") {
                                searchText = ""
                                debouncedText = ""
                                searchRadius = 5.0
                                selectedCategory = "catering.restaurant"
                                selectedSort = "distance"
                                hasFetched = false
                                places.removeAll()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    HStack {
                        Button {
                            Task { await fetchPlaces(for: selectedCategory) }
                        } label: {
                            Text("Hent steder")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color("BeaconOrange"))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation { showList.toggle() } }) {
                            HStack {
                                Image(systemName: showList ? "list.bullet" : "map")
                                Text(showList ? "Vis kart" : "Vis liste")
                            }
                            .font(.headline)
                            .foregroundColor(showList ? .white : Color("BeaconOrange"))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(showList ? Color("BeaconOrange") : Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                    }
                    
                    if isLoading {
                        ProgressView("Laster steder...")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                    
                    if hasFetched && !isLoading && errorMessage == nil && places.isEmpty {
                        VStack {
                            Text("Ingen treff")
                                .font(.headline)
                            Text("😅")
                                .font(.largeTitle)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LocationButton(.currentLocation) {
                            if let coordinate = locationDelegate.lastLocation {
                                region.center = coordinate
                                savedLatitude = coordinate.latitude
                                savedLongitude = coordinate.longitude
                            } else {
                                print("Fant ikke posisjon")
                            }
                        }
                        .labelStyle(.iconOnly)
                        .tint(Color("BeaconOrange"))
                    }
                    .sheet(isPresented: $showDetailSheet) {
                        if let selectedPlace = selectedPlace {
                            PlaceDetailView(place: selectedPlace)
                                .presentationDetents([.large])
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func saveRegionCenter() {
        savedLatitude = region.center.latitude
        savedLongitude = region.center.longitude
    }
    
    func fetchDetails(for place: Place) async -> Place{
        isLoading = true
        errorMessage = nil

        guard let apiKey, !apiKey.isEmpty else {
            errorMessage = "Geoapify API-nøkkel mangler. Se README.md."
            isLoading = false
            return place
        }
        
        guard let placeId = place.placeId else {
            print("Mangler placeId")
            isLoading = false
            return place
        }
        
        let urlString = """
        https://api.geoapify.com/v2/place-details?id=\(placeId)&features=details&apiKey=\(apiKey)
        """
        
        guard let url = URL(string: urlString) else {
            errorMessage = "URL ugyldig."
            isLoading = false
            return place
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
            
            if let feature = decoded.features.first {
                let props = feature.properties
                let detailedPlace = Place(
                    placeId: props.place_id,
                    name: props.name ?? place.name,
                    address: props.formatted ?? place.address,
                    lat: props.lat,
                    lon: props.lon,
                    category: selectedCategory,
                    openingHours: props.opening_hours,
                    phone: props.contact?.phone
                )
                return detailedPlace
            }
        } catch {
            print("Kunne ikke hente detaljer: \(error)")
        }
        return place
    }
    
    
    func fetchPlaces(for category: String) async {
        isLoading = true
        errorMessage = nil
        hasFetched = true
        places.removeAll()

        guard let apiKey, !apiKey.isEmpty else {
            errorMessage = "Geoapify API-nøkkel mangler. Se README.md."
            isLoading = false
            return
        }
        
        let lat = region.center.latitude
        let lon = region.center.longitude
        let radiusMeters = Int(searchRadius * 1000)
        
        let query = debouncedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        var urlString = """
        https://api.geoapify.com/v2/places?categories=\(category)&filter=circle:\(lon),\(lat),\(radiusMeters)&bias=proximity:\(lon),\(lat)&limit=10&apiKey=\(apiKey)
        """
        
        if !query.isEmpty {
            urlString += "&name=\(query)"
        }
        
        guard let url = URL(string: urlString) else {
            errorMessage = "URL ugyldig."
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PlaceResponse.self, from: data)
            places = response.features.compactMap { feature -> Place? in
                guard let name = feature.properties.name else { return nil }
                return Place(
                    placeId: feature.properties.place_id,
                    name: name,
                    address: feature.properties.address_line2 ?? "Ukjent addresse",
                    lat: feature.properties.lat,
                    lon: feature.properties.lon,
                    category: nil,
                    openingHours: nil,
                    phone: nil
                )
            }
            isLoading = false
        } catch {
            errorMessage = "Feil ved henting av restauranter: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
}

#Preview {
    ExploreView()
}
