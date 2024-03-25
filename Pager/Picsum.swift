import Foundation

actor PicsumAPI {
    struct Response {
        let pageInfo: [Pagination]
        let list: [Metadata]
    }

    struct Metadata: Decodable, Identifiable {
        enum CodingKeys: String, CodingKey {
            case id, author, width, height, url
            case downloadURL = "download_url"
        }

        let id: String
        let author: String
        let width: Int
        let height: Int
        let url: URL
        let downloadURL: URL
    }

    func fetchList(page: Int = 10, limit: Int = 5) async throws -> Response {
        let listURL = URL(string: "https://picsum.photos/v2/list")!
        let queryItems = [URLQueryItem(name: "page", value: "\(page)"), .init(name: "limit", value: "\(limit)")]
        return try await fetchList(listURL.appending(queryItems: queryItems))
    }

    func fetchList(_ pageInfo: [Pagination], rel: Pagination.Relation = .next) async throws -> Response {
        guard let page = pageInfo.first(where: { $0.relation == rel }) else { throw URLError(.badURL) }
        return try await fetchList(page.url)
    }

    private func fetchList(_ url: URL) async throws -> Response {
        let listRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: listRequest)
        let list = try JSONDecoder().decode([Metadata].self, from: data)
        let pageInfo: [Pagination] = if let linkValue = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Link") {
            try parsePagination(from: linkValue)
        } else {
            []
        }
        return Response(pageInfo: pageInfo, list: list)
    }
}


public struct Pagination {
    public enum Relation: String {
        case first, last, next, prev
    }

    public let url: URL
    public let relation: Relation

    public init(url: URL, relation: Relation) {
        self.url = url
        self.relation = relation
    }

    public init?(urlString: String, relString: String) {
        guard let relation = Relation(rawValue: relString),
              let url = URL(string: urlString)
        else { return nil }

        self.init(url: url, relation: relation)
    }

    public var isNext: Bool {
        relation == .next
    }
}

public func parsePagination(from string: String) throws -> [Pagination] {
    try NSRegularExpression(
        pattern: #"<(?<url>http[|s]://[\d\w].*?)>; rel="(?<rel>[\w].*?)""#,
        options: []
    )
        .matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count)
        )
        .compactMap { match -> Pagination? in
            guard
                let urlString = string.substring(in: match.range(withName: "url")),
                let relString = string.substring(in: match.range(withName: "rel"))
            else { return nil }

            return Pagination(urlString: urlString, relString: relString)
        }
}

private extension String {
    func substring(in range: NSRange) -> String? {
        guard let range = Range(range, in: self) else { return nil }
        return String(self[range])
    }
}
