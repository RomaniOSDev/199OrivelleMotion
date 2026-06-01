import SwiftUI
import UniformTypeIdentifiers

struct ExportImportView: View {
    @ObservedObject var store: AppStorage
    @State private var showImporter = false
    @State private var showExportSuccess = false
    @State private var showImportSuccess = false
    @State private var showImportError = false
    @State private var exportURL: URL?

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            IconBadgeView(iconName: "square.and.arrow.up", style: .accent, size: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                SectionHeaderView(title: "Export")
                                Text("Save all your data as a JSON file to share or backup.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                        PrimaryActionButton(title: "Export Data") { exportData() }
                        if let exportURL {
                            ShareLink(item: exportURL) {
                                Text("Share Backup File")
                                    .font(.headline)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color("AppAccent"))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                    .appCard()

                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            IconBadgeView(iconName: "square.and.arrow.down", style: .primary, size: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                SectionHeaderView(title: "Import")
                                Text("Restore data from a previously exported JSON backup file.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                        PrimaryActionButton(title: "Import Data") {
                            HapticManager.lightTap()
                            showImporter = true
                        }
                    }
                    .appCard()

                    if showExportSuccess {
                        statusBanner("Export ready!", isSuccess: true)
                    }
                    if showImportSuccess {
                        statusBanner("Import successful!", isSuccess: true)
                    }
                    if showImportError {
                        statusBanner("Could not read the backup file.", isSuccess: false)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Export / Import")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            handleImport(result)
        }
    }

    private func statusBanner(_ text: String, isSuccess: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(isSuccess ? Color("AppAccent") : Color("AppPrimary"))
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 12)
    }

    private func exportData() {
        guard let data = store.exportJSONData() else { return }
        let fileName = "serenehub-backup-\(Int(Date().timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            exportURL = url
            showExportSuccess = true
            HapticManager.success()
            SoundManager.playSuccess()
        } catch {
            showExportSuccess = false
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            if let data = try? Data(contentsOf: url), store.importJSONData(data) {
                showImportSuccess = true
                showImportError = false
                HapticManager.success()
                SoundManager.playSuccess()
            } else {
                showImportError = true
                HapticManager.warning()
            }
        case .failure:
            showImportError = true
            HapticManager.warning()
        }
    }
}
