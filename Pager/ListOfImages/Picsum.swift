import Foundation

actor PicsumAPI {
    struct Response {
        let pageInfo: [Pagination]
        let list: [Metadata]
    }

    enum BlurRadius: Int {
        case small = 1
        case medium = 5
        case large = 10
    }

    enum ImageSize {
        case size(width: Int, height: Int)
        case original
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

        var imageBaseURL: URL {
            // https://picsum.photos/id/48/5000/3333 -> https://picsum.photos/id/48
            downloadURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        }

        func downloadURL(size: ImageSize, blur: BlurRadius? = nil, grayscale: Bool = false) -> URL {
            var url = switch size {
            case .original:
                downloadURL
            case .size(width: let width, height: let height):
                imageBaseURL
                    .appending(path: "\(width)")
                    .appending(path: "\(height)")
            }
            if let blur {
                url.append(queryItems: [.init(name: "blur", value: "\(blur.rawValue)")])
            }
            if grayscale {
                url.append(queryItems: [.init(name: "grayscale", value: nil)])
            }
            return url
        }
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
    string
        .matches(of: /<(?<url>[^;]+)>; rel="(?<rel>[^,]+)"/)
        .compactMap {
            (url: String($0.output.url), rel: String($0.output.rel))
        }
        .compactMap {
            Pagination(urlString: $0.url, relString: $0.rel)
        }
}
