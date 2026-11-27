import Cocoa

@MainActor
public final class SyntaxHighlighter {
    public static func highlight(textStorage: NSTextStorage, language: SyntaxLanguage, font: NSFont, theme: AppTheme = .classicLight) {
        let fullRange = NSRange(location: 0, length: textStorage.length)
        guard fullRange.length > 0 else { return }

        textStorage.beginEditing()

        // 1. Reset everything to base font and text color
        textStorage.addAttribute(.foregroundColor, value: theme.textColor, range: fullRange)
        textStorage.addAttribute(.font, value: font, range: fullRange)

        guard language != .plainText else {
            textStorage.endEditing()
            return
        }

        let isDark = theme.isDark
        let text = textStorage.string as NSString
        let boldFont = NSFont.monospacedSystemFont(ofSize: font.pointSize, weight: .bold)

        // Authentic Notepad++ Palette
        let keywordColor = isDark ? NSColor(red: 0.35, green: 0.65, blue: 1.0, alpha: 1.0) : NSColor(red: 0.0, green: 0.15, blue: 0.95, alpha: 1.0) // Vibrant Blue
        let stringColor = isDark ? NSColor(red: 0.95, green: 0.70, blue: 0.40, alpha: 1.0) : (language == .html || language == .xml ? NSColor(red: 0.55, green: 0.0, blue: 0.75, alpha: 1.0) : NSColor(red: 0.65, green: 0.15, blue: 0.15, alpha: 1.0)) // Purple in HTML, Red/Brown in code
        let numberColor = isDark ? NSColor(red: 0.98, green: 0.60, blue: 0.20, alpha: 1.0) : NSColor(red: 1.0, green: 0.40, blue: 0.0, alpha: 1.0) // Orange
        let commentColor = isDark ? NSColor(red: 0.45, green: 0.75, blue: 0.45, alpha: 1.0) : NSColor(red: 0.0, green: 0.55, blue: 0.0, alpha: 1.0) // Classic N++ Green
        let attrColor = isDark ? NSColor(red: 1.0, green: 0.50, blue: 0.50, alpha: 1.0) : NSColor(red: 0.90, green: 0.0, blue: 0.0, alpha: 1.0) // Vibrant Red (Notepad++ attribute)
        let typeColor = isDark ? NSColor(red: 0.35, green: 0.85, blue: 0.85, alpha: 1.0) : NSColor(red: 0.10, green: 0.50, blue: 0.75, alpha: 1.0) // Cyan/Teal
        let functionColor = isDark ? NSColor(red: 0.95, green: 0.85, blue: 0.50, alpha: 1.0) : NSColor(red: 0.45, green: 0.20, blue: 0.65, alpha: 1.0)

        // Find comments
        var commentRanges: [NSRange] = []
        var commentPatterns: [String] = []
        if language == .html || language == .xml {
            commentPatterns.append("<!--[\\s\\S]*?-->")
        } else if language == .python || language == .shell || language == .yaml || language == .ini || language == .dockerfile {
            commentPatterns.append("#.*$")
        } else if language == .sql {
            commentPatterns.append("--.*$")
            commentPatterns.append("/\\*[\\s\\S]*?\\*/")
        } else {
            commentPatterns.append("//.*$")
            commentPatterns.append("/\\*[\\s\\S]*?\\*/")
        }

        for pattern in commentPatterns {
            if let cRegex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) {
                let matches = cRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    commentRanges.append(match.range)
                }
            }
        }

        // Find strings (outside comments)
        var stringRanges: [NSRange] = []
        let stringPattern = "\"(\\\\.|[^\"])*\"|'(\\\\.|[^'])*'"
        if let strRegex = try? NSRegularExpression(pattern: stringPattern) {
            let matches = strRegex.matches(in: text as String, range: fullRange)
            for match in matches {
                let r = match.range
                if !commentRanges.contains(where: { NSIntersectionRange($0, r).length > 0 }) {
                    stringRanges.append(r)
                }
            }
        }

        func isProtected(_ r: NSRange) -> Bool {
            for cr in commentRanges {
                if NSIntersectionRange(cr, r).length > 0 { return true }
            }
            for sr in stringRanges {
                if NSIntersectionRange(sr, r).length > 0 { return true }
            }
            return false
        }

        // 2. Numbers (outside comments & strings)
        if let numRegex = try? NSRegularExpression(pattern: "\\b(0x[0-9a-fA-F]+|\\d+(\\.\\d+)?)\\b") {
            let matches = numRegex.matches(in: text as String, range: fullRange)
            for match in matches {
                if !isProtected(match.range) {
                    textStorage.addAttribute(.foregroundColor, value: numberColor, range: match.range)
                }
            }
        }

        // 3. Types / Classes (outside comments & strings)
        if language != .html && language != .xml && language != .json && language != .css {
            if let typeRegex = try? NSRegularExpression(pattern: "\\b[A-Z][a-zA-Z0-9_]*\\b") {
                let matches = typeRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !isProtected(match.range) {
                        textStorage.addAttribute(.foregroundColor, value: typeColor, range: match.range)
                    }
                }
            }
        }

        // 4. Keywords (outside comments & strings)
        if !language.keywords.isEmpty {
            let escaped = language.keywords.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
            let pattern = "\\b(\(escaped))\\b"
            if let keywordRegex = try? NSRegularExpression(pattern: pattern, options: language == .sql ? [.caseInsensitive] : []) {
                let matches = keywordRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !isProtected(match.range) {
                        textStorage.addAttribute(.foregroundColor, value: keywordColor, range: match.range)
                        textStorage.addAttribute(.font, value: boldFont, range: match.range)
                    }
                }
            }
        }

        // 5. Function calls (outside comments & strings)
        if language != .html && language != .xml && language != .json && language != .css {
            if let fnRegex = try? NSRegularExpression(pattern: "\\b([a-zA-Z_][a-zA-Z0-9_]*)(?=\\s*\\()") {
                let matches = fnRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !isProtected(match.range) {
                        textStorage.addAttribute(.foregroundColor, value: functionColor, range: match.range)
                    }
                }
            }
        }

        // 6. HTML / XML syntax: Tags and Attributes
        if language == .html || language == .xml {
            // Tag names & opening: </?[a-zA-Z0-9\-_]+
            if let tagRegex = try? NSRegularExpression(pattern: "</?[a-zA-Z0-9\\-_]+") {
                let matches = tagRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !commentRanges.contains(where: { NSIntersectionRange($0, match.range).length > 0 }) {
                        textStorage.addAttribute(.foregroundColor, value: keywordColor, range: match.range)
                        textStorage.addAttribute(.font, value: boldFont, range: match.range)
                    }
                }
            }
            // Tag closing: /?>
            if let closeRegex = try? NSRegularExpression(pattern: "/?>") {
                let matches = closeRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !commentRanges.contains(where: { NSIntersectionRange($0, match.range).length > 0 }) {
                        textStorage.addAttribute(.foregroundColor, value: keywordColor, range: match.range)
                        textStorage.addAttribute(.font, value: boldFont, range: match.range)
                    }
                }
            }
            // Tag attributes: ([a-zA-Z0-9\-_]+)(?=\s*=)
            if let attrRegex = try? NSRegularExpression(pattern: "\\b([a-zA-Z0-9\\-_]+)(?=\\s*=)") {
                let matches = attrRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !isProtected(match.range) {
                        textStorage.addAttribute(.foregroundColor, value: attrColor, range: match.range)
                        textStorage.addAttribute(.font, value: font, range: match.range)
                    }
                }
            }
        }

        // 7. JSON Keys
        if language == .json {
            if let keyRegex = try? NSRegularExpression(pattern: "\"([^\"]+)\"\\s*:") {
                let matches = keyRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    textStorage.addAttribute(.foregroundColor, value: keywordColor, range: match.range)
                    textStorage.addAttribute(.font, value: boldFont, range: match.range)
                }
            }
        }

        // 8. CSS properties and selectors
        if language == .css || language == .scss {
            if let propRegex = try? NSRegularExpression(pattern: "([a-zA-Z\\-]+)(?=\\s*:)") {
                let matches = propRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !isProtected(match.range) {
                        textStorage.addAttribute(.foregroundColor, value: keywordColor, range: match.range)
                    }
                }
            }
            if let selRegex = try? NSRegularExpression(pattern: "[\\.#][a-zA-Z0-9_\\-]+") {
                let matches = selRegex.matches(in: text as String, range: fullRange)
                for match in matches {
                    if !isProtected(match.range) {
                        textStorage.addAttribute(.foregroundColor, value: attrColor, range: match.range)
                    }
                }
            }
        }

        // 9. Apply Strings (overrides any inner highlights, resets font)
        for sr in stringRanges {
            textStorage.addAttribute(.foregroundColor, value: stringColor, range: sr)
            textStorage.addAttribute(.font, value: font, range: sr)
        }

        // 10. Apply Comments (overrides everything in comment range, resets font)
        for cr in commentRanges {
            textStorage.addAttribute(.foregroundColor, value: commentColor, range: cr)
            textStorage.addAttribute(.font, value: font, range: cr)
        }

        textStorage.endEditing()
    }
}
