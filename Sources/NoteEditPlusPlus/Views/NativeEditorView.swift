import SwiftUI
import AppKit

public struct NativeEditorView: NSViewRepresentable {
    @Bindable var document: DocumentModel
    @Bindable var appState: AppState
    var isWordWrapEnabled: Bool
    var fontSize: CGFloat
    var findReplaceState: FindReplaceState

    public init(
        document: DocumentModel,
        appState: AppState,
        isWordWrapEnabled: Bool,
        fontSize: CGFloat,
        findReplaceState: FindReplaceState
    ) {
        self.document = document
        self.appState = appState
        self.isWordWrapEnabled = isWordWrapEnabled
        self.fontSize = fontSize
        self.findReplaceState = findReplaceState
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = !isWordWrapEnabled
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = appState.theme.backgroundColor
        scrollView.contentView.drawsBackground = true
        scrollView.contentView.backgroundColor = appState.theme.backgroundColor

        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        let layoutManager = InvisibleCharactersLayoutManager()
        layoutManager.showInvisibles = appState.showInvisibleCharacters
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(
            containerSize: isWordWrapEnabled
                ? NSSize(width: max(contentSize.width, 200), height: CGFloat.greatestFiniteMagnitude)
                : NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        )
        textContainer.widthTracksTextView = isWordWrapEnabled
        textContainer.lineFragmentPadding = 2
        layoutManager.addTextContainer(textContainer)

        let initialFrame = NSRect(origin: .zero, size: contentSize)
        let textView = CustomTextView(frame: initialFrame, textContainer: textContainer)
        textView.minSize = NSSize(width: 0.0, height: contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = !isWordWrapEnabled
        textView.autoresizingMask = isWordWrapEnabled ? [.width] : []

        textView.isEditable = true
        textView.isSelectable = true
        textView.drawsBackground = true
        textView.allowsUndo = true
        textView.isRichText = true
        textView.importsGraphics = false
        textView.allowsImageEditing = false
        textView.isFieldEditor = false
        textView.delegate = context.coordinator

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.textContainerInset = NSSize(width: 6, height: 6)

        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let appearance = appState.theme.isDark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)

        scrollView.appearance = appearance
        textView.appearance = appearance
        textView.backgroundColor = appState.theme.backgroundColor
        textView.textColor = appState.theme.textColor
        textView.insertionPointColor = appState.theme.textColor
        textView.font = font
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: appState.theme.textColor
        ]

        scrollView.documentView = textView

        // Configure Line Number Ruler
        let ruler = LineNumberRulerView(scrollView: scrollView)
        ruler.theme = appState.theme
        ruler.document = document
        scrollView.verticalRulerView = ruler
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true

        context.coordinator.scrollView = scrollView
        context.coordinator.textView = textView
        context.coordinator.rulerView = ruler

        // Load initial text
        textView.string = document.content
        if document.syntaxLanguage == .plainText, let detected = SyntaxLanguage.detect(fromContent: document.content) {
            document.syntaxLanguage = detected
        }
        context.coordinator.lastLanguage = document.syntaxLanguage
        context.coordinator.highlightSyntax()
        context.coordinator.updateCursorInfo()

