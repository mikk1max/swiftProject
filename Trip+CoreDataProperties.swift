import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var dateFrom: Date?
    @NSManaged public var dateTo: Date?
    @NSManaged public var notes: String?
    @NSManaged public var trip_id: UUID?
    @NSManaged public var toPlace: NSSet?
    @NSManaged public var toRoute: Route?

}

// MARK: Generated accessors for toPlace
extension Trip {

    @objc(addToPlaceObject:)
    @NSManaged public func addToToPlace(_ value: Place)

    @objc(removeToPlaceObject:)
    @NSManaged public func removeFromToPlace(_ value: Place)

    @objc(addToPlace:)
    @NSManaged public func addToToPlace(_ values: NSSet)

    @objc(removeToPlace:)
    @NSManaged public func removeFromToPlace(_ values: NSSet)

}

extension Trip : Identifiable {

}
