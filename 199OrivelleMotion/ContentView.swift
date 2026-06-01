import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStorage.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView(store: store)
            } else {
                OnboardingView(store: store)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
