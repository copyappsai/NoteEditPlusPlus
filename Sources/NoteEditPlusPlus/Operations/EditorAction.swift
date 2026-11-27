import Foundation

public enum EditorAction: Sendable {
    case duplicateLine
    case deleteLine
    case moveLineUp
    case moveLineDown
    case joinLines
    case sortAscending
    case sortDescending
    case sortNumeric
    case removeDuplicates
    case removeEmptyLines
    case trimTrailing
    case trimLeading
    case trimBoth
    case toUppercase
    case toLowercase
    case toTitleCase
    case invertCase
    case tabsToSpaces
    case spacesToTabs
    case insertDate
    case insertDateTime
}
