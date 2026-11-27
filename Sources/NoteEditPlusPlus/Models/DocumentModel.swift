import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
public final class DocumentModel: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var fileURL: URL?
    public var content: String
    public var isModified: Bool
    public var encoding: DocumentEncoding
    public var lineEnding: LineEnding
    public var syntaxLanguage: SyntaxLanguage
    
    // Cursor & Selection telemetry for Notepad++ style status bar
    public var cursorLine: Int = 1
    public var cursorColumn: Int = 1
    public var selectionLength: Int = 0
    public var selectionLines: Int = 0
    
    // Bookmarks for Notepad++ style gutter and navigation
    public var bookmarks: Set<Int> = []

    public init(
        id: UUID = UUID(),
        title: String = "new 1",
        fileURL: URL? = nil,
        content: String = "",
        isModified: Bool = false,
        encoding: DocumentEncoding = .utf8,
        lineEnding: LineEnding = .lf,
        syntaxLanguage: SyntaxLanguage = .plainText
    ) {
        self.id = id
        self.title = title
        self.fileURL = fileURL
        self.content = content
        self.isModified = isModified
        self.encoding = encoding
        self.lineEnding = lineEnding
        self.syntaxLanguage = syntaxLanguage
    }

    public nonisolated static func == (lhs: DocumentModel, rhs: DocumentModel) -> Bool {
        lhs.id == rhs.id
    }

    public var characterCount: Int {
        content.count
    }

    public var lineCount: Int {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        return max(1, lines.count)
    }

    public func updateCursor(line: Int, column: Int, selectionLength: Int, selectionLines: Int) {
        self.cursorLine = max(1, line)
        self.cursorColumn = max(1, column)
        self.selectionLength = selectionLength
        self.selectionLines = selectionLines
    }
}
