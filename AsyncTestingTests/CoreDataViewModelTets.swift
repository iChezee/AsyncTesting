import XCTest
import CoreData
import Combine
@testable import AsyncTesting

final class CoreDataViewModelTets: XCTestCase {
    let manager = CoreDataManager.shared
    let viewModel = CoreDataViewModel()
    
    var cancallables = Set<AnyCancellable>()
    var dataCreationExpectation: XCTestExpectation {
        let expectation = XCTestExpectation(description: "Data creation")
        expectation.expectedFulfillmentCount = 3
        return expectation
    }
    
    override func setUp() async throws {
        try await manager.clearData()
    }
    
    override func tearDown() async throws {
        try await manager.clearData()
    }
    
    func test_viewModelInit_when_coreDataHasEntities() async {
        let createExpectation = dataCreationExpectation
        await createData(with: createExpectation)
        await fulfillment(of: [createExpectation])
        
        let viewModel = CoreDataViewModel()
        let fetchExpectation = XCTestExpectation(description: "Fetch books expectation")
        viewModel.$books
            .receive(on: OperationQueue.main)
            .sink { books in
                if !books.isEmpty {
                    fetchExpectation.fulfill()
                }
            }
            .store(in: &cancallables)
        await fulfillment(of: [fetchExpectation])
        XCTAssertTrue(viewModel.books.count == bookTitles.count)
    }
    
    func test_viewModelPublishedEntities_when_addingBook() async throws {
        let expectation = dataCreationExpectation
        await createData(with: expectation)
        await fulfillment(of: [expectation])
        XCTAssertTrue(viewModel.books.count == bookTitles.count)
    }
    
    func test_correctRelations_when_relationsCreated() async throws {
        let expectation = dataCreationExpectation
        await createData(with: expectation)
        await fulfillment(of: [expectation])
        
        // swiftlint:disable force_cast
        let book = await manager.mainContext.object(with: try await manager.getBookBy(title: bookTitles[0]).get().objectID) as! BookMO
        let author = await manager.mainContext.object(with: try await manager.getAuthorBy(name: authorsNames[0]).get().objectID) as! AuthorMO
        let genre = await manager.mainContext.object(with: try await manager.getGenreBy(title: genre).get().objectID) as! GenreMO
        // swiftlint:enable force_cast
        
        XCTAssertEqual(book.genre.objectID, genre.objectID)
        XCTAssertEqual(book.author.objectID, author.objectID)
        XCTAssertTrue(author.books.contains(book))
        guard let genreBooks = genre.books else {
            throw(CocoaError(.coreData))
        }
        XCTAssertTrue(genreBooks.contains(book))
        XCTAssertTrue(genreBooks.count == bookTitles.count)
    }
}

extension CoreDataViewModelTets {
    func createData(with expectation: XCTestExpectation) async {
        for index in 0..<bookTitles.count {
            await viewModel.addBook(title: bookTitles[index], authorName: authorsNames[index], genreTitle: genre) {
                expectation.fulfill()
            }
        }
    }
}

extension CoreDataViewModelTets {
    var bookTitles: [String] { ["1984", "451", "Brand new world"] }
    var authorsNames: [String] { ["Orwell", "Bradbury", "Huxley"] }
    var genre: String { "Antiutopia" }
    
    var countOfFulfills: Int {
        bookTitles.count + authorsNames.count + 1
    }
}
