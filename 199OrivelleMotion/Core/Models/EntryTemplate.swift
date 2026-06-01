import Foundation

struct EntryTemplate: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let titlePlaceholder: String
    let notesPlaceholder: String
    let tag: String
    let captionPrefix: String?

    static let all: [EntryTemplate] = [
        EntryTemplate(
            id: "travel_log",
            name: "Travel Log",
            emoji: "✈️",
            titlePlaceholder: "Destination name",
            notesPlaceholder: "Places visited, highlights, impressions...",
            tag: "Travel",
            captionPrefix: "Travel day:"
        ),
        EntryTemplate(
            id: "event_recap",
            name: "Event Recap",
            emoji: "🎉",
            titlePlaceholder: "Event name",
            notesPlaceholder: "Who was there, key moments, feelings...",
            tag: "Events",
            captionPrefix: "Event recap:"
        ),
        EntryTemplate(
            id: "quote_of_day",
            name: "Quote of the Day",
            emoji: "💬",
            titlePlaceholder: "Today's quote",
            notesPlaceholder: "Why this quote resonates with you...",
            tag: "General",
            captionPrefix: "Quote:"
        )
    ]
}
