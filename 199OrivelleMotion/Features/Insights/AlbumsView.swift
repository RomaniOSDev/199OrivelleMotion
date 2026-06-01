import SwiftUI

struct AlbumsView: View {
    @ObservedObject var store: AppStorage
    @State private var showCreateSheet = false
    @State private var newAlbumName = ""
    @State private var newAlbumEmoji = "📁"

    private let emojiOptions = ["📁", "✈️", "👨‍👩‍👧", "🌿", "🎉", "📸", "❤️", "⭐"]

    var body: some View {
        ZStack {
            AppBackgroundView()
            if store.albums.isEmpty {
                VStack(spacing: 20) {
                    EmptyStateView(
                        symbolName: "folder",
                        title: "No Albums Yet",
                        subtitle: "Create albums to group your tags and captions."
                    )
                    PrimaryActionButton(title: "Create Album") {
                        showCreateSheet = true
                    }
                    .padding(.horizontal, 32)
                }
            } else {
                List {
                    ForEach(store.albums) { album in
                        NavigationLink(value: album) {
                            AlbumCell(album: album)
                        }
                        .appListRowInsets()
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) { store.deleteAlbum(id: album.id) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Albums")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticManager.lightTap()
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) { createAlbumSheet }
        .navigationDestination(for: Album.self) { album in
            AlbumDetailView(store: store, album: album)
        }
    }

    private var createAlbumSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Album name", text: $newAlbumName)
                    }
                    .appListRowBackground()
                    Section("Emoji") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button {
                                    HapticManager.lightTap()
                                    newAlbumEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.title)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle().fill(newAlbumEmoji == emoji ? Color("AppPrimary") : Color("AppBackground"))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .appListRowBackground()
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Album")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCreateSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let name = newAlbumName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        HapticManager.mediumTap()
                        SoundManager.playSuccess()
                        _ = store.addAlbum(name: name, emoji: newAlbumEmoji)
                        newAlbumName = ""
                        showCreateSheet = false
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
            }
        }
    }
}

struct AlbumDetailView: View {
    @ObservedObject var store: AppStorage
    let album: Album

    private var memories: [MemoryEntry] {
        store.memoryEntries.filter { album.memoryEntryIDs.contains($0.id) }
    }

    private var captions: [Caption] {
        store.captions.filter { album.captionIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            List {
                if !memories.isEmpty {
                    Section("Tags") {
                        ForEach(memories) { entry in
                            HStack {
                                Text(entry.emoji)
                                Text(entry.title)
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                            .appListRowBackground()
                        }
                    }
                }
                if !captions.isEmpty {
                    Section("Captions") {
                        ForEach(captions) { caption in
                            Text(caption.text)
                                .lineLimit(2)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .appListRowBackground()
                        }
                    }
                }
                if memories.isEmpty && captions.isEmpty {
                    Section {
                        Text("No items in this album yet.")
                            .foregroundStyle(Color("AppTextSecondary"))
                            .appListRowBackground()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("\(album.emoji) \(album.name)")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }
}
