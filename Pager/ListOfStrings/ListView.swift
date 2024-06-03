import SwiftUI

@Observable @MainActor final class Model<Element: Hashable> {

    let lastElementsCount: Int
    let requestDuration: Duration
    let moreItems: () async throws -> [Element]
    let description: (Int, Element) -> String

    private(set) var state: ListState<Element> = .initial

    init(
        lastElementsCount: Int = 5,
        requestDuration: Duration = .seconds(2),
        moreItems: @escaping () async throws -> [Element],
        description: @escaping (Int, Element) -> String
    ) {
        self.lastElementsCount = lastElementsCount
        self.requestDuration = requestDuration
        self.moreItems = moreItems
        self.description = description
    }

    func refresh() async {
        state = .initial
        await load()
    }

    func load() async {
        guard state.isLoading == false else { return }

        state = .loading(state.items)

        do {
            try await Task.sleep(for: requestDuration)
            let moreItems = try await moreItems()
            let allItems = state.items + moreItems
            state = .loaded(allItems)
        } catch {
            state = .error(state.items, error)
        }
    }

    func reportAppearance(ofItemAtIndex index: Int) async {
        if state.lastIndices(n: lastElementsCount).contains(index) {
            await load()
        }
    }

    func description(forItemAtIndex index: Int) -> String {
        guard state.items.isEmpty == false else { return "<description not available>" }
        return description(index, state.items[index])
    }
}

@MainActor struct ListView<Element: Hashable>: View {

    @Environment(Model<Element>.self) var model: Model<Element>
    @State private var navigationBarTint: Color = .white

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                List(0..<model.state.items.endIndex, id: \.self) { index in
                    NavigationLink {
                        DetailView(
                            index: index,
                            text: model.description(forItemAtIndex: index),
                            tint: $navigationBarTint
                        )
                    } label: {
                        RowView(
                            index: index,
                            content: model.description(forItemAtIndex: index)
                        )
                        .task {
                            // Without the additional task, the disappearing of the row will also cancel the loading of the next page.
                            let task = Task {
                                await model.reportAppearance(ofItemAtIndex: index)
                            }
                            await task.value
                        }
                    }
                    .listRowBackground(rowBackgroundColor(at: index))
                }
                .listStyle(.plain)
                .navigationTitle("List")
                .toolbarBackground(.visible, for: .navigationBar)
                .background(model.state.currentBackgroundColor)
            }
            .tint(navigationBarTint)

            if model.state.isLoading {
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
        .animation(
            .easeIn(duration: 0.25),
            value: model.state.isLoading
        )
        .refreshable {
            await model.refresh()
        }
        .task {
            await model.load()
        }
    }
}

extension ListState {
    var currentBackgroundColor: Color {
        if items.isEmpty {
            return .clear
        }

        guard let lastIndex = lastIndices(n: 1).first else {
            return .clear
        }

        return rowBackgroundColor(at: lastIndex)
    }
}

// MARK: - Previews -

fileprivate func defaultDescription<Element>(index: Int, value: Element) -> String {
    "value: \(value)"
}

#Preview("List") {
    ListView<Int>()
        .environment(
            Model<Int>(
                lastElementsCount: 8,
                requestDuration: .milliseconds(500),
                moreItems: randomData.callAsFunction,
                description: defaultDescription
            )
        )
}

#Preview("List with strings") {
    ListView<String>()
        .environment(
            Model<String>(
                lastElementsCount: 8,
                requestDuration: .milliseconds(100),
                moreItems: randomData.callAsFunction,
                description: defaultDescription
            )
        )
}

#Preview("List with random failures") {
    ListView<Int>()
        .environment(
            Model<Int>(
                lastElementsCount: 1,
                moreItems: {
                    if Int.random(in: 1...5) == 5 {
                        throw URLError(.badURL)
                    } else {
                        randomData()
                    }
                },
                description: defaultDescription
            )
        )
}

#Preview("Errrror") {
    ListView<Int>()
        .environment(
            Model<Int>(
                moreItems: { throw URLError(.badURL) },
                description: defaultDescription
            )
        )
}

#Preview("Empty") {
    ListView<Int>()
        .environment(
            Model<Int>(
                moreItems: { [] },
                description: defaultDescription
            )
        )
}
