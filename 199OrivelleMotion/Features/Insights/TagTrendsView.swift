import SwiftUI
import Charts

struct TagTrendsView: View {
    @ObservedObject var store: AppStorage

    private var trends: [TagTrend] { store.tagTrends() }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if trends.isEmpty {
                EmptyStateView(
                    symbolName: "chart.bar",
                    title: "No Tag Data",
                    subtitle: "Add tags and captions to see trends."
                )
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        Chart(trends.prefix(8)) { trend in
                            BarMark(
                                x: .value("Count", trend.count),
                                y: .value("Tag", trend.tag)
                            )
                            .foregroundStyle(Color("AppAccent"))
                            .cornerRadius(4)
                        }
                        .chartXAxis {
                            AxisMarks { _ in
                                AxisValueLabel()
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                        .chartYAxis {
                            AxisMarks { _ in
                                AxisValueLabel()
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                        .frame(height: CGFloat(min(trends.count, 8)) * 36 + 40)
                        .padding(16)
                        .background(Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        VStack(spacing: 8) {
                            ForEach(trends) { trend in
                                HStack {
                                    Text(trend.tag)
                                        .font(.subheadline)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Spacer()
                                    Text("\(trend.count)")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color("AppSurface"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Tag Trends")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }
}