        // Hook up Find & Replace closures
        context.coordinator.bindFindReplace()
        context.coordinator.bindEditorActions()

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }

        return scrollView
    }

    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? CustomTextView else { return }

        textView.isEditable = true
        textView.isSelectable = true

        // Update layout manager invisibles
        if let lm = textView.layoutManager as? InvisibleCharactersLayoutManager {
            if lm.showInvisibles != appState.showInvisibleCharacters {
                lm.showInvisibles = appState.showInvisibleCharacters
            }
        }

        // Update theme colors and appearance
        let appearance = appState.theme.isDark ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
        scrollView.appearance = appearance
        scrollView.backgroundColor = appState.theme.backgroundColor
        scrollView.contentView.backgroundColor = appState.theme.backgroundColor
        textView.appearance = appearance
        textView.backgroundColor = appState.theme.backgroundColor
        textView.insertionPointColor = appState.theme.textColor
        textView.typingAttributes = [
            .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
            .foregroundColor: appState.theme.textColor
        ]

        if context.coordinator.lastTheme != appState.theme {
            context.coordinator.lastTheme = appState.theme
            context.coordinator.highlightSyntax()
        }

        context.coordinator.rulerView?.theme = appState.theme
        context.coordinator.rulerView?.document = document

        // Update language if document changed syntax
        if document.syntaxLanguage == .plainText, let detected = SyntaxLanguage.detect(fromContent: document.content) {
            document.syntaxLanguage = detected
        }
        if context.coordinator.lastLanguage != document.syntaxLanguage {
            context.coordinator.lastLanguage = document.syntaxLanguage
            context.coordinator.highlightSyntax()
        }

        // Update word wrap if needed
        if context.coordinator.lastWordWrap != isWordWrapEnabled {
            context.coordinator.lastWordWrap = isWordWrapEnabled
            scrollView.hasHorizontalScroller = !isWordWrapEnabled
            if isWordWrapEnabled {
                textView.textContainer?.widthTracksTextView = true
                textView.isHorizontallyResizable = false
            } else {
                textView.textContainer?.widthTracksTextView = false
                textView.isHorizontallyResizable = true
                textView.textContainer?.containerSize = NSSize(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: CGFloat.greatestFiniteMagnitude
                )
            }
        }

        // Update font size if needed
        if context.coordinator.lastFontSize != fontSize {
            context.coordinator.lastFontSize = fontSize
            let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            textView.font = font
            context.coordinator.rulerView?.updateFont(size: fontSize)
            context.coordinator.highlightSyntax()
        }

        // Update content if document changed from outside
        if textView.string != document.content {
            let previousSelected = textView.selectedRange()
            textView.string = document.content
            if previousSelected.location + previousSelected.length <= (document.content as NSString).length {
                textView.setSelectedRange(previousSelected)
            }
            context.coordinator.highlightSyntax()
            context.coordinator.updateCursorInfo()
            context.coordinator.rulerView?.needsDisplay = true
        }

        context.coordinator.document = document
        context.coordinator.appState = appState
        context.coordinator.bindFindReplace()
        context.coordinator.bindEditorActions()
    }

    @MainActor
    public final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NativeEditorView
        var document: DocumentModel
        var appState: AppState
        weak var scrollView: NSScrollView?
        weak var textView: CustomTextView?
        weak var rulerView: LineNumberRulerView?

        var lastWordWrap: Bool = true
        var lastFontSize: CGFloat = 13.0
        var lastLanguage: SyntaxLanguage = .plainText
        var lastTheme: AppTheme = .classicLight

        init(_ parent: NativeEditorView) {
            self.parent = parent
            self.document = parent.document
            self.appState = parent.appState
            self.lastWordWrap = parent.isWordWrapEnabled
            self.lastFontSize = parent.fontSize
            self.lastLanguage = parent.document.syntaxLanguage
            self.lastTheme = parent.appState.theme
        }

        public func textDidChange(_ notification: Notification) {
            guard let tv = textView else { return }
            let newText = tv.string
            if document.content != newText {
                document.content = newText
                document.isModified = true

                // Auto-detect code language immediately as user types or pastes
                if document.syntaxLanguage == .plainText, let detected = SyntaxLanguage.detect(fromContent: newText) {
                    document.syntaxLanguage = detected
                    lastLanguage = detected
                }
            }
            rulerView?.needsDisplay = true
            updateCursorInfo()
            highlightSyntax()
        }

        public func textViewDidChangeSelection(_ notification: Notification) {
            updateCursorInfo()
            rulerView?.needsDisplay = true
            updateBracketHighlight()
        }

        func updateBracketHighlight() {
            guard let tv = textView, let layoutManager = tv.layoutManager, let storage = tv.textStorage else { return }
            layoutManager.removeTemporaryAttribute(.backgroundColor, forCharacterRange: NSRange(location: 0, length: storage.length))
            guard appState.highlightMatchingBrackets else { return }

            let cur = tv.selectedRange().location
            if let match = BracketMatcher.findMatchingBracket(in: tv.string, at: cur) {
                let color = NSColor.systemYellow.withAlphaComponent(0.4)
                layoutManager.addTemporaryAttribute(.backgroundColor, value: color, forCharacterRange: match.sourceRange)
                layoutManager.addTemporaryAttribute(.backgroundColor, value: color, forCharacterRange: match.matchRange)
            }
        }

        func updateCursorInfo() {
            guard let tv = textView else { return }
            let text = tv.string as NSString
            let selectedRange = tv.selectedRange()

            var line = 1
            var col = 1
            let selLength = selectedRange.length
            var selLines = 0

            if selectedRange.location <= text.length {
                let prefix = text.substring(to: selectedRange.location) as NSString
                if prefix.length == 0 {
                    line = 1
                    col = 1
                } else {
                    var lines = 1
                    var lastNewline = -1
                    for i in 0..<prefix.length {
                        let ch = prefix.character(at: i)
                        if ch == 10 { // \n
                            lines += 1
                            lastNewline = i
                        }
                    }
                    line = lines
                    col = prefix.length - lastNewline
                }
            }

            if selLength > 0 && selectedRange.location + selLength <= text.length {
                let selectedSub = text.substring(with: selectedRange)
                selLines = selectedSub.components(separatedBy: "\n").count
            }

            DispatchQueue.main.async {
                self.document.updateCursor(
                    line: line,
                    column: col,
                    selectionLength: selLength,
                    selectionLines: selLines
                )
            }
        }

        func highlightSyntax() {
            guard let tv = textView, let storage = tv.textStorage else { return }
            let font = NSFont.monospacedSystemFont(ofSize: parent.fontSize, weight: .regular)
            SyntaxHighlighter.highlight(textStorage: storage, language: document.syntaxLanguage, font: font, theme: appState.theme)
            tv.typingAttributes = [
                .font: font,
                .foregroundColor: appState.theme.textColor
            ]
            tv.needsDisplay = true
        }

        func bindEditorActions() {
            appState.activeEditorAction = { [weak self] action in
                self?.handleEditorAction(action)
            }
        }

        func handleEditorAction(_ action: EditorAction) {
            guard let tv = textView else { return }
            let currentText = tv.string
            let selectedRange = tv.selectedRange()
            var newText = currentText
            var newRange = selectedRange

            switch action {
            case .duplicateLine:
                (newText, newRange) = TextOperationsManager.duplicateLineOrSelection(text: currentText, selectedRange: selectedRange)
            case .deleteLine:
                (newText, newRange) = TextOperationsManager.deleteLine(text: currentText, selectedRange: selectedRange)
            case .moveLineUp:
                (newText, newRange) = TextOperationsManager.moveLineUp(text: currentText, selectedRange: selectedRange)
            case .moveLineDown:
                (newText, newRange) = TextOperationsManager.moveLineDown(text: currentText, selectedRange: selectedRange)
            case .joinLines:
                (newText, newRange) = TextOperationsManager.joinLines(text: currentText, selectedRange: selectedRange)
            case .sortAscending:
                (newText, newRange) = TextOperationsManager.sortLines(text: currentText, selectedRange: selectedRange, ascending: true)
            case .sortDescending:
                (newText, newRange) = TextOperationsManager.sortLines(text: currentText, selectedRange: selectedRange, ascending: false)
            case .sortNumeric:
                (newText, newRange) = TextOperationsManager.sortLines(text: currentText, selectedRange: selectedRange, ascending: true, numeric: true)
            case .removeDuplicates:
                (newText, newRange) = TextOperationsManager.removeDuplicateLines(text: currentText, selectedRange: selectedRange)
            case .removeEmptyLines:
                (newText, newRange) = TextOperationsManager.removeEmptyLines(text: currentText, selectedRange: selectedRange)
            case .trimTrailing:
                (newText, newRange) = TextOperationsManager.trimWhitespace(text: currentText, selectedRange: selectedRange, mode: .trailing)
            case .trimLeading:
                (newText, newRange) = TextOperationsManager.trimWhitespace(text: currentText, selectedRange: selectedRange, mode: .leading)
            case .trimBoth:
                (newText, newRange) = TextOperationsManager.trimWhitespace(text: currentText, selectedRange: selectedRange, mode: .both)
            case .toUppercase:
                (newText, newRange) = TextOperationsManager.convertCase(text: currentText, selectedRange: selectedRange, targetCase: .uppercase)
            case .toLowercase:
                (newText, newRange) = TextOperationsManager.convertCase(text: currentText, selectedRange: selectedRange, targetCase: .lowercase)
            case .toTitleCase:
                (newText, newRange) = TextOperationsManager.convertCase(text: currentText, selectedRange: selectedRange, targetCase: .titleCase)
            case .invertCase:
                (newText, newRange) = TextOperationsManager.convertCase(text: currentText, selectedRange: selectedRange, targetCase: .invertCase)
            case .tabsToSpaces:
                newText = TextOperationsManager.convertTabsToSpaces(text: currentText)
                newRange = selectedRange
            case .spacesToTabs:
                newText = TextOperationsManager.convertSpacesToTabs(text: currentText)
                newRange = selectedRange
            case .insertDate:
                let dateStr = TextOperationsManager.currentFormattedDate(longFormat: false)
                tv.insertText(dateStr, replacementRange: selectedRange)
                return
            case .insertDateTime:
                let dateStr = TextOperationsManager.currentFormattedDate(longFormat: true)
                tv.insertText(dateStr, replacementRange: selectedRange)
                return
            }

            if newText != currentText {
                tv.string = newText
                tv.setSelectedRange(newRange)
                textDidChange(Notification(name: NSText.didChangeNotification))
            }
        }

        func bindFindReplace() {
            let state = parent.findReplaceState

            state.performFindNext = { [weak self] in
                self?.findNext(forward: true)
            }
            state.performFindPrevious = { [weak self] in
                self?.findNext(forward: false)
            }
            state.performReplace = { [weak self] in
                self?.replace()
            }
            state.performReplaceAll = { [weak self] in
                self?.replaceAll()
            }
            state.performCount = { [weak self] in
                self?.countMatches()
            }
        }

        private func buildRegex() -> NSRegularExpression? {
            let state = parent.findReplaceState
            guard !state.findText.isEmpty else { return nil }

            var pattern = state.useRegex ? state.findText : NSRegularExpression.escapedPattern(for: state.findText)
            if state.wholeWord {
                pattern = "\\b\(pattern)\\b"
            }

            var options: NSRegularExpression.Options = []
            if !state.matchCase {
                options.insert(.caseInsensitive)
            }

            return try? NSRegularExpression(pattern: pattern, options: options)
        }

        func findNext(forward: Bool) {
            guard let tv = textView, let regex = buildRegex() else { return }
            let fullText = tv.string
            let fullRange = NSRange(location: 0, length: (fullText as NSString).length)
            let matches = regex.matches(in: fullText, range: fullRange)

            if matches.isEmpty {
                parent.findReplaceState.statusMessage = parent.appState.tr("no_matches")
                return
            }

            let currentPos = tv.selectedRange().location

            if forward {
                let nextMatch = matches.first { $0.range.location > currentPos } ?? (parent.findReplaceState.wrapAround ? matches.first : nil)
                if let target = nextMatch {
                    tv.setSelectedRange(target.range)
                    tv.scrollRangeToVisible(target.range)
                    parent.findReplaceState.statusMessage = parent.appState.tr("match_selected")
                }
            } else {
                let prevMatch = matches.reversed().first { $0.range.location < currentPos } ?? (parent.findReplaceState.wrapAround ? matches.last : nil)
                if let target = prevMatch {
                    tv.setSelectedRange(target.range)
                    tv.scrollRangeToVisible(target.range)
                    parent.findReplaceState.statusMessage = parent.appState.tr("match_selected")
                }
            }
        }

        func replace() {
            guard let tv = textView else { return }
            let state = parent.findReplaceState
            let selectedRange = tv.selectedRange()

            if selectedRange.length > 0 {
                tv.insertText(state.replaceText, replacementRange: selectedRange)
                textDidChange(Notification(name: NSText.didChangeNotification))
            }
            findNext(forward: true)
        }

        func replaceAll() {
            guard let tv = textView, let regex = buildRegex() else { return }
            let text = tv.string
            let fullRange = NSRange(location: 0, length: (text as NSString).length)
            let matches = regex.matches(in: text, range: fullRange)

            guard !matches.isEmpty else {
                parent.findReplaceState.statusMessage = parent.appState.tr("no_matches")
                return
            }

            let newString = regex.stringByReplacingMatches(
                in: text,
                range: fullRange,
                withTemplate: parent.findReplaceState.replaceText
            )
            tv.string = newString
            textDidChange(Notification(name: NSText.didChangeNotification))
            parent.findReplaceState.statusMessage = String(format: parent.appState.tr("matches_replaced"), matches.count)
        }

        func countMatches() {
            guard let tv = textView, let regex = buildRegex() else {
                parent.findReplaceState.matchCount = 0
                return
            }
            let text = tv.string
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length))
            parent.findReplaceState.matchCount = matches.count
            parent.findReplaceState.statusMessage = String(format: parent.appState.tr("matches_found"), matches.count)
        }
    }
}

