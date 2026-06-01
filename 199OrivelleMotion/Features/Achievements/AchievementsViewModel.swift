import Foundation
import Combine

final class AchievementsViewModel: ObservableObject {
    @Published private(set) var achievements: [Achievement] = Achievement.all

    private let store: AppStorage

    init(store: AppStorage) {
        self.store = store
    }

    func isUnlocked(_ achievement: Achievement) -> Bool {
        store.isAchievementUnlocked(achievement)
    }

    func unlockDate(for achievement: Achievement) -> Date? {
        store.unlockDate(for: achievement)
    }

    var unlockedCount: Int {
        achievements.filter { isUnlocked($0) }.count
    }
}
