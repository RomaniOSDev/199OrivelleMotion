import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published private(set) var greeting: String = ""
    @Published private(set) var recentTimeline: [TimelineItem] = []

    private let store: AppStorage

    init(store: AppStorage) {
        self.store = store
        refresh()
    }

    func refresh() {
        greeting = Self.greetingForCurrentTime()
        recentTimeline = Array(store.timelineItems().prefix(4))
    }

    var streakDays: Int { store.streakDays }
    var itemsCount: Int { store.itemsAdded }
    var favouritesCount: Int { store.favouritesCount }
    var albumsCount: Int { store.albums.count }
    var quickNotesCount: Int { store.quickNotes.count }
    var weeklyEntries: Int { store.weeklySummary().entryCount }
    var unlockedAchievements: Int {
        Achievement.all.filter { store.isAchievementUnlocked($0) }.count
    }
    var totalAchievements: Int { Achievement.all.count }

    private static func greetingForCurrentTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
}
