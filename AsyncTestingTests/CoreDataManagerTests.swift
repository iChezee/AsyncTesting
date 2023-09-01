import XCTest
import CoreData
@testable import AsyncTesting

final class CoreDataManagerTests: XCTestCase {
    let manager = CoreDataManager.shared
    
    override func setUp() async throws {
        try await manager.clearData()
    }
    
    func test_manager_when_addItem() async throws {
        let name = "Zamyatin"
        let parameters = [
            #selector(getter: AuthorMO.name).description: name
        ] as? [String: Any]
        
        let result = try await manager.addItem(type: AuthorMO.self, parameters: parameters)
        guard case .success(let createdAuthor) = result else {
            throw(CocoaError(.coreData))
        }

        let fetchedAuthor = await manager.mainContext.object(with: createdAuthor.objectID)
        XCTAssertEqual(createdAuthor.objectID, fetchedAuthor.objectID)
        
        guard case .success(let authorByName) = await manager.getAuthorBy(name: name) else {
            throw(CocoaError(.coreData))
        }
        
        XCTAssertEqual(createdAuthor.objectID, authorByName.objectID)
    }
}

extension CoreDataManagerTests {
    func delete(_ objects: [NSManagedObject]) async {
        for object in objects {
            await manager.mainContext.delete(object)
        }
    }
}
