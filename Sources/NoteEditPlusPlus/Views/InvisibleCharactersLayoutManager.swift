import Cocoa

public final class InvisibleCharactersLayoutManager: NSLayoutManager {
    public var showInvisibles: Bool = false {
        didSet {
            guard let storage = textStorage else { return }
            invalidateDisplay(forCharacterRange: NSRange(location: 0, length: storage.length))
        }
    }

    private let invisibleAttrs: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.placeholderTextColor,
        .font: NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)
    ]

    public override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)

        guard showInvisibles, let storage = textStorage else { return }
        let text = storage.string as NSString
        let charRange = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        guard charRange.location + charRange.length <= text.length else { return }

        text.enumerateSubstrings(in: charRange, options: .byComposedCharacterSequences) { [weak self] substring, subRange, _, _ in
            guard let self = self, let char = substring?.first else { return }

            if char == " " || char == "\t" || char == "\n" {
                let glyphIndex = self.glyphIndexForCharacter(at: subRange.location)
                let point = self.location(forGlyphAt: glyphIndex)
                let lineRect = self.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)
                let drawPoint = NSPoint(
                    x: origin.x + lineRect.origin.x + point.x,
                    y: origin.y + lineRect.origin.y + (lineRect.height - 10) / 2
                )

                let symbol: String
                switch char {
                case " ": symbol = "·"
                case "\t": symbol = "→"
                case "\n": symbol = "¬"
                default: symbol = ""
                }

                if !symbol.isEmpty {
                    (symbol as NSString).draw(at: drawPoint, withAttributes: self.invisibleAttrs)
                }
            }
        }
    }
}
