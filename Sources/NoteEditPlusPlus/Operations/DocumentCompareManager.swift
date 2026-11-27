import Foundation

public enum DiffLineType: Sendable {
    case unchanged
    case added
    case removed
    case modified
}

public struct DiffLine: Identifiable, Sendable {
    public let id = UUID()
    public let type: DiffLineType
    public let lineNumA: Int?
    public let textA: String?
    public let lineNumB: Int?
    public let textB: String?

    public init(type: DiffLineType, lineNumA: Int?, textA: String?, lineNumB: Int?, textB: String?) {
        self.type = type
        self.lineNumA = lineNumA
        self.textA = textA
        self.lineNumB = lineNumB
        self.textB = textB
    }
}

public struct DiffSummary: Sendable {
    public let lines: [DiffLine]
    public let addedCount: Int
    public let removedCount: Int
    public let modifiedCount: Int
    public let unchangedCount: Int
}

public struct DocumentCompareManager: Sendable {
    public static func compare(textA: String, textB: String) -> DiffSummary {
        let linesA = textA.components(separatedBy: "\n")
        let linesB = textB.components(separatedBy: "\n")

        let n = linesA.count
        let m = linesB.count

        // Standard dynamic programming LCS (Longest Common Subsequence) table
        var lcs = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)

        for i in 0..<n {
            for j in 0..<m {
                if linesA[i] == linesB[j] {
                    lcs[i + 1][j + 1] = lcs[i][j] + 1
                } else {
                    lcs[i + 1][j + 1] = max(lcs[i + 1][j], lcs[i][j + 1])
                }
            }
        }

        var result: [DiffLine] = []
        var i = n
        var j = m

        while i > 0 || j > 0 {
            if i > 0 && j > 0 && linesA[i - 1] == linesB[j - 1] {
                result.append(DiffLine(
                    type: .unchanged,
                    lineNumA: i,
                    textA: linesA[i - 1],
                    lineNumB: j,
                    textB: linesB[j - 1]
                ))
                i -= 1
                j -= 1
            } else if j > 0 && (i == 0 || lcs[i][j - 1] >= lcs[i - 1][j]) {
                result.append(DiffLine(
                    type: .added,
                    lineNumA: nil,
                    textA: nil,
                    lineNumB: j,
                    textB: linesB[j - 1]
                ))
                j -= 1
            } else if i > 0 && (j == 0 || lcs[i][j - 1] < lcs[i - 1][j]) {
                result.append(DiffLine(
                    type: .removed,
                    lineNumA: i,
                    textA: linesA[i - 1],
                    lineNumB: nil,
                    textB: nil
                ))
                i -= 1
            }
        }

        let ordered = result.reversed()
        var added = 0
        var removed = 0
        var unchanged = 0

        for line in ordered {
            switch line.type {
            case .added: added += 1
            case .removed: removed += 1
            case .unchanged: unchanged += 1
            case .modified: break
            }
        }

        return DiffSummary(
            lines: Array(ordered),
            addedCount: added,
            removedCount: removed,
            modifiedCount: 0,
            unchangedCount: unchanged
        )
    }
}
