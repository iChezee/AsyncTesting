import SwiftUI

struct CoreDataView: View {
    @ObservedObject private var viewModel = CoreDataViewModel()
    @State private var isAddWindowOpened = false
    
    var body: some View {
        VStack {
            topBar
            Divider().padding(.top, Sizes.small)
            CoreDataMainView(models: $viewModel.books)
            Spacer()
        }
        .ignoresSafeArea()
        .padding(.top, Sizes.mediumSmall)
    }
    
    var topBar: some View {
        HStack {
            Button {
                isAddWindowOpened.toggle()
            } label: {
                Image(systemName: "plus")
                    .imageScale(.large)
            }
            .popover(isPresented: $isAddWindowOpened) {
                AddBookPopover { book, author, genre in
                    Task {
                        await viewModel.addBook(title: book, authorName: author, genreTitle: genre)
                        isAddWindowOpened = false
                    }
                }
            }
        }
        .frame(height: Sizes.large)
    }
}
