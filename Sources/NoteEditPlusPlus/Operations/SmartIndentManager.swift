import Foundation

public struct SmartIndentResult: Equatable, Sendable {
    public let textToInsert: String
    public let cursorOffset: Int

    public init(textToInsert: String, cursorOffset: Int) {
        self.textToInsert = textToInsert
        self.cursorOffset = cursorOffset
    }
}

public struct SmartIndentManager: Sendable {
    /// Computes the exact newline and indentation to insert when the user presses Enter/Return.
    public static func computeNewline(
        fullText: String,
        selectedRange: NSRange,
        tabSize: Int = 4,
        useTabs: Bool = false
    ) -> SmartIndentResult {
        let ns = fullText as NSString
        let location = min(max(0, selectedRange.location), ns.length)

        // 1. Find the start of the current line
        var lineStart = 0
        if location > 0 {
            let searchRange = NSRange(location: 0, length: location)
            let lastNL = ns.range(of: "\n", options: .backwards, range: searchRange)
            if lastNL.location != NSNotFound {
                lineStart = lastNL.location + 1
            }
        }

        // 2. Extract line content up to the cursor
        let lineBeforeCursor = ns.substring(with: NSRange(location: lineStart, length: location - lineStart))

        // 3. Extract base indentation (leading whitespace)
        var baseIndent = ""
        for ch in lineBeforeCursor {
            if ch == " " || ch == "\t" {
                baseIndent.append(ch)
            } else {
                break
            }
        }

        let indentUnit = useTabs ? "\t" : String(repeating: " ", count: max(1, tabSize))
        let trimmedBefore = lineBeforeCursor.trimmingCharacters(in: .whitespaces)

        // 4. Extract text after the cursor on the current line
        var lineAfterCursor = ""
        if location < ns.length {
            let nextSearchRange = NSRange(location: location, length: ns.length - location)
            let nextNL = ns.range(of: "\n", options: [], range: nextSearchRange)
            let lineEnd = (nextNL.location != NSNotFound) ? nextNL.location : ns.length
            lineAfterCursor = ns.substring(with: NSRange(location: location, length: lineEnd - location))
        }
        let trimmedAfter = lineAfterCursor.trimmingCharacters(in: .whitespaces)

        let charBefore = trimmedBefore.last
        let charAfter = trimmedAfter.first

        // 5. Check for Brace / Bracket / Tag expansion (e.g., {|} or [|] or <tag>|</tag>)
        let isBracePair = (charBefore == "{" && charAfter == "}") ||
                          (charBefore == "(" && charAfter == ")") ||
                          (charBefore == "[" && charAfter == "]") ||
                          (trimmedBefore.hasSuffix(">") && trimmedAfter.hasPrefix("</"))

        if isBracePair {
            let text = "\n" + baseIndent + indentUnit + "\n" + baseIndent
            let offset = 1 + baseIndent.count + indentUnit.count
            return SmartIndentResult(textToInsert: text, cursorOffset: offset)
        }

        // 6. Check for Block Opener (Increase indent)
        let isOpeningTag = trimmedBefore.hasSuffix(">") &&
                           !trimmedBefore.hasSuffix("/>") &&
                           !trimmedBefore.hasPrefix("</") &&
                           trimmedBefore.contains("<")

        let isBlockOpener = trimmedBefore.hasSuffix("{") ||
                            trimmedBefore.hasSuffix("(") ||
                            trimmedBefore.hasSuffix("[") ||
                            trimmedBefore.hasSuffix(":") ||
                            trimmedBefore.hasSuffix("do") ||
                            isOpeningTag

        if isBlockOpener {
            let text = "\n" + baseIndent + indentUnit
            return SmartIndentResult(textToInsert: text, cursorOffset: text.count)
        }

        // 7. Standard auto-indent: preserve the indentation of the previous line
        let text = "\n" + baseIndent
        return SmartIndentResult(textToInsert: text, cursorOffset: text.count)
    }

    /// Smart backspace: if the characters before the cursor on the current line are exclusively spaces,
    /// delete spaces up to the previous tab stop in a single backspace.
    public static func smartBackspaceRange(
        fullText: String,
        selectedRange: NSRange,
        tabSize: Int = 4
    ) -> NSRange? {
        guard selectedRange.length == 0, selectedRange.location > 0 else { return nil }
        let ns = fullText as NSString
        let loc = selectedRange.location

        var lineStart = 0
        let searchRange = NSRange(location: 0, length: loc)
        let lastNL = ns.range(of: "\n", options: .backwards, range: searchRange)
        if lastNL.location != NSNotFound {
            lineStart = lastNL.location + 1
        }

        let lineBeforeCursor = ns.substring(with: NSRange(location: lineStart, length: loc - lineStart))
        guard lineBeforeCursor.allSatisfy({ $0 == " " }) && !lineBeforeCursor.isEmpty else {
            return nil
        }

        let currentSpaces = lineBeforeCursor.count
        let remainder = currentSpaces % max(1, tabSize)
        let spacesToDelete = (remainder == 0) ? tabSize : remainder

        return NSRange(location: loc - spacesToDelete, length: spacesToDelete)
    }
}
