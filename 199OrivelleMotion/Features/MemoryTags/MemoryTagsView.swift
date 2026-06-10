import SwiftUI

struct MemoryTagsView: View {
    @ObservedObject var store: AppStorage
    @StateObject private var viewModel: MemoryTagsViewModel

    init(store: AppStorage) {
        self.store = store
        _viewModel = StateObject(wrappedValue: MemoryTagsViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 0) {
                    SmartFilterBar(
                        selectedFilter: $viewModel.smartFilter,
                        selectedTag: $viewModel.filterTag,
                        availableTags: viewModel.availableTags
                    )
                    content
                }
                if viewModel.showSuccessCheckmark {
                    SuccessCheckmarkOverlay(isShowing: $viewModel.showSuccessCheckmark)
                }
            }
            .navigationTitle("Memory Tags")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .searchable(text: $viewModel.searchText, prompt: "Search tags and notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        SortMenuButton(store: store)
                        Button {
                            HapticManager.lightTap()
                            viewModel.showTemplateSheet = true
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .foregroundStyle(Color("AppAccent"))
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryActionButton(title: "Add Memory") {
                    viewModel.editingEntry = nil
                    viewModel.selectedTemplate = nil
                    viewModel.showAddSheet = true
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    Color("AppBackground")
                        .opacity(0.95)
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet, onDismiss: {
                viewModel.editingEntry = nil
                viewModel.selectedTemplate = nil
            }) {
                AddMemoryView(viewModel: viewModel, store: store)
            }
            .sheet(isPresented: $viewModel.showTemplateSheet) {
                TemplatePickerSheet { viewModel.applyTemplate($0) }
            }
            .navigationDestination(for: MemoryEntry.self) { entry in
                MemoryDetailView(entry: entry, viewModel: viewModel, store: store)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            ScrollView {
                EmptyStateView(
                    symbolName: "star",
                    title: "No Memories Yet",
                    subtitle: "Tap '+' to create your first tagged memory!"
                )
                Image(systemName: "square.and.pencil")
                    .font(.title)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        } else if viewModel.filteredEntries.isEmpty {
            ScrollView {
                EmptyStateView(
                    symbolName: "magnifyingglass",
                    title: "No Results",
                    subtitle: "Try a different search or filter."
                )
            }
        } else {
            List {
                ForEach(viewModel.filteredEntries) { entry in
                    NavigationLink(value: entry) {
                        MemoryTagCell(
                            entry: entry,
                            albumName: entry.albumID.flatMap { store.album(for: $0)?.name }
                        )
                    }
                    .appListRowInsets()
                    .pulseHighlight(isPulsing: .constant(viewModel.pulsingEntryID == entry.id))
                    .swipeActions(edge: .leading) {
                        Button { viewModel.togglePin(entry) } label: {
                            Label(entry.isPinned ? "Unpin" : "Pin", systemImage: entry.isPinned ? "pin.slash" : "pin")
                        }
                        .tint(Color("AppAccent"))
                        Button { viewModel.toggleArchive(entry) } label: {
                            Label(entry.isArchived ? "Unarchive" : "Archive", systemImage: "archivebox")
                        }
                        .tint(Color("AppSurface"))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) { viewModel.deleteEntry(entry) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            viewModel.editingEntry = entry
                            viewModel.showAddSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(Color("AppAccent"))
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private func albumName(for id: UUID?) -> String? {
        guard let id else { return nil }
        return store.album(for: id)?.name
    }
}

struct MemoryDetailView: View {
    let entry: MemoryEntry
    @ObservedObject var viewModel: MemoryTagsViewModel
    @ObservedObject var store: AppStorage
    @State private var showLinkSheet = false

    private var currentEntry: MemoryEntry {
        store.memoryEntries.first(where: { $0.id == entry.id }) ?? entry
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        IconBadgeView(iconName: "tag.fill", style: .emoji(currentEntry.emoji), size: 72)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(currentEntry.title)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                            HStack(spacing: 8) {
                                TagChipView(text: currentEntry.tag, isActive: true)
                                if currentEntry.isPinned { TagChipView(text: "Pinned") }
                            }
                        }
                    }
                    .appCard()

                    if !currentEntry.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeaderView(title: "Notes")
                            Text(currentEntry.notes)
                                .font(.body)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .appCard()
                    }

                    if let albumID = currentEntry.albumID, let album = store.album(for: albumID) {
                        HStack(spacing: 12) {
                            IconBadgeView(iconName: "folder.fill", style: .emoji(album.emoji), size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Album").font(.caption).foregroundStyle(Color("AppTextSecondary"))
                                Text(album.name).font(.subheadline.weight(.semibold)).foregroundStyle(Color("AppTextPrimary"))
                            }
                            Spacer()
                        }
                        .appCard(padding: 14)
                    }

                    RelatedItemsSection(
                        store: store,
                        memoryIDs: [],
                        captionIDs: currentEntry.relatedCaptionIDs,
                        favouriteIDs: currentEntry.relatedFavouriteIDs
                    )

                    PrimaryActionButton(title: "Link Related Item") { showLinkSheet = true }

                    Text("Created \(currentEntry.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    HapticManager.lightTap()
                    viewModel.editingEntry = currentEntry
                    viewModel.showAddSheet = true
                }
                .foregroundStyle(Color("AppAccent"))
            }
        }
        .sheet(isPresented: $showLinkSheet) {
            LinkRelatedItemsSheet(store: store, memoryID: currentEntry.id, captionID: nil)
        }
        .onAppear { store.incrementMemoryAccess(id: entry.id) }
    }
}

struct AddMemoryView: View {
    @ObservedObject var viewModel: MemoryTagsViewModel
    @ObservedObject var store: AppStorage
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedField: Field?

    @State private var title = ""
    @State private var notes = ""
    @State private var selectedEmoji = "📸"
    @State private var selectedTag = "General"
    @State private var selectedAlbumID: UUID?
    @State private var showValidationError = false
    @State private var showValidationAlert = false
    @State private var shakeTrigger: CGFloat = 0

    private enum Field: Hashable {
        case title
        case notes
    }

    private let tags = ["General", "Travel", "Family", "Nature", "Events"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollViewReader { proxy in
                    Form {
                        Section {
                            TextField("Title", text: $title)
                                .focused($focusedField, equals: .title)
                                .textInputAutocapitalization(.sentences)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .notes }
                                .modifier(ShakeEffect(animatableData: shakeTrigger))
                                .id(Field.title)

                            TextField("Notes", text: $notes, axis: .vertical)
                                .focused($focusedField, equals: .notes)
                                .lineLimit(3...6)
                                .id(Field.notes)

                            if showValidationError {
                                Text("Add a title or notes to save this memory.")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                        } footer: {
                            Text("If the title is empty, your notes will be used as the memory title.")
                        }
                        .appListRowBackground()

                        Section("Emoji") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(viewModel.emojiOptions, id: \.self) { emoji in
                                    Button {
                                        HapticManager.lightTap()
                                        selectedEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.title)
                                            .frame(width: 44, height: 44)
                                            .background(Circle().fill(selectedEmoji == emoji ? Color("AppPrimary") : Color("AppBackground")))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .appListRowBackground()

                        Section("Tag") {
                            Picker("Tag", selection: $selectedTag) {
                                ForEach(tags, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.segmented)
                        }
                        .appListRowBackground()

                        if !store.albums.isEmpty {
                            Section("Album") {
                                Picker("Album", selection: $selectedAlbumID) {
                                    Text("None").tag(UUID?.none)
                                    ForEach(store.albums) { album in
                                        Text("\(album.emoji) \(album.name)").tag(Optional(album.id))
                                    }
                                }
                            }
                            .appListRowBackground()
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: showValidationError) { hasError in
                        guard hasError else { return }
                        withAnimation {
                            proxy.scrollTo(Field.title, anchor: .top)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.editingEntry == nil ? "Add Memory" : "Edit Memory")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.lightTap()
                        viewModel.showAddSheet = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(canSave ? Color("AppAccent") : Color("AppTextSecondary"))
                }
            }
            .alert("Can't Save Memory", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {
                    focusedField = .title
                }
            } message: {
                Text("Please enter a title or notes before saving.")
            }
            .onAppear { populateFields() }
        }
    }

    private var canSave: Bool {
        !viewModel.resolvedTitle(title: title, notes: notes).isEmpty
    }

    private func populateFields() {
        if let entry = viewModel.editingEntry {
            title = entry.title
            notes = entry.notes
            selectedEmoji = entry.emoji
            selectedTag = entry.tag
            selectedAlbumID = entry.albumID
        } else if let template = viewModel.selectedTemplate {
            title = template.titlePlaceholder
            notes = template.notesPlaceholder
            selectedEmoji = template.emoji
            selectedTag = template.tag
        }
    }

    private func save() {
        HapticManager.lightTap()

        let success = viewModel.saveEntry(
            title: title,
            emoji: selectedEmoji,
            notes: notes,
            tag: selectedTag,
            albumID: selectedAlbumID,
            existingID: viewModel.editingEntry?.id
        )

        if success {
            viewModel.showAddSheet = false
            dismiss()
            return
        }

        HapticManager.warning()
        showValidationError = true
        showValidationAlert = true
        focusedField = .title
        withAnimation { shakeTrigger += 1 }
    }
}
