import Foundation

class AddBookPopoverViewModel: ObservableObject {
    @Published var bookTitle: String = ""
    @Published var authorName: String = ""
    @Published var genreTitle: String = ""
    
    func validate() -> Bool {
        return (!bookTitle.isEmpty && !authorName.isEmpty && !genreTitle.isEmpty) &&
        (!authorName.checkForSpecialSymbols() && !genreTitle.checkForSpecialSymbols())
    }
}
