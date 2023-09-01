import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @State var isOpenedAlert = false
    
    var body: some View {
        VStack {
            navigationBar
            Divider().padding(.top, Sizes.small)
            mainList
            Spacer()
        }
        .ignoresSafeArea()
        .padding(.top, Sizes.mediumSmall)
        .alert(isPresented: $isOpenedAlert) {
            Alert(title: Text("UI Test"))
        }
    }
    
    var navigationBar: some View {
        HStack {
            Button {
                isOpenedAlert.toggle()
            } label: {
                Image(systemName: isOpenedAlert ? "eye.fill" : "eye")
            }
            Spacer()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.black)
            Spacer()
            Button {
                withAnimation {
                    viewModel.switchViewModel()
                }
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
        }
        .padding(.horizontal, Sizes.medium)
        .frame(height: Sizes.large)
    }
    
    var mainList: some View {
        VStack {
            ForEach(viewModel.names) { model in
                cellFor(model: model)
            }
        }
        .padding(.top, Sizes.medium)
    }
    
    func cellFor(model: NameModel) -> some View {
        HStack {
            model.image
                .padding(.leading, Sizes.small)
            Text(model.name)
                .font(.title)
            Spacer()
            Image(systemName: "arrowshape.right")
                .foregroundColor(.blue)
                .padding(.trailing, Sizes.small)
        }
        .overlay(content: {
            RoundedRectangle(cornerRadius: Sizes.small)
                .stroke(Color.gray, lineWidth: 1)
        })
        .padding(.horizontal, Sizes.medium)
        .padding(.bottom, Sizes.small)
    }
}

struct ContentViewPreview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
