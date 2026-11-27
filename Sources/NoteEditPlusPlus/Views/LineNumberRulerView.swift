import Cocoa
import AppKit

public class LineNumberRulerView: NSRulerView {
    private var font: NSFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    public var theme: AppTheme = .classicLight {
        didSet {
            needsDisplay = true
        }
    }
    public weak var document: DocumentModel?

    public init(scrollView: NSScrollView) {
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        self.clientView = scrollView.documentView
        self.ruleThickness = 52
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func updateFont(size: CGFloat) {
        self.font = NSFont.monospacedSystemFont(ofSize: max(9, size - 2), weight: .regular)
        needsDisplay = true
    }

    public override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            return
        }

        let drawBounds = self.bounds
        NSGraphicsContext.saveGraphicsState()
        NSBezierPath(rect: drawBounds).addClip()
        defer { NSGraphicsContext.restoreGraphicsState() }

        theme.gutterBackgroundColor.setFill()
        drawBounds.fill()

        // Separator line on the right
        let sepColor = theme.isDark ? NSColor.separatorColor : NSColor(white: 0.82, alpha: 1.0)
        sepColor.setStroke()
        let sepPath = NSBezierPath()
        sepPath.move(to: NSPoint(x: drawBounds.maxX - 0.5, y: drawBounds.minY))
        sepPath.line(to: NSPoint(x: drawBounds.maxX - 0.5, y: drawBounds.maxY))
        sepPath.lineWidth = 1.0
        sepPath.stroke()

        let lineNumberColor = theme.gutterTextColor
        let activeLineNumberColor = theme.isDark ? NSColor.white : NSColor.black

        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)
        let text = (textView.string as NSString)
        if text.length == 0 {
            // Empty document line 1
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: activeLineNumberColor
            ]
            let str = NSAttributedString(string: "1", attributes: attrs)
            let textSize = str.size()
            let strRect = NSRect(
                x: drawBounds.width - textSize.width - 18,
                y: textView.textContainerInset.height,
                width: textSize.width,
                height: textSize.height
            )
            str.draw(in: strRect)
            return
        }

        let selectedRange = textView.selectedRange()
        var currentSelectedLine = -1
        if selectedRange.location <= text.length {
            var lineIndex = 1
            text.enumerateSubstrings(in: NSRange(location: 0, length: selectedRange.location), options: [.byLines, .substringNotRequired]) { _, _, _, _ in
                lineIndex += 1
            }
            currentSelectedLine = lineIndex
        }

        var lineNumber = 1
        // Count lines up to visible range start
        let startCharIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
        if startCharIndex > 0 {
            text.enumerateSubstrings(in: NSRange(location: 0, length: startCharIndex), options: [.byLines, .substringNotRequired]) { _, _, _, _ in
                lineNumber += 1
            }
        }

        // Adjust rule thickness if line numbers grow large
        let totalLines = text.components(separatedBy: "\n").count
        let digitCount = max(3, "\(totalLines)".count)
        let neededThickness = CGFloat(digitCount * 9 + 18)
        if abs(ruleThickness - neededThickness) > 2 {
            DispatchQueue.main.async {
                self.ruleThickness = neededThickness
            }
        }

        var glyphIndex = visibleGlyphRange.location
        while glyphIndex < NSMaxRange(visibleGlyphRange) {
            let charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
            let lineRange = text.lineRange(for: NSRange(location: charIndex, length: 0))
            let lineGlyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)

            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
            let origin = textView.textContainerOrigin
            let y = lineRect.origin.y + origin.y - textView.visibleRect.origin.y

            let isCurrentLine = (lineNumber == currentSelectedLine)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: isCurrentLine ? activeLineNumberColor : lineNumberColor
            ]

            let numStr = "\(lineNumber)"
            let str = NSAttributedString(string: numStr, attributes: attrs)
            let textSize = str.size()
            let drawRect = NSRect(
                x: bounds.width - textSize.width - 18,
                y: y + (lineRect.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            // Draw 3D bookmark sphere if bookmarked
            if let doc = self.document, doc.bookmarks.contains(lineNumber) {
                let bookmarkRect = NSRect(x: 4, y: y + (lineRect.height - 11) / 2, width: 11, height: 11)
                let gradient = NSGradient(
                    starting: NSColor(red: 0.35, green: 0.70, blue: 1.0, alpha: 1.0),
                    ending: NSColor(red: 0.05, green: 0.25, blue: 0.75, alpha: 1.0)
                )
                gradient?.draw(in: NSBezierPath(ovalIn: bookmarkRect), relativeCenterPosition: NSPoint(x: -0.25, y: 0.25))

                // Shiny specular reflection dot
                let dotRect = NSRect(x: bookmarkRect.minX + 2.5, y: bookmarkRect.minY + 6.0, width: 2.5, height: 2.5)
                NSColor.white.withAlphaComponent(0.85).setFill()
                NSBezierPath(ovalIn: dotRect).fill()
            }

            // Draw Scintilla tree fold box [-] if line starts a foldable block
            let lineString = text.substring(with: lineRange)
            let trimmed = lineString.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.contains("{") || (trimmed.hasSuffix(":") && (self.document?.syntaxLanguage == .python || self.document?.syntaxLanguage == .yaml)) {
                let boxSize: CGFloat = 9.0
                let boxRect = NSRect(x: bounds.width - 13, y: y + (lineRect.height - boxSize) / 2, width: boxSize, height: boxSize)
                NSColor.windowBackgroundColor.setFill()
                boxRect.fill()
                NSColor.gray.setStroke()
                let bp = NSBezierPath(rect: boxRect)
                bp.lineWidth = 1.0
                bp.stroke()

                // Minus sign inside box
                let minusPath = NSBezierPath()
                minusPath.move(to: NSPoint(x: boxRect.minX + 2, y: boxRect.midY))
                minusPath.line(to: NSPoint(x: boxRect.maxX - 2, y: boxRect.midY))
                minusPath.lineWidth = 1.0
                NSColor.darkGray.setStroke()
                minusPath.stroke()
            }

            str.draw(in: drawRect)

            lineNumber += 1
            glyphIndex = NSMaxRange(lineGlyphRange)
        }
    }

    public override func mouseDown(with event: NSEvent) {
        guard let textView = clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer,
              let doc = document else {
            super.mouseDown(with: event)
            return
        }

        let point = convert(event.locationInWindow, from: nil)
        let glyphIndex = layoutManager.glyphIndex(for: NSPoint(x: 0, y: point.y + textView.visibleRect.origin.y), in: textContainer)
        let charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)

        let text = (textView.string as NSString)
        if charIndex < text.length {
            var clickedLine = 1
            text.enumerateSubstrings(in: NSRange(location: 0, length: charIndex), options: [.byLines, .substringNotRequired]) { _, _, _, _ in
                clickedLine += 1
            }

            if doc.bookmarks.contains(clickedLine) {
                doc.bookmarks.remove(clickedLine)
            } else {
                doc.bookmarks.insert(clickedLine)
            }
            needsDisplay = true
            return
        }

        super.mouseDown(with: event)
    }
}
