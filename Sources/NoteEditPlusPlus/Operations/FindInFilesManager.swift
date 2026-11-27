import Foundation

public struct FileSearchResult: Identifiable, Hashable, Sendable {
    public var id: String { "\(fileURL.path):\(lineNumber):\(matchRange.location)" }
    public let fileURL: URL
    public let lineNumber: Int
    public let lineContent: String
    public let matchRange: NSRange

    public init(fileURL: URL, lineNumber: Int, lineContent: String, matchRange: NSRange) {
        self.fileURL = fileURL
        self.lineNumber = lineNumber
        self.lineContent = lineContent
        self.matchRange = matchRange
    }
}

public struct FindInFilesOptions: Sendable {
    public var query: String
    public var directoryURL: URL
    public var fileFilter: String // e.g. "*.*" or "*.swift,*.txt"
    public var matchCase: Bool
    public var wholeWord: Bool
    public var useRegex: Bool
    public var recursive: Bool

    public init(
        query: String = "",
        directoryURL: URL = URL(fileURLWithPath: "."),
        fileFilter: String = "*.*",
        matchCase: Bool = false,
        wholeWord: Bool = false,
        useRegex: Bool = false,
        recursive: Bool = true
    ) {
        self.query = query
        self.directoryURL = directoryURL
        self.fileFilter = fileFilter
        self.matchCase = matchCase
        self.wholeWord = wholeWord
        self.useRegex = useRegex
        self.recursive = recursive
    }
}

public final class FindInFilesManager: Sendable {
    public static func search(options: FindInFilesOptions) -> [FileSearchResult] {
        guard !options.query.isEmpty else { return [] }

        var pattern = options.useRegex ? options.query : NSRegularExpression.escapedPattern(for: options.query)
        if options.wholeWord {
            pattern = "\\b\(pattern)\\b"
        }

        var regexOptions: NSRegularExpression.Options = []
        if !options.matchCase {
            regexOptions.insert(.caseInsensitive)
        }

        guard let regex = try? NSRegularExpression(pattern: pattern, options: regexOptions) else {
            return []
        }

        var results: [FileSearchResult] = []
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey]

        let enumerator = fileManager.enumerator(
            at: options.directoryURL,
            includingPropertiesForKeys: keys,
            options: options.recursive ? [.skipsHiddenFiles] : [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        )

        let filters = options.fileFilter
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "*", with: "") }
            .filter { !$0.isEmpty && $0 != "." }

        while let fileURL = enumerator?.nextObject() as? URL {
            // Check extension filter
            if !filters.isEmpty {
                let matched = filters.contains { filter in
                    fileURL.lastPathComponent.contains(filter)
                }
                if !matched { continue }
            }

            guard let isRegular = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile, isRegular else {
                continue
            }

            // Limit file size to 10MB to prevent hanging on massive binaries
            if let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize, fileSize > 10 * 1024 * 1024 {
                continue
            }

            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
                continue
            }

            let lines = content.components(separatedBy: "\n")
            for (index, line) in lines.enumerated() {
                let lineRange = NSRange(location: 0, length: (line as NSString).length)
                let matches = regex.matches(in: line, range: lineRange)
                for match in matches {
                    results.append(FileSearchResult(
                        fileURL: fileURL,
                        lineNumber: index + 1,
                        lineContent: line.trimmingCharacters(in: .whitespaces),
                        matchRange: match.range
                    ))
                }
            }
        }

        return results
    }
}
