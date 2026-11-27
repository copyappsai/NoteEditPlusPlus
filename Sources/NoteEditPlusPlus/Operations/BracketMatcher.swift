import Foundation

public struct BracketMatchResult: Equatable, Sendable {
    public let sourceRange: NSRange
    public let matchRange: NSRange
    public let isClosing: Bool

    public init(sourceRange: NSRange, matchRange: NSRange, isClosing: Bool) {
        self.sourceRange = sourceRange
        self.matchRange = matchRange
        self.isClosing = isClosing
    }
}

public struct BracketMatcher: Sendable {
    private static let pairs: [Character: Character] = [
        "(": ")",
        "[": "]",
        "{": "}"
    ]

    private static let reversePairs: [Character: Character] = [
        ")": "(",
        "]": "[",
        "}": "{"
    ]

    public static func findMatchingBracket(in text: String, at index: Int) -> BracketMatchResult? {
        guard !text.isEmpty else { return nil }
        let chars = Array(text)
        let len = chars.count
        guard index >= 0 && index <= len else { return nil }

        // Check character right before cursor or at cursor
        var testIndex = index
        var bracketChar: Character? = nil

        if testIndex < len && (pairs.keys.contains(chars[testIndex]) || reversePairs.keys.contains(chars[testIndex])) {
            bracketChar = chars[testIndex]
        } else if testIndex > 0 && (pairs.keys.contains(chars[testIndex - 1]) || reversePairs.keys.contains(chars[testIndex - 1])) {
            testIndex -= 1
            bracketChar = chars[testIndex]
        }

        guard let target = bracketChar else { return nil }

        if let closing = pairs[target] {
            // Forward search for matching closing bracket
            var depth = 1
            var scan = testIndex + 1
            while scan < len {
                let c = chars[scan]
                if c == target {
                    depth += 1
                } else if c == closing {
                    depth -= 1
                    if depth == 0 {
                        return BracketMatchResult(
                            sourceRange: NSRange(location: testIndex, length: 1),
                            matchRange: NSRange(location: scan, length: 1),
                            isClosing: false
                        )
                    }
                }
                scan += 1
            }
        } else if let opening = reversePairs[target] {
            // Backward search for matching opening bracket
            var depth = 1
            var scan = testIndex - 1
            while scan >= 0 {
                let c = chars[scan]
                if c == target {
                    depth += 1
                } else if c == opening {
                    depth -= 1
                    if depth == 0 {
                        return BracketMatchResult(
                            sourceRange: NSRange(location: testIndex, length: 1),
                            matchRange: NSRange(location: scan, length: 1),
                            isClosing: true
                        )
                    }
                }
                scan -= 1
            }
        }

        return nil
    }

    public static func jumpToMatchingBracket(in text: String, at index: Int) -> Int? {
        guard let match = findMatchingBracket(in: text, at: index) else { return nil }
        return match.matchRange.location
    }
}
