import Foundation
import SwiftUI
import Observation
import AppKit

@MainActor
@Observable
public final class AppState {
    public var documents: [DocumentModel] = []
    public var activeDocumentId: UUID?
    public var isWordWrapEnabled: Bool = true
    public var fontSize: CGFloat = 13.0
    public var fontName: String = "SF Mono"
    public var tabSize: Int = 4
    public var theme: AppTheme = .classicLight
    public var uiLanguage: UILanguage = .english
    public var showInvisibleCharacters: Bool = false
    public var highlightMatchingBrackets: Bool = true
    public var defaultLineEnding: LineEnding = .lf
    public var defaultEncoding: DocumentEncoding = .utf8

    public var isOvertypeMode: Bool = false
    public var findReplaceState = FindReplaceState()
    
    public var workspaceURL: URL?
    public var isSidebarVisible: Bool = false
    public var isFindInFilesVisible: Bool = false
    public var isCompareVisible: Bool = false
    public var isDualViewEnabled: Bool = false
    public var isAboutVisible: Bool = false
    public var isHelpVisible: Bool = false
    public var secondaryDocuments: [DocumentModel] = []
    public var secondaryActiveDocumentId: UUID?

    public var activeEditorAction: ((EditorAction) -> Void)?

    private var untitledCounter: Int = 1

    public init() {
        restoreOrCreateDefaultSession()
    }

    public func performAction(_ action: EditorAction) {
        activeEditorAction?(action)
    }

    public func tr(_ key: String) -> String {
        LocalizationManager.tr(key, lang: uiLanguage)
    }

    // MARK: - Bookmarks Management
    public func toggleBookmarkOnActiveLine() {
        guard let doc = activeDocument else { return }
        let line = doc.cursorLine
        if doc.bookmarks.contains(line) {
            doc.bookmarks.remove(line)
        } else {
            doc.bookmarks.insert(line)
        }
    }

    public func nextBookmark() {
        guard let doc = activeDocument else { return }
        if let target = BookmarkManager.nextBookmark(in: doc.bookmarks, currentLine: doc.cursorLine, totalLines: doc.lineCount) {
            doc.cursorLine = target
            activeEditorAction?(.moveLineUp) // Trigger position refresh
        }
    }

    public func prevBookmark() {
        guard let doc = activeDocument else { return }
        if let target = BookmarkManager.prevBookmark(in: doc.bookmarks, currentLine: doc.cursorLine, totalLines: doc.lineCount) {
            doc.cursorLine = target
            activeEditorAction?(.moveLineUp) // Trigger position refresh
        }
    }

    public func clearBookmarks() {
        activeDocument?.bookmarks.removeAll()
    }

