import SwiftUI

struct HomeView: View {
    @ObservedObject var store: AppStorage
    @Binding var selectedTab: MainTab
    @StateObject private var viewModel: HomeViewModel
    @State private var heroAppeared = false

    init(store: AppStorage, selectedTab: Binding<MainTab>) {
        self.store = store
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: HomeViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroSection
                        weeklyProgressWidget
                        statsWidgetRow
                        featuredWidgets
                        quickActionsSection
                        recentActivitySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .refreshable {
                HapticManager.lightTap()
                viewModel.refresh()
            }
            .onAppear {
                viewModel.refresh()
                withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                    heroAppeared = true
                }
            }
            .onChange(of: selectedTab) { tab in
                if tab == .home { viewModel.refresh() }
            }
            .onChange(of: store.itemsAdded) { _ in viewModel.refresh() }
            .onChange(of: store.streakDays) { _ in viewModel.refresh() }
            .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
                viewModel.refresh()
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .aspectRatio(16 / 9, contentMode: .fill)
                .frame(height: 168)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.1),
                    Color("AppBackground").opacity(0.55),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.greeting)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                HStack(spacing: 8) {
                    TagChipView(text: "\(viewModel.streakDays) day streak", isActive: true)
                    TagChipView(text: "\(viewModel.weeklyEntries) this week")
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppSurfaceFill.accentBorderGradient, lineWidth: 1.5)
        )
        .modifier(AppShadowModifier(elevation: .floating))
        .scaleEffect(heroAppeared ? 1 : 0.96)
        .opacity(heroAppeared ? 1 : 0)
    }

    // MARK: - Weekly Progress

    private var weeklyProgressWidget: some View {
        let summary = store.weeklySummary()
        let maxCount = max(summary.dailyCounts.values.max() ?? 1, 1)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionHeaderView(title: "This Week", trailing: "\(summary.entryCount) entries")
                Spacer(minLength: 0)
            }
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(days, id: \.self) { day in
                    let count = summary.dailyCounts[day] ?? 0
                    let isToday = calendar.isDateInToday(day)
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(
                                count > 0
                                    ? LinearGradient(colors: [Color("AppPrimary"), Color("AppAccent")], startPoint: .bottom, endPoint: .top)
                                    : LinearGradient(colors: [Color("AppBackground"), Color("AppBackground")], startPoint: .bottom, endPoint: .top)
                            )
                            .frame(height: max(8, CGFloat(count) / CGFloat(maxCount) * 48))
                        Text(day.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2.weight(isToday ? .bold : .regular))
                            .foregroundStyle(isToday ? Color("AppAccent") : Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 72)

            NavigationLink {
                WeeklyReviewView(store: store)
            } label: {
                HStack {
                    Text("Open weekly review")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(Color("AppAccent"))
            }
        }
        .appCard()
    }

    // MARK: - Stats Row

    private var statsWidgetRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            HomeStatWidget(
                icon: "tag.fill",
                value: "\(viewModel.itemsCount)",
                label: "Organized Items",
                accent: Color("AppPrimary")
            ) {
                navigate(to: .tags)
            }
            HomeStatWidget(
                icon: "heart.fill",
                value: "\(viewModel.favouritesCount)",
                label: "Favourites",
                accent: Color("AppAccent")
            ) {
                navigate(to: .media)
            }
            HomeStatWidget(
                icon: "folder.fill",
                value: "\(viewModel.albumsCount)",
                label: "Albums",
                accent: Color("AppAccent")
            ) {
                navigate(to: .insights)
            }
            HomeStatWidget(
                icon: "rosette",
                value: "\(viewModel.unlockedAchievements)/\(viewModel.totalAchievements)",
                label: "Achievements",
                accent: Color("AppPrimary")
            ) {
                navigate(to: .achievements)
            }
        }
    }

    // MARK: - Featured Image Widgets

    private var featuredWidgets: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Highlights")

            HStack(spacing: 12) {
                HomeImageWidget(
                    imageName: "HomeWidgetMemories",
                    title: "Your Vault",
                    subtitle: "\(viewModel.itemsCount) memories organized",
                    actionTitle: "Open Tags"
                ) {
                    navigate(to: .tags)
                }

                HomeImageWidget(
                    imageName: "HomeWidgetStreak",
                    title: "Stay Consistent",
                    subtitle: "\(viewModel.streakDays) day streak",
                    actionTitle: "View Calendar"
                ) {
                    navigate(to: .insights)
                }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                NavigationLink {
                    QuickNoteView(store: store)
                } label: {
                    HomeQuickActionLabel(icon: "bolt.fill", title: "Quick Note")
                }

                Button {
                    HapticManager.lightTap()
                    navigate(to: .tags)
                } label: {
                    HomeQuickActionLabel(icon: "plus.circle.fill", title: "Add Tag")
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    HapticManager.lightTap()
                    navigate(to: .media)
                } label: {
                    HomeQuickActionLabel(icon: "text.quote", title: "Caption")
                }
                .buttonStyle(PressableButtonStyle())

                NavigationLink {
                    GlobalSearchView(store: store)
                } label: {
                    HomeQuickActionLabel(icon: "magnifyingglass", title: "Search")
                }

                NavigationLink {
                    TimelineFeedView(store: store)
                } label: {
                    HomeQuickActionLabel(icon: "clock.arrow.circlepath", title: "Timeline")
                }

                Button {
                    HapticManager.lightTap()
                    navigate(to: .settings)
                } label: {
                    HomeQuickActionLabel(icon: "gearshape.fill", title: "Settings")
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .appCard(padding: 14)
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeaderView(title: "Recent Activity")
                Spacer()
                NavigationLink {
                    TimelineFeedView(store: store)
                } label: {
                    Text("See All")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                }
            }

            if viewModel.recentTimeline.isEmpty {
                HStack(spacing: 12) {
                    IconBadgeView(iconName: "sparkles", style: .accent, size: 40)
                    Text("Start by adding your first tag or caption.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .appCard(padding: 14)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.recentTimeline) { item in
                        HomeRecentRow(item: item)
                    }
                }
                .appCard(padding: 12)

                NavigationLink {
                    TimelineFeedView(store: store)
                } label: {
                    Text("View full timeline")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
            }
        }
    }

    private func navigate(to tab: MainTab) {
        HapticManager.lightTap()
        SoundManager.playTick()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedTab = tab
        }
    }
}

// MARK: - Home Stat Widget

private struct HomeStatWidget: View {
    let icon: String
    let value: String
    let label: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accent)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
                }
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(AppSurfaceShape(cornerRadius: 18, elevation: .raised))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(accent.opacity(0.28), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Image Widget

private struct HomeImageWidget: View {
    let imageName: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            ZStack(alignment: .bottomLeading) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .clipped()

                LinearGradient(
                    colors: [Color.clear, Color("AppBackground").opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                    Text(actionTitle)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppSurfaceFill.borderGradient, lineWidth: 1)
            )
            .modifier(AppShadowModifier(elevation: .raised))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Quick Action Label

private struct HomeQuickActionLabel: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppSurface"), Color("AppBackground").opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Recent Row

private struct HomeRecentRow: View {
    let item: TimelineItem

    var body: some View {
        HStack(spacing: 12) {
            IconBadgeView(iconName: item.type.iconName, style: .muted, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text(item.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            TagChipView(text: item.type.label, isActive: true)
        }
        .padding(.vertical, 4)
    }
}
