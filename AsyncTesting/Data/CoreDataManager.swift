import CoreData
import Foundation

@globalActor
actor CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var mainContext: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    @discardableResult
    func addItem<T>(type: T.Type, parameters: [String: Any]?) async throws -> Result<T, Error> where T: NSManagedObject {
        return try await backgroundContext.perform({
            let entity = NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self.backgroundContext)
            if let parameters = parameters {
                for key in parameters.keys {
                    if let value = parameters[key] as? NSManagedObject {
                        let object = self.backgroundContext.object(with: value.objectID)
                        entity.setValue(object, forKey: key)
                    } else {
                        entity.setValue(parameters[key], forKey: key)
                    }
                }
            }
            try self.backgroundContext.save()
            return .success(entity as! T) // swiftlint:disable:this force_cast
        })
    }
    
    func getAuthorBy(name: String) -> Result<AuthorMO, Error> {
        return backgroundContext.performAndWait({
            let request = AuthorMO.fetchRequest()
            let nameField = #selector(getter: AuthorMO.name).description
            request.predicate = NSPredicate(format: "\(nameField) == %@", name)
            request.fetchLimit = 1
            
            do {
                let authors = try backgroundContext.fetch(request)
                if let author = authors.first {
                    return .success(author)
                } else {
                    return .failure(FetchError.nothingIsHere)
                }
            } catch {
                return .failure(error)
            }
        })
    }
    
    func getGenreBy(title: String) -> Result<GenreMO, Error> {
        return backgroundContext.performAndWait({
            let request = GenreMO.fetchRequest()
            let nameField = #selector(getter: GenreMO.title).description
            request.predicate = NSPredicate(format: "\(nameField) == %@", title)
            request.fetchLimit = 1
            
            do {
                let genres = try backgroundContext.fetch(request)
                if let genre = genres.first {
                    return .success(genre)
                } else {
                    return .failure(FetchError.nothingIsHere)
                }
            } catch {
                return .failure(error)
            }
        })
    }
    
    func getBookBy(title: String) async -> Result<BookMO, Error> {
        return backgroundContext.performAndWait({
            let request = BookMO.fetchRequest()
            let titleField = #selector(getter: BookMO.title).description
            request.predicate = NSPredicate(format: "\(titleField) == %@", title)
            
            do {
                let books = try backgroundContext.fetch(request)
                if let book = books.first {
                    return .success(book)
                } else {
                    return .failure(FetchError.nothingIsHere)
                }
            } catch {
                return .failure(error)
            }
        })
    }
    
    func getAllBooks() async -> Result<[BookMO], Error> {
        return await backgroundContext.perform({
            let request = BookMO.fetchRequest()
            do {
                let books = try self.backgroundContext.fetch(request)
                return .success(books)
            } catch {
                return .failure(error)
            }
        })
    }
    
    func clearData() throws {
        let authorsRequest = AuthorMO.fetchRequest()
        let allAuthors = try mainContext.fetch(authorsRequest)
        
        let genresRequest = GenreMO.fetchRequest()
        let allGenres = try mainContext.fetch(genresRequest)
        
        let booksRequest = BookMO.fetchRequest()
        let allBooks = try mainContext.fetch(booksRequest)
        
        for book in allBooks {
            for author in allAuthors {
                author.removeFromBooks(book)
            }
            
            for genre in allGenres {
                genre.removeFromBooks(book)
            }
        }
        
        delete(allAuthors)
        delete(allGenres)
        delete(allBooks)
        
        try mainContext.save()
    }
    
    func delete(_ objects: [NSManagedObject]) {
        for object in objects {
            mainContext.delete(object)
        }
    }
}

enum FetchError: String, Error {
    case nothingIsHere = "No entries"
}
