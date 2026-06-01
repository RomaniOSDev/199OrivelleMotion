import SwiftUI

struct StreakCalendarView: View {
    @ObservedObject var store: AppStorage
    @State private var displayedMonth = Date()

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        metricBlock(value: "\(store.streakDays)", label: "Current Streak")
                        metricBlock(value: "\(store.activeDaysInMonth(displayedMonth))", label: "Active This Month")
                        metricBlock(value: "\(store.activeDays.count)", label: "Total Active Days")
                    }

                    VStack(spacing: 12) {
                        HStack {
                            Button {
                                HapticManager.lightTap()
                                displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(Color("AppAccent"))
                                    .frame(width: 44, height: 44)
                            }
                            Spacer()
                            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                            Button {
                                HapticManager.lightTap()
                                displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color("AppAccent"))
                                    .frame(width: 44, height: 44)
                            }
                        }

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(weekdaySymbols, id: \.self) { symbol in
                                Text(symbol)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            ForEach(calendarDays, id: \.self) { day in
                                dayCell(day)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
            }
        }
        .navigationTitle("Streak Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }

    private func metricBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("AppAccent"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmpty = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        return days
    }

    private func dayCell(_ day: Date?) -> some View {
        Group {
            if let day {
                let isActive = store.activeDays.contains(where: { Calendar.current.isDate($0, inSameDayAs: day) })
                let isToday = Calendar.current.isDateInToday(day)
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.caption.weight(isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        Circle()
                            .fill(isActive ? Color("AppPrimary") : (isToday ? Color("AppSurface") : Color.clear))
                    )
                    .overlay(
                        Circle().stroke(isToday && !isActive ? Color("AppAccent") : Color.clear, lineWidth: 1)
                    )
            } else {
                Color.clear.frame(height: 36)
            }
        }
    }
}
