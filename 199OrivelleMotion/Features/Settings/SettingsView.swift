import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: AppStorage
    @StateObject private var viewModel: SettingsViewModel

    init(store: AppStorage) {
        self.store = store
        _viewModel = StateObject(wrappedValue: SettingsViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeaderView(title: "Your Stats")
                            StatsGridView(metrics: [
                                (value: "\(viewModel.totalEntriesCreated)", label: "Entries", icon: "doc.text.fill"),
                                (value: "\(viewModel.totalMinutesUsed)", label: "Minutes", icon: "clock.fill"),
                                (value: "\(viewModel.currentStreak)", label: "Streak", icon: "flame.fill")
                            ])
                        }
                        .appCard()

                        VStack(spacing: 0) {
                            settingsButton(title: "Rate Us", icon: "star.fill") {
                                viewModel.rateApp()
                            }
                            settingsDivider
                            settingsButton(title: "Privacy", icon: "hand.raised.fill") {
                                viewModel.openExternalLink(.privacyPolicy)
                            }
                            settingsDivider
                            settingsButton(title: "Terms", icon: "doc.text.fill") {
                                viewModel.openExternalLink(.termsOfUse)
                            }
                            settingsDivider
                            settingsButton(title: "Support", icon: "envelope.fill") {
                                viewModel.openSupport()
                            }
                            settingsDivider
                            NavigationLink {
                                ExportImportView(store: store)
                            } label: {
                                SettingsRowCell(title: "Export / Import", icon: "square.and.arrow.up")
                            }
                            .buttonStyle(.plain)
                            settingsDivider
                            Button {
                                HapticManager.lightTap()
                                viewModel.showResetAlert = true
                            } label: {
                                SettingsRowCell(title: "Reset All Data", icon: "trash.fill", isDestructive: true, showChevron: false)
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                        .appCard(padding: 0)

                        Text("Version \(viewModel.appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .alert("Reset All Data?", isPresented: $viewModel.showResetAlert) {
                Button("Cancel", role: .cancel) { HapticManager.lightTap() }
                Button("Reset", role: .destructive) { viewModel.resetAllData() }
            } message: {
                Text("This will permanently delete all your data. This action cannot be undone.")
            }
        }
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(Color("AppBackground").opacity(0.5))
            .frame(height: 1)
            .padding(.leading, 70)
    }

    private func settingsButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            SettingsRowCell(title: title, icon: icon)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

