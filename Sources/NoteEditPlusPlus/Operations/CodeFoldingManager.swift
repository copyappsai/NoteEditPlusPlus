import Foundation

public struct CodeFoldRange: Identifiable, Equatable, Sendable {
    public var id: Int { startLine }
    public let startLine: Int
    public let endLine: Int
    public var isFolded: Bool

    public init(startLine: Int, endLine: Int, isFolded: Bool = false) {
        self.startLine = startLine
        self.endLine = endLine
        self.isFolded = isFolded
    }
}

public struct CodeFoldingManager: Sendable {
    public static func detectFoldableRanges(text: String, language: SyntaxLanguage) -> [CodeFoldRange] {
        let lines = text.components(separatedBy: "\n")
        var ranges: [CodeFoldRange] = []

        // 1. Brace-based languages ({ ... })
        var braceStack: [Int] = [] // Line numbers of opening braces (1-based)
        for (i, line) in lines.enumerated() {
            let lineNum = i + 1
            var openCount = 0
            var closeCount = 0

            for char in line {
                if char == "{" {
                    openCount += 1
                } else if char == "}" {
                    closeCount += 1
                }
            }

            for _ in 0..<openCount {
                braceStack.append(lineNum)
            }

            for _ in 0..<closeCount {
                if let start = braceStack.popLast() {
                    if lineNum > start {
                        ranges.append(CodeFoldRange(startLine: start, endLine: lineNum))
                    }
                }
            }
        }

        // 2. Indentation-based folding for Python / YAML if braceStack found few
        if (language == .python || language == .yaml) && ranges.isEmpty {
            var blockStack: [(line: Int, indent: Int)] = []

            for (i, line) in lines.enumerated() {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

                let lineNum = i + 1
                let indent = line.prefix(while: { $0 == " " || $0 == "\t" }).count

                while let last = blockStack.last, last.indent >= indent {
                    let popped = blockStack.removeLast()
                    if (lineNum - 1) > popped.line {
                        ranges.append(CodeFoldRange(startLine: popped.line, endLine: lineNum - 1))
                    }
                }

                if trimmed.hasSuffix(":") {
                    blockStack.append((lineNum, indent))
                }
            }

            let lastLine = lines.count
            while let popped = blockStack.popLast() {
                if lastLine > popped.line {
                    ranges.append(CodeFoldRange(startLine: popped.line, endLine: lastLine))
                }
            }
        }

        return ranges.sorted { $0.startLine < $1.startLine }
    }
}
