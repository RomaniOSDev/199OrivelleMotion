import SwiftUI

struct CustomCollectionsView: View {
    @ObservedObject var store: AppStorage
    @State private var showCreate = false
    @State private var newName = ""
    @State private var newEmoji = "⭐"

    private let emojis = ["⭐", "❤️", "🌅", "✈️", "🎨", "📸", "🎵", "🌊"]

    var body: some View {
        ZStack {
                AppBackgroundView()
                if store.customCollections.isEmpty {
                    VStack(spacing: 20) {
                        EmptyStateView(
                            symbolName: "square.stack",
                            title: "No Custom Collections",
                            subtitle: "Create your own curated media collections."
                        )
                        PrimaryActionButton(title: "Create Collection") {
                            showCreate = true
                        }
                        .padding(.horizontal, 32)
                    }
                } else {
                    List {
                        ForEach(store.customCollections) { collection in
                            NavigationLink(value: collection) {
                                HStack(spacing: 14) {
                                    Text(collection.emoji).font(.title2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(collection.name)
                                            .font(.headline)
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Text("\(collection.favouriteIDs.count) items")
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                    Spacer()
                                }
                            }
                            .appListRowBackground()
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.deleteCustomCollection(id: collection.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Custom Collections")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.lightTap()
                        showCreate = true
                    } label: {
                        Image(systemName: "plus").foregroundStyle(Color("AppAccent"))
                    }
                }
            }
            .sheet(isPresented: $showCreate) { createSheet }
            .navigationDestination(for: CustomCollection.self) { collection in
                CustomCollectionDetailView(store: store, collection: collection)
            }
    }

    private var createSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    TextField("Collection name", text: $newName)
                        .appListRowBackground()
                    Section("Emoji") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(emojis, id: \.self) { emoji in
                                Button {
                                    newEmoji = emoji
                                } label: {
                                    Text(emoji).font(.title)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(newEmoji == emoji ? Color("AppPrimary") : Color("AppBackground")))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .appListRowBackground()
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showCreate = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        HapticManager.mediumTap()
                        _ = store.addCustomCollection(name: name, emoji: newEmoji)
                        newName = ""
                        showCreate = false
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
            }
        }
    }
}

struct CustomCollectionDetailView: View {
    @ObservedObject var store: AppStorage
    @State var collection: CustomCollection
    @State private var notes: String = ""

    var body: some View {
        ZStack {
            AppBackgroundView()
            List {
                Section("Notes") {
                    TextField("Collection notes...", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                        .onChange(of: notes) { newValue in
                            collection.notes = newValue
                            store.updateCustomCollection(collection)
                        }
                }
                .appListRowBackground()

                Section("Items") {
                    ForEach(SampleMediaItem.curated.filter { collection.favouriteIDs.contains($0.id) }) { item in
                        HStack {
                            MediaThumbnailView(iconName: item.iconName, accentHue: item.accentHue, size: 40)
                            Text(item.title).foregroundStyle(Color("AppTextPrimary"))
                        }
                        .appListRowBackground()
                    }
                }

                Section("Add Items") {
                    ForEach(SampleMediaItem.curated.filter { !collection.favouriteIDs.contains($0.id) }) { item in
                        Button {
                            HapticManager.lightTap()
                            store.addFavouriteToCollection(collectionID: collection.id, mediaID: item.id)
                            if let updated = store.customCollections.first(where: { $0.id == collection.id }) {
                                collection = updated
                            }
                        } label: {
                            HStack {
                                MediaThumbnailView(iconName: item.iconName, accentHue: item.accentHue, size: 36)
                                Text(item.title).foregroundStyle(Color("AppTextPrimary"))
                                Spacer()
                                Image(systemName: "plus.circle").foregroundStyle(Color("AppAccent"))
                            }
                        }
                        .appListRowBackground()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("\(collection.emoji) \(collection.name)")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .onAppear { notes = collection.notes }
    }
}

struct CollectionCompareView: View {
    @ObservedObject var store: AppStorage
    @State private var leftID: UUID?
    @State private var rightID: UUID?

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        collectionPicker(title: "Collection A", selection: $leftID)
                        collectionPicker(title: "Collection B", selection: $rightID)
                    }

                    if let leftID, let rightID, leftID != rightID,
                       let left = store.customCollections.first(where: { $0.id == leftID }),
                       let right = store.customCollections.first(where: { $0.id == rightID }) {
                        HStack(alignment: .top, spacing: 12) {
                            compareColumn(collection: left)
                            compareColumn(collection: right)
                        }
                    } else {
                        EmptyStateView(
                            symbolName: "rectangle.split.2x1",
                            title: "Select Two Collections",
                            subtitle: "Pick two different collections to compare side by side."
                        )
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Compare Collections")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }

    private func collectionPicker(title: String, selection: Binding<UUID?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
            Picker(title, selection: Binding(
                get: { selection.wrappedValue ?? store.customCollections.first?.id ?? UUID() },
                set: { selection.wrappedValue = $0 }
            )) {
                ForEach(store.customCollections) { col in
                    Text("\(col.emoji) \(col.name)").tag(col.id)
                }
            }
            .pickerStyle(.menu)
            .tint(Color("AppAccent"))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func compareColumn(collection: CustomCollection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(collection.emoji) \(collection.name)")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text("\(collection.favouriteIDs.count) items")
                .font(.caption)
                .foregroundStyle(Color("AppAccent"))
            ForEach(SampleMediaItem.curated.filter { collection.favouriteIDs.contains($0.id) }) { item in
                HStack(spacing: 8) {
                    MediaThumbnailView(iconName: item.iconName, accentHue: item.accentHue, size: 32)
                    Text(item.title)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
