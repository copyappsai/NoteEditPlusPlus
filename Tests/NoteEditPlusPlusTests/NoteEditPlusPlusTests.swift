import Testing
import Foundation
import SwiftUI
import AppKit
@testable import NoteEditPlusPlus

@Test func testEncodingDetectorAndLineEndings() async throws {
    let sampleWindows = "Line 1\r\nLine 2\r\nLine 3"
    let endingWindows = EncodingDetector.detectLineEnding(text: sampleWindows)
    #expect(endingWindows == .crlf)

    let sampleUnix = "Line 1\nLine 2\nLine 3"
    let endingUnix = EncodingDetector.detectLineEnding(text: sampleUnix)
    #expect(endingUnix == .lf)

    let convertedToUnix = EncodingDetector.convertLineEndings(in: sampleWindows, to: .lf)
    #expect(!convertedToUnix.contains("\r\n"))
    #expect(convertedToUnix.contains("\n"))

    let convertedToWindows = EncodingDetector.convertLineEndings(in: sampleUnix, to: .crlf)
    #expect(convertedToWindows.contains("\r\n"))
}

@Test func testSyntaxLanguageDetection() async throws {
    let jsonURL = URL(fileURLWithPath: "/path/to/test.json")
    #expect(SyntaxLanguage.detect(from: jsonURL) == .json)

    let pyURL = URL(fileURLWithPath: "/path/to/script.py")
    #expect(SyntaxLanguage.detect(from: pyURL) == .python)

    let swiftURL = URL(fileURLWithPath: "/path/to/App.swift")
    #expect(SyntaxLanguage.detect(from: swiftURL) == .swift)

    let sqlURL = URL(fileURLWithPath: "/path/to/query.sql")
    #expect(SyntaxLanguage.detect(from: sqlURL) == .sql)

    // Additional languages
    let rustURL = URL(fileURLWithPath: "/path/to/main.rs")
    #expect(SyntaxLanguage.detect(from: rustURL) == .rust)

    let goURL = URL(fileURLWithPath: "/path/to/server.go")
    #expect(SyntaxLanguage.detect(from: goURL) == .go)

    let zigURL = URL(fileURLWithPath: "/path/to/build.zig")
    #expect(SyntaxLanguage.detect(from: zigURL) == .zig)

    let csURL = URL(fileURLWithPath: "/path/to/Program.cs")
    #expect(SyntaxLanguage.detect(from: csURL) == .csharp)

    let dockerURL = URL(fileURLWithPath: "/path/to/Dockerfile")
    #expect(SyntaxLanguage.detect(from: dockerURL) == .dockerfile)

    let makeURL = URL(fileURLWithPath: "/path/to/Makefile")
    #expect(SyntaxLanguage.detect(from: makeURL) == .makefile)
}

@Test func testContentSyntaxLanguageDetection() async throws {
    let htmlCode = "<!DOCTYPE html><html><body><h1>Hello</h1></body></html>"
    #expect(SyntaxLanguage.detect(fromContent: htmlCode) == .html)

    let htmlFragment = "<form action=\"action_page.php\" method=\"post\">\n<div class=\"container\">\n</div>\n</form>"
    #expect(SyntaxLanguage.detect(fromContent: htmlFragment) == .html)

    let pythonCode = "import sys\ndef calculate(val):\n    return val * 2"
    #expect(SyntaxLanguage.detect(fromContent: pythonCode) == .python)

    let swiftCode = "import SwiftUI\nstruct ContentView: View {\n    var body: some View { Text(\"Hi\") }\n}"
    #expect(SyntaxLanguage.detect(fromContent: swiftCode) == .swift)

    let jsonCode = "{\n  \"name\": \"NoteEdit++\",\n  \"version\": 1\n}"
    #expect(SyntaxLanguage.detect(fromContent: jsonCode) == .json)

    let sqlCode = "SELECT id, name FROM users WHERE active = 1 ORDER BY id DESC"
    #expect(SyntaxLanguage.detect(fromContent: sqlCode) == .sql)

    let phpCode = "<?php\necho 'Hello World';\n?>"
    #expect(SyntaxLanguage.detect(fromContent: phpCode) == .php)

    let cssCode = ".button {\n    background-color: #333;\n    color: white;\n    padding: 10px;\n}"
    #expect(SyntaxLanguage.detect(fromContent: cssCode) == .css)
}

