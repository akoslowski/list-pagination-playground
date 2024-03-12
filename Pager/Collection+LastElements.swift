import Foundation

extension Collection {
    func last(n: Int) -> SubSequence {
        guard isEmpty == false else { return self[...] }
        let start = index(endIndex, offsetBy: -n, limitedBy: startIndex) ?? startIndex
        return self[start...]
    }
}
