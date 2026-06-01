import SwiftUI

// MARK: - Elevation (performance: flat = scroll lists, raised/floating = static UI)

enum AppElevation {
    /// Gradient + border only — use in List / LazyVStack while scrolling.
    case flat
    /// Single soft shadow — cards on screen.
    case raised
    /// Slightly stronger shadow — hero, tab bar, primary CTA.
    case floating
}

// MARK: - Surface fill (no Color extension — asset colors only)

enum AppSurfaceFill {
    static func gradient(accentHighlight: Bool = false) -> LinearGradient {
        if accentHighlight {
            return LinearGradient(
                colors: [
                    Color("AppSurface"),
                    Color("AppAccent").opacity(0.12),
                    Color("AppBackground").opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.94),
                Color("AppBackground").opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextPrimary").opacity(0.14),
                Color("AppTextSecondary").opacity(0.06),
                Color("AppBackground").opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentBorderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent").opacity(0.55),
                Color("AppPrimary").opacity(0.25),
                Color("AppTextSecondary").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Reusable surface shape

struct AppSurfaceShape: View {
    var cornerRadius: CGFloat = 18
    var elevation: AppElevation = .raised
    var accentBorder: Bool = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        shape
            .fill(AppSurfaceFill.gradient(accentHighlight: accentBorder))
            .overlay(
                shape.stroke(
                    accentBorder ? AppSurfaceFill.accentBorderGradient : AppSurfaceFill.borderGradient,
                    lineWidth: accentBorder ? 1.5 : 1
                )
            )
            .modifier(AppShadowModifier(elevation: elevation))
    }
}

/// Lightweight row background for `List` — no shadow.
struct ListRowSurface: View {
    var cornerRadius: CGFloat = 18

    var body: some View {
        AppSurfaceShape(cornerRadius: cornerRadius, elevation: .flat)
    }
}

struct AppShadowModifier: ViewModifier {
    let elevation: AppElevation

    func body(content: Content) -> some View {
        switch elevation {
        case .flat:
            content
        case .raised:
            content.shadow(color: Color("AppBackground").opacity(0.45), radius: 6, x: 0, y: 3)
        case .floating:
            content.shadow(color: Color("AppBackground").opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - View modifiers

struct AppCardModifier: ViewModifier {
    var elevation: AppElevation = .raised
    var accentBorder: Bool = false
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                AppSurfaceShape(cornerRadius: 18, elevation: elevation, accentBorder: accentBorder)
            )
    }
}

struct AppNavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(
                LinearGradient(
                    colors: [Color("AppBackground"), Color("AppSurface").opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func appCard(
        elevation: AppElevation = .raised,
        accentBorder: Bool = false,
        padding: CGFloat = 16
    ) -> some View {
        modifier(AppCardModifier(elevation: elevation, accentBorder: accentBorder, padding: padding))
    }

    func appNavigationChrome() -> some View {
        modifier(AppNavigationBarModifier())
    }

    func appListRowInsets() -> some View {
        listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
            .appListRowBackground()
    }

    func appListRowBackground() -> some View {
        listRowBackground(ListRowSurface().padding(.vertical, 3))
    }

    /// Inline content inside a list row — gradient only, no shadow.
    func appInlineCard(contentPadding: CGFloat = 12) -> some View {
        padding(contentPadding)
            .background(AppSurfaceShape(cornerRadius: 16, elevation: .flat))
    }
}
