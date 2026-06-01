import SwiftUI

struct TemplatePickerSheet: View {
    let onSelect: (EntryTemplate) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                List {
                    ForEach(EntryTemplate.all) { template in
                        Button {
                            HapticManager.lightTap()
                            onSelect(template)
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                Text(template.emoji).font(.title)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text(template.notesPlaceholder)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .appListRowBackground()
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationChrome()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct LinkRelatedItemsSheet: View {
    @ObservedObject var store: AppStorage
    let memoryID: UUID?
    let captionID: UUID?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                List {
                    if memoryID != nil {
                        Section("Link Caption") {
                            ForEach(store.captions.filter { !$0.isArchived }) { caption in
                                Button {
                                    if let memoryID {
                                        store.linkMemoryToCaption(memoryID: memoryID, captionID: caption.id)
                                        HapticManager.success()
                                        dismiss()
                                    }
                                } label: {
                                    Text(String(caption.text.prefix(50)))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                                .appListRowBackground()
                            }
                        }
                    }
                    if captionID != nil {
                        Section("Link Tag") {
                            ForEach(store.memoryEntries.filter { !$0.isArchived }) { entry in
                                Button {
                                    if let captionID {
                                        store.linkMemoryToCaption(memoryID: entry.id, captionID: captionID)
                                        HapticManager.success()
                                        dismiss()
                                    }
                                } label: {
                                    Text(entry.title).foregroundStyle(Color("AppTextPrimary"))
                                }
                                .appListRowBackground()
                            }
                        }
                    }
                    Section("Link Favourite") {
                        ForEach(SampleMediaItem.curated) { item in
                            Button {
                                if let memoryID {
                                    store.linkMemoryToFavourite(memoryID: memoryID, favouriteID: item.id)
                                }
                                if let captionID {
                                    store.linkCaptionToFavourite(captionID: captionID, favouriteID: item.id)
                                }
                                HapticManager.success()
                                dismiss()
                            } label: {
                                Text(item.title).foregroundStyle(Color("AppTextPrimary"))
                            }
                            .appListRowBackground()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Link Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
        }
    }
}
