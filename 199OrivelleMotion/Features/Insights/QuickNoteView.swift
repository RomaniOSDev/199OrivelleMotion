import SwiftUI

struct QuickNoteView: View {
    @ObservedObject var store: AppStorage
    @State private var text = ""
    @State private var showSuccess = false
    @State private var shakeTrigger: CGFloat = 0
    @State private var showError = false

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(title: "New Note")
                        TextField("Write a quick note...", text: $text, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(14)
                            .background(Color("AppBackground").opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: shakeTrigger))
                        if showError {
                            Text("Please enter some text.")
                                .font(.caption)
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                    .appCard()

                    PrimaryActionButton(title: "Save Quick Note") { save() }
                }
                .padding(16)

                if !store.quickNotes.isEmpty {
                    CardListContainer {
                        SectionHeaderView(title: "Recent Notes", trailing: "\(store.quickNotes.count)")
                        ForEach(store.quickNotes) { note in
                            QuickNoteCell(note: note)
                                .appCard(padding: 12)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteQuickNote(id: note.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } else {
                    Spacer()
                }
            }

            SuccessCheckmarkOverlay(isShowing: $showSuccess)
        }
        .navigationTitle("Quick Note")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            HapticManager.warning()
            showError = true
            withAnimation { shakeTrigger += 1 }
            return
        }
        store.addQuickNote(trimmed)
        HapticManager.mediumTap()
        SoundManager.playSuccess()
        SuccessCheckmarkOverlay.trigger(isShowing: $showSuccess)
        text = ""
        showError = false
    }
}
