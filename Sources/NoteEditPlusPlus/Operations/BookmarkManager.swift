import Foundation

public struct BookmarkManager: Sendable {
    public static func nextBookmark(in bookmarks: Set<Int>, currentLine: Int, totalLines: Int) -> Int? {
        guard !bookmarks.isEmpty else { return nil }
        let sorted = bookmarks.sorted()
        if let next = sorted.first(where: { $0 > currentLine }) {
            return next
        }
        return sorted.first // Wrap around
    }

    public static func prevBookmark(in bookmarks: Set<Int>, currentLine: Int, totalLines: Int) -> Int? {
        guard !bookmarks.isEmpty else { return nil }
        let sorted = bookmarks.sorted()
        if let prev = sorted.last(where: { $0 < currentLine }) {
            return prev
        }
        return sorted.last // Wrap around
    }

    public static func copyBookmarkedLines(text: String, bookmarks: Set<Int>) -> String {
        let lines = text.components(separatedBy: "\n")
        let extracted = lines.enumerated()
            .filter { bookmarks.contains($0.offset + 1) }
            .map { $0.element }
        return extracted.joined(separator: "\n")
    }

    public static func deleteBookmarkedLines(text: String, bookmarks: Set<Int>) -> String {
        let lines = text.components(separatedBy: "\n")
        let kept = lines.enumerated()
            .filter { !bookmarks.contains($0.offset + 1) }
            .map { $0.element }
        return kept.joined(separator: "\n")
    }

    public static func invertBookmarks(current: Set<Int>, totalLines: Int) -> Set<Int> {
        var inverted = Set<Int>()
        for line in 1...max(1, totalLines) {
            if !current.contains(line) {
                inverted.insert(line)
            }
        }
        return inverted
    }
}
