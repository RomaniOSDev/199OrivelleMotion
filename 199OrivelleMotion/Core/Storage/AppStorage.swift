import Foundation
import Combine

final class AppStorage: ObservableObject {
    static let shared = AppStorage()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let memoryEntries = "memoryEntries"
        static let lastAccessedTag = "lastAccessedTag"
        static let isFirstLaunch = "isFirstLaunch"
        static let captions = "captions"
        static let lastOpened = "lastOpened"
        static let captionSortOrder = "captionSortOrder"
        static let favourites = "favourites"
        static let userNotes = "userNotes"
        static let albums = "albums"
        static let quickNotes = "quickNotes"
        static let customCollections = "customCollections"
        static let favouriteRatings = "favouriteRatings"
        static let activityLog = "activityLog"
        static let activeDays = "activeDays"
        static let globalSortOption = "globalSortOption"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }
    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }
    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }
    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }
    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }
    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveJSON(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }
    @Published var memoryEntries: [MemoryEntry] {
        didSet { saveJSON(memoryEntries, key: Keys.memoryEntries) }
    }
    @Published var lastAccessedTag: String {
        didSet { defaults.set(lastAccessedTag, forKey: Keys.lastAccessedTag) }
    }
    @Published var isFirstLaunch: Bool {
        didSet { defaults.set(isFirstLaunch, forKey: Keys.isFirstLaunch) }
    }
    @Published var captions: [Caption] {
        didSet { saveJSON(captions, key: Keys.captions) }
    }
    @Published var lastOpened: Date {
        didSet { defaults.set(lastOpened, forKey: Keys.lastOpened) }
    }
    @Published var captionSortOrder: String {
        didSet { defaults.set(captionSortOrder, forKey: Keys.captionSortOrder) }
    }
    @Published var favourites: [String] {
        didSet { defaults.set(favourites, forKey: Keys.favourites) }
    }
    @Published var userNotes: [String: String] {
        didSet { saveJSON(userNotes, key: Keys.userNotes) }
    }
    @Published var albums: [Album] {
        didSet { saveJSON(albums, key: Keys.albums) }
    }
    @Published var quickNotes: [QuickNote] {
        didSet { saveJSON(quickNotes, key: Keys.quickNotes) }
    }
    @Published var customCollections: [CustomCollection] {
        didSet { saveJSON(customCollections, key: Keys.customCollections) }
    }
    @Published var favouriteRatings: [String: Int] {
        didSet { saveJSON(favouriteRatings, key: Keys.favouriteRatings) }
    }
    @Published var activityLog: [ActivityRecord] {
        didSet { saveJSON(activityLog, key: Keys.activityLog) }
    }
    @Published var activeDays: [Date] {
        didSet { saveJSON(activeDays, key: Keys.activeDays) }
    }
    @Published var globalSortOption: SortOption {
        didSet { defaults.set(globalSortOption.rawValue, forKey: Keys.globalSortOption) }
    }
    @Published var pendingAchievementBanners: [Achievement] = []

    private let defaults = UserDefaults.standard
    private var sessionStartDate: Date?
    private var sessionTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    var itemsAdded: Int { memoryEntries.count + captions.count + quickNotes.count }
    var entriesWritten: Int { memoryEntries.count + captions.count + quickNotes.count }
    var favouritesCount: Int { favourites.count }

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadJSON(key: Keys.achievementsUnlocked, from: defaults) ?? [:]
        memoryEntries = Self.loadJSON(key: Keys.memoryEntries, from: defaults) ?? []
        lastAccessedTag = defaults.string(forKey: Keys.lastAccessedTag) ?? "All"
        isFirstLaunch = defaults.object(forKey: Keys.isFirstLaunch) as? Bool ?? true
        captions = Self.loadJSON(key: Keys.captions, from: defaults) ?? []
        lastOpened = defaults.object(forKey: Keys.lastOpened) as? Date ?? Date()
        captionSortOrder = defaults.string(forKey: Keys.captionSortOrder) ?? "dateCreated"
        favourites = defaults.stringArray(forKey: Keys.favourites) ?? []
        userNotes = Self.loadJSON(key: Keys.userNotes, from: defaults) ?? [:]
        albums = Self.loadJSON(key: Keys.albums, from: defaults) ?? []
        quickNotes = Self.loadJSON(key: Keys.quickNotes, from: defaults) ?? []
        customCollections = Self.loadJSON(key: Keys.customCollections, from: defaults) ?? []
        favouriteRatings = Self.loadJSON(key: Keys.favouriteRatings, from: defaults) ?? [:]
        activityLog = Self.loadJSON(key: Keys.activityLog, from: defaults) ?? []
        activeDays = Self.loadJSON(key: Keys.activeDays, from: defaults) ?? []
        let sortRaw = defaults.string(forKey: Keys.globalSortOption) ?? SortOption.dateNewest.rawValue
        globalSortOption = SortOption(rawValue: sortRaw) ?? .dateNewest

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reloadFromDefaults() }
            .store(in: &cancellables)
    }

    // MARK: - Session

    func beginSession() {
        guard sessionStartDate == nil else { return }
        sessionStartDate = Date()
        totalSessionsCompleted += 1
        startSessionTimer()
    }

    func endSession() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        if let start = sessionStartDate {
            totalMinutesUsed += max(1, Int(Date().timeIntervalSince(start) / 60))
        }
        sessionStartDate = nil
    }

    // MARK: - Memory

    func addMemoryEntry(_ entry: MemoryEntry) {
        memoryEntries.insert(entry, at: 0)
        lastAccessedTag = entry.tag
        isFirstLaunch = false
        if let albumID = entry.albumID { addToAlbum(albumID: albumID, memoryID: entry.id) }
        logActivity(type: .memory, title: entry.title, referenceID: entry.id.uuidString)
        recordMeaningfulAction()
    }

    func updateMemoryEntry(_ entry: MemoryEntry) {
        guard let index = memoryEntries.firstIndex(where: { $0.id == entry.id }) else { return }
        memoryEntries[index] = entry
        lastAccessedTag = entry.tag
        recordMeaningfulAction()
    }

    func deleteMemoryEntry(id: UUID) {
        memoryEntries.removeAll { $0.id == id }
        for i in albums.indices {
            albums[i].memoryEntryIDs.removeAll { $0 == id }
        }
        recordMeaningfulAction()
    }

    func togglePinMemory(id: UUID) {
        guard let i = memoryEntries.firstIndex(where: { $0.id == id }) else { return }
        memoryEntries[i].isPinned.toggle()
        HapticManager.lightTap()
    }

    func toggleArchiveMemory(id: UUID) {
        guard let i = memoryEntries.firstIndex(where: { $0.id == id }) else { return }
        memoryEntries[i].isArchived.toggle()
        memoryEntries[i].isPinned = false
        HapticManager.lightTap()
    }

    func incrementMemoryAccess(id: UUID) {
        guard let i = memoryEntries.firstIndex(where: { $0.id == id }) else { return }
        memoryEntries[i].accessCount += 1
    }

    // MARK: - Captions

    func addCaption(_ caption: Caption) {
        captions.insert(caption, at: 0)
        lastOpened = Date()
        if let albumID = caption.albumID { addToAlbum(albumID: albumID, captionID: caption.id) }
        logActivity(type: .caption, title: String(caption.text.prefix(40)), referenceID: caption.id.uuidString)
        recordMeaningfulAction()
    }

    func updateCaption(_ caption: Caption) {
        guard let index = captions.firstIndex(where: { $0.id == caption.id }) else { return }
        captions[index] = caption
        recordMeaningfulAction()
    }

    func deleteCaption(id: UUID) {
        captions.removeAll { $0.id == id }
        for i in albums.indices { albums[i].captionIDs.removeAll { $0 == id } }
        recordMeaningfulAction()
    }

    func togglePinCaption(id: UUID) {
        guard let i = captions.firstIndex(where: { $0.id == id }) else { return }
        captions[i].isPinned.toggle()
        HapticManager.lightTap()
    }

    func toggleArchiveCaption(id: UUID) {
        guard let i = captions.firstIndex(where: { $0.id == id }) else { return }
        captions[i].isArchived.toggle()
        captions[i].isPinned = false
        HapticManager.lightTap()
    }

    func incrementCaptionAccess(id: UUID) {
        guard let i = captions.firstIndex(where: { $0.id == id }) else { return }
        captions[i].accessCount += 1
    }

    // MARK: - Favourites

    func toggleFavourite(mediaId: String) -> Bool {
        if favourites.contains(mediaId) {
            favourites.removeAll { $0 == mediaId }
            favouriteRatings.removeValue(forKey: mediaId)
            recordMeaningfulAction()
            return false
        } else {
            favourites.append(mediaId)
            if let item = SampleMediaItem.curated.first(where: { $0.id == mediaId }) {
                logActivity(type: .favourite, title: item.title, referenceID: mediaId)
            }
            recordMeaningfulAction()
            return true
        }
    }

    func isFavourite(mediaId: String) -> Bool { favourites.contains(mediaId) }

    func setFavouriteRating(mediaId: String, rating: Int) {
        favouriteRatings[mediaId] = min(5, max(1, rating))
        if !favourites.contains(mediaId) { favourites.append(mediaId) }
        recordMeaningfulAction()
    }

    func favouriteRating(for mediaId: String) -> Int? { favouriteRatings[mediaId] }

    func moveFavourites(from source: IndexSet, to destination: Int) {
        var updated = favourites
        let moving = source.sorted().compactMap { index -> String? in
            guard updated.indices.contains(index) else { return nil }
            return updated[index]
        }
        for index in source.sorted(by: >) {
            guard updated.indices.contains(index) else { continue }
            updated.remove(at: index)
        }
        var insertIndex = destination
        for index in source.sorted() where index < destination {
            insertIndex -= 1
        }
        insertIndex = max(0, min(insertIndex, updated.count))
        updated.insert(contentsOf: moving, at: insertIndex)
        favourites = updated
    }

    func setUserNote(for mediaId: String, note: String) {
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            userNotes.removeValue(forKey: mediaId)
        } else {
            userNotes[mediaId] = note
        }
    }

    // MARK: - Quick Notes

    func addQuickNote(_ text: String) {
        let note = QuickNote(text: text)
        quickNotes.insert(note, at: 0)
        logActivity(type: .quickNote, title: String(text.prefix(40)), referenceID: note.id.uuidString)
        recordMeaningfulAction()
    }

    func deleteQuickNote(id: UUID) {
        quickNotes.removeAll { $0.id == id }
    }

    // MARK: - Albums

    func addAlbum(name: String, emoji: String = "📁") -> Album {
        let album = Album(name: name, emoji: emoji)
        albums.insert(album, at: 0)
        logActivity(type: .album, title: name, referenceID: album.id.uuidString)
        recordMeaningfulAction()
        return album
    }

    func updateAlbum(_ album: Album) {
        guard let i = albums.firstIndex(where: { $0.id == album.id }) else { return }
        albums[i] = album
    }

    func deleteAlbum(id: UUID) {
        albums.removeAll { $0.id == id }
        for i in memoryEntries.indices where memoryEntries[i].albumID == id {
            memoryEntries[i].albumID = nil
        }
        for i in captions.indices where captions[i].albumID == id {
            captions[i].albumID = nil
        }
    }

    func addToAlbum(albumID: UUID, memoryID: UUID? = nil, captionID: UUID? = nil) {
        guard let i = albums.firstIndex(where: { $0.id == albumID }) else { return }
        if let memoryID, !albums[i].memoryEntryIDs.contains(memoryID) {
            albums[i].memoryEntryIDs.append(memoryID)
        }
        if let captionID, !albums[i].captionIDs.contains(captionID) {
            albums[i].captionIDs.append(captionID)
        }
    }

    func album(for id: UUID) -> Album? { albums.first { $0.id == id } }

    // MARK: - Custom Collections

    func addCustomCollection(name: String, emoji: String = "⭐") -> CustomCollection {
        let collection = CustomCollection(name: name, emoji: emoji)
        customCollections.insert(collection, at: 0)
        logActivity(type: .collection, title: name, referenceID: collection.id.uuidString)
        recordMeaningfulAction()
        return collection
    }

    func updateCustomCollection(_ collection: CustomCollection) {
        guard let i = customCollections.firstIndex(where: { $0.id == collection.id }) else { return }
        customCollections[i] = collection
    }

    func deleteCustomCollection(id: UUID) {
        customCollections.removeAll { $0.id == id }
    }

    func addFavouriteToCollection(collectionID: UUID, mediaID: String) {
        guard let i = customCollections.firstIndex(where: { $0.id == collectionID }) else { return }
        if !customCollections[i].favouriteIDs.contains(mediaID) {
            customCollections[i].favouriteIDs.append(mediaID)
        }
    }

    // MARK: - Related Items

    func linkMemoryToCaption(memoryID: UUID, captionID: UUID) {
        guard let mi = memoryEntries.firstIndex(where: { $0.id == memoryID }),
              let ci = captions.firstIndex(where: { $0.id == captionID }) else { return }
        if !memoryEntries[mi].relatedCaptionIDs.contains(captionID) {
            memoryEntries[mi].relatedCaptionIDs.append(captionID)
        }
        if !captions[ci].relatedMemoryIDs.contains(memoryID) {
            captions[ci].relatedMemoryIDs.append(memoryID)
        }
    }

    func linkMemoryToFavourite(memoryID: UUID, favouriteID: String) {
        guard let i = memoryEntries.firstIndex(where: { $0.id == memoryID }) else { return }
        if !memoryEntries[i].relatedFavouriteIDs.contains(favouriteID) {
            memoryEntries[i].relatedFavouriteIDs.append(favouriteID)
        }
    }

    func linkCaptionToFavourite(captionID: UUID, favouriteID: String) {
        guard let i = captions.firstIndex(where: { $0.id == captionID }) else { return }
        if !captions[i].relatedFavouriteIDs.contains(favouriteID) {
            captions[i].relatedFavouriteIDs.append(favouriteID)
        }
    }

    // MARK: - Filtering & Sorting

    func filteredMemories(filter: SmartFilter, tag: String? = nil, includeArchived: Bool = false) -> [MemoryEntry] {
        var items = memoryEntries
        if !includeArchived { items = items.filter { !$0.isArchived } }
        items = applySmartFilterToMemories(items, filter: filter, tag: tag)
        return sortMemories(items)
    }

    func filteredCaptions(filter: SmartFilter, tag: String? = nil, includeArchived: Bool = false) -> [Caption] {
        var items = captions
        if !includeArchived { items = items.filter { !$0.isArchived } }
        items = applySmartFilterToCaptions(items, filter: filter, tag: tag)
        return sortCaptions(items)
    }

    func sortMemories(_ items: [MemoryEntry]) -> [MemoryEntry] {
        switch globalSortOption {
        case .dateNewest:
            return items.sorted { pinnedFirst($0, $1) || $0.createdAt > $1.createdAt }
        case .dateOldest:
            return items.sorted { pinnedFirst($0, $1) || $0.createdAt < $1.createdAt }
        case .alphabetical:
            return items.sorted { pinnedFirst($0, $1) || $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .frequency:
            return items.sorted { pinnedFirst($0, $1) || $0.accessCount > $1.accessCount }
        }
    }

    func sortCaptions(_ items: [Caption]) -> [Caption] {
        switch globalSortOption {
        case .dateNewest:
            return items.sorted { pinnedFirst($0, $1) || $0.date > $1.date }
        case .dateOldest:
            return items.sorted { pinnedFirst($0, $1) || $0.date < $1.date }
        case .alphabetical:
            return items.sorted { pinnedFirst($0, $1) || $0.text.localizedCaseInsensitiveCompare($1.text) == .orderedAscending }
        case .frequency:
            return items.sorted { pinnedFirst($0, $1) || $0.accessCount > $1.accessCount }
        }
    }

    private func pinnedFirst(_ a: MemoryEntry, _ b: MemoryEntry) -> Bool {
        if a.isPinned != b.isPinned { return a.isPinned && !b.isPinned }
        return false
    }

    private func pinnedFirst(_ a: Caption, _ b: Caption) -> Bool {
        if a.isPinned != b.isPinned { return a.isPinned && !b.isPinned }
        return false
    }

    private func applySmartFilterToMemories(_ items: [MemoryEntry], filter: SmartFilter, tag: String?) -> [MemoryEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        switch filter {
        case .all: return items
        case .last7Days: return items.filter { $0.createdAt >= cutoff }
        case .withNotes: return items.filter { !$0.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        case .favouritesOnly: return items.filter { !$0.relatedFavouriteIDs.isEmpty }
        case .pinnedOnly: return items.filter { $0.isPinned }
        case .archived: return items.filter { $0.isArchived }
        case .byTag:
            guard let tag, !tag.isEmpty else { return items }
            return items.filter { $0.tag == tag }
        }
    }

    private func applySmartFilterToCaptions(_ items: [Caption], filter: SmartFilter, tag: String?) -> [Caption] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        switch filter {
        case .all: return items
        case .last7Days: return items.filter { $0.date >= cutoff }
        case .withNotes: return items.filter { $0.text.count > 20 }
        case .favouritesOnly: return items.filter { !$0.relatedFavouriteIDs.isEmpty }
        case .pinnedOnly: return items.filter { $0.isPinned }
        case .archived: return items.filter { $0.isArchived }
        case .byTag:
            guard let tag, !tag.isEmpty else { return items }
            return items.filter { $0.tags.contains(tag) }
        }
    }

    // MARK: - Search

    func globalSearch(query: String) -> [SearchResult] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        var results: [SearchResult] = []

        for entry in memoryEntries where !entry.isArchived {
            if entry.title.lowercased().contains(q) || entry.notes.lowercased().contains(q) || entry.tag.lowercased().contains(q) {
                results.append(SearchResult(id: "m-\(entry.id)", type: .memory, title: entry.title, subtitle: entry.notes, referenceID: entry.id.uuidString, date: entry.createdAt))
            }
        }
        for caption in captions where !caption.isArchived {
            if caption.text.lowercased().contains(q) || caption.tags.contains(where: { $0.lowercased().contains(q) }) {
                results.append(SearchResult(id: "c-\(caption.id)", type: .caption, title: String(caption.text.prefix(50)), subtitle: caption.tags.joined(separator: ", "), referenceID: caption.id.uuidString, date: caption.date))
            }
        }
        for favID in favourites {
            if let item = SampleMediaItem.curated.first(where: { $0.id == favID }),
               item.title.lowercased().contains(q) || item.description.lowercased().contains(q) {
                let note = userNotes[favID] ?? ""
                results.append(SearchResult(id: "f-\(favID)", type: .favourite, title: item.title, subtitle: note, referenceID: favID, date: Date()))
            }
        }
        for note in quickNotes where note.text.lowercased().contains(q) {
            results.append(SearchResult(id: "q-\(note.id)", type: .quickNote, title: note.text, subtitle: "Quick Note", referenceID: note.id.uuidString, date: note.createdAt))
        }
        return results.sorted { $0.date > $1.date }
    }

    // MARK: - Analytics

    func timelineItems() -> [TimelineItem] {
        var items: [TimelineItem] = []
        for entry in memoryEntries {
            items.append(TimelineItem(id: "m-\(entry.id)", date: entry.createdAt, type: .memory, title: entry.title, subtitle: entry.tag, referenceID: entry.id.uuidString))
        }
        for caption in captions {
            items.append(TimelineItem(id: "c-\(caption.id)", date: caption.date, type: .caption, title: String(caption.text.prefix(50)), subtitle: caption.tags.joined(separator: ", "), referenceID: caption.id.uuidString))
        }
        for favID in favourites {
            if let item = SampleMediaItem.curated.first(where: { $0.id == favID }) {
                items.append(TimelineItem(id: "f-\(favID)", date: Date(), type: .favourite, title: item.title, subtitle: "Favourite", referenceID: favID))
            }
        }
        for note in quickNotes {
            items.append(TimelineItem(id: "q-\(note.id)", date: note.createdAt, type: .quickNote, title: note.text, subtitle: "Quick Note", referenceID: note.id.uuidString))
        }
        for album in albums {
            items.append(TimelineItem(id: "a-\(album.id)", date: album.createdAt, type: .album, title: album.name, subtitle: "\(album.itemCount) items", referenceID: album.id.uuidString))
        }
        for collection in customCollections {
            items.append(TimelineItem(id: "col-\(collection.id)", date: collection.createdAt, type: .collection, title: collection.name, subtitle: "\(collection.favouriteIDs.count) items", referenceID: collection.id.uuidString))
        }
        return items.sorted { $0.date > $1.date }
    }

    func weeklySummary() -> WeeklySummary {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) else {
            return WeeklySummary(entryCount: 0, activeDays: 0, topTags: [], dailyCounts: [:])
        }

        var dailyCounts: [Date: Int] = [:]
        var tagCounts: [String: Int] = [:]
        var count = 0

        for entry in memoryEntries where entry.createdAt >= weekAgo {
            count += 1
            let day = calendar.startOfDay(for: entry.createdAt)
            dailyCounts[day, default: 0] += 1
            tagCounts[entry.tag, default: 0] += 1
        }
        for caption in captions where caption.date >= weekAgo {
            count += 1
            let day = calendar.startOfDay(for: caption.date)
            dailyCounts[day, default: 0] += 1
            for tag in caption.tags { tagCounts[tag, default: 0] += 1 }
        }
        for note in quickNotes where note.createdAt >= weekAgo {
            count += 1
            let day = calendar.startOfDay(for: note.createdAt)
            dailyCounts[day, default: 0] += 1
        }

        let topTags = tagCounts.map { TagTrend(id: $0.key, tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }

        return WeeklySummary(
            entryCount: count,
            activeDays: dailyCounts.keys.count,
            topTags: Array(topTags),
            dailyCounts: dailyCounts
        )
    }

    func tagTrends() -> [TagTrend] {
        var tagCounts: [String: Int] = [:]
        for entry in memoryEntries { tagCounts[entry.tag, default: 0] += 1 }
        for caption in captions { for tag in caption.tags { tagCounts[tag, default: 0] += 1 } }
        return tagCounts.map { TagTrend(id: $0.key, tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    func streakCalendarDays(month: Date = Date()) -> [Date: Bool] {
        let calendar = Calendar.current
        var result: [Date: Bool] = [:]
        for day in activeDays {
            result[calendar.startOfDay(for: day)] = true
        }
        return result
    }

    func activeDaysInMonth(_ month: Date) -> Int {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return 0 }
        return range.filter { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { return false }
            return activeDays.contains(where: { calendar.isDate($0, inSameDayAs: date) })
        }.count
    }

    // MARK: - Export / Import

    func makeExportBundle() -> ExportBundle {
        ExportBundle(
            exportedAt: Date(),
            version: ExportBundle.currentVersion,
            memoryEntries: memoryEntries,
            captions: captions,
            albums: albums,
            quickNotes: quickNotes,
            customCollections: customCollections,
            favourites: favourites,
            userNotes: userNotes,
            favouriteRatings: favouriteRatings,
            activityLog: activityLog
        )
    }

    func exportJSONData() -> Data? {
        try? JSONEncoder().encode(makeExportBundle())
    }

    func importJSONData(_ data: Data) -> Bool {
        guard let bundle = try? JSONDecoder().decode(ExportBundle.self, from: data) else { return false }
        memoryEntries = bundle.memoryEntries
        captions = bundle.captions
        albums = bundle.albums
        quickNotes = bundle.quickNotes
        customCollections = bundle.customCollections
        favourites = bundle.favourites
        userNotes = bundle.userNotes
        favouriteRatings = bundle.favouriteRatings
        activityLog = bundle.activityLog
        recordMeaningfulAction()
        return true
    }

    // MARK: - Achievements

    func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        achievementsUnlocked[achievement.id] != nil
    }

    func unlockDate(for achievement: Achievement) -> Date? {
        achievementsUnlocked[achievement.id]
    }

    func meetsCondition(for achievement: Achievement) -> Bool {
        switch achievement.id {
        case "first_tag": return itemsAdded >= 1
        case "journal_starter": return entriesWritten >= 5
        case "memory_maker": return itemsAdded >= 10
        case "weekly_logger": return entriesWritten >= 7
        case "top_picks": return favouritesCount >= 3
        case "explorer": return itemsAdded >= 20
        case "reflection_time": return entriesWritten >= 50
        case "favourite_curator": return favouritesCount >= 10
        default: return false
        }
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func dequeueNextBanner() -> Achievement? {
        guard !pendingAchievementBanners.isEmpty else { return nil }
        return pendingAchievementBanners.removeFirst()
    }

    // MARK: - Private

    func recordMeaningfulAction() {
        updateStreak()
        checkAchievements()
    }

    private func logActivity(type: ActivityType, title: String, referenceID: String) {
        let record = ActivityRecord(type: type, title: title, referenceID: referenceID)
        activityLog.insert(record, at: 0)
        if activityLog.count > 500 { activityLog = Array(activityLog.prefix(500)) }
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if !activeDays.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            activeDays.append(today)
        }
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), lastDay == yesterday {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = today
    }

    private func checkAchievements() {
        var newlyUnlocked: [Achievement] = []
        for achievement in Achievement.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            if meetsCondition(for: achievement) {
                achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }
        if !newlyUnlocked.isEmpty {
            pendingAchievementBanners.append(contentsOf: newlyUnlocked)
        }
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadJSON(key: Keys.achievementsUnlocked, from: defaults) ?? [:]
        memoryEntries = Self.loadJSON(key: Keys.memoryEntries, from: defaults) ?? []
        lastAccessedTag = defaults.string(forKey: Keys.lastAccessedTag) ?? "All"
        isFirstLaunch = defaults.object(forKey: Keys.isFirstLaunch) as? Bool ?? true
        captions = Self.loadJSON(key: Keys.captions, from: defaults) ?? []
        lastOpened = defaults.object(forKey: Keys.lastOpened) as? Date ?? Date()
        captionSortOrder = defaults.string(forKey: Keys.captionSortOrder) ?? "dateCreated"
        favourites = defaults.stringArray(forKey: Keys.favourites) ?? []
        userNotes = Self.loadJSON(key: Keys.userNotes, from: defaults) ?? [:]
        albums = Self.loadJSON(key: Keys.albums, from: defaults) ?? []
        quickNotes = Self.loadJSON(key: Keys.quickNotes, from: defaults) ?? []
        customCollections = Self.loadJSON(key: Keys.customCollections, from: defaults) ?? []
        favouriteRatings = Self.loadJSON(key: Keys.favouriteRatings, from: defaults) ?? [:]
        activityLog = Self.loadJSON(key: Keys.activityLog, from: defaults) ?? []
        activeDays = Self.loadJSON(key: Keys.activeDays, from: defaults) ?? []
        let sortRaw = defaults.string(forKey: Keys.globalSortOption) ?? SortOption.dateNewest.rawValue
        globalSortOption = SortOption(rawValue: sortRaw) ?? .dateNewest
        pendingAchievementBanners = []
    }

    private func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async { self?.totalMinutesUsed += 1 }
        }
    }

    private func saveJSON<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadJSON<T: Decodable>(key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