public class CustomTextView: NSTextView {
    public override var acceptsFirstResponder: Bool { true }
    public override var canBecomeKeyView: Bool { true }

    public override func paste(_ sender: Any?) {
        pasteAsPlainText(sender)
    }

    public override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }

    private var isCompletionWindowVisible: Bool {
        NSApp.windows.contains { $0.isVisible && String(describing: type(of: $0)).contains("Completion") }
    }

    public override func insertNewline(_ sender: Any?) {
        if isCompletionWindowVisible {
            super.insertNewline(sender)
            return
        }

        let tabSize = (self.delegate as? NativeEditorView.Coordinator)?.appState.tabSize ?? 4
        let currentString = self.string
        let selRange = self.selectedRange()

        let result = SmartIndentManager.computeNewline(
            fullText: currentString,
            selectedRange: selRange,
            tabSize: tabSize
        )

        if self.shouldChangeText(in: selRange, replacementString: result.textToInsert) {
            self.replaceCharacters(in: selRange, with: result.textToInsert)
            let newCursorLoc = selRange.location + result.cursorOffset
            self.setSelectedRange(NSRange(location: newCursorLoc, length: 0))
            self.didChangeText()
            self.scrollRangeToVisible(NSRange(location: newCursorLoc, length: 0))
        }
    }

    public override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Return / Enter key (36 = main Return, 76 = keypad Enter)
        if (event.keyCode == 36 || event.keyCode == 76) && (flags.isEmpty || flags == .shift) {
            if isCompletionWindowVisible {
                super.keyDown(with: event)
                return
            }
            self.insertNewline(nil)
            return
        }

        // Backspace key (51) - smart backspace over indentation spaces
        if event.keyCode == 51 && flags.isEmpty {
            let tabSize = (self.delegate as? NativeEditorView.Coordinator)?.appState.tabSize ?? 4
            if let delRange = SmartIndentManager.smartBackspaceRange(
                fullText: self.string,
                selectedRange: self.selectedRange(),
                tabSize: tabSize
            ) {
                if self.shouldChangeText(in: delRange, replacementString: "") {
                    self.replaceCharacters(in: delRange, with: "")
                    self.setSelectedRange(NSRange(location: delRange.location, length: 0))
                    self.didChangeText()
                    self.scrollRangeToVisible(NSRange(location: delRange.location, length: 0))
                    return
                }
            }
        }

        // Ctrl + Space or Option + Escape: Trigger code suggestions / auto-completion
        if (flags.contains(.control) && event.keyCode == 49) || (flags.contains(.option) && event.keyCode == 53) {
            self.complete(nil)
            return
        }

        // Tab key: if completion list is open, let AppKit insert completion; otherwise insert 4 spaces
        if event.keyCode == 48 {
            if isCompletionWindowVisible {
                super.keyDown(with: event)
                return
            }
            if flags.contains(.shift) {
                super.keyDown(with: event)
            } else {
                self.insertText("    ", replacementRange: self.selectedRange())
            }
            return
        }

        // Option + Up: Move line up
        if event.keyCode == 126 && flags == .option {
            if let coordinator = self.delegate as? NativeEditorView.Coordinator {
                coordinator.handleEditorAction(.moveLineUp)
                return
            }
        }

        // Option + Down: Move line down
        if event.keyCode == 125 && flags == .option {
            if let coordinator = self.delegate as? NativeEditorView.Coordinator {
                coordinator.handleEditorAction(.moveLineDown)
                return
            }
        }

        // Cmd + B: Jump to matching bracket
        if event.keyCode == 11 && flags == .command {
            if let matchLoc = BracketMatcher.jumpToMatchingBracket(in: self.string, at: self.selectedRange().location) {
                self.setSelectedRange(NSRange(location: matchLoc, length: 0))
                self.scrollRangeToVisible(NSRange(location: matchLoc, length: 0))
                return
            }
        }

        super.keyDown(with: event)

        // Auto-trigger completion as you type if prefix has 2 or more characters
        if flags.isEmpty || flags == .shift {
            if let chars = event.characters, !chars.isEmpty {
                let first = chars.first!
                if first.isLetter || first.isNumber || first == "_" || first == "-" {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let userRange = self.rangeForUserCompletion
                        if userRange.length >= 2 {
                            self.complete(nil)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Auto-Completion / Suggestions
    public override var rangeForUserCompletion: NSRange {
        let selRange = selectedRange()
        guard selRange.location > 0, let string = self.textStorage?.string as NSString? else {
            return super.rangeForUserCompletion
        }

        var loc = selRange.location - 1
        while loc >= 0 {
            let char = string.character(at: loc)
            if let scalar = UnicodeScalar(char), CharacterSet.alphanumerics.contains(scalar) || char == 95 /* _ */ || char == 45 /* - */ {
                if loc == 0 {
                    return NSRange(location: 0, length: selRange.location)
                }
                loc -= 1
            } else {
                return NSRange(location: loc + 1, length: selRange.location - (loc + 1))
            }
        }
        return super.rangeForUserCompletion
    }

    public override func completions(forPartialWordRange charRange: NSRange, indexOfSelectedItem: UnsafeMutablePointer<Int>?) -> [String]? {
        guard let text = self.textStorage?.string as NSString?,
              charRange.location + charRange.length <= text.length else {
            return nil
        }
        let prefix = text.substring(with: charRange)
        guard prefix.count >= 1 else { return nil }
        let lowerPrefix = prefix.lowercased()

        var candidateSet = Set<String>()

        // 1. Language keywords
        if let coordinator = self.delegate as? NativeEditorView.Coordinator {
            for kw in coordinator.document.syntaxLanguage.keywords {
                if kw.lowercased().hasPrefix(lowerPrefix) && kw.lowercased() != lowerPrefix {
                    candidateSet.insert(kw)
                }
            }
        }

        // 2. Words in the current document (Notepad++ Word Completion)
        let pattern = "\\b[a-zA-Z_][a-zA-Z0-9_\\-]{2,}\\b"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: text as String, range: NSRange(location: 0, length: text.length))
            for match in matches {
                let word = text.substring(with: match.range)
                if word.lowercased().hasPrefix(lowerPrefix) && word.lowercased() != lowerPrefix {
                    candidateSet.insert(word)
                }
            }
        }

        guard !candidateSet.isEmpty else { return nil }

        // Sort: exact case match first, then alphabetical, limit to 25
        let sorted = candidateSet.sorted { a, b in
            let aExact = a.hasPrefix(prefix)
            let bExact = b.hasPrefix(prefix)
            if aExact != bExact { return aExact }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }

        indexOfSelectedItem?.pointee = 0
        return Array(sorted.prefix(25))
    }
}
