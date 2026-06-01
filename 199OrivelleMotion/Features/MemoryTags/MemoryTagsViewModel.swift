import Foundation
import Combine

final class MemoryTagsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var smartFilter: SmartFilter = .all
    @Published var filterTag = "General"
    @Published var showAddSheet = false
    @Published var showTemplateSheet = false
    @Published var editingEntry: MemoryEntry?
    @Published var showSuccessCheckmark = false
    @Published var pulsingEntryID: UUID?
    @Published var selectedTemplate: EntryTemplate?

    private let store: AppStorage

    let emojiOptions = ["📸", "🌅", "🏔️", "🎉", "❤️", "✈️", "🌊", "🎨", "📖", "⭐"]

    init(store: AppStorage) {
        self.store = store
    }

    var availableTags: [String] {
        Array(Set(store.memoryEntries.map(\.tag))).sorted()
    }

    var filteredEntries: [MemoryEntry] {
        var entries = store.filteredMemories(
            filter: smartFilter,
            tag: smartFilter == .byTag ? filterTag : nil,
            includeArchived: smartFilter == .archived
        )
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            entries = entries.filter {
                $0.title.lowercased().contains(query) ||
                $0.notes.lowercased().contains(query) ||
                $0.tag.lowercased().contains(query)
            }
        }
        return entries
    }

    var isEmpty: Bool {
        store.memoryEntries.isEmpty
    }

    func applyTemplate(_ template: EntryTemplate) {
        selectedTemplate = template
        showTemplateSheet = false
        showAddSheet = true
    }

    func saveEntry(
        title: String,
        emoji: String,
        notes: String,
        tag: String,
        albumID: UUID?,
        existingID: UUID?
    ) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }

        if let existingID, let index = store.memoryEntries.firstIndex(where: { $0.id == existingID }) {
            var updated = store.memoryEntries[index]
            updated.title = trimmedTitle
            updated.emoji = emoji
            updated.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.tag = tag
            updated.albumID = albumID
            store.updateMemoryEntry(updated)
            if let albumID { store.addToAlbum(albumID: albumID, memoryID: existingID) }
        } else {
            let entry = MemoryEntry(
                title: trimmedTitle,
                emoji: emoji,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                tag: tag,
                albumID: albumID
            )
            store.addMemoryEntry(entry)
            HapticManager.mediumTap()
            SoundManager.playSave()
            triggerSuccess(for: entry.id)
        }
        selectedTemplate = nil
        return true
    }

    func deleteEntry(_ entry: MemoryEntry) {
        HapticManager.lightTap()
        store.deleteMemoryEntry(id: entry.id)
    }

    func togglePin(_ entry: MemoryEntry) {
        store.togglePinMemory(id: entry.id)
    }

    func toggleArchive(_ entry: MemoryEntry) {
        store.toggleArchiveMemory(id: entry.id)
    }

    func triggerSuccess(for id: UUID) {
        pulsingEntryID = id
        showSuccessCheckmark = true
        HapticManager.success()
        SoundManager.playSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.pulsingEntryID = nil }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.showSuccessCheckmark = false }
    }
}
