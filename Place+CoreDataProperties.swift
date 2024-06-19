import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var place_id: UUID?
    @NSManaged public var toRoute: Route?
    @NSManaged public var toTrip: Trip?

}

extension Place : Identifiable {

}
