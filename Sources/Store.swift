import Foundation
import SwiftUI

/// Remote source for the guide library. The app fetches this JSON on launch;
/// when the fetch fails it falls back to the cached copy, and finally to the
/// bundled snapshot in GuidesData.
let GUIDES_JSON_URL = "https://raw.githubusercontent.com/kar-liang/iconpack/master/data/gta6-guides.json"

final class GuideStore: ObservableObject {
    @Published var library: GuideLibrary
    @Published var favoriteGuideIDs: Set<String> = [] {
        didSet { saveStringSet(favoriteGuideIDs, key: Self.favoritesKey) }
    }
    @Published var checkedItemIDs: Set<String> = [] {
        didSet { saveStringSet(checkedItemIDs, key: Self.checkedKey) }
    }

    private static let cacheKey = "gta6Helper.libraryCache.v1"
    private static let favoritesKey = "gta6Helper.favorites.v1"
    private static let checkedKey = "gta6Helper.checkedItems.v1"

    init() {
        // Render immediately: cached remote copy if we have one, otherwise
        // the bundled snapshot. The remote refresh happens in .task.
        if let data = UserDefaults.standard.data(forKey: Self.cacheKey),
           let cached = try? JSONDecoder().decode(GuideLibrary.self, from: data) {
            library = cached
        } else {
            library = GuidesData.fallback
        }
        favoriteGuideIDs = Self.loadStringSet(key: Self.favoritesKey)
        checkedItemIDs = Self.loadStringSet(key: Self.checkedKey)
    }

    // MARK: - Remote refresh

    func refreshFromRemote() async {
        guard let url = URL(string: GUIDES_JSON_URL) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let remote = try JSONDecoder().decode(GuideLibrary.self, from: data)
            library = remote
            UserDefaults.standard.set(data, forKey: Self.cacheKey)
        } catch {
            // Offline or bad payload: keep showing the bundled/cached data.
        }
    }

    // MARK: - Favorites

    func isFavorite(_ guide: GuideArticle) -> Bool {
        favoriteGuideIDs.contains(guide.id)
    }

    func toggleFavorite(_ guide: GuideArticle) {
        if favoriteGuideIDs.contains(guide.id) {
            favoriteGuideIDs.remove(guide.id)
        } else {
            favoriteGuideIDs.insert(guide.id)
        }
    }

    var favoriteGuides: [GuideArticle] {
        library.guides.filter { favoriteGuideIDs.contains($0.id) }
    }

    // MARK: - Checklist progress

    func isChecked(_ item: ChecklistItem) -> Bool {
        checkedItemIDs.contains(item.id)
    }

    func toggleChecked(_ item: ChecklistItem) {
        if checkedItemIDs.contains(item.id) {
            checkedItemIDs.remove(item.id)
        } else {
            checkedItemIDs.insert(item.id)
        }
    }

    func checkedCount(in group: ChecklistGroup) -> Int {
        group.items.filter { checkedItemIDs.contains($0.id) }.count
    }

    func progress(in group: ChecklistGroup) -> Double {
        guard !group.items.isEmpty else { return 0 }
        return Double(checkedCount(in: group)) / Double(group.items.count)
    }

    var overallCheckedCount: Int {
        library.allChecklistItems.filter { checkedItemIDs.contains($0.id) }.count
    }

    var overallProgress: Double {
        let total = library.allChecklistItems.count
        guard total > 0 else { return 0 }
        return Double(overallCheckedCount) / Double(total)
    }

    // MARK: - Persistence helpers

    private static func loadStringSet(key: String) -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(decoded)
    }

    private func saveStringSet(_ set: Set<String>, key: String) {
        if let data = try? JSONEncoder().encode(Array(set)) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
