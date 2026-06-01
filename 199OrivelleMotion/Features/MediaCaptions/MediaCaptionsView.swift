import SwiftUI

struct MediaCaptionsView: View {
    @ObservedObject var store: AppStorage
    @StateObject private var viewModel: MediaCaptionsViewModel

    init(store: AppStorage) {
        self.store = store
        _viewModel = StateObject(wrappedValue: MediaCaptionsViewModel(store: store))
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
            }
            .navigationTitle("Media Captions")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .searchable(text: $viewModel.searchText, prompt: "Search captions")
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
                PrimaryActionButton(title: "Add Caption") {
                    viewModel.editingCaption = nil
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
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddCaptionView(viewModel: viewModel, store: store)
            }
            .sheet(isPresented: $viewModel.showTemplateSheet) {
                TemplatePickerSheet { viewModel.applyTemplate($0) }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            ScrollView {
                EmptyStateView(
                    symbolName: "pencil.tip",
                    title: "No Captions Yet",
                    subtitle: "No captions added yet. Tap '+' to start!"
                )
            }
        } else if viewModel.sortedCaptions.isEmpty {
            ScrollView {
                EmptyStateView(
                    symbolName: "magnifyingglass",
                    title: "No Results",
                    subtitle: "Try a different search term."
                )
            }
        } else {
            List {
                ForEach(viewModel.sortedCaptions) { caption in
                    CaptionCell(caption: caption)
                        .appListRowInsets()
                        .scaleEffect(viewModel.scaledCaptionID == caption.id ? 1.02 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.scaledCaptionID)
                        .swipeActions(edge: .leading) {
                            Button { viewModel.togglePin(caption) } label: {
                                Label(caption.isPinned ? "Unpin" : "Pin", systemImage: caption.isPinned ? "pin.slash" : "pin")
                            }
                            .tint(Color("AppAccent"))
                            Button { viewModel.toggleArchive(caption) } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                            .tint(Color("AppSurface"))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { viewModel.deleteCaption(caption) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                viewModel.editingCaption = caption
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
}

struct AddCaptionView: View {
    @ObservedObject var viewModel: MediaCaptionsViewModel
    @ObservedObject var store: AppStorage
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var date = Date()
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var selectedAlbumID: UUID?
    @State private var showValidationError = false
    @State private var shakeTrigger: CGFloat = 0

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Write your caption...", text: $text, axis: .vertical)
                            .lineLimit(4...8)
                            .modifier(ShakeEffect(animatableData: shakeTrigger))
                        if showValidationError {
                            Text("Please enter caption text.")
                                .font(.caption)
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appListRowBackground()

                    Section("Date") {
                        DatePicker("Timestamp", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    }
                    .appListRowBackground()

                    Section("Tags") {
                        HStack {
                            TextField("Add tag", text: $tagInput)
                            Button("Add") { addTag() }
                                .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        if !tags.isEmpty {
                            FlowTagsView(tags: tags) { tag in tags.removeAll { $0 == tag } }
                        }
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
            }
            .navigationTitle(viewModel.editingCaption == nil ? "Add Caption" : "Edit Caption")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { HapticManager.lightTap(); dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.foregroundStyle(Color("AppAccent"))
                }
            }
            .onAppear { populateFields() }
        }
    }

    private func populateFields() {
        if let caption = viewModel.editingCaption {
            text = caption.text
            date = caption.date
            tags = caption.tags
            selectedAlbumID = caption.albumID
        } else if let template = viewModel.selectedTemplate {
            text = template.captionPrefix ?? template.notesPlaceholder
            tags = [template.tag]
        }
    }

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        HapticManager.lightTap()
        tags.append(trimmed)
        tagInput = ""
    }

    private func save() {
        let success = viewModel.saveCaption(
            text: text,
            date: date,
            tags: tags,
            albumID: selectedAlbumID,
            existingID: viewModel.editingCaption?.id
        )
        if success { dismiss() }
        else {
            HapticManager.warning()
            showValidationError = true
            withAnimation { shakeTrigger += 1 }
        }
    }
}

struct FlowTagsView: View {
    let tags: [String]
    let onRemove: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text(tag).font(.caption)
                        Button {
                            HapticManager.lightTap()
                            onRemove(tag)
                        } label: {
                            Image(systemName: "xmark.circle.fill").font(.caption)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color("AppPrimary"))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .clipShape(Capsule())
                }
            }
        }
    }
}
