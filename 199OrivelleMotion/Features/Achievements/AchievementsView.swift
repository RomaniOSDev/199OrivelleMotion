import SwiftUI

struct AchievementsView: View {
    @ObservedObject var store: AppStorage
    @StateObject private var viewModel: AchievementsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(store: AppStorage) {
        self.store = store
        _viewModel = StateObject(wrappedValue: AchievementsViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        StatsSummaryCard(
                            itemsAdded: store.itemsAdded,
                            entriesWritten: store.entriesWritten,
                            favouritesCount: store.favouritesCount,
                            streakDays: store.streakDays,
                            totalMinutesUsed: store.totalMinutesUsed
                        )

                        SectionHeaderView(
                            title: "Achievements",
                            trailing: "\(viewModel.unlockedCount)/\(viewModel.achievements.count)"
                        )

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.achievements) { achievement in
                                AchievementCell(
                                    achievement: achievement,
                                    isUnlocked: viewModel.isUnlocked(achievement)
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
        }
    }
}
