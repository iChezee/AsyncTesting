import Foundation

final actor ContentCustomActorModel {
    static let shared = ContentCustomActorModel()
    
    // Preparing all the data before adding it to @Published array
    func fetchMockedData() async -> [NameModel] {
        let encoded = await getEncodedData()
        var models = [NameModel]()
        for data in encoded {
            let model = await decode(data: data)
            models.append(model)
        }
        return models
    }
    
    // Fetch mocked data and encode it. Synchronized with one TaskGroup to collect all the data at once
    func getEncodedData() async -> [Data] {
        await withTaskGroup(of: Data.self, returning: [Data].self, body: { group in
            let names = await MockedNamesGenerator.getActorNames()
            for name in names {
                group.addTask {
                    return await self.encode(name: name)
                }
            }
            var data = [Data]()
            for await result in group {
                data.append(result)
            }
            return data
        })
    }
    
    // Encode name to Data
    func encode(name: String) async -> Data {
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        return name.data(using: .utf8)! // swiftlint:disable:this force_unwrapping
    }
    
    // Decode data to readable name
    func decode(data: Data) async -> NameModel {
        let name = String(data: data, encoding: .utf8)! // swiftlint:disable:this force_unwrapping
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        return NameModel(id: Int.random(in: 0..<Int.max),
                         name: name)
    }
}
