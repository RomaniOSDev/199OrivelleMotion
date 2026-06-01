import SwiftUI

struct MainTabView: View {
    @ObservedObject var store: AppStorage
    @State private var selectedTab: MainTab = .home
    @Environment(\.scenePhase) private var scenePhase

    private let tabBarHeight: CGFloat = 56

    var body: some View {
        GeometryReader { geometry in
            let bottomInset = geometry.safeAreaInsets.bottom
            let tabBarTotalHeight = tabBarHeight + bottomInset

            ZStack(alignment: .bottom) {
                AppBackgroundView()

                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, tabBarTotalHeight)

                CustomTabBar(selectedTab: $selectedTab, bottomInset: bottomInset)

                AchievementBannerContainer(store: store)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
        .preferredColorScheme(.dark)
        .onAppear {
            store.beginSession()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.beginSession()
            case .background, .inactive:
                store.endSession()
            @unknown default:
                break
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView(store: store, selectedTab: $selectedTab)
        case .tags:
            MemoryTagsView(store: store)
        case .media:
            MediaHubView(store: store)
        case .insights:
            InsightsHubView(store: store)
        case .achievements:
            AchievementsView(store: store)
        case .settings:
            SettingsView(store: store)
        }
    }
}
