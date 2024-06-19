import SwiftUI
import CoreData

struct TripListView: View {
    var date: Date
    var items: [Trip]

    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: TripDetailView(trip: item)) {
                    VStack(alignment: .leading) {
                        Text("\(item.county ?? "Unknown County"), \(item.city ?? "Unknown City")")
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
            }
        }
        .navigationTitle("Trips on \(formattedDate(date))")
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
