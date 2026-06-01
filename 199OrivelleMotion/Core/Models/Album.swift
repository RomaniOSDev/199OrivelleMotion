import Foundation

struct Album: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var emoji: String
    var createdAt: Date
    var memoryEntryIDs: [UUID]
    var captionIDs: [UUID]

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "📁",
        createdAt: Date = Date(),
        memoryEntryIDs: [UUID] = [],
        captionIDs: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.createdAt = createdAt
        self.memoryEntryIDs = memoryEntryIDs
        self.captionIDs = captionIDs
    }

    var itemCount: Int {
        memoryEntryIDs.count + captionIDs.count
    }
}
