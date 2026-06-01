import SwiftUI

struct MediaThumbnailView: View {
    let iconName: String
    let accentHue: Double
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hue: accentHue, saturation: 0.55, brightness: 0.45),
                            Color(hue: accentHue + 0.05, saturation: 0.65, brightness: 0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.2, style: .continuous)
                        .stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
                )
            Image(systemName: iconName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(Color("AppTextPrimary").opacity(0.92))
        }
        .frame(width: size, height: size)
        .modifier(AppShadowModifier(elevation: .raised))
    }
}

struct EmptyStateView: View {
    let symbolName: String
    let title: String
    let subtitle: String
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppSurfaceFill.gradient(accentHighlight: true))
                    .frame(width: 100, height: 100)
                Circle()
                    .stroke(AppSurfaceFill.accentBorderGradient, lineWidth: 2)
                    .frame(width: 100, height: 100)
                Image(systemName: symbolName)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color("AppAccent"))
            }
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0.5)
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

struct StatsSummaryCard: View {
    let itemsAdded: Int
    let entriesWritten: Int
    let favouritesCount: Int
    let streakDays: Int
    let totalMinutesUsed: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Summary", trailing: "\(itemsAdded) total")
            StatsGridView(metrics: [
                (value: "\(entriesWritten)", label: "Entries", icon: "doc.text.fill"),
                (value: "\(favouritesCount)", label: "Favourites", icon: "heart.fill"),
                (value: "\(streakDays)", label: "Day Streak", icon: "flame.fill"),
                (value: "\(totalMinutesUsed)", label: "Minutes", icon: "clock.fill")
            ])
        }
        .appCard()
    }
}

struct ScreenHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}
