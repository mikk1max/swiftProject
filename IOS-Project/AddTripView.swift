import SwiftUI
import CoreData

struct AddTripView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshView = UUID()
    @Binding var isPresented: Bool

    @State private var country = ""
    @State private var city = ""
    @State private var notes = ""
    @State private var dateFrom = Date()
    @State private var dateTo = Date()

    @State private var countryError = ""
    @State private var cityError = ""
    @State private var notesError = ""
    @State private var dateError = ""

    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.presentationMode) private var presentationMode

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    TextField("Country", text: $country)
                        .onChange(of: country) { _ in validateCountry() }
                    if !countryError.isEmpty {
                        Text(countryError).foregroundColor(.red)
                    }

                    TextField("City", text: $city)
                        .onChange(of: city) { _ in validateCity() }
                    if !cityError.isEmpty {
                        Text(cityError).foregroundColor(.red)
                    }

                    TextField("Notes", text: $notes)
                        .onChange(of: notes) { _ in validateNotes() }
                    if !notesError.isEmpty {
                        Text(notesError).foregroundColor(.red)
                    }

                    DatePicker("From", selection: $dateFrom, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("To", selection: $dateTo, displayedComponents: [.date, .hourAndMinute])
                        .onChange(of: dateTo) { _ in validateDates() }
                    if !dateError.isEmpty {
                        Text(dateError).foregroundColor(.red)
                    }
                }

                Section {
                    HStack(spacing: 10) {
                        Button("Confirm") {
                            if fieldsAreValid(){
                                saveTrip()
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(fieldsAreValid() ? Color.blue : Color.gray)
                        .cornerRadius(8)
                        .frame(width: 130)
                        .disabled(!fieldsAreValid())
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Add Trip")
        }
    }

    private func saveTrip() {
        guard fieldsAreValid() else {
            return
        }

        let newTrip = Trip(context: managedObjectContext)
        newTrip.trip_id = UUID()
        newTrip.country = country
        newTrip.city = city
        newTrip.notes = notes
        newTrip.dateFrom = dateFrom
        newTrip.dateTo = dateTo

        do {
            try managedObjectContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func fieldsAreValid() -> Bool {
        return validateCountry() && validateCity() && validateNotes() && validateDates()
    }

    @discardableResult
    private func validateCountry() -> Bool {
        if country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            countryError = "Country cannot be empty"
            return false
        } else if !country.allSatisfy({ $0.isLetter || $0.isWhitespace }) {
            countryError = "Country can only contain letters"
            return false
        }
        countryError = ""
        return true
    }

    @discardableResult
    private func validateCity() -> Bool {
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            cityError = "City cannot be empty"
            return false
        } else if !city.allSatisfy({ $0.isLetter || $0.isWhitespace }) {
            cityError = "City can only contain letters"
            return false
        }
        cityError = ""
        return true
    }

    @discardableResult
    private func validateNotes() -> Bool {
        if notes.count > 500 {
            notesError = "Notes cannot exceed 500 characters"
            return false
        }
        notesError = ""
        return true
    }

    private func validateDates() -> Bool {
        if dateTo < dateFrom {
            dateError = "Data powrotu jest mniejsza niz data wyjazdu"
            return false
        }
        dateError = ""
        return true
    }
}
