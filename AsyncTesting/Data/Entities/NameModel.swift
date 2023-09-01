import Foundation
import SwiftUI

struct NameModel: Identifiable, Comparable, CustomDebugStringConvertible {
    let id: Int
    let name: String
    let image: Image
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        let imageName = ImageNames.allCases.randomElement()!.name // swiftlint:disable:this force_unwrapping
        
        self.image = Image(systemName: imageName)
    }
    
    var debugDescription: String {
        return "NameModel id \(id) name \(name)"
    }
    
    static func ==(lhs: NameModel, rhs: NameModel) -> Bool { // swiftlint:disable:this operator_whitespace
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    static func < (lhs: NameModel, rhs: NameModel) -> Bool {
        return lhs.name < rhs.name
    }
}

extension NameModel {
    enum ImageNames: Int, CaseIterable {
        case pencil = 0
        case pencilLine
        case eraser
        case highlighter
        
        var name: String {
            switch self {
            case .pencil:
                return "pencil"
            case .pencilLine:
                return "pencil.line"
            case .eraser:
                return "eraser"
            case .highlighter:
                return "highlighter"
            }
        }
    }
}
