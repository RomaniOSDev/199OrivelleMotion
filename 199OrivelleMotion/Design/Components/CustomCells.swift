import SwiftUI

// MARK: - Icon Badge

struct IconBadgeView: View {
    let iconName: String
    var style: BadgeStyle = .accent
    var size: CGFloat = 48

    enum BadgeStyle {
        case accent, primary, muted, emoji(String)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(badgeFill)
            switch style {
            case .emoji(let emoji):
                Text(emoji).font(.system(size: size * 0.48))
            default:
                Image(systemName: iconName)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
        .frame(width: size, height: size)
    }

    private var badgeFill: AnyShapeStyle {
        switch style {
        case .accent:
            return AnyShapeStyle(LinearGradient(
                colors: [Color("AppAccent").opacity(0.35), Color("AppPrimary").opacity(0.2)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        case .primary:
            return AnyShapeStyle(LinearGradient(
                colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        case .muted:
            return AnyShapeStyle(Color("AppBackground").opacity(0.6))
        case .emoji:
            return AnyShapeStyle(Color("AppBackground").opacity(0.5))
        }
    }
}

// MARK: - Tag Chip

struct TagChipView: View {
    let text: String
    var isActive: Bool = false

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(isActive ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .background(
                Capsule().fill(isActive ? Color("AppPrimary") : Color("AppBackground").opacity(0.7))
            )
    }
}

// MARK: - Section Header

struct SectionHeaderView: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Memory Tag Cell

struct MemoryTagCell: View {
    let entry: MemoryEntry
    var albumName: String?

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(iconName: "tag.fill", style: .emoji(entry.emoji), size: 52)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    if entry.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                }
                HStack(spacing: 8) {
                    TagChipView(text: entry.tag, isActive: true)
                    if let albumName {
                        TagChipView(text: albumName)
                    }
                    if entry.accessCount > 0 {
                        Label("\(entry.accessCount)", systemImage: "eye")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextSecondary").opacity(0.6))
        }
    }
}

// MARK: - Caption Cell

struct CaptionCell: View {
    let caption: Caption

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                IconBadgeView(iconName: "text.quote", style: .accent, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(caption.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                    if caption.isPinned {
                        Label("Pinned", systemImage: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
                Spacer()
            }
            Text(caption.text)
                .font(.body)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            if !caption.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(caption.tags, id: \.self) { TagChipView(text: $0) }
                    }
                }
            }
        }
    }
}

// MARK: - Favourite Media Cell

struct FavouriteMediaCell: View {
    let item: SampleMediaItem
    let isFavourite: Bool
    var rating: Int?
    var notePreview: String?

    var body: some View {
        HStack(spacing: 14) {
            MediaThumbnailView(iconName: item.iconName, accentHue: item.accentHue, size: 58)
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                if let notePreview, !notePreview.isEmpty {
                    Text(notePreview)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent").opacity(0.9))
                        .lineLimit(1)
                }
                if let rating {
                    PriorityDotsView(rating: rating)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: isFavourite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isFavourite ? Color("AppPrimary") : Color("AppTextSecondary"))
                .frame(width: 44, height: 44)
        }
    }
}

struct PriorityDotsView: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { level in
                Circle()
                    .fill(level <= rating ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.25))
                    .frame(width: 7, height: 7)
            }
            Text("Priority \(rating)")
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }
}

// MARK: - Hub Navigation Cell

struct HubNavigationCell: View {
    let icon: String
    let title: String
    let subtitle: String
    var badge: String?

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(iconName: icon, style: .accent, size: 50)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
            }
            Spacer()
            if let badge {
                Text(badge)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color("AppPrimary")))
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextSecondary").opacity(0.5))
        }
        .appCard(padding: 14)
    }
}

// MARK: - Timeline Cell

struct TimelineCell: View {
    let item: TimelineItem

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color("AppAccent"))
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color("AppTextSecondary").opacity(0.2))
                    .frame(width: 2)
            }
            .frame(width: 10)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    IconBadgeView(iconName: item.type.iconName, style: .muted, size: 28)
                    Text(item.type.label)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                    Spacer()
                    Text(item.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                if !item.subtitle.isEmpty {
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
            }
            .appInlineCard(contentPadding: 12)
        }
    }
}

// MARK: - Search Result Cell

struct SearchResultCell: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(iconName: result.type.iconName, style: .accent, size: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                HStack(spacing: 6) {
                    TagChipView(text: result.type.label, isActive: true)
                    if !result.subtitle.isEmpty {
                        Text(result.subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
        }
        .appInlineCard(contentPadding: 12)
    }
}

// MARK: - Album Cell

struct AlbumCell: View {
    let album: Album

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(iconName: "folder.fill", style: .emoji(album.emoji), size: 52)
            VStack(alignment: .leading, spacing: 5) {
                Text(album.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(album.itemCount) items · \(album.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextSecondary").opacity(0.5))
        }
    }
}

// MARK: - Quick Note Cell

struct QuickNoteCell: View {
    let note: QuickNote

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadgeView(iconName: "bolt.fill", style: .primary, size: 36)
            VStack(alignment: .leading, spacing: 6) {
                Text(note.text)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(4)
                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
        }
    }
}

// MARK: - Achievement Cell

struct AchievementCell: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                            ? LinearGradient(colors: [Color("AppPrimary"), Color("AppAccent")], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color("AppSurface"), Color("AppBackground")], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 58, height: 58)
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.4))
            }
            Text(achievement.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isUnlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 168)
        .appCard(elevation: isUnlocked ? .raised : .flat, accentBorder: isUnlocked, padding: 14)
        .opacity(isUnlocked ? 1 : 0.75)
    }
}

// MARK: - Settings Row Cell

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            IconBadgeView(
                iconName: icon,
                style: isDestructive ? .primary : .accent,
                size: 40
            )
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(isDestructive ? Color("AppPrimary") : Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 44)
    }
}

// MARK: - Stats Grid

struct StatsGridView: View {
    let metrics: [(value: String, label: String, icon: String)]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                VStack(spacing: 8) {
                    Image(systemName: metric.icon)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Text(metric.value)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(metric.label)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    AppSurfaceShape(cornerRadius: 14, elevation: .flat)
                )
            }
        }
    }
}

// MARK: - Card List Container

struct CardListContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: spacing) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

struct SwipeableCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .appCard(padding: 14)
    }
}
