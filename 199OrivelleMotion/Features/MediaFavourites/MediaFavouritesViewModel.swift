import Foundation
import Combine

final class MediaFavouritesViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedItem: SampleMediaItem?
    @Published var showDetailSheet = false

    private let store: AppStorage

    init(store: AppStorage) {
        self.store = store
    }

    var allItems: [SampleMediaItem] {
        SampleMediaItem.curated
    }

    var filteredItems: [SampleMediaItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return allItems }
        return allItems.filter {
            $0.title.lowercased().contains(query) ||
            $0.description.lowercased().contains(query)
        }
    }

    var favouriteItems: [SampleMediaItem] {
        allItems.filter { store.isFavourite(mediaId: $0.id) }
    }

    var showFavouritesOnly: Bool = false

    func displayedItems(showFavourites: Bool) -> [SampleMediaItem] {
        let base = showFavourites ? favouriteItems : filteredItems
        return base
    }

    func toggleFavourite(_ item: SampleMediaItem) {
        let added = store.toggleFavourite(mediaId: item.id)
        if added {
            HapticManager.lightTap()
            SoundManager.playSave()
        } else {
            HapticManager.lightTap()
        }
    }

    func note(for item: SampleMediaItem) -> String {
        store.userNotes[item.id] ?? ""
    }

    func saveNote(for item: SampleMediaItem, note: String) {
        store.setUserNote(for: item.id, note: note)
        HapticManager.mediumTap()
        SoundManager.playSuccess()
    }
}
