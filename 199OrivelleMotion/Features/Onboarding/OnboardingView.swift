import SwiftUI

// MARK: - Onboarding

struct OnboardingView: View {
    @ObservedObject var store: AppStorage
    @State private var currentPage = 0

    private var pages: [OnboardingPage] { OnboardingPage.allCases }
    private var isLastPage: Bool { currentPage == pages.count - 1 }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                onboardingTopBar
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                bottomBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Top Bar

    private var onboardingTopBar: some View {
        HStack(alignment: .center) {
            TagChipView(text: "Step \(currentPage + 1) of \(pages.count)", isActive: true)
            Spacer()
            Text(pages[currentPage].badge)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
        }
    }

    // MARK: - Page

    private func onboardingPage(page: OnboardingPage, index: Int) -> some View {
        let isActive = currentPage == index

        return VStack(spacing: 28) {
            Spacer(minLength: 4)

            ZStack {
                AppSurfaceShape(cornerRadius: 28, elevation: isActive ? .floating : .raised, accentBorder: isActive)
                    .frame(width: 240, height: 240)

                page.illustration
                    .frame(width: 200, height: 200)
            }
            .scaleEffect(isActive ? 1 : 0.9)
            .opacity(isActive ? 1 : 0.55)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: currentPage)

            VStack(spacing: 14) {
                IconBadgeView(iconName: page.iconName, style: .accent, size: 52)

                Text(page.headline)
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity)
            .background(
                AppSurfaceShape(
                    cornerRadius: 22,
                    elevation: .raised,
                    accentBorder: isActive
                )
            )
            .padding(.horizontal, 20)

            Spacer(minLength: 8)
        }
    }

    // MARK: - Bottom

    private var bottomBar: some View {
        VStack(spacing: 20) {
            pageIndicator

            PrimaryActionButton(title: isLastPage ? "Get Started" : "Next") {
                advance()
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(indicatorFill(isSelected: index == currentPage))
                    .frame(width: index == currentPage ? 32 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentPage)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppSurfaceShape(cornerRadius: 18, elevation: .flat))
    }

    private func indicatorFill(isSelected: Bool) -> LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [Color("AppPrimary"), Color("AppAccent")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        return LinearGradient(
            colors: [
                Color("AppTextSecondary").opacity(0.35),
                Color("AppTextSecondary").opacity(0.2)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func advance() {
        HapticManager.lightTap()
        if isLastPage {
            store.hasSeenOnboarding = true
            store.beginSession()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }
}

// MARK: - Page Model

private enum OnboardingPage: Int, CaseIterable {
    case organize
    case capture
    case journey

    var headline: String {
        switch self {
        case .organize: return "Get Organized"
        case .capture: return "Capture Memories"
        case .journey: return "Start Your Journey"
        }
    }

    var description: String {
        switch self {
        case .organize:
            return "Discover how this app helps you organize your media files effectively."
        case .capture:
            return "Tag your photos with notes to capture the moment's essence."
        case .journey:
            return "Begin organizing your first photo collection now."
        }
    }

    var iconName: String {
        switch self {
        case .organize: return "square.grid.2x2.fill"
        case .capture: return "photo.on.rectangle.angled"
        case .journey: return "flag.fill"
        }
    }

    var badge: String {
        switch self {
        case .organize: return "Organize"
        case .capture: return "Memories"
        case .journey: return "Begin"
        }
    }

    @ViewBuilder
    var illustration: some View {
        switch self {
        case .organize: OrganizeIllustration()
        case .capture: CaptureIllustration()
        case .journey: JourneyIllustration()
        }
    }
}

// MARK: - Illustrations

private struct OrganizeIllustration: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                tagBar(width: 44, primary: true)
                tagBar(width: 32, primary: false)
            }
            HStack(spacing: 10) {
                tagBar(width: 56, primary: false)
                tagBar(width: 24, primary: true)
            }
            HStack(spacing: 10) {
                tagBar(width: 38, primary: true)
                tagBar(width: 48, primary: false)
            }
            HStack(spacing: 8) {
                IconBadgeView(iconName: "tag.fill", style: .accent, size: 36)
                IconBadgeView(iconName: "folder.fill", style: .primary, size: 36)
                IconBadgeView(iconName: "heart.fill", style: .muted, size: 36)
            }
            .padding(.top, 4)
        }
        .scaleEffect(appeared ? 1 : 0.75)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }

    private func tagBar(width: CGFloat, primary: Bool) -> some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(
                LinearGradient(
                    colors: primary
                        ? [Color("AppPrimary"), Color("AppAccent").opacity(0.85)]
                        : [Color("AppAccent").opacity(0.7), Color("AppPrimary").opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: 10)
    }
}

private struct CaptureIllustration: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.35), Color("AppBackground").opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 96)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppSurfaceFill.borderGradient, lineWidth: 1)
                )

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Color("AppTextPrimary").opacity(0.9))

            ZStack {
                Circle()
                    .fill(AppSurfaceFill.gradient(accentHighlight: true))
                    .frame(width: 52, height: 52)
                Circle()
                    .stroke(AppSurfaceFill.accentBorderGradient, lineWidth: 1.5)
                    .frame(width: 52, height: 52)
                Image(systemName: "pencil.line")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
            .offset(x: 58, y: 48)
            .modifier(AppShadowModifier(elevation: .raised))
        }
        .scaleEffect(appeared ? 1 : 0.75)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }
}

private struct JourneyIllustration: View {
    @State private var appeared = false
    @State private var pathProgress: CGFloat = 0

    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 24, y: 110))
                path.addCurve(
                    to: CGPoint(x: 176, y: 36),
                    control1: CGPoint(x: 64, y: 24),
                    control2: CGPoint(x: 128, y: 88)
                )
            }
            .trim(from: 0, to: pathProgress)
            .stroke(
                LinearGradient(
                    colors: [Color("AppPrimary"), Color("AppAccent")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 18, height: 18)
                Circle()
                    .stroke(Color("AppTextPrimary").opacity(0.2), lineWidth: 1)
                    .frame(width: 18, height: 18)
            }
            .offset(x: -72, y: 58)

            ZStack {
                AppSurfaceShape(cornerRadius: 12, elevation: .raised, accentBorder: true)
                    .frame(width: 44, height: 44)
                Image(systemName: "flag.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            }
            .offset(x: 68, y: -36)
        }
        .frame(width: 200, height: 140)
        .scaleEffect(appeared ? 1 : 0.75)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.1).delay(0.15)) {
                pathProgress = 1
            }
        }
    }
}