@Test @MainActor func testCodeCompletionsAndSuggestions() async throws {
    let appState = AppState()
    let doc = DocumentModel(title: "test.html", content: "function calculateTotal() {\n    let totalAmount = 100;\n}", syntaxLanguage: .javascript)
    let editorView = NativeEditorView(
        document: doc,
        appState: appState,
        isWordWrapEnabled: true,
        fontSize: 13.0,
        findReplaceState: appState.findReplaceState
    )
    let hosting = NSHostingView(rootView: editorView)
    hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
        styleMask: [.titled, .resizable],
        backing: .buffered,
        defer: false
    )
    window.contentView = hosting
    window.display()

    func findTextView(in v: NSView) -> CustomTextView? {
        if let tv = v as? CustomTextView { return tv }
        for sub in v.subviews {
            if let f = findTextView(in: sub) { return f }
        }
        return nil
    }

    let tv = findTextView(in: hosting)!

    // Test partial word range
    tv.string = "function calc"
    tv.setSelectedRange(NSRange(location: 13, length: 0))
    let range = tv.rangeForUserCompletion
    #expect(range == NSRange(location: 9, length: 4))

    // Test suggestions for "calc" -> matches "calculateTotal" from document
    tv.string = "function calculateTotal() {\n    let amount = calc"
    let calcRange = (tv.string as NSString).range(of: "calc", options: .backwards)
    let completions = tv.completions(forPartialWordRange: calcRange, indexOfSelectedItem: nil)
    #expect(completions != nil)
    #expect(completions!.contains("calculateTotal"))

    // Test suggestions for "func" -> matches keyword "function"
    let funcRange = (tv.string as NSString).range(of: "func")
    let kwCompletions = tv.completions(forPartialWordRange: funcRange, indexOfSelectedItem: nil)
    #expect(kwCompletions != nil)
    #expect(kwCompletions!.contains("function"))
}

@Test @MainActor func testHTMLSyntaxHighlightingColors() async throws {
    let storage = NSTextStorage(string: "<form action=\"login.php\">\n<!-- A comment -->\n</form>")
    let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    SyntaxHighlighter.highlight(textStorage: storage, language: .html, font: font, theme: .classicLight)

    // Tag opening "<form" should be colored with blue tag/keyword color
    let tagColor = storage.attribute(.foregroundColor, at: 1, effectiveRange: nil) as? NSColor
    #expect(tagColor != nil)
    #expect(tagColor!.blueComponent > 0.7)

    // Attribute "action" should be colored with red attribute color
    let attrColor = storage.attribute(.foregroundColor, at: 7, effectiveRange: nil) as? NSColor
    #expect(attrColor != nil)
    #expect(attrColor!.redComponent > 0.7) // Red

    // Comment "<!-- A comment -->" should be colored with green commentColor
    let commentIndex = 27
    let commentColor = storage.attribute(.foregroundColor, at: commentIndex, effectiveRange: nil) as? NSColor
    #expect(commentColor != nil)
    #expect(commentColor!.greenComponent > 0.4)
}

@Test @MainActor func testDocumentModelOperations() async throws {
    let doc = DocumentModel(title: "test.txt", content: "Hello world\nSecond line")
    #expect(doc.lineCount == 2)
    #expect(doc.characterCount == 23)

    doc.updateCursor(line: 2, column: 5, selectionLength: 0, selectionLines: 0)
    #expect(doc.cursorLine == 2)
    #expect(doc.cursorColumn == 5)
}

@Test func testTextOperationsLineDuplicationAndDeletion() async throws {
    let sample = "Line 1\nLine 2\nLine 3"
    let (dupText, _) = TextOperationsManager.duplicateLineOrSelection(text: sample, selectedRange: NSRange(location: 2, length: 0))
    #expect(dupText == "Line 1\nLine 1\nLine 2\nLine 3")

    let (delText, _) = TextOperationsManager.deleteLine(text: sample, selectedRange: NSRange(location: 8, length: 0))
    #expect(delText == "Line 1\nLine 3")
}

@Test func testTextOperationsLineMove() async throws {
    let sample = "A\nB\nC"
    let (movedUp, _) = TextOperationsManager.moveLineUp(text: sample, selectedRange: NSRange(location: 2, length: 0))
    #expect(movedUp == "B\nA\nC")

    let (movedDown, _) = TextOperationsManager.moveLineDown(text: movedUp, selectedRange: NSRange(location: 0, length: 0))
    #expect(movedDown == "A\nB\nC")
}

@Test func testTextOperationsSortAndDuplicates() async throws {
    let unsorted = "Cherry\nApple\nBanana"
    let (sortedAsc, _) = TextOperationsManager.sortLines(text: unsorted, selectedRange: NSRange(location: 0, length: 0), ascending: true)
    #expect(sortedAsc == "Apple\nBanana\nCherry")

    let withDupes = "A\nB\nA\nC\nB"
    let (deduped, _) = TextOperationsManager.removeDuplicateLines(text: withDupes, selectedRange: NSRange(location: 0, length: 0))
    #expect(deduped == "A\nB\nC")
}

