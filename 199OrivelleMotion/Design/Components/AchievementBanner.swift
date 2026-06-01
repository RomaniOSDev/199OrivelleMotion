import SwiftUI

struct AchievementBannerView: View {
    let achievement: Achievement
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundStyle(Color("AppAccent"))
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
        }
        .padding(16)
        .background(AppSurfaceShape(cornerRadius: 16, elevation: .floating, accentBorder: true))
        .padding(.horizontal, 16)
    }
}

struct AchievementBannerContainer: View {
    @ObservedObject var store: AppStorage
    @State private var currentBanner: Achievement?
    @State private var showBanner = false

    var body: some View {
        VStack {
            if showBanner, let achievement = currentBanner {
                AchievementBannerView(achievement: achievement, isVisible: $showBanner)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showBanner)
        .onChange(of: store.pendingAchievementBanners.count) { _ in
            presentNextBannerIfNeeded()
        }
        .onAppear {
            presentNextBannerIfNeeded()
        }
    }

    private func presentNextBannerIfNeeded() {
        guard !showBanner, currentBanner == nil else { return }
        guard let next = store.dequeueNextBanner() else { return }
        currentBanner = next
        HapticManager.success()
        SoundManager.playSuccess()
        withAnimation {
            showBanner = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showBanner = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                currentBanner = nil
                presentNextBannerIfNeeded()
            }
        }
    }
}

struct SuccessCheckmarkOverlay: View {
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
        }
    }

    static func trigger(isShowing: Binding<Bool>) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isShowing.wrappedValue = true
        }
        HapticManager.success()
        SoundManager.playSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isShowing.wrappedValue = false
            }
        }
    }
}

struct PulseHighlightModifier: ViewModifier {
    @Binding var isPulsing: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPulsing ? Color("AppAccent").opacity(0.35) : Color.clear)
            )
            .animation(.easeInOut(duration: 0.4), value: isPulsing)
    }
}

extension View {
    func pulseHighlight(isPulsing: Binding<Bool>) -> some View {
        modifier(PulseHighlightModifier(isPulsing: isPulsing))
    }
}
