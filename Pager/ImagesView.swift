import SwiftUI

@Observable @MainActor final class ImageFetcher {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }

    func resizedImage() {
        
    }
}

@Observable @MainActor final class ImagesModel {

    private(set) var state: ListState<PicsumAPI.Metadata> = .initial
    private(set) var pageInfo: [Pagination] = []

    func load() async {
        guard state.isLoading == false else { return }
        state = .loading(state.items)
        do {
            let picsum = PicsumAPI()
            let response = try await picsum.fetchList()
            pageInfo = response.pageInfo
            let all = state.items + response.list
            state = .loaded(all)
        } catch {
            state = .error(state.items, error)
        }
    }

    func reportAppearance(_ item: PicsumAPI.Metadata) async {
        guard item.id == state.items.last?.id else { return }
        guard state.isLoading == false else { return }
        state = .loading(state.items)
        do {
            let picsum = PicsumAPI()
            let response = try await picsum.fetchList(pageInfo)
            pageInfo = response.pageInfo
            let all = state.items + response.list
            state = .loaded(all)
        } catch {
            state = .error(state.items, error)
        }
    }
}


struct ImagesView: View {

    @Environment(ImagesModel.self) var model: ImagesModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 0, pinnedViews: []) {
                ForEach(model.state.items) { p in
                    ZStack(alignment: .bottomLeading) {

//                        AsyncImage(url: p.downloadURL) { image in
//                            image.resizable().aspectRatio(contentMode: .fill)
//
//                        } placeholder: {
//                            ProgressView()
//                                .frame(maxWidth: .infinity, minHeight: 200)
//                        }
//                        .frame(maxWidth: .infinity)
                        VStack {
                            Text("\(UIScreen.main.bounds.size.width)x\(UIScreen.main.bounds.size.height)@\(UIScreen.main.scale)")

                            Text("\(p.width)x\(p.height) (\(Double(p.width)/Double(p.height)))")

                            Text(p.author)
                                .padding(8)
                                .background(Capsule().foregroundStyle(.ultraThinMaterial))
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .task {
                        await model.reportAppearance(p)
                    }
                }
            }
        }

        .task {
            await model.load()
        }
    }
}

#Preview {
    ImagesView()
        .environment(ImagesModel())
}
