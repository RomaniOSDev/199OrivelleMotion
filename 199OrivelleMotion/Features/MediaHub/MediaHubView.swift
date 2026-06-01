import SwiftUI

enum MediaHubSection: String, CaseIterable, Identifiable {
    case captions
    case favourites
    case collections

    var id: String { rawValue }

    var title: String {
        switch self {
        case .captions: return "Captions"
        case .favourites: return "Favourites"
        case .collections: return "Collections"
        }
    }

    var iconName: String {
        switch self {
        case .captions: return "text.quote"
        case .favourites: return "heart.fill"
        case .collections: return "square.stack.fill"
        }
    }
}

struct MediaHubView: View {
    @ObservedObject var store: AppStorage
    @State private var selectedSection: MediaHubSection = .captions

    var body: some View {
        VStack(spacing: 0) {
            sectionPicker
            switch selectedSection {
            case .captions:
                MediaCaptionsView(store: store)
            case .favourites:
                MediaFavouritesView(store: store)
            case .collections:
                MediaCollectionsHubView(store: store)
            }
        }
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(MediaHubSection.allCases) { section in
                    Button {
                        HapticManager.lightTap()
                        SoundManager.playTick()
                        withAnimation(.easeInOut(duration: 0.3)) { selectedSection = section }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: section.iconName)
                            Text(section.title)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .foregroundStyle(
                            selectedSection == section
                                ? Color("AppTextPrimary")
                                : Color("AppTextSecondary")
                        )
                        .background(
                            selectedSection == section
                                ? Color("AppPrimary")
                                : Color("AppSurface")
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color("AppBackground"))
    }
}

struct MediaCollectionsHubView: View {
    @ObservedObject var store: AppStorage

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 12) {
                        NavigationLink {
                            CustomCollectionsView(store: store)
                        } label: {
                            hubRow(icon: "square.stack.fill", title: "Custom Collections", subtitle: "\(store.customCollections.count) collections")
                        }
                        NavigationLink {
                            CollectionCompareView(store: store)
                        } label: {
                            hubRow(icon: "rectangle.split.2x1", title: "Compare Collections", subtitle: "Side-by-side view")
                        }
                        NavigationLink {
                            FavouriteReorderView(store: store)
                        } label: {
                            hubRow(icon: "line.3.horizontal", title: "Reorder Favourites", subtitle: "Drag to set personal order")
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
        }
    }

    private func hubRow(icon: String, title: String, subtitle: String) -> some View {
        HubNavigationCell(icon: icon, title: title, subtitle: subtitle)
    }
}

struct FavouriteReorderView: View {
    @ObservedObject var store: AppStorage

    var body: some View {
        ZStack {
            AppBackgroundView()
            if store.favourites.isEmpty {
                EmptyStateView(
                    symbolName: "heart",
                    title: "No Favourites",
                    subtitle: "Add favourites first to reorder them."
                )
            } else {
                List {
                    ForEach(store.favourites, id: \.self) { favID in
                        if let item = SampleMediaItem.curated.first(where: { $0.id == favID }) {
                            HStack(spacing: 12) {
                                MediaThumbnailView(iconName: item.iconName, accentHue: item.accentHue, size: 40)
                                Text(item.title).foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                if let rating = store.favouriteRating(for: favID) {
                                    Text("\(rating)/5")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color("AppAccent"))
                                }
                            }
                            .appListRowBackground()
                        }
                    }
                    .onMove { store.moveFavourites(from: $0, to: $1) }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Reorder Favourites")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .toolbar { EditButton().tint(Color("AppAccent")) }
    }
}
