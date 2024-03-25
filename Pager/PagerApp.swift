import SwiftUI

let randomData = RandomData(minimumNumberOfElements: 25)

@main @MainActor struct PagerApp: App {

    struct PageItem: Hashable {
        let id: UUID
        let name: String

        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }

        init(_ int: Int) {
            self.id = UUID()
            self.name = "PageItem<\(int)/\(id.uuidString.prefix(8))>"
        }
    }

    @State var listModel = Model(
        moreItems: { randomData().map(PageItem.init) },
        description: { index, value in value.name }
    )

    @State var imagesModel = ImagesModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                ListView<PageItem>()
                    .environment(listModel)
                    .tabItem {
                        Label("Strings", systemImage: "s.square")
                    }

                ImagesView()
                    .environment(imagesModel)
                    .tabItem {
                        Label("Pictures", systemImage: "p.square")
                    }
            }
            .toolbarBackground(.visible, for: .bottomBar)
        }
    }
}
