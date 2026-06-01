import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppBackground"),
                    Color("AppSurface").opacity(0.35),
                    Color("AppBackground")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color("AppPrimary").opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 320
            )

            StaticDotPatternView()
                .opacity(0.12)
        }
        .ignoresSafeArea()
        .drawingGroup(opaque: false)
    }
}

/// Drawn once per screen via `drawingGroup` on parent — cheaper than per-frame Canvas in scroll.
private struct StaticDotPatternView: View {
    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 44
            let cols = Int(proxy.size.width / spacing) + 2
            let rows = Int(proxy.size.height / spacing) + 2
            Canvas { context, _ in
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * spacing
                        let y = CGFloat(row) * spacing
                        let rect = CGRect(x: x, y: y, width: 2, height: 2)
                        context.fill(Path(ellipseIn: rect), with: .color(Color("AppTextSecondary").opacity(0.35)))
                    }
                }
            }
        }
    }
}
