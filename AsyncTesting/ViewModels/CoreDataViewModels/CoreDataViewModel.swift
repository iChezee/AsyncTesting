import Foundation
import CoreData

class CoreDataViewModel: ObservableObject {
    @Published var books = [BookMO]()
    private var manager = CoreDataManager.shared
    
    init() {
        Task {
            await fetchAllBooks()
        }
    }
    
    func addBook(title: String, authorName: String, genreTitle: String, competion: (() -> Void)? = nil) async {
        do {
            if case .success = await manager.getBookBy(title: title) {
                return
            }
            
            let author = try await getAuthor(authorName)
            let genre = try await getGenre(genreTitle)
            
            let parameters = [
                #selector(getter: BookMO.title).description: title,
                #selector(getter: BookMO.author).description: author,
                #selector(getter: BookMO.genre).description: genre
            ] as [String: Any]
            let book = try await manager.addItem(type: BookMO.self, parameters: parameters).get()
            
            _ = await manager.backgroundContext.perform {
                Task {
                    await self.makeRelations(book: book.objectID, author: author.objectID, genre: genre.objectID)
                }
            }
            
            await appendBook(book.objectID)
            competion?()
        } catch {
            print(error)
        }
    }
}

extension CoreDataViewModel {
    // Init data previously saved to CoreData
    func fetchAllBooks() async {
        let booksResult = await manager.getAllBooks()
        if case .success(let books) = booksResult,
           !books.isEmpty {
            await MainActor.run {
                self.books = books
            }
        }
    }
    
    // Making relations in separate context for objects.
    func makeRelations(book: NSManagedObjectID, author: NSManagedObjectID, genre: NSManagedObjectID) async {
        let context = await manager.backgroundContext
        guard let book = context.object(with: book) as? BookMO,
              let author = context.object(with: author) as? AuthorMO,
              let genre = context.object(with: genre) as? GenreMO else {
            return
        }
        author.addToBooks(book)
        genre.addToBooks(book)
    }
    
    // Fetch author if it was created already
    func getAuthor(_ name: String) async throws -> AuthorMO {
        let fetchedAuthorResult = await manager.getAuthorBy(name: name)
        switch fetchedAuthorResult {
        case .success(let fetchedAuthor):
            return fetchedAuthor
        case .failure(let error):
            if error as? FetchError == FetchError.nothingIsHere {
                return try await createAuthor(name)
            } else {
                print(error)
                throw(error)
            }
        }
    }
    
    func createAuthor(_ name: String) async throws -> AuthorMO {
        let nameField = #selector(getter: AuthorMO.name).description
        return try await manager.addItem(type: AuthorMO.self, parameters: [nameField: name]).get()
    }
    
    // Fetch genre if it was created already
    func getGenre(_ title: String) async throws -> GenreMO {
        let fetchedResult = await manager.getGenreBy(title: title)
        switch fetchedResult {
        case .success(let genre):
            return genre
        case .failure(let error):
            if error as? FetchError == FetchError.nothingIsHere {
                return try await createGenre(title)
            } else {
                print(error)
                throw(error)
            }
        }
    }
    
    func createGenre(_ title: String) async throws -> GenreMO {
        let titleField = #selector(getter: GenreMO.title).description
        return try await manager.addItem(type: GenreMO.self, parameters: [titleField: title]).get()
    }
    
    func appendBook(_ bookID: NSManagedObjectID) async {
        guard let book = await manager.mainContext.object(with: bookID) as? BookMO else {
            return
        }
        await MainActor.run { [weak self] in
            self?.books.append(book)
        }
    }
}
