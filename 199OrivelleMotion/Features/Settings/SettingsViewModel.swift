import Foundation
import Combine
import UIKit
import StoreKit

final class SettingsViewModel: ObservableObject {
    @Published var showResetAlert = false

    private let store: AppStorage

    init(store: AppStorage) {
        self.store = store
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var totalEntriesCreated: Int {
        store.itemsAdded
    }

    var totalMinutesUsed: Int {
        store.totalMinutesUsed
    }

    var currentStreak: Int {
        store.streakDays
    }

    func openExternalLink(_ link: AppExternalLink) {
        HapticManager.lightTap()
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    func rateApp() {
        HapticManager.lightTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func openSupport() {
        HapticManager.lightTap()
        if let url = URL(string: "mailto:support@example.com") {
            UIApplication.shared.open(url)
        }
    }

    func resetAllData() {
        HapticManager.mediumTap()
        store.resetAllData()
    }
}
