import Foundation

public enum TrimMode: Sendable {
    case leading
    case trailing
    case both
}

public enum TextCase: Sendable {
    case uppercase
    case lowercase
    case titleCase
    case sentenceCase
    case invertCase
}

public struct TextOperationsManager: Sendable {
    
    // MARK: - Line Operations
    
    public static func duplicateLineOrSelection(text: String, selectedRange: NSRange) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        if selectedRange.length > 0 {
            // Duplicate selection
            let selectedText = ns.substring(with: selectedRange)
            let newText = ns.replacingCharacters(in: NSRange(location: selectedRange.location + selectedRange.length, length: 0), with: selectedText)
            let newRange = NSRange(location: selectedRange.location + selectedRange.length, length: selectedRange.length)
            return (newText, newRange)
        } else {
            // Duplicate current line
            let lineRange = ns.lineRange(for: selectedRange)
            let lineText = ns.substring(with: lineRange)
            var duplicateText = lineText
            if !duplicateText.hasSuffix("\n") && !duplicateText.hasSuffix("\r") {
                duplicateText = "\n" + duplicateText
            }
            let insertLocation = NSMaxRange(lineRange)
            let newText = ns.replacingCharacters(in: NSRange(location: insertLocation, length: 0), with: duplicateText)
            let newRange = NSRange(location: insertLocation + (selectedRange.location - lineRange.location), length: 0)
            return (newText, newRange)
        }
    }
    
    public static func deleteLine(text: String, selectedRange: NSRange) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        if ns.length == 0 { return (text, selectedRange) }
        
        let lineRange = ns.lineRange(for: selectedRange)
        let newText = ns.replacingCharacters(in: lineRange, with: "")
        let newLocation = min(lineRange.location, (newText as NSString).length)
        return (newText, NSRange(location: newLocation, length: 0))
    }
    
    public static func moveLineUp(text: String, selectedRange: NSRange) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let currentLineRange = ns.lineRange(for: selectedRange)
        if currentLineRange.location == 0 {
            return (text, selectedRange) // Already at top
        }
        
        // Find previous line range
        let prevLineEnd = currentLineRange.location - 1
        let prevLineRange = ns.lineRange(for: NSRange(location: prevLineEnd, length: 0))
        
        var currentText = ns.substring(with: currentLineRange)
        var prevText = ns.substring(with: prevLineRange)
        
        // Handle trailing newline if at EOF
        let hasTrailingNewline = currentText.hasSuffix("\n") || currentText.hasSuffix("\r")
        if !hasTrailingNewline {
            currentText += "\n"
            if prevText.hasSuffix("\n") {
                prevText.removeLast()
            }
        }
        
        let combinedRange = NSRange(location: prevLineRange.location, length: prevLineRange.length + currentLineRange.length)
        let swapped = currentText + prevText
        let newText = ns.replacingCharacters(in: combinedRange, with: swapped)
        
        let cursorOffset = selectedRange.location - currentLineRange.location
        let newRange = NSRange(location: prevLineRange.location + cursorOffset, length: selectedRange.length)
        return (newText, newRange)
    }
    
    public static func moveLineDown(text: String, selectedRange: NSRange) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let currentLineRange = ns.lineRange(for: selectedRange)
        let currentLineEnd = NSMaxRange(currentLineRange)
        if currentLineEnd >= ns.length {
            return (text, selectedRange) // Already at bottom
        }
        
        let nextLineRange = ns.lineRange(for: NSRange(location: currentLineEnd, length: 0))
        
        var currentText = ns.substring(with: currentLineRange)
        var nextText = ns.substring(with: nextLineRange)
        
        let nextHasTrailingNewline = nextText.hasSuffix("\n") || nextText.hasSuffix("\r")
        if !nextHasTrailingNewline {
            nextText += "\n"
            if currentText.hasSuffix("\n") {
                currentText.removeLast()
            }
        }
        
        let combinedRange = NSRange(location: currentLineRange.location, length: currentLineRange.length + nextLineRange.length)
        let swapped = nextText + currentText
        let newText = ns.replacingCharacters(in: combinedRange, with: swapped)
        
        let cursorOffset = selectedRange.location - currentLineRange.location
        let newRange = NSRange(location: currentLineRange.location + nextLineRange.length + cursorOffset, length: selectedRange.length)
        return (newText, newRange)
    }
    
    public static func joinLines(text: String, selectedRange: NSRange) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let targetRange = selectedRange.length > 0 ? ns.lineRange(for: selectedRange) : ns.lineRange(for: NSRange(location: selectedRange.location, length: 0))
        let targetText = ns.substring(with: targetRange)
        
        let joined = targetText
            .replacingOccurrences(of: "\r\n", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
            + "\n"
        
        let newText = ns.replacingCharacters(in: targetRange, with: joined)
        return (newText, NSRange(location: targetRange.location, length: joined.count))
    }
    
    // MARK: - Sorting & Duplicates
    
    public static func sortLines(text: String, selectedRange: NSRange, ascending: Bool = true, caseSensitive: Bool = false, numeric: Bool = false) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let range = selectedRange.length > 0 ? ns.lineRange(for: selectedRange) : NSRange(location: 0, length: ns.length)
        let sub = ns.substring(with: range)
        
        var lines = sub.components(separatedBy: "\n")
        let hadTrailingNewline = lines.last?.isEmpty == true
        if hadTrailingNewline { lines.removeLast() }
        
        lines.sort { a, b in
            if numeric {
                let numA = Double(a.trimmingCharacters(in: .whitespaces)) ?? 0
                let numB = Double(b.trimmingCharacters(in: .whitespaces)) ?? 0
                return ascending ? numA < numB : numA > numB
            }
            if caseSensitive {
                return ascending ? a < b : a > b
            } else {
                return ascending ? a.localizedCaseInsensitiveCompare(b) == .orderedAscending : a.localizedCaseInsensitiveCompare(b) == .orderedDescending
            }
        }
        
        var result = lines.joined(separator: "\n")
        if hadTrailingNewline { result += "\n" }
        
        let newText = ns.replacingCharacters(in: range, with: result)
        return (newText, NSRange(location: range.location, length: (result as NSString).length))
    }
    
    public static func removeDuplicateLines(text: String, selectedRange: NSRange) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let range = selectedRange.length > 0 ? ns.lineRange(for: selectedRange) : NSRange(location: 0, length: ns.length)
        let sub = ns.substring(with: range)
        
        var seen = Set<String>()
        var uniqueLines: [String] = []
        var lines = sub.components(separatedBy: "\n")
        let hadTrailing = lines.last?.isEmpty == true
        if hadTrailing { lines.removeLast() }
        
        for line in lines {
            if !seen.contains(line) {
                seen.insert(line)
                uniqueLines.append(line)
            }
        }
        
        var result = uniqueLines.joined(separator: "\n")
        if hadTrailing { result += "\n" }
        
        let newText = ns.replacingCharacters(in: range, with: result)
        return (newText, NSRange(location: range.location, length: (result as NSString).length))
    }
    
    public static func removeEmptyLines(text: String, selectedRange: NSRange) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let range = selectedRange.length > 0 ? ns.lineRange(for: selectedRange) : NSRange(location: 0, length: ns.length)
        let sub = ns.substring(with: range)
        
        let lines = sub.components(separatedBy: "\n")
        let filtered = lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let result = filtered.joined(separator: "\n") + (sub.hasSuffix("\n") ? "\n" : "")
        
        let newText = ns.replacingCharacters(in: range, with: result)
        return (newText, NSRange(location: range.location, length: (result as NSString).length))
    }
    
    public static func trimWhitespace(text: String, selectedRange: NSRange, mode: TrimMode) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let range = selectedRange.length > 0 ? ns.lineRange(for: selectedRange) : NSRange(location: 0, length: ns.length)
        let sub = ns.substring(with: range)
        
        var lines = sub.components(separatedBy: "\n")
        let hadTrailing = lines.last?.isEmpty == true
        if hadTrailing { lines.removeLast() }
        
        let trimmedLines = lines.map { line -> String in
            switch mode {
            case .leading:
                return line.replacingOccurrences(of: "^[ \\t]+", with: "", options: .regularExpression)
            case .trailing:
                return line.replacingOccurrences(of: "[ \\t]+$", with: "", options: .regularExpression)
            case .both:
                return line.trimmingCharacters(in: .whitespaces)
            }
        }
        
        var result = trimmedLines.joined(separator: "\n")
        if hadTrailing { result += "\n" }
        
        let newText = ns.replacingCharacters(in: range, with: result)
        return (newText, NSRange(location: range.location, length: (result as NSString).length))
    }
    
    // MARK: - Case Conversions
    
    public static func convertCase(text: String, selectedRange: NSRange, targetCase: TextCase) -> (newText: String, newRange: NSRange) {
        let ns = text as NSString
        let range = selectedRange.length > 0 ? selectedRange : NSRange(location: 0, length: ns.length)
        let sub = ns.substring(with: range)
        
        let converted: String
        switch targetCase {
        case .uppercase:
            converted = sub.uppercased()
        case .lowercase:
            converted = sub.lowercased()
        case .titleCase:
            converted = sub.capitalized
        case .sentenceCase:
            converted = sub.prefix(1).uppercased() + sub.dropFirst().lowercased()
        case .invertCase:
            converted = String(sub.map { char in
                if char.isUppercase {
                    return Character(char.lowercased())
                } else if char.isLowercase {
                    return Character(char.uppercased())
                }
                return char
            })
        }
        
        let newText = ns.replacingCharacters(in: range, with: converted)
        return (newText, NSRange(location: range.location, length: (converted as NSString).length))
    }
    
    // MARK: - Indentation and Whitespace Conversion
    
    public static func convertTabsToSpaces(text: String, tabSize: Int = 4) -> String {
        let spaces = String(repeating: " ", count: max(1, tabSize))
        return text.replacingOccurrences(of: "\t", with: spaces)
    }
    
    public static func convertSpacesToTabs(text: String, tabSize: Int = 4) -> String {
        let spaces = String(repeating: " ", count: max(1, tabSize))
        return text.replacingOccurrences(of: spaces, with: "\t")
    }
    
    public static func currentFormattedDate(longFormat: Bool = false) -> String {
        let formatter = DateFormatter()
        if longFormat {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        } else {
            formatter.dateFormat = "yyyy-MM-dd"
        }
        return formatter.string(from: Date())
    }
}
