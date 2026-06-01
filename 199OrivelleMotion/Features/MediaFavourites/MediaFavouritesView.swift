import SwiftUI

struct MediaFavouritesView: View {
    @ObservedObject var store: AppStorage
    @StateObject private var viewModel: MediaFavouritesViewModel
    @State private var showFavouritesOnly = false

    init(store: AppStorage) {
        self.store = store
        _viewModel = StateObject(wrappedValue: MediaFavouritesViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                content
            }
            .navigationTitle("Media Favourites")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .searchable(text: $viewModel.searchText, prompt: "Search collections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.lightTap()
                        showFavouritesOnly.toggle()
                    } label: {
                        Image(systemName: showFavouritesOnly ? "star.fill" : "star")
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
            }
            .sheet(item: $viewModel.selectedItem) { item in
                MediaDetailSheet(item: item, viewModel: viewModel, store: store)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        let items = viewModel.displayedItems(showFavourites: showFavouritesOnly)

        if showFavouritesOnly && viewModel.favouriteItems.isEmpty {
            ScrollView {
                EmptyStateView(
                    symbolName: "star.circle",
                    title: "No Favourites Yet",
                    subtitle: "No favourites added yet!"
                )
            }
        } else if items.isEmpty {
            ScrollView {
                EmptyStateView(
                    symbolName: "magnifyingglass",
                    title: "No Results",
                    subtitle: "Try a different search term."
                )
            }
        } else {
            List {
                ForEach(items) { item in
                    Button {
                        HapticManager.lightTap()
                        viewModel.selectedItem = item
                    } label: {
                        FavouriteMediaCell(
                            item: item,
                            isFavourite: store.isFavourite(mediaId: item.id),
                            rating: store.favouriteRating(for: item.id),
                            notePreview: store.userNotes[item.id]
                        )
                    }
                    .buttonStyle(.plain)
                    .appListRowInsets()
                    .swipeActions(edge: .leading) {
                        Button { viewModel.toggleFavourite(item) } label: {
                            Label(
                                store.isFavourite(mediaId: item.id) ? "Unfavourite" : "Favourite",
                                systemImage: store.isFavourite(mediaId: item.id) ? "star.slash" : "star.fill"
                            )
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

struct MediaDetailSheet: View {
    let item: SampleMediaItem
    @ObservedObject var viewModel: MediaFavouritesViewModel
    @ObservedObject var store: AppStorage
    @Environment(\.dismiss) private var dismiss
    @State private var noteText = ""
    @State private var showSaveConfirmation = false
    @State private var selectedRating = 3

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        FavouriteMediaCell(
                            item: item,
                            isFavourite: store.isFavourite(mediaId: item.id),
                            rating: selectedRating
                        )
                        .appCard(padding: 14)

                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeaderView(title: "Personal Priority")
                            PriorityDotsView(rating: selectedRating)
                            HStack(spacing: 10) {
                                ForEach(1...5, id: \.self) { level in
                                    Button {
                                        HapticManager.lightTap()
                                        selectedRating = level
                                    } label: {
                                        Text("\(level)")
                                            .font(.headline)
                                            .frame(width: 44, height: 44)
                                            .foregroundStyle(selectedRating == level ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                                            .background(Circle().fill(selectedRating == level ? Color("AppPrimary") : Color("AppSurface")))
                                    }
                                    .buttonStyle(PressableButtonStyle())
                                }
                            }
                        }
                        .appCard()

                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeaderView(title: "Your Notes")
                            TextField("Add personal notes...", text: $noteText, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(12)
                                .background(Color("AppBackground").opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        .appCard()

                        if !store.customCollections.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Add to Collection")
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                ForEach(store.customCollections) { collection in
                                    Button {
                                        store.addFavouriteToCollection(collectionID: collection.id, mediaID: item.id)
                                        HapticManager.success()
                                    } label: {
                                        HStack {
                                            Text("\(collection.emoji) \(collection.name)")
                                                .foregroundStyle(Color("AppTextPrimary"))
                                            Spacer()
                                            if collection.favouriteIDs.contains(item.id) {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(Color("AppAccent"))
                                            }
                                        }
                                        .padding(12)
                                        .background(Color("AppSurface"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(PressableButtonStyle())
                                }
                            }
                        }

                        PrimaryActionButton(title: "Save") {
                            viewModel.saveNote(for: item, note: noteText)
                            store.setFavouriteRating(mediaId: item.id, rating: selectedRating)
                            SuccessCheckmarkOverlay.trigger(isShowing: $showSaveConfirmation)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { dismiss() }
                        }
                    }
                    .padding(20)
                    SuccessCheckmarkOverlay(isShowing: $showSaveConfirmation)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { HapticManager.lightTap(); dismiss() }
                }
            }
            .onAppear {
                noteText = viewModel.note(for: item)
                selectedRating = store.favouriteRating(for: item.id) ?? 3
            }
        }
    }
}
