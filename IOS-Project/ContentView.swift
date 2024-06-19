import SwiftUI

struct ContentView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Trip.trip_id, ascending: true)]) private var items: FetchedResults<Trip>
    
    @State private var showingAddTripView = false
    @State private var selectedDate = Date()
    @State private var selectedTrip: Trip? = nil
    @State private var showingEditTripView = false
    
    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(items) { item in
                        NavigationLink(destination: TripDetailView(trip: item)) {
                            VStack(alignment: .leading) {
                                Text("\(item.country ?? "Unknown Country"), \(item.city ?? "Unknown City")")
                                    .font(.headline)
                                HStack {
                                    Text("From: \(formattedDate(item.dateFrom))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("To: \(formattedDate(item.dateTo))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .contextMenu {
                            Button("Edit") {
                                selectedTrip = item
                                showingEditTripView = true
                            }

                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingAddTripView.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                .sheet(isPresented: $showingAddTripView) {
                    AddTripView(isPresented: $showingAddTripView)
                        .environment(\.managedObjectContext, managedObjectContext)
                }
                .sheet(isPresented: $showingEditTripView) {
                    if let trip = selectedTrip {
                        EditTripView(trip: trip, isPresented: $showingEditTripView)
                            .environment(\.managedObjectContext, managedObjectContext)
                    }
                }
                .navigationTitle("My trips")
//                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "list.dash")
                Text("Trips")
            }

            RecommendationsView()
                 .tabItem {
                     Image(systemName: "star")
                     Text("Recommendations")
                 }

             CalendarView(selectedDate: $selectedDate, items: items)
                 .tabItem {
                     Image(systemName: "calendar")
                     Text("Calendar")
                 }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(managedObjectContext.delete)

            do {
                try managedObjectContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
