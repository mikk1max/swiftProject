import Foundation
import CoreData


extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var priority: Int16
    @NSManaged public var route_id: UUID?
    @NSManaged public var transportType: String?
    @NSManaged public var toPlace: NSSet?
    @NSManaged public var toTrip: Trip?

}

// MARK: Generated accessors for toPlace
extension Route {

    @objc(addToPlaceObject:)
    @NSManaged public func addToToPlace(_ value: Place)

    @objc(removeToPlaceObject:)
    @NSManaged public func removeFromToPlace(_ value: Place)

    @objc(addToPlace:)
    @NSManaged public func addToToPlace(_ values: NSSet)

    @objc(removeToPlace:)
    @NSManaged public func removeFromToPlace(_ values: NSSet)

}

extension Route : Identifiable {

}
