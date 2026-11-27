import Cocoa
import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case classicLight = "Notepad++ Classic (Light)"
    case classicDark = "Notepad++ Dark"
    case monokai = "Monokai"
    case solarizedLight = "Solarized Light"
    case solarizedDark = "Solarized Dark"
    case dracula = "Dracula"

    public var id: String { rawValue }

    public var backgroundColor: NSColor {
        switch self {
        case .classicLight: return NSColor.white
        case .classicDark: return NSColor(red: 0.12, green: 0.12, blue: 0.13, alpha: 1.0)
        case .monokai: return NSColor(red: 0.15, green: 0.16, blue: 0.13, alpha: 1.0)
        case .solarizedLight: return NSColor(red: 0.99, green: 0.96, blue: 0.89, alpha: 1.0)
        case .solarizedDark: return NSColor(red: 0.0, green: 0.17, blue: 0.21, alpha: 1.0)
        case .dracula: return NSColor(red: 0.16, green: 0.16, blue: 0.21, alpha: 1.0)
        }
    }

    public var textColor: NSColor {
        switch self {
        case .classicLight: return NSColor.black
        case .classicDark: return NSColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0)
        case .monokai: return NSColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        case .solarizedLight: return NSColor(red: 0.40, green: 0.48, blue: 0.51, alpha: 1.0)
        case .solarizedDark: return NSColor(red: 0.51, green: 0.58, blue: 0.59, alpha: 1.0)
        case .dracula: return NSColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)
        }
    }

    public var gutterBackgroundColor: NSColor {
        switch self {
        case .classicLight: return NSColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)
        case .classicDark: return NSColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)
        case .monokai: return NSColor(red: 0.12, green: 0.13, blue: 0.11, alpha: 1.0)
        case .solarizedLight: return NSColor(red: 0.93, green: 0.90, blue: 0.82, alpha: 1.0)
        case .solarizedDark: return NSColor(red: 0.03, green: 0.21, blue: 0.26, alpha: 1.0)
        case .dracula: return NSColor(red: 0.13, green: 0.13, blue: 0.18, alpha: 1.0)
        }
    }

    public var gutterTextColor: NSColor {
        switch self {
        case .classicLight, .solarizedLight: return NSColor.secondaryLabelColor
        case .classicDark, .monokai, .solarizedDark, .dracula: return NSColor.gray
        }
    }

    public var keywordColor: NSColor {
        switch self {
        case .classicLight: return NSColor(red: 0.0, green: 0.0, blue: 0.85, alpha: 1.0) // Classic N++ Blue
        case .classicDark: return NSColor(red: 0.35, green: 0.65, blue: 0.98, alpha: 1.0)
        case .monokai: return NSColor(red: 0.97, green: 0.15, blue: 0.45, alpha: 1.0) // Pink
        case .solarizedLight, .solarizedDark: return NSColor(red: 0.52, green: 0.60, blue: 0.0, alpha: 1.0) // Green
        case .dracula: return NSColor(red: 1.0, green: 0.47, blue: 0.77, alpha: 1.0) // Pink
        }
    }

    public var stringColor: NSColor {
        switch self {
        case .classicLight: return NSColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.0) // Classic N++ Grey/Brown
        case .classicDark: return NSColor(red: 0.93, green: 0.65, blue: 0.40, alpha: 1.0)
        case .monokai: return NSColor(red: 0.90, green: 0.86, blue: 0.45, alpha: 1.0) // Yellow
        case .solarizedLight, .solarizedDark: return NSColor(red: 0.16, green: 0.63, blue: 0.60, alpha: 1.0) // Cyan
        case .dracula: return NSColor(red: 0.95, green: 0.98, blue: 0.55, alpha: 1.0) // Yellow
        }
    }

    public var commentColor: NSColor {
        switch self {
        case .classicLight: return NSColor(red: 0.0, green: 0.50, blue: 0.0, alpha: 1.0) // Classic N++ Green
        case .classicDark: return NSColor(red: 0.45, green: 0.65, blue: 0.45, alpha: 1.0)
        case .monokai: return NSColor(red: 0.46, green: 0.44, blue: 0.36, alpha: 1.0)
        case .solarizedLight, .solarizedDark: return NSColor(red: 0.36, green: 0.43, blue: 0.44, alpha: 1.0)
        case .dracula: return NSColor(red: 0.38, green: 0.44, blue: 0.64, alpha: 1.0)
        }
    }

    public var numberColor: NSColor {
        switch self {
        case .classicLight: return NSColor(red: 1.0, green: 0.30, blue: 0.0, alpha: 1.0) // Orange
        case .classicDark: return NSColor(red: 0.70, green: 0.85, blue: 1.0, alpha: 1.0)
        case .monokai: return NSColor(red: 0.68, green: 0.51, blue: 1.0, alpha: 1.0) // Purple
        case .solarizedLight, .solarizedDark: return NSColor(red: 0.83, green: 0.21, blue: 0.51, alpha: 1.0) // Magenta
        case .dracula: return NSColor(red: 0.74, green: 0.58, blue: 0.98, alpha: 1.0) // Purple
        }
    }

    public var isDark: Bool {
        switch self {
        case .classicLight, .solarizedLight: return false
        case .classicDark, .monokai, .solarizedDark, .dracula: return true
        }
    }
}
