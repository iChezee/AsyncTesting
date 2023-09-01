import CoreData

extension NSManagedObject {
    @nonobjc public class var entityName: String {
        String(self.description().lastPathComponent().dropLast(2))
    }
}