@Test func testTextOperationsCaseConversion() async throws {
    let input = "hello world"
    let (upper, _) = TextOperationsManager.convertCase(text: input, selectedRange: NSRange(location: 0, length: 11), targetCase: .uppercase)
    #expect(upper == "HELLO WORLD")

    let (title, _) = TextOperationsManager.convertCase(text: input, selectedRange: NSRange(location: 0, length: 11), targetCase: .titleCase)
    #expect(title == "Hello World")

    let (inverted, _) = TextOperationsManager.convertCase(text: "Hello World", selectedRange: NSRange(location: 0, length: 11), targetCase: .invertCase)
    #expect(inverted == "hELLO wORLD")
}

@Test func testBracketMatching() async throws {
    let code = "func foo() { return [1, 2]; }"
    let matchParen = BracketMatcher.findMatchingBracket(in: code, at: 8)
    #expect(matchParen != nil)
    #expect(matchParen?.matchRange.location == 9)

    let matchBrace = BracketMatcher.findMatchingBracket(in: code, at: 11)
    #expect(matchBrace != nil)
    #expect(matchBrace?.matchRange.location == 28)
}

@Test func testBookmarksManager() async throws {
    let text = "Line 1\nLine 2\nLine 3\nLine 4"
    let bookmarks: Set<Int> = [2, 4]

    let copied = BookmarkManager.copyBookmarkedLines(text: text, bookmarks: bookmarks)
    #expect(copied == "Line 2\nLine 4")

    let deleted = BookmarkManager.deleteBookmarkedLines(text: text, bookmarks: bookmarks)
    #expect(deleted == "Line 1\nLine 3")

    let next = BookmarkManager.nextBookmark(in: bookmarks, currentLine: 2, totalLines: 4)
    #expect(next == 4)

    let wrapped = BookmarkManager.nextBookmark(in: bookmarks, currentLine: 4, totalLines: 4)
    #expect(wrapped == 2)
}

@Test func testDeveloperTools() async throws {
    let unformattedJSON = "{\"name\":\"Mark\",\"age\":30}"
    let formattedJSON = DeveloperToolsManager.formatJSON(unformattedJSON, indent: 4)
    #expect(formattedJSON != nil)
    #expect(formattedJSON!.contains("\n"))

    let minified = DeveloperToolsManager.minifyJSON(formattedJSON!)
    #expect(minified != nil)
    let parsedMinified = try? JSONSerialization.jsonObject(with: minified!.data(using: .utf8)!) as? [String: Any]
    #expect(parsedMinified?["name"] as? String == "Mark")
    #expect(parsedMinified?["age"] as? Int == 30)

    let original = "Notepad++ on Mac!"
    let encoded = DeveloperToolsManager.base64Encode(original)
    let decoded = DeveloperToolsManager.base64Decode(encoded)
    #expect(decoded == original)

    let sha = DeveloperToolsManager.sha256Hex("hello")
    #expect(sha == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
}

@Test func testDocumentDiff() async throws {
    let textA = "A\nB\nC"
    let textB = "A\nB\nD\nE"

    let diff = DocumentCompareManager.compare(textA: textA, textB: textB)
    #expect(diff.unchangedCount == 2)
    #expect(diff.removedCount == 1)
    #expect(diff.addedCount == 2)
}

@Test @MainActor func testLocalizationManager() async throws {
    let state = AppState()
    #expect(state.uiLanguage == .english, "Default UI language must be English")

    #expect(LocalizationManager.tr("file", lang: .hungarian) == "Fájl")
    #expect(LocalizationManager.tr("file", lang: .english) == "File")
    #expect(LocalizationManager.tr("file", lang: .german) == "Datei")
    #expect(LocalizationManager.tr("file", lang: .french) == "Fichier")
    #expect(LocalizationManager.tr("file", lang: .spanish) == "Archivo")
    #expect(LocalizationManager.tr("file", lang: .chineseSimp) == "文件")

    #expect(LocalizationManager.tr("new_file", lang: .hungarian) == "Új fájl")
    #expect(LocalizationManager.tr("new_file", lang: .english) == "New File")

    // Verify all 32 UI languages have clean native display names without mixed strings
    for lang in UILanguage.allCases {
        let name = lang.displayName
        #expect(!name.isEmpty)
        #expect(!name.contains("/"))
        #expect(!name.contains("("))
        
        let findInFiles = LocalizationManager.tr("find_in_files", lang: lang)
        #expect(!findInFiles.isEmpty)
        #expect(!findInFiles.contains("Find in Files") || lang == .english)
    }
}

