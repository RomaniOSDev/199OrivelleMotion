import Foundation

enum TimelineItemType: String {
    case memory
    case caption
    case favourite
    case quickNote
    case album
    case collection

    var iconName: String {
        switch self {
        case .memory: return "tag.fill"
        case .caption: return "text.quote"
        case .favourite: return "heart.fill"
        case .quickNote: return "bolt.fill"
        case .album: return "folder.fill"
        case .collection: return "square.stack.fill"
        }
    }

    var label: String {
        switch self {
        case .memory: return "Tag"
        case .caption: return "Caption"
        case .favourite: return "Favourite"
        case .quickNote: return "Quick Note"
        case .album: return "Album"
        case .collection: return "Collection"
        }
    }
}

struct TimelineItem: Identifiable, Equatable {
    let id: String
    let date: Date
    let type: TimelineItemType
    let title: String
    let subtitle: String
    let referenceID: String
}

struct TagTrend: Identifiable, Equatable {
    let id: String
    let tag: String
    let count: Int
}

struct WeeklySummary: Equatable {
    let entryCount: Int
    let activeDays: Int
    let topTags: [TagTrend]
    let dailyCounts: [Date: Int]
}

struct SearchResult: Identifiable, Equatable {
    let id: String
    let type: TimelineItemType
    let title: String
    let subtitle: String
    let referenceID: String
    let date: Date
}
