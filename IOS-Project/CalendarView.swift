import SwiftUI
import CoreData

struct CalendarView: View {
    @Binding var selectedDate: Date
    var items: FetchedResults<Trip>
    @State private var selectedTrips: [Trip] = []

    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        return calendar
    }()
    private let dateFormatter: DateFormatter

    init(selectedDate: Binding<Date>, items: FetchedResults<Trip>) {
        self._selectedDate = selectedDate
        self.items = items
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: selectedDate))
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()

                let days = generateDaysInMonth(for: selectedDate)
                let weekdays = calendar.shortWeekdaySymbols

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                        ForEach(Array(weekdays.dropFirst()) + [weekdays.first!], id: \.self) { weekday in
                            Text(weekday)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }

                        ForEach(days, id: \.self) { date in
                            if calendar.isDate(date, equalTo: Date.distantPast, toGranularity: .day) {
                                Text("")
                                    .frame(maxWidth: .infinity, maxHeight: 40)
                                    .padding(5)
                            } else {
                                VStack {
                                    Text(dateFormatter.string(from: date))
                                        .frame(maxWidth: .infinity, maxHeight: 40)
                                        .padding(5)
                                        .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.3) : Color.clear)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            selectedDate = date
                                            selectedTrips = getTrips(for: date)
                                        }
                                    
                                    if hasTripsOnDate(date: date) {
                                        Color.blue
                                            .frame(width: 6, height: 6)
                                            .clipShape(Circle())
                                    } else {
                                        Color.clear
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .onTapGesture {
                                    selectedDate = date
                                    selectedTrips = getTrips(for: date)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    if !selectedTrips.isEmpty {
                        Divider()
                        ForEach(selectedTrips, id: \.self) { trip in
                            NavigationLink(destination: TripDetailView(trip: trip)) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image("iconTrip")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                            .padding(.trailing, 10)

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Trip Details:")
                                                .font(.headline)
                                                .padding(.bottom, 5)

                                            Text("\(trip.country ?? "Unknown Country"), \(trip.city ?? "Unknown City")")
                                                .foregroundColor(.black)
                                                
                                            Text("\(formattedDate(trip.dateFrom)) -> \(formattedDate(trip.dateTo))")
                                                .foregroundColor(.gray)
                                                .font(.footnote)
                                            
                                            if let notes = trip.notes, !notes.isEmpty {
                                                if notes.count > 10 {
                                                    Text("Notes: more...")
                                                } else {
                                                    Text("Notes: \(notes)")
                                                }
                                            }
                                        }
                                        .padding(.leading, 10)
                                        .padding(.trailing, 10)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding()

                                    Divider()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Calendar")
            }
        }
    }

    private func generateDaysInMonth(for date: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let firstWeekday = calendar.dateComponents([.weekday], from: firstDayOfMonth).weekday else {
            return []
        }

        let firstWeekdayIndex = (firstWeekday + 5) % 7 + 1
        var days = Array(repeating: Date.distantPast, count: firstWeekdayIndex - 1)
        days += range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }

        return days
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func hasTripsOnDate(date: Date) -> Bool {
        let tripsOnDate = items.contains { trip in
            guard let tripStartDate = trip.dateFrom, let tripEndDate = trip.dateTo else { return false }
            
            return (date >= tripStartDate && date <= tripEndDate) || Calendar.current.isDate(date, inSameDayAs: tripStartDate)
        }
        return tripsOnDate
    }

    private func getTrips(for date: Date) -> [Trip] {
        return items.filter { trip in
            guard let tripStartDate = trip.dateFrom, let tripEndDate = trip.dateTo else { return false }
            
            return (date >= tripStartDate && date <= tripEndDate) || Calendar.current.isDate(date, inSameDayAs: tripStartDate)
        }
    }
}
