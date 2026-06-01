import SwiftUI

struct WeeklyReviewView: View {
    @ObservedObject var store: AppStorage

    private var summary: WeeklySummary { store.weeklySummary() }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    StatsGridView(metrics: [
                        (value: "\(summary.entryCount)", label: "Entries This Week", icon: "doc.text.fill"),
                        (value: "\(summary.activeDays)", label: "Active Days", icon: "flame.fill")
                    ])
                    .appCard()

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeaderView(title: "Daily Activity")
                        weekDayBars
                    }
                    .appCard()

                    if !summary.topTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(title: "Top Tags")
                            ForEach(summary.topTags) { trend in
                                HStack {
                                    TagChipView(text: trend.tag, isActive: true)
                                    Spacer()
                                    Text("\(trend.count)")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .appCard()
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("This Week")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }

    private var weekDayBars: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }
        let maxCount = max(summary.dailyCounts.values.max() ?? 1, 1)

        return HStack(alignment: .bottom, spacing: 8) {
            ForEach(days, id: \.self) { day in
                let count = summary.dailyCounts[day] ?? 0
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            count > 0
                                ? LinearGradient(colors: [Color("AppPrimary"), Color("AppAccent")], startPoint: .bottom, endPoint: .top)
                                : LinearGradient(colors: [Color("AppBackground"), Color("AppBackground")], startPoint: .bottom, endPoint: .top)
                        )
                        .frame(height: max(10, CGFloat(count) / CGFloat(maxCount) * 64))
                    Text(day.formatted(.dateTime.weekday(.abbreviated)))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 96)
    }
}
