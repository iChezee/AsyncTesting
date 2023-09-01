import Foundation
import CoreData


extension BookMO {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<BookMO> {
        return NSFetchRequest<BookMO>(entityName: "Book")
    }
    
    @NSManaged public var title: String
    @NSManaged public var author: AuthorMO
    @NSManaged public var genre: GenreMO
}

extension BookMO: Identifiable { }
