import SwiftUI

struct EditTripView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    var trip: Trip
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

    init(trip: Trip, isPresented: Binding<Bool>) {
        self.trip = trip
        self._isPresented = isPresented
        self._editedCountry = State(initialValue: trip.country ?? "")
        self._editedCity = State(initialValue: trip.city ?? "")
        self._editedNotes = State(initialValue: trip.notes ?? "")
        self._editedDateFrom = State(initialValue: trip.dateFrom ?? Date())
        self._editedDateTo = State(initialValue: trip.dateTo ?? Date())
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
                    DatePicker("From", selection: $editedDateFrom, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("To", selection: $editedDateTo, displayedComponents: [.date, .hourAndMinute])
                        .onChange(of: editedDateTo) { _ in validateDates() }
                    if !dateError.isEmpty {
                        Text(dateError).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Trip")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if fieldsAreValid(){
                            saveChanges()
                        }
                    }
                }
            }
        }
    }

    private func saveChanges() {
        // Sprawdzamy czy wymagane pola są wypełnione
        if editedCountry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isCountryValid = false
        } else {
            isCountryValid = true
        }
        if editedCity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isCityValid = false
        } else {
            isCityValid = true
        }


        // Zapisujemy zmiany do trip
        if isCountryValid && isCityValid && isNotesValid {
            trip.country = editedCountry
            trip.city = editedCity
            trip.notes = editedNotes
            trip.dateFrom = editedDateFrom
            trip.dateTo = editedDateTo

            do {
                try managedObjectContext.save()
                isPresented = false // Zamykamy widok po zapisaniu
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
            dateError = "Data powrotu jest mniejsza niz data wyjazdu"
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
