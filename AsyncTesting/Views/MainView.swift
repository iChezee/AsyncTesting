import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Main async", systemImage: "trash")
                }
            CoreDataView()
                .tabItem {
                    Label("CoreData async", systemImage: "trash.slash")
                }
        }
    }
}
