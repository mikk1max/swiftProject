import SwiftUI
import CoreData

struct TripDetailView: View {
    
    var trip: Trip
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var places: FetchedResults<Place>
    @State private var newPlaceName: String = ""
    @State private var newPlaceDate = Date()
    @State private var refreshView = UUID() // stan do śledzenia zmian
    @State private var isEditing = false
    @State private var selectedPlace: Place?

    init(trip: Trip) {
        self.trip = trip
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "toTrip == %@", trip)
        fetchRequest.sortDescriptors = []
        _places = FetchRequest(fetchRequest: fetchRequest)
    }

    var sortedPlaces: [Place] {
        places.sorted { ($0.date ?? Date.distantPast) < ($1.date ?? Date.distantPast) }
    }

    var body: some View {
        VStack (alignment: .center) {
            
            if (trip.country != "" && trip.city != "") {
                
                MapView(cityName: "\(trip.city ?? ""), \(trip.country ?? "")")

            }
            
            Text("\(formattedDate(trip.dateFrom)) \(Image(systemName: "arrowshape.right.fill")) \(formattedDate(trip.dateTo))")
                .font(.subheadline)
                .foregroundColor(.gray)
                
                
            if let notes = trip.notes, !notes.isEmpty {
                    Text("Notes: \(notes)")
                        .font(.body)
                        .padding(10)
                        .overlay(
                        Rectangle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5])).foregroundColor(Color.blue)
                        )

            }
                
            Spacer()
            Divider()

            List {
                ForEach(sortedPlaces, id: \.self) { place in
                    VStack(alignment: .leading) {
                        Text(place.name ?? "Unknown Place")
                            .fontWeight(.bold)

                        if let date = place.date {
                            Text(formattedDate(date))
                                .font(.caption)
                        }

                        Picker("Transport", selection: Binding(
                            get: {
                                place.toRoute?.transportType ?? "None"
                            },
                            set: { newValue in
                                if let route = place.toRoute {
                                    route.transportType = newValue == "None" ? nil : newValue
                                    do {
                                        try viewContext.save()
                                        refreshView = UUID() // Odświeżenie widoku po zapisaniu
                                    } catch {
                                        print("Error saving transport type: \(error.localizedDescription)")
                                    }
                                }
                            }
                        )) {
                            Text("None").tag("None")
                            Text("Bike").tag("Bike")
                            Text("Car").tag("Car")
                            Text("Train").tag("Train")
                            Text("Bus").tag("Bus")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)

                        
                        .contextMenu {
                            Button(action: {
                                deletePlace(place)
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }

                            Button(action: {
                                self.selectedPlace = place
                                self.newPlaceName = place.name ?? ""
                                self.newPlaceDate = place.date ?? Date()
                                self.isEditing = true
                            }) {
                                Text("Edit")
                                Image(systemName: "pencil")
                            }
                        }
                    }
                    .id(UUID()) // Odświeża pojedynczy wiersz po edycji/usunięciu
                }
            }
            .id(refreshView) // refreshView jako id Listy do wymuszenia jej odświeżenia
            .listStyle(PlainListStyle())
            .background(Color.white)

            VStack {
                TextField("New Place", text: $newPlaceName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack {
                    DatePicker("", selection: $newPlaceDate, in: trip.dateFrom!...trip.dateTo!, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())

                    Button(action: {
                        if isEditing {
                            updatePlace()
                        } else {
                            addPlace()
                        }
                    }) {
                        Text(isEditing ? "Confirm" : "Add Place")
                    }
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                }
                .padding(.top, 10)
                .padding([.leading, .trailing], 20)
            }
            .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("\(trip.country ?? "Unknown Country"), \(trip.city ?? "Unknown City")")
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func addPlace() {
        guard !newPlaceName.isEmpty else { return }

        let newPlace = Place(context: viewContext)
        newPlace.name = newPlaceName
        newPlace.date = newPlaceDate
        newPlace.place_id = UUID()
        newPlace.toTrip = trip

        let newRoute = Route(context: viewContext)
        newRoute.route_id = UUID()
        newRoute.transportType = "None" // Ustawienie początkowe na "None"
        newRoute.addToToPlace(newPlace)
        newRoute.toTrip = trip

        do {
            try viewContext.save()
            newPlaceName = ""
            newPlaceDate = Date()
            refreshView = UUID() // Odświeżenie widoku po zapisaniu
        } catch {
            print(error.localizedDescription)
        }
    }

    private func updatePlace() {
        guard let place = selectedPlace else { return }
        place.name = newPlaceName
        place.date = newPlaceDate

        do {
            try viewContext.save()
            newPlaceName = ""
            newPlaceDate = Date()
            refreshView = UUID() // Odświeżenie widoku po zapisaniu
            isEditing = false
        } catch {
            print(error.localizedDescription)
        }
    }

    private func deletePlace(_ place: Place) {
        viewContext.delete(place)

        do {
            try viewContext.save()
            refreshView = UUID() // Odświeżenie widoku po usunięciu
        } catch {
            print(error.localizedDescription)
        }
    }
}
