import SwiftUI

struct GlobalSearchView: View {
    @ObservedObject var store: AppStorage
    @State private var query = ""

    private var results: [SearchResult] {
        store.globalSearch(query: query)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if query.isEmpty {
                EmptyStateView(
                    symbolName: "magnifyingglass",
                    title: "Search Everything",
                    subtitle: "Find tags, captions, favourites and quick notes in one place."
                )
            } else if results.isEmpty {
                EmptyStateView(
                    symbolName: "doc.text.magnifyingglass",
                    title: "No Results",
                    subtitle: "Try a different keyword."
                )
            } else {
                CardListContainer {
                    SectionHeaderView(title: "Results", trailing: "\(results.count)")
                    ForEach(results) { result in
                        SearchResultCell(result: result)
                    }
                }
            }
        }
        .navigationTitle("Global Search")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationChrome()
        .searchable(text: $query, prompt: "Search all content")
    }
}
