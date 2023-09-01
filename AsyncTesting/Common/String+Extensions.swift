import Foundation

extension String {
    func lastPathComponent() -> String {
        self.components(separatedBy: ".").last! // swiftlint:disable:this force_unwrapping
    }
    
    func checkForSpecialSymbols() -> Bool {
        self.range(of: "^[!\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]+", options: .regularExpression) != nil
    }
}
