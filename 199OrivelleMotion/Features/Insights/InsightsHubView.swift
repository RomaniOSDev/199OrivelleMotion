import SwiftUI

struct InsightsHubView: View {
    @ObservedObject var store: AppStorage

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                CardListContainer {
                    ScreenHeaderView(
                        title: "Discover",
                        subtitle: "Search, analyze and organize your content"
                    )

                    NavigationLink {
                        GlobalSearchView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "magnifyingglass",
                            title: "Global Search",
                            subtitle: "Search tags, captions and favourites"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        QuickNoteView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "bolt.fill",
                            title: "Quick Note",
                            subtitle: "Capture a thought in one line"
                        )
                    }
                    .buttonStyle(.plain)

                    SectionHeaderView(title: "Analytics")
                        .padding(.top, 8)

                    NavigationLink {
                        WeeklyReviewView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "calendar.badge.clock",
                            title: "This Week",
                            subtitle: "Weekly activity overview",
                            badge: "\(store.weeklySummary().entryCount)"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        TimelineFeedView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "clock.arrow.circlepath",
                            title: "Timeline",
                            subtitle: "All activity by date"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        TagTrendsView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "chart.bar.fill",
                            title: "Tag Trends",
                            subtitle: "Most used themes"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        StreakCalendarView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "flame.fill",
                            title: "Streak Calendar",
                            subtitle: "Track your active days",
                            badge: "\(store.streakDays)d"
                        )
                    }
                    .buttonStyle(.plain)

                    SectionHeaderView(title: "Organize")
                        .padding(.top, 8)

                    NavigationLink {
                        AlbumsView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "folder.fill",
                            title: "Albums",
                            subtitle: "Group tags and captions",
                            badge: "\(store.albums.count)"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ExportImportView(store: store)
                    } label: {
                        HubNavigationCell(
                            icon: "square.and.arrow.up",
                            title: "Export / Import",
                            subtitle: "Backup and restore JSON data"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
        }
    }
}
