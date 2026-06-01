import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case home
    case tags
    case media
    case insights
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .tags: return "Tags"
        case .media: return "Media"
        case .insights: return "Insights"
        case .achievements: return "Progress"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .tags: return "tag.fill"
        case .media: return "photo.on.rectangle.angled"
        case .insights: return "chart.bar.fill"
        case .achievements: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    var bottomInset: CGFloat = 0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(MainTab.allCases) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.top, 10)
        .padding(.bottom, 10 + bottomInset)
        .background {
            tabBarBackground
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var tabBarBackground: some View {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppBackground")],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppSurfaceFill.borderGradient)
                .frame(height: 1)
        }
        .modifier(AppShadowModifier(elevation: .floating))
    }

    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            HapticManager.lightTap()
            SoundManager.playTick()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.iconName)
                    .font(.system(size: isSelected ? 18 : 16, weight: .semibold))
                if isSelected {
                    Text(tab.title)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                }
            }
            .frame(minWidth: isSelected ? 64 : 48)
            .padding(.horizontal, isSelected ? 12 : 8)
            .padding(.vertical, 8)
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color("AppPrimary") : Color.clear)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(tab.title)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.headline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
                )
                .modifier(AppShadowModifier(elevation: .floating))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