@Test @MainActor func testNativeEditorViewRendering() async throws {
    let appState = AppState()
    let doc = DocumentModel(title: "test.txt", content: "Hello NoteEdit++ on Mac!")
    let editorView = NativeEditorView(
        document: doc,
        appState: appState,
        isWordWrapEnabled: true,
        fontSize: 14.0,
        findReplaceState: appState.findReplaceState
    )
    let hosting = NSHostingView(rootView: editorView)
    hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
        styleMask: [.titled, .resizable],
        backing: .buffered,
        defer: false
    )
    window.contentView = hosting
    window.display()

    func findTextView(in v: NSView) -> NSTextView? {
        if let tv = v as? NSTextView { return tv }
        for sub in v.subviews {
            if let f = findTextView(in: sub) { return f }
        }
        return nil
    }

    let tv = findTextView(in: hosting)!
    #expect(tv.string == "Hello NoteEdit++ on Mac!")

    let scrollView = tv.enclosingScrollView!
    #expect(scrollView.rulersVisible == true)
    #expect(scrollView.verticalRulerView != nil)

    guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
        #expect(Bool(false), "Failed to create bitmap rep")
        return
    }
    hosting.cacheDisplay(in: hosting.bounds, to: rep)

    var darkPixels = 0
    var whitePixels = 0
    for y in 0..<rep.pixelsHigh {
        for x in 0..<rep.pixelsWide {
            if let c = rep.colorAt(x: x, y: y) {
                if c.redComponent < 0.3 && c.greenComponent < 0.3 && c.blueComponent < 0.3 {
                    darkPixels += 1
                } else if c.redComponent > 0.95 && c.greenComponent > 0.95 && c.blueComponent > 0.95 {
                    whitePixels += 1
                }
            }
        }
    }
    print("Test cacheDisplay: darkPixels=\(darkPixels), whitePixels=\(whitePixels)")
    #expect(darkPixels > 100, "Text must be visibly rendered with dark pixels on white background")
    #expect(whitePixels > 10000, "Editor background must be light/white")
}

@Test func testSmartAutoIndentation() async throws {
    // 1. Basic auto-indentation (preserve previous line's 4 spaces)
    let code1 = "    let a = 10"
    let res1 = SmartIndentManager.computeNewline(fullText: code1, selectedRange: NSRange(location: code1.count, length: 0), tabSize: 4)
    #expect(res1.textToInsert == "\n    ")
    #expect(res1.cursorOffset == 5)

    // 2. Block opener (opening brace '{' adds 4 spaces)
    let code2 = "func test() {"
    let res2 = SmartIndentManager.computeNewline(fullText: code2, selectedRange: NSRange(location: code2.count, length: 0), tabSize: 4)
    #expect(res2.textToInsert == "\n    ")
    #expect(res2.cursorOffset == 5)

    // 3. Python colon block opener
    let code3 = "    def calculate():"
    let res3 = SmartIndentManager.computeNewline(fullText: code3, selectedRange: NSRange(location: code3.count, length: 0), tabSize: 4)
    #expect(res3.textToInsert == "\n        ") // 4 base + 4 new = 8 spaces
    #expect(res3.cursorOffset == 9)

    // 4. HTML tag opener
    let code4 = "<div class=\"wrapper\">"
    let res4 = SmartIndentManager.computeNewline(fullText: code4, selectedRange: NSRange(location: code4.count, length: 0), tabSize: 4)
    #expect(res4.textToInsert == "\n    ")

    // 5. Brace expansion between '{' and '}'
    let code5 = "func run() {}"
    let braceLoc = (code5 as NSString).range(of: "}").location
    let res5 = SmartIndentManager.computeNewline(fullText: code5, selectedRange: NSRange(location: braceLoc, length: 0), tabSize: 4)
    #expect(res5.textToInsert == "\n    \n")
    #expect(res5.cursorOffset == 5) // cursor positioned on the indented middle line

    // 6. Custom tabSize = 2
    let res6 = SmartIndentManager.computeNewline(fullText: "func mini() {", selectedRange: NSRange(location: 13, length: 0), tabSize: 2)
    #expect(res6.textToInsert == "\n  ")
}

@Test func testSmartBackspace() async throws {
    let text = "    code"
    let range = SmartIndentManager.smartBackspaceRange(fullText: text, selectedRange: NSRange(location: 4, length: 0), tabSize: 4)
    #expect(range == NSRange(location: 0, length: 4))

    // Cursor after non-space should NOT trigger smart indent backspace
    let noRange = SmartIndentManager.smartBackspaceRange(fullText: text, selectedRange: NSRange(location: 5, length: 0), tabSize: 4)
    #expect(noRange == nil)
}


