
import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct RouteSteps: Identifiable {
    let id = UUID()
    let step: String
}

struct ContentView: View {

    @State var firstStop: String = ""
    @State var secondStop: String = ""
    @State var destination: String = ""
    @State var selectedRoute: Int = 0

    @StateObject private var gps = GPSManager()

    @State var annotations: [Location] = []
    @State var firstCoordinate: CLLocationCoordinate2D?
    @State var secondCoordinate: CLLocationCoordinate2D?
    @State var destinationCoordinate: CLLocationCoordinate2D?

    @State var searchedFirstStop = ""
    @State var searchedSecondStop = ""
    @State var searchedDestination = ""

    @State var searchMessage = "Enter your locations and tap DROP PINS."
    @State var routeMessage = "Drop your pins, then tap TRACE ROUTE."
    @State var isSearching = false
    @State var isRouting = false

    @State var firstSteps: [RouteSteps] = []
    @State var secondSteps: [RouteSteps] = []
    @State var thirdSteps: [RouteSteps] = []
    @State var fullSteps: [RouteSteps] = []

    @State var firstRoute: MKRoute?
    @State var secondRoute: MKRoute?
    @State var thirdRoute: MKRoute?

    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 43.6532,
                longitude: -79.3832
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.08,
                longitudeDelta: 0.08
            )
        )
    )

    var locationsMatch: Bool {
        return firstStop == searchedFirstStop &&
               secondStop == searchedSecondStop &&
               destination == searchedDestination
    }

    var displayedSteps: [RouteSteps] {
        if !locationsMatch {
            return []
        }

        if selectedRoute == 1 {
            return firstSteps
        } else if selectedRoute == 2 {
            return secondSteps
        } else {
            return fullSteps
        }
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 5) {

                HStack {
                    Image("HopOpsLogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)

                    VStack(spacing: 2) {
                        Text("HopOps")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("REAL-WORLD TRACEROUTE")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(6)

                Text("You are the packet. The city is your network.")
                    .font(.subheadline)
                    .foregroundColor(.white)

                VStack(spacing: 6) {
                    HStack {
                        Text("01")
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        TextField("First stop", text: $firstStop)
                            .padding(8)
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("02")
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        TextField("Second stop", text: $secondStop)
                            .padding(8)
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    HStack {
                        Text("03")
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        TextField("Final destination", text: $destination)
                            .padding(8)
                            .background(Color.gray)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                }
                .padding(6)

                HStack(spacing: 12) {
                    Button(action: {
                        findLocations()
                    }) {
                        Text(isSearching ? "SEARCHING..." : "DROP PINS")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(9)
                            .background(Color.green)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        calculateRoutes()
                    }) {
                        Text(isRouting ? "ROUTING..." : "TRACE ROUTE")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(9)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }

                Text(searchMessage)
                    .font(.caption)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("LIVE MAP")
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Spacer()

                    Button(action: {
                        focusMap()
                    }) {
                        Text("FOCUS")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        if !isSearching && !isRouting {
                            gps.locate()
                        }
                    }) {
                        Text("LOCATE ME")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 10)

                Text(gps.status)
                    .font(.caption)
                    .foregroundColor(.white)

                Map(position: $position) {
                    if locationsMatch && (selectedRoute == 0 || selectedRoute == 1) {
                        if let route = firstRoute {
                            MapPolyline(route.polyline)
                                .stroke(.green, lineWidth: 4)
                        }
                    }

                    if locationsMatch && (selectedRoute == 0 || selectedRoute == 2) {
                        if let route = secondRoute {
                            MapPolyline(route.polyline)
                                .stroke(.blue, lineWidth: 4)
                        }
                    }

                    if locationsMatch && selectedRoute == 0 {
                        if let route = thirdRoute {
                            MapPolyline(route.polyline)
                                .stroke(.orange, lineWidth: 4)
                        }
                    }

                    ForEach(annotations) { item in
                        Marker(item.name, coordinate: item.coordinate)
                    }
                }
                .frame(height: 175)
                .cornerRadius(12)
                .padding(.horizontal, 10)

                Text("ROUTE LOG")
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Picker(selection: $selectedRoute, label: Text("Route")) {
                    Text("Full Route").tag(0)
                    Text("Start to 1").tag(1)
                    Text("1 to 2").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 10)

                List {
                    if !locationsMatch && !firstSteps.isEmpty {
                        Text("Locations changed. Tap DROP PINS again.")
                    } else if displayedSteps.isEmpty {
                        Text(routeMessage)
                    } else {
                        ForEach(displayedSteps) { item in
                            Text(item.step)
                        }
                    }
                }
            }
        }
        .onChange(of: gps.location) { oldValue, newValue in
            if let newLocation = newValue {
                resetRoutes()

                firstCoordinate = nil
                secondCoordinate = nil
                destinationCoordinate = nil

                searchedFirstStop = ""
                searchedSecondStop = ""
                searchedDestination = ""

                searchMessage = "Starting location updated. Ready to search."

                annotations = [
                    Location(
                        name: "YOU - START",
                        coordinate: newLocation.coordinate
                    )
                ]

                position = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: newLocation.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.05,
                            longitudeDelta: 0.05
                        )
                    )
                )
            }
        }
    }

    func focusMap() {
        if annotations.count > 1 {
            position = .automatic
        } else if let start = gps.location?.coordinate {
            position = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: start,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.05,
                        longitudeDelta: 0.05
                    )
                )
            )
        } else {
            searchMessage = "Tap LOCATE ME to set your starting point."
        }
    }

    func resetRoutes() {
        firstSteps = []
        secondSteps = []
        thirdSteps = []
        fullSteps = []

        firstRoute = nil
        secondRoute = nil
        thirdRoute = nil

        routeMessage = "Drop your pins, then tap TRACE ROUTE."
    }

    func findLocations() {
        if isSearching || isRouting {
            return
        }

        if gps.location == nil {
            searchMessage = "Tap LOCATE ME before searching."
            return
        }

        if firstStop.isEmpty || secondStop.isEmpty || destination.isEmpty {
            searchMessage = "Please enter all three locations."
            return
        }

        resetRoutes()

        firstCoordinate = nil
        secondCoordinate = nil
        destinationCoordinate = nil

        searchedFirstStop = firstStop
        searchedSecondStop = secondStop
        searchedDestination = destination

        isSearching = true
        searchMessage = "Searching for first stop..."

        if let start = gps.location {
            annotations = [
                Location(
                    name: "YOU - START",
                    coordinate: start.coordinate
                )
            ]
        }

        findFirstStop()
    }

    func findFirstStop() {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(
            searchedFirstStop,
            completionHandler: { (placemarks, error) -> Void in

                if let coordinate = placemarks?.first?.location?.coordinate {
                    firstCoordinate = coordinate

                    annotations.append(
                        Location(name: "STOP 1", coordinate: coordinate)
                    )

                    searchMessage = "Searching for second stop..."
                    findSecondStop()
                } else {
                    searchMessage = "First stop not found. Try a full address."
                    isSearching = false
                }
            }
        )
    }

    func findSecondStop() {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(
            searchedSecondStop,
            completionHandler: { (placemarks, error) -> Void in

                if let coordinate = placemarks?.first?.location?.coordinate {
                    secondCoordinate = coordinate

                    annotations.append(
                        Location(name: "STOP 2", coordinate: coordinate)
                    )

                    searchMessage = "Searching for destination..."
                    findDestination()
                } else {
                    searchMessage = "Second stop not found. Try a full address."
                    isSearching = false
                }
            }
        )
    }

    func findDestination() {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(
            searchedDestination,
            completionHandler: { (placemarks, error) -> Void in

                if let coordinate = placemarks?.first?.location?.coordinate {
                    destinationCoordinate = coordinate

                    annotations.append(
                        Location(name: "DESTINATION", coordinate: coordinate)
                    )

                    position = .automatic
                    searchMessage = "Four pins ready. Tap TRACE ROUTE."
                    isSearching = false
                } else {
                    searchMessage = "Destination not found. Try a full address."
                    isSearching = false
                }
            }
        )
    }

    func calculateRoutes() {
        if isSearching || isRouting {
            return
        }

        if firstStop != searchedFirstStop ||
           secondStop != searchedSecondStop ||
           destination != searchedDestination {

            routeMessage = "Addresses changed. Tap DROP PINS again."
            return
        }

        if let start = gps.location?.coordinate,
           let first = firstCoordinate,
           let second = secondCoordinate,
           let finish = destinationCoordinate {

            resetRoutes()

            isRouting = true
            routeMessage = "Calculating the first hop..."

            calculateFirstLeg(
                start: start,
                first: first,
                second: second,
                finish: finish
            )
        } else {
            routeMessage = "Locate yourself and DROP PINS first."
        }
    }

    func calculateFirstLeg(
        start: CLLocationCoordinate2D,
        first: CLLocationCoordinate2D,
        second: CLLocationCoordinate2D,
        finish: CLLocationCoordinate2D
    ) {
        let request = MKDirections.Request()

        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: start)
        )

        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: first)
        )

        request.requestsAlternateRoutes = false
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { response, error in
            if let route = response?.routes.first {
                firstRoute = route
                firstSteps = []

                for step in route.steps {
                    if !step.instructions.isEmpty {
                        firstSteps.append(
                            RouteSteps(step: step.instructions)
                        )
                    }
                }

                routeMessage = "Calculating the second hop..."

                calculateSecondLeg(
                    first: first,
                    second: second,
                    finish: finish
                )
            } else {
                routeMessage = "No driving route from Start to Stop 1."
                isRouting = false
            }
        })
    }

    func calculateSecondLeg(
        first: CLLocationCoordinate2D,
        second: CLLocationCoordinate2D,
        finish: CLLocationCoordinate2D
    ) {
        let request = MKDirections.Request()

        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: first)
        )

        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: second)
        )

        request.requestsAlternateRoutes = false
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { response, error in
            if let route = response?.routes.first {
                secondRoute = route
                secondSteps = []

                for step in route.steps {
                    if !step.instructions.isEmpty {
                        secondSteps.append(
                            RouteSteps(step: step.instructions)
                        )
                    }
                }

                routeMessage = "Calculating the final hop..."

                calculateThirdLeg(
                    second: second,
                    finish: finish
                )
            } else {
                routeMessage = "No driving route from Stop 1 to Stop 2."
                isRouting = false
            }
        })
    }

    func calculateThirdLeg(
        second: CLLocationCoordinate2D,
        finish: CLLocationCoordinate2D
    ) {
        let request = MKDirections.Request()

        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: second)
        )

        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: finish)
        )

        request.requestsAlternateRoutes = false
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate(completionHandler: { response, error in
            if let route = response?.routes.first {
                thirdRoute = route
                thirdSteps = []

                for step in route.steps {
                    if !step.instructions.isEmpty {
                        thirdSteps.append(
                            RouteSteps(step: step.instructions)
                        )
                    }
                }

                fullSteps = []

                fullSteps.append(
                    RouteSteps(step: "HOP 01 - Start to Stop 1")
                )

                for item in firstSteps {
                    fullSteps.append(item)
                }

                fullSteps.append(
                    RouteSteps(step: "HOP 02 - Stop 1 to Stop 2")
                )

                for item in secondSteps {
                    fullSteps.append(item)
                }

                fullSteps.append(
                    RouteSteps(step: "HOP 03 - Stop 2 to Destination")
                )

                for item in thirdSteps {
                    fullSteps.append(item)
                }

                position = .automatic
                routeMessage = "Route complete! All three hops calculated."
                isRouting = false
            } else {
                routeMessage = "No driving route from Stop 2 to Destination."
                isRouting = false
            }
        })
    }
}

#Preview {
    ContentView()
}
