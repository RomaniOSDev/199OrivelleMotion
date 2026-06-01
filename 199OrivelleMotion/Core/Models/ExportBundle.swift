import Foundation

struct ExportBundle: Codable {
    let exportedAt: Date
    let version: Int
    let memoryEntries: [MemoryEntry]
    let captions: [Caption]
    let albums: [Album]
    let quickNotes: [QuickNote]
    let customCollections: [CustomCollection]
    let favourites: [String]
    let userNotes: [String: String]
    let favouriteRatings: [String: Int]
    let activityLog: [ActivityRecord]

    static let currentVersion = 1
}
