import SwiftUI
#if !os(macOS)
import UIKit
#endif

struct CoreDataMainView: View {
    @Binding var models: [BookMO]
    private let ipadGrid = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
#if os(macOS)
        macList
#else
        if UIDevice.current.userInterfaceIdiom == .phone {
            iosList
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            ipadList
        }
#endif
    }
    
    func commonCell(_ model: BookMO) -> some View {
        VStack {
            AsyncImage(url: getRandomPicURL(width: Sizes.picWidth, height: Sizes.picHeight)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: Sizes.picWidth, height: Sizes.picHeight)
                } else {
                    Image("Placeholder")
                        .resizable()
                        .frame(width: Sizes.picWidth, height: Sizes.picHeight)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: Sizes.mediumSmall)
                    .stroke(Color.black, lineWidth: Sizes.overlayLineWidth)
            }
            .cornerRadius(Sizes.mediumSmall)
            Text(model.title)
                .font(.title)
            Text("by \(model.author.name)")
                .font(.body)
            Text(model.genre.title)
                .font(.caption)
        }
        .frame(width: Sizes.picWidth)
    }
}

// iOS
extension CoreDataMainView {
    var iosList: some View {
        VStack {
            ForEach(models) { model in
                iosCellFor(model)
            }
        }
        .padding(.top, Sizes.medium)
    }
    
    func iosCellFor(_ model: BookMO) -> some View {
        HStack {
            Text(model.author.name)
                .font(.body)
                .padding(.leading, Sizes.small)
                .frame(maxWidth: Sizes.large2)
            Spacer()
            VStack {
                Text(model.title)
                    .font(.title)
                Text(model.genre.title)
                    .font(.caption)
            }
            .frame(maxWidth: Sizes.large4)
            Spacer()
            Image(systemName: "arrowshape.right")
                .foregroundColor(.blue)
                .padding(.trailing, Sizes.small)
        }
        .overlay(content: {
            RoundedRectangle(cornerRadius: Sizes.small)
                .stroke(Color.gray, lineWidth: Sizes.overlayLineWidth)
        })
        .padding(.horizontal, Sizes.medium)
        .padding(.bottom, Sizes.small)
    }
}

// macOS
extension CoreDataMainView {
    var macList: some View {
        HStack {
            ForEach(models) { model in
                commonCell(model)
            }
        }
    }
}

// iPadOS
extension CoreDataMainView {
    var ipadList: some View {
        LazyVGrid(columns: ipadGrid) {
            ForEach(models) { model in
                commonCell(model)
            }
        }
    }
}

// Functional
extension CoreDataMainView {
    func getRandomPicURL(width: CGFloat, height: CGFloat) -> URL? {
        URL(string: "https://picsum.photos/\(Int(height))/\(Int(width))")
    }
}
