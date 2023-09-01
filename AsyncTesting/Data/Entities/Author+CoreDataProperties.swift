import Foundation
import CoreData

extension AuthorMO {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<AuthorMO> {
        return NSFetchRequest<AuthorMO>(entityName: "Author")
    }
    
    @NSManaged public var name: String
    @NSManaged public var books: NSSet
    public var countOfBooks: Int {
        books.count
    }
}

extension AuthorMO {
    @objc(addBooksObject:) @NSManaged public func addToBooks(_ value: BookMO)
    @objc(removeBooksObject:) @NSManaged public func removeFromBooks(_ value: BookMO)
    @objc(addBooks:) @NSManaged public func addToBooks(_ values: NSSet)
    @objc(removeBooks:) @NSManaged public func removeFromBooks(_ values: NSSet)
}

extension AuthorMO: Identifiable {
    var id: String {
        String(name.hashValue)
    }
}
