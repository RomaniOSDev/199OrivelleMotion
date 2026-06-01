import SwiftUI

struct TimelineFeedView: View {
    @ObservedObject var store: AppStorage

    private var items: [TimelineItem] {
        store.timelineItems()
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if items.isEmpty {
                EmptyStateView(
                    symbolName: "clock",
                    title: "No Activity Yet",
                    subtitle: "Your timeline will appear as you add content."
                )
            } else {
                CardListContainer(spacing: 4) {
                    SectionHeaderView(title: "Activity Feed", trailing: "\(items.count)")
                    ForEach(items) { item in
                        TimelineCell(item: item)
                    }
                }
            }
        }
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }
}
