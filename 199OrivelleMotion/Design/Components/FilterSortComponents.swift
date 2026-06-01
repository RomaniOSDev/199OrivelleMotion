import SwiftUI

struct SmartFilterBar: View {
    @Binding var selectedFilter: SmartFilter
    @Binding var selectedTag: String
    let availableTags: [String]

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SmartFilter.allCases) { filter in
                        Button {
                            HapticManager.lightTap()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedFilter = filter
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: filter.iconName)
                                    .font(.caption)
                                Text(filter.title)
                                    .font(.caption.weight(.medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(
                                selectedFilter == filter
                                    ? Color("AppTextPrimary")
                                    : Color("AppTextSecondary")
                            )
                            .background(
                                Capsule().fill(
                                    selectedFilter == filter
                                        ? Color("AppPrimary")
                                        : Color("AppSurface")
                                )
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }

            if selectedFilter == .byTag, !availableTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(availableTags, id: \.self) { tag in
                            Button {
                                HapticManager.lightTap()
                                selectedTag = tag
                            } label: {
                                Text(tag)
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .foregroundStyle(
                                        selectedTag == tag
                                            ? Color("AppTextPrimary")
                                            : Color("AppTextSecondary")
                                    )
                                    .background(
                                        Capsule().fill(
                                            selectedTag == tag
                                                ? Color("AppAccent")
                                                : Color("AppSurface")
                                        )
                                    )
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct SortMenuButton: View {
    @ObservedObject var store: AppStorage

    var body: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    HapticManager.lightTap()
                    store.globalSortOption = option
                } label: {
                    HStack {
                        Text(option.title)
                        if store.globalSortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
                .foregroundStyle(Color("AppAccent"))
        }
    }
}

struct RelatedItemsSection: View {
    @ObservedObject var store: AppStorage
    let memoryIDs: [UUID]
    let captionIDs: [UUID]
    let favouriteIDs: [String]

    var body: some View {
        if !memoryIDs.isEmpty || !captionIDs.isEmpty || !favouriteIDs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(title: "Related Items")

                ForEach(memoryIDs, id: \.self) { id in
                    if let entry = store.memoryEntries.first(where: { $0.id == id }) {
                        relatedRow(icon: "tag.fill", title: entry.title, subtitle: "Tag")
                    }
                }
                ForEach(captionIDs, id: \.self) { id in
                    if let caption = store.captions.first(where: { $0.id == id }) {
                        relatedRow(icon: "text.quote", title: String(caption.text.prefix(40)), subtitle: "Caption")
                    }
                }
                ForEach(favouriteIDs, id: \.self) { id in
                    if let item = SampleMediaItem.curated.first(where: { $0.id == id }) {
                        relatedRow(icon: "heart.fill", title: item.title, subtitle: "Favourite")
                    }
                }
            }
            .appCard()
        }
    }

    private func relatedRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            IconBadgeView(iconName: icon, style: .accent, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                TagChipView(text: subtitle, isActive: true)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
