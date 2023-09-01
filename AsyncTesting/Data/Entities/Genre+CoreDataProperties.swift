import Foundation
import CoreData

extension GenreMO {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<GenreMO> {
        return NSFetchRequest<GenreMO>(entityName: "Genre")
    }
    
    @NSManaged public var title: String
    @NSManaged public var books: NSSet?
}

extension GenreMO {
    @objc(addBooksObject:) @NSManaged public func addToBooks(_ value: BookMO)
    @objc(removeBooksObject:) @NSManaged public func removeFromBooks(_ value: BookMO)
    @objc(addBooks:) @NSManaged public func addToBooks(_ values: NSSet)
    @objc(removeBooks:) @NSManaged public func removeFromBooks(_ values: NSSet)
}

extension GenreMO: Identifiable {
    var id: String {
        String(title.hashValue)
    }
}
