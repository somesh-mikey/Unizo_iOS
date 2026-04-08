import Foundation

enum SearchHistoryStore {
    private static let key = "recent_search_terms"
    private static let maxCount = 10

    static func all() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    static func add(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var searches = all()
        searches.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        searches.insert(trimmed, at: 0)

        if searches.count > maxCount {
            searches = Array(searches.prefix(maxCount))
        }

        UserDefaults.standard.set(searches, forKey: key)
        print("🔎 [SearchHistory] Saved term='\(trimmed)' total=\(searches.count)")
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        print("🧹 [SearchHistory] Cleared recent searches")
    }
}