    public func copyBookmarkedLines() {
        guard let doc = activeDocument else { return }
        let text = BookmarkManager.copyBookmarkedLines(text: doc.content, bookmarks: doc.bookmarks)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    public func deleteBookmarkedLines() {
        guard let doc = activeDocument else { return }
        doc.content = BookmarkManager.deleteBookmarkedLines(text: doc.content, bookmarks: doc.bookmarks)
        doc.bookmarks.removeAll()
        doc.isModified = true
    }

    // MARK: - Developer Tools
    public func formatActiveJSON() {
        guard let doc = activeDocument else { return }
        if let formatted = DeveloperToolsManager.formatJSON(doc.content, indent: tabSize) {
            doc.content = formatted
            doc.isModified = true
            doc.syntaxLanguage = .json
        } else {
            showErrorAlert(message: "Érvénytelen JSON formátum.")
        }
    }

    public func minifyActiveJSON() {
        guard let doc = activeDocument else { return }
        if let minified = DeveloperToolsManager.minifyJSON(doc.content) {
            doc.content = minified
            doc.isModified = true
            doc.syntaxLanguage = .json
        } else {
            showErrorAlert(message: "Érvénytelen JSON formátum.")
        }
    }

    public func formatActiveXML() {
        guard let doc = activeDocument else { return }
        doc.content = DeveloperToolsManager.formatXML(doc.content)
        doc.isModified = true
        doc.syntaxLanguage = .xml
    }

    public func base64EncodeActive() {
        guard let doc = activeDocument else { return }
        doc.content = DeveloperToolsManager.base64Encode(doc.content)
        doc.isModified = true
    }

    public func base64DecodeActive() {
        guard let doc = activeDocument else { return }
        if let decoded = DeveloperToolsManager.base64Decode(doc.content) {
            doc.content = decoded
            doc.isModified = true
        } else {
            showErrorAlert(message: tr("invalid_base64"))
        }
    }

    public func urlEncodeActive() {
        guard let doc = activeDocument else { return }
        doc.content = DeveloperToolsManager.urlEncode(doc.content)
        doc.isModified = true
    }

    public func urlDecodeActive() {
        guard let doc = activeDocument else { return }
        doc.content = DeveloperToolsManager.urlDecode(doc.content)
        doc.isModified = true
    }

    // MARK: - Dual View / Split Tabs
    public func cloneActiveToSecondaryView() {
        guard let doc = activeDocument else { return }
        isDualViewEnabled = true
        if !secondaryDocuments.contains(where: { $0.id == doc.id }) {
            secondaryDocuments.append(doc)
        }
        secondaryActiveDocumentId = doc.id
    }

    public func moveActiveToSecondaryView() {
        guard let doc = activeDocument else { return }
        isDualViewEnabled = true
        secondaryDocuments.append(doc)
        secondaryActiveDocumentId = doc.id
        closeDocument(id: doc.id)
    }

    public var activeDocument: DocumentModel? {
        get {
            guard let id = activeDocumentId else { return documents.first }
            return documents.first(where: { $0.id == id }) ?? documents.first
        }
        set {
            if let newDoc = newValue {
                activeDocumentId = newDoc.id
            }
        }
    }

    public func newDocument() {
        untitledCounter += 1
        let doc = DocumentModel(
            title: "new \(untitledCounter)",
            fileURL: nil,
            content: "",
            isModified: false,
            encoding: .utf8,
            lineEnding: .lf,
            syntaxLanguage: .plainText
        )
        documents.append(doc)
        activeDocumentId = doc.id
        saveSession()
    }

    public func openDocument(from url: URL) {
        // If already open, switch to it
        if let existing = documents.first(where: { $0.fileURL == url }) {
            activeDocumentId = existing.id
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let detected = EncodingDetector.detect(data: data)
            var language = SyntaxLanguage.detect(from: url)
            if language == .plainText, let contentLang = SyntaxLanguage.detect(fromContent: detected.text) {
                language = contentLang
            }

            let doc = DocumentModel(
                title: url.lastPathComponent,
                fileURL: url,
                content: detected.text,
                isModified: false,
                encoding: detected.encoding,
                lineEnding: detected.lineEnding,
                syntaxLanguage: language
            )

            // If the only open document is an untouched "new 1", replace it
            if documents.count == 1 && documents[0].fileURL == nil && !documents[0].isModified && documents[0].content.isEmpty {
                documents[0] = doc
            } else {
                documents.append(doc)
            }
            activeDocumentId = doc.id
            saveSession()
        } catch {
            showErrorAlert(message: String(format: tr("open_failed"), error.localizedDescription))
        }
    }

    public func saveActiveDocument(as promptForPath: Bool = false) {
        guard let doc = activeDocument else { return }

        if doc.fileURL == nil || promptForPath {
            let panel = NSSavePanel()
            panel.title = tr("save_as")
            panel.nameFieldStringValue = doc.title
            panel.canCreateDirectories = true

            if panel.runModal() == .OK, let targetURL = panel.url {
                doc.fileURL = targetURL
                doc.title = targetURL.lastPathComponent
                doc.syntaxLanguage = SyntaxLanguage.detect(from: targetURL)
                performSave(document: doc)
            }
        } else {
            performSave(document: doc)
        }
    }

    public func saveAllDocuments() {
        for doc in documents where doc.isModified && doc.fileURL != nil {
            performSave(document: doc)
        }
    }

    public func printActiveDocument() {
        guard let doc = activeDocument else { return }
        let printInfo = NSPrintInfo.shared
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 468, height: 648))
        textView.string = doc.content
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let printOp = NSPrintOperation(view: textView, printInfo: printInfo)
        printOp.jobTitle = doc.title
        printOp.showsPrintPanel = true
        printOp.run()
    }

    private func performSave(document: DocumentModel) {
        guard let url = document.fileURL else { return }
        guard let data = EncodingDetector.encode(
            text: document.content,
            encoding: document.encoding,
            lineEnding: document.lineEnding
        ) else {
            showErrorAlert(message: tr("encoding_error"))
            return
        }

        do {
            try data.write(to: url, options: .atomic)
            document.isModified = false
            saveSession()
        } catch {
            showErrorAlert(message: String(format: tr("save_failed"), error.localizedDescription))
        }
    }

    public func closeDocument(id: UUID) {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
        let doc = documents[index]

        if doc.isModified {
            let alert = NSAlert()
            alert.messageText = String(format: tr("save_changes_prompt"), doc.title)
            alert.informativeText = tr("discard_warning")
            alert.addButton(withTitle: tr("save"))
            alert.addButton(withTitle: tr("discard"))
            alert.addButton(withTitle: tr("cancel"))

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                activeDocumentId = id
                saveActiveDocument()
                if doc.isModified { return } // If save cancelled
            } else if response == .alertThirdButtonReturn {
                return // Cancel
            }
        }

        documents.remove(at: index)

        if documents.isEmpty {
            newDocument()
        } else {
            let newIndex = min(index, documents.count - 1)
            activeDocumentId = documents[newIndex].id
        }
        saveSession()
    }

    public func closeAllDocuments() {
        let copy = documents
        for doc in copy {
            closeDocument(id: doc.id)
        }
    }

    public func convertLineEnding(for doc: DocumentModel, to newEnding: LineEnding) {
        doc.lineEnding = newEnding
        doc.content = EncodingDetector.convertLineEndings(in: doc.content, to: newEnding)
        doc.isModified = true
    }

    public func convertEncoding(for doc: DocumentModel, to newEncoding: DocumentEncoding) {
        doc.encoding = newEncoding
        doc.isModified = true
    }

    public func saveSession() {
        SessionManager.shared.saveSession(documents: documents, activeId: activeDocumentId)
    }

    private func restoreOrCreateDefaultSession() {
        if let session = SessionManager.shared.loadSession(), !session.documents.isEmpty {
            self.documents = session.documents
            self.activeDocumentId = session.activeId ?? session.documents.first?.id
            self.untitledCounter = session.documents.count
        } else {
            let initialDoc = DocumentModel(
                title: "new 1",
                fileURL: nil,
                content: "",
                isModified: false,
                encoding: .utf8,
                lineEnding: .lf,
                syntaxLanguage: .plainText
            )
            self.documents = [initialDoc]
            self.activeDocumentId = initialDoc.id
            self.untitledCounter = 1
        }
    }

    private func showErrorAlert(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "NoteEdit++"
            alert.informativeText = message
            alert.runModal()
        }
    }
}
