import Foundation

struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [Achievement] = [
        Achievement(
            id: "first_tag",
            title: "First Tag",
            description: "Added your first tagged note to a photo.",
            iconName: "tag.fill"
        ),
        Achievement(
            id: "journal_starter",
            title: "Journal Starter",
            description: "Created five entries in your visual journal.",
            iconName: "book.fill"
        ),
        Achievement(
            id: "memory_maker",
            title: "Memory Maker",
            description: "Added ten different photos with context to your gallery.",
            iconName: "photo.stack.fill"
        ),
        Achievement(
            id: "weekly_logger",
            title: "Weekly Logger",
            description: "Wrote journal entries for seven consecutive days.",
            iconName: "calendar"
        ),
        Achievement(
            id: "top_picks",
            title: "Top Picks",
            description: "Selected three or more favourites from your media collection.",
            iconName: "star.fill"
        ),
        Achievement(
            id: "explorer",
            title: "Explorer",
            description: "Organized twenty unique items in the app.",
            iconName: "map.fill"
        ),
        Achievement(
            id: "reflection_time",
            title: "Reflection Time",
            description: "Wrote over fifty journal entries reflecting on experiences.",
            iconName: "sparkles"
        ),
        Achievement(
            id: "favourite_curator",
            title: "Favourite Curator",
            description: "Marked ten items as favourites.",
            iconName: "heart.fill"
        )
    ]
}
