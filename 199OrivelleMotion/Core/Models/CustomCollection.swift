import Foundation

struct CustomCollection: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var emoji: String
    var favouriteIDs: [String]
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "⭐",
        favouriteIDs: [String] = [],
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.favouriteIDs = favouriteIDs
        self.notes = notes
        self.createdAt = createdAt
    }
}
