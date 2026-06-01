import Foundation

enum ActivityType: String, Codable {
    case memory
    case caption
    case favourite
    case quickNote
    case album
    case collection
}

struct ActivityRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let type: ActivityType
    let title: String
    let referenceID: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        type: ActivityType,
        title: String,
        referenceID: String
    ) {
        self.id = id
        self.date = date
        self.type = type
        self.title = title
        self.referenceID = referenceID
    }
}
