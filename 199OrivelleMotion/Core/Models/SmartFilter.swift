import Foundation

enum SmartFilter: String, CaseIterable, Identifiable {
    case all
    case last7Days
    case withNotes
    case favouritesOnly
    case pinnedOnly
    case archived
    case byTag

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .last7Days: return "Last 7 Days"
        case .withNotes: return "With Notes"
        case .favouritesOnly: return "Favourites"
        case .pinnedOnly: return "Pinned"
        case .archived: return "Archived"
        case .byTag: return "By Tag"
        }
    }

    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .last7Days: return "calendar"
        case .withNotes: return "note.text"
        case .favouritesOnly: return "heart.fill"
        case .pinnedOnly: return "pin.fill"
        case .archived: return "archivebox.fill"
        case .byTag: return "tag.fill"
        }
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case dateNewest
    case dateOldest
    case alphabetical
    case frequency

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateNewest: return "Newest First"
        case .dateOldest: return "Oldest First"
        case .alphabetical: return "A–Z"
        case .frequency: return "Most Used"
        }
    }
}
