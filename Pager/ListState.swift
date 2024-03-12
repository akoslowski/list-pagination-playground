import Foundation

enum ListState<Element> {

    case initial
    case loading([Element])
    case loaded([Element])
    case error([Element], Error)

    var isLoading: Bool {
        if case .loading = self {
            true
        } else {
            false
        }
    }

    var items: [Element] {
        switch self {
        case .initial:
            []
        case .loading(let array), .loaded(let array), .error(let array, _):
            array
        }
    }

    func lastIndices(n: Int) -> Range<Int>.SubSequence {
        items.indices.last(n: n)
    }
}

extension ListState: CustomDebugStringConvertible, CustomStringConvertible {
    var debugDescription: String {
        switch self {
        case .initial:
            "initial"
        case .loading(let array):
            "loading (\(array.count) elements)"
        case .loaded(let array):
            "loaded (\(array.count) elements)"
        case .error(let array, let error):
            "error \(error) (\(array.count) elements)"
        }
    }

    var description: String {
        debugDescription
    }
}
