import Foundation
import Combine

final class MediaCaptionsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var smartFilter: SmartFilter = .all
    @Published var filterTag = ""
    @Published var showAddSheet = false
    @Published var showTemplateSheet = false
    @Published var editingCaption: Caption?
    @Published var scaledCaptionID: UUID?
    @Published var selectedTemplate: EntryTemplate?

    private let store: AppStorage

    init(store: AppStorage) {
        self.store = store
    }

    var availableTags: [String] {
        Array(Set(store.captions.flatMap(\.tags))).sorted()
    }

    var sortedCaptions: [Caption] {
        var items = store.filteredCaptions(
            filter: smartFilter,
            tag: smartFilter == .byTag ? filterTag : nil,
            includeArchived: smartFilter == .archived
        )
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            items = items.filter {
                $0.text.lowercased().contains(query) ||
                $0.tags.contains { $0.lowercased().contains(query) }
            }
        }
        return items
    }

    var isEmpty: Bool { store.captions.isEmpty }

    func applyTemplate(_ template: EntryTemplate) {
        selectedTemplate = template
        showTemplateSheet = false
        showAddSheet = true
    }

    func saveCaption(text: String, date: Date, tags: [String], albumID: UUID?, existingID: UUID?) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        if let existingID, let index = store.captions.firstIndex(where: { $0.id == existingID }) {
            var updated = store.captions[index]
            updated.text = trimmed
            updated.date = date
            updated.tags = tags
            updated.albumID = albumID
            store.updateCaption(updated)
            if let albumID { store.addToAlbum(albumID: albumID, captionID: existingID) }
        } else {
            let caption = Caption(text: trimmed, date: date, tags: tags, albumID: albumID)
            store.addCaption(caption)
            HapticManager.mediumTap()
            SoundManager.playCaptionSave()
            triggerScaleAnimation(for: caption.id)
        }
        selectedTemplate = nil
        return true
    }

    func deleteCaption(_ caption: Caption) {
        HapticManager.lightTap()
        store.deleteCaption(id: caption.id)
    }

    func togglePin(_ caption: Caption) { store.togglePinCaption(id: caption.id) }
    func toggleArchive(_ caption: Caption) { store.toggleArchiveCaption(id: caption.id) }

    private func triggerScaleAnimation(for id: UUID) {
        scaledCaptionID = id
        HapticManager.success()
        SoundManager.playSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.scaledCaptionID = nil }
    }
}
