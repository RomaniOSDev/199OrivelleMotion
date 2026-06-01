import Foundation

struct Caption: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var text: String
    var date: Date
    var tags: [String]
    var isPinned: Bool
    var isArchived: Bool
    var accessCount: Int
    var albumID: UUID?
    var relatedMemoryIDs: [UUID]
    var relatedFavouriteIDs: [String]

    init(
        id: UUID = UUID(),
        text: String,
        date: Date = Date(),
        tags: [String] = [],
        isPinned: Bool = false,
        isArchived: Bool = false,
        accessCount: Int = 0,
        albumID: UUID? = nil,
        relatedMemoryIDs: [UUID] = [],
        relatedFavouriteIDs: [String] = []
    ) {
        self.id = id
        self.text = text
        self.date = date
        self.tags = tags
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.accessCount = accessCount
        self.albumID = albumID
        self.relatedMemoryIDs = relatedMemoryIDs
        self.relatedFavouriteIDs = relatedFavouriteIDs
    }

    enum CodingKeys: String, CodingKey {
        case id, text, date, tags
        case isPinned, isArchived, accessCount, albumID
        case relatedMemoryIDs, relatedFavouriteIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        date = try container.decode(Date.self, forKey: .date)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        accessCount = try container.decodeIfPresent(Int.self, forKey: .accessCount) ?? 0
        albumID = try container.decodeIfPresent(UUID.self, forKey: .albumID)
        relatedMemoryIDs = try container.decodeIfPresent([UUID].self, forKey: .relatedMemoryIDs) ?? []
        relatedFavouriteIDs = try container.decodeIfPresent([String].self, forKey: .relatedFavouriteIDs) ?? []
    }
}
