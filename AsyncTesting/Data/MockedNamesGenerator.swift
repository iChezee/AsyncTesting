import Foundation

enum MockedNamesGenerator {
    static func getAsyncNames() async -> [String] {
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        let first = "Adam"
        async let second = "Betty"
        async let third = "Brian"
        async let additional = additionalName()
        return await [first, second, third, additional]
    }
    
    static func getActorNames() async -> [String] {
        let first = "Ben"
        async let second = "Chris"
        async let third = "David"
        async let additional = additionalName()
        return await [first, second, third, additional]
    }
    
    // Async adding one more instance
    static func additionalName() async -> String {
        try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
        return "Phillip"
    }
}
