import SwiftUI

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
        ZStack {
            ScrollView {
                LazyVStack(alignment: .center, spacing: 0, pinnedViews: []) {
                    ForEach(model.state.items) { imageItem in
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(
                                url: imageItem.downloadURL(
                                    size: .size(
                                        width: 400,
                                        height: 400
                                    )
                                )
                            ) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 400, height: 400)
                            }
                            .frame(maxWidth: .infinity)

                            Text(imageItem.author)
                                .padding(8)
                                .background(Capsule().foregroundStyle(.ultraThinMaterial))
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .task {
                            await model.reportAppearance(imageItem)
                        }
                    }
                }
            }

            if model.state.isLoading, model.state.items.isEmpty {
                ProgressView("loading")
                    .padding(24)
                    .background(
                        Circle().foregroundStyle(.ultraThinMaterial)
                    )
            } else if model.state.items.isEmpty {
                Text("Nothing here.")
            }

            if case .error(_, let error) = model.state {
                ErrorView(error: error)
                    .onTapGesture {
                        Task {
                            await model.load()
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
