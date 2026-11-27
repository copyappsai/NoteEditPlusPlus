import Foundation
import Observation

@MainActor
@Observable
public final class FindReplaceState {
    public var isVisible: Bool = false
    public var findText: String = ""
    public var replaceText: String = ""
    public var matchCase: Bool = false
    public var wholeWord: Bool = false
    public var useRegex: Bool = false
    public var wrapAround: Bool = true
    
    public var matchCount: Int? = nil
    public var statusMessage: String = ""

    public var performFindNext: (() -> Void)?
    public var performFindPrevious: (() -> Void)?
    public var performReplace: (() -> Void)?
    public var performReplaceAll: (() -> Void)?
    public var performCount: (() -> Void)?

    public init() {}
}
