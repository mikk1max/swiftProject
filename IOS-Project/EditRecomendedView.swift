import SwiftUI

struct EditRecomendedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var trip: Trip
    var country: String
    var city: String
    @Binding var isPresented: Bool

    @State private var editedCountry: String
    @State private var editedCity: String
    @State private var editedNotes: String
    @State private var editedDateFrom: Date
    @State private var editedDateTo: Date

    @State private var isCountryValid: Bool = true
    @State private var isCityValid: Bool = true
    @State private var isNotesValid: Bool = true
    
    @State private var countryError = ""
    @State private var cityError = ""
    @State private var notesError = ""
    @State private var dateError = ""

    init(trip: Trip, country: String, city: String, isPresented: Binding<Bool>) {
        self.trip = trip
        self.country = country
        self.city = city
        self._isPresented = isPresented
        self._editedCountry = State(initialValue: trip.country ?? country)
        self._editedCity = State(initialValue: trip.city ?? city)
        self._editedNotes = State(initialValue: trip.notes ?? "")
        self._editedDateFrom = State(initialValue: trip.dateFrom ?? Date())
        self._editedDateTo = State(initialValue: trip.dateTo ?? Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    TextField("Country", text: $editedCountry)
                        .overlay(validationIcon(for: isCountryValid))
                        .onChange(of: editedCountry) { _ in validateCountry() }
                    if !countryError.isEmpty {
                        Text(countryError).foregroundColor(.red)
                    }
                    TextField("City", text: $editedCity)
                        .overlay(validationIcon(for: isCityValid))
                        .onChange(of: editedCity) { _ in validateCity() }
                    if !cityError.isEmpty {
                        Text(cityError).foregroundColor(.red)
                    }
                    TextField("Notes", text: $editedNotes)
                        .overlay(validationIcon(for: isNotesValid))
                        .onChange(of: editedNotes) { _ in validateNotes() }
                    if !notesError.isEmpty {
                        Text(notesError).foregroundColor(.red)
                    }
                    DatePicker("From", selection: $editedDateFrom, displayedComponents: .date)
                    DatePicker("To", selection: $editedDateTo, displayedComponents: .date)
                        .onChange(of: editedDateTo) { _ in validateDates() }
                    if !dateError.isEmpty {
                        Text(dateError).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Trip confirm")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Revoke") {
                        deleteTrip(trip)
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveChanges()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        if fieldsAreValid() {
            trip.country = editedCountry
            trip.city = editedCity
            trip.notes = editedNotes
            trip.dateFrom = editedDateFrom
            trip.dateTo = editedDateTo
            
            do {
                try viewContext.save()
                isPresented = false
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteTrip(_ trip: Trip) {
        viewContext.delete(trip)

        do {
            try viewContext.save()
            isPresented = false
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fieldsAreValid() -> Bool {
        return validateCountry() && validateCity() && validateNotes() && validateDates()
    }
    
    @discardableResult
    private func validateCountry() -> Bool {
        if editedCountry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            countryError = "Country cannot be empty"
            return false
        } else if !editedCountry.allSatisfy({ $0.isLetter || $0.isWhitespace }) {
            countryError = "Country can only contain letters"
            return false
        }
        countryError = ""
        return true
    }
    
    @discardableResult
    private func validateCity() -> Bool {
        if editedCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cityError = "City cannot be empty"
            return false
        } else if !editedCity.allSatisfy({ $0.isLetter || $0.isWhitespace }) {
            cityError = "City can only contain letters"
            return false
        }
        cityError = ""
        return true
    }
    
    @discardableResult
    private func validateNotes() -> Bool {
        if editedNotes.count > 500 {
            notesError = "Notes cannot exceed 500 characters"
            return false
        }
        notesError = ""
        return true
    }
    
    private func validateDates() -> Bool {
        if editedDateTo < editedDateFrom {
            dateError = "End date must be after start date"
            return false
        }
        dateError = ""
        return true
    }

    private func validationIcon(for isValid: Bool) -> AnyView {
        if !isValid {
            return AnyView(
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .padding(.trailing, 8)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}
