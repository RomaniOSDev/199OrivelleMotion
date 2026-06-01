import Foundation

struct MemoryEntry: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var emoji: String
    var notes: String
    var tag: String
    var createdAt: Date
    var isPinned: Bool
    var isArchived: Bool
    var accessCount: Int
    var albumID: UUID?
    var relatedCaptionIDs: [UUID]
    var relatedFavouriteIDs: [String]

    init(
        id: UUID = UUID(),
        title: String,
        emoji: String,
        notes: String,
        tag: String = "General",
        createdAt: Date = Date(),
        isPinned: Bool = false,
        isArchived: Bool = false,
        accessCount: Int = 0,
        albumID: UUID? = nil,
        relatedCaptionIDs: [UUID] = [],
        relatedFavouriteIDs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.notes = notes
        self.tag = tag
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.accessCount = accessCount
        self.albumID = albumID
        self.relatedCaptionIDs = relatedCaptionIDs
        self.relatedFavouriteIDs = relatedFavouriteIDs
    }

    enum CodingKeys: String, CodingKey {
        case id, title, emoji, notes, tag, createdAt
        case isPinned, isArchived, accessCount, albumID
        case relatedCaptionIDs, relatedFavouriteIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        emoji = try container.decode(String.self, forKey: .emoji)
        notes = try container.decode(String.self, forKey: .notes)
        tag = try container.decode(String.self, forKey: .tag)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        accessCount = try container.decodeIfPresent(Int.self, forKey: .accessCount) ?? 0
        albumID = try container.decodeIfPresent(UUID.self, forKey: .albumID)
        relatedCaptionIDs = try container.decodeIfPresent([UUID].self, forKey: .relatedCaptionIDs) ?? []
        relatedFavouriteIDs = try container.decodeIfPresent([String].self, forKey: .relatedFavouriteIDs) ?? []
    }
}
