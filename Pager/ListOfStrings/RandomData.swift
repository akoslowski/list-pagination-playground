import Foundation

struct RandomData {
    let minimumNumberOfElements: UInt

    func makeItems() -> [Int] {
        let upperBoundRange = Int(minimumNumberOfElements)...Int(minimumNumberOfElements) + 15
        return Array(1...Int.random(in: upperBoundRange))
    }

    func makeItems() -> [String] {
        let items: [Int] = makeItems()
        return items.map { _ in String(UUID().uuidString.prefix(8)) }
    }

    func callAsFunction() -> [Int] {
        makeItems()
    }

    func callAsFunction() -> [String] {
        makeItems()
    }

    func callAsFunction() async throws -> [Int] {
        makeItems()
    }

    func callAsFunction() async throws -> [String] {
        makeItems()
    }
}
