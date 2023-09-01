import XCTest
import Combine
@testable import AsyncTesting

final class ContentViewModelTests: XCTestCase {
    var cancallables = Set<AnyCancellable>()
    
    func test_asyncModel_when_encodeDecode() async {
        let asyncModel = ContentAsyncModel()
        let encodingExpectation = expectation(description: "Encoding with async model")
        var encoded = [Data]()
        for name in mockedAsyncNames {
            encoded.append(await asyncModel.encode(name: name))
            if name == mockedAsyncNames.last {
                encodingExpectation.fulfill()
            }
        }
        await fulfillment(of: [encodingExpectation])
        XCTAssertEqual(encoded, encodeMocked(mockedAsyncNames))
        
        let decodingExpectation = expectation(description: "Decoding with async model")
        var decoded = [NameModel]()
        for data in encoded {
            decoded.append(await asyncModel.decode(data: data))
            if data == encoded.last {
                decodingExpectation.fulfill()
            }
        }
        await fulfillment(of: [decodingExpectation])
        XCTAssertEqual(decoded.map { $0.name }, mockedAsyncNames)
    }
    
    func test_actorModel_when_encodeDecode() async {
        let actorModel = ContentCustomActorModel()
        let encodingExpectation = expectation(description: "Encoding with async model")
        var encoded = [Data]()
        for name in mockedActorNames {
            encoded.append(await actorModel.encode(name: name))
            if name == mockedActorNames.last {
                encodingExpectation.fulfill()
            }
        }
        await fulfillment(of: [encodingExpectation])
        XCTAssertEqual(encoded, encodeMocked(mockedActorNames))
        
        let decodingExpectation = expectation(description: "Decoding with async model")
        var decoded = [NameModel]()
        for data in encoded {
            decoded.append(await actorModel.decode(data: data))
            if data == encoded.last {
                decodingExpectation.fulfill()
            }
        }
        await fulfillment(of: [decodingExpectation])
        XCTAssertEqual(decoded.map { $0.name }, mockedActorNames)
    }
    
    func test_init_when_asyncModelUsage() async {
        let viewModel = ContentViewModel()
        let names = await viewModel.names
        XCTAssertTrue(names.isEmpty)
        
        let expectation = expectation(description: "Init load mockedData")
        viewModel.$names
            .receive(on: OperationQueue.main)
            .sink { names in
                if !names.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancallables)
        await fulfillment(of: [expectation])
        let fetchedNames = await viewModel.names.compactMap { $0.name }
        XCTAssertFalse(fetchedNames.isEmpty)
        XCTAssertEqual(fetchedNames, mockedAsyncNames)
    }
    
    func test_viewModel_when_switch() async {
        let viewModel = ContentViewModel()
        await viewModel.switchViewModel()
        let expectation = expectation(description: "Switch source model")
        viewModel.$names
            .receive(on: OperationQueue.main)
            .sink { names in
                if !names.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancallables)
        await fulfillment(of: [expectation])
        
        let fetchedNames = await viewModel.names.compactMap { $0.name }
        XCTAssertFalse(fetchedNames.isEmpty)
        XCTAssertEqual(fetchedNames, mockedActorNames)
    }
}

extension ContentViewModelTests {
    var mockedAsyncNames: [String] {
        ["Adam", "Betty", "Brian", "Phillip"]
    }
    
    var mockedActorNames: [String] {
        ["Ben", "Chris", "David", "Phillip"]
    }
    
    func encodeMocked(_ names: [String]) -> [Data] {
        var data = [Data]()
        for name in names {
            data.append(name.data(using: .utf8)!) // swiftlint:disable:this force_unwrapping
        }
        return data
    }
    
    func decodeMockedNames(_ encoded: [Data]) -> [String] {
        var names = [String]()
        for data in encoded {
            names.append(String(data: data, encoding: .utf8)!) // swiftlint:disable:this force_unwrapping
        }
        return names
    }
}
