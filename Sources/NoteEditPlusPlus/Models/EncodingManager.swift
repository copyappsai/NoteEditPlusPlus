import Foundation

public enum LineEnding: String, CaseIterable, Identifiable, Codable, Sendable {
    case lf = "\n"
    case crlf = "\r\n"
    case cr = "\r"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .lf: return "Unix (LF)"
        case .crlf: return "Windows (CR LF)"
        case .cr: return "Macintosh (CR)"
        }
    }

    public var shortName: String {
        switch self {
        case .lf: return "LF"
        case .crlf: return "CRLF"
        case .cr: return "CR"
        }
    }
}

public enum DocumentEncoding: String, CaseIterable, Identifiable, Codable, Sendable {
    case utf8 = "UTF-8"
    case utf8BOM = "UTF-8-BOM"
    case utf16LE = "UTF-16 LE"
    case utf16BE = "UTF-16 BE"
    case windows1252 = "Windows-1252 (ANSI)"
    case windows1250 = "Windows-1250 (Central European)"
    case isoLatin1 = "ISO-8859-1 (Latin 1)"
    case ascii = "US-ASCII"

    public var id: String { rawValue }

    public var stringEncoding: String.Encoding {
        switch self {
        case .utf8, .utf8BOM:
            return .utf8
        case .utf16LE:
            return .utf16LittleEndian
        case .utf16BE:
            return .utf16BigEndian
        case .windows1252:
            return .windowsCP1252
        case .windows1250:
            return .windowsCP1250
        case .isoLatin1:
            return .isoLatin1
        case .ascii:
            return .ascii
        }
    }
}

public struct EncodingDetector {
    public static func detect(data: Data) -> (encoding: DocumentEncoding, lineEnding: LineEnding, text: String) {
        // Check for BOMs
        if data.starts(with: [0xEF, 0xBB, 0xBF]) {
            let contentData = data.dropFirst(3)
            let text = String(data: contentData, encoding: .utf8) ?? ""
            return (.utf8BOM, detectLineEnding(text: text), text)
        }
        if data.starts(with: [0xFF, 0xFE]) {
            let contentData = data.dropFirst(2)
            let text = String(data: contentData, encoding: .utf16LittleEndian) ?? ""
            return (.utf16LE, detectLineEnding(text: text), text)
        }
        if data.starts(with: [0xFE, 0xFF]) {
            let contentData = data.dropFirst(2)
            let text = String(data: contentData, encoding: .utf16BigEndian) ?? ""
            return (.utf16BE, detectLineEnding(text: text), text)
        }

        // Try standard UTF-8
        if let utf8Text = String(data: data, encoding: .utf8) {
            return (.utf8, detectLineEnding(text: utf8Text), utf8Text)
        }

        // Try Windows-1250 / 1252
        if let win1250Text = String(data: data, encoding: .windowsCP1250) {
            return (.windows1250, detectLineEnding(text: win1250Text), win1250Text)
        }

        if let latinText = String(data: data, encoding: .isoLatin1) {
            return (.isoLatin1, detectLineEnding(text: latinText), latinText)
        }

        let fallbackText = String(decoding: data, as: UTF8.self)
        return (.utf8, detectLineEnding(text: fallbackText), fallbackText)
    }

    public static func detectLineEnding(text: String) -> LineEnding {
        if text.contains("\r\n") {
            return .crlf
        } else if text.contains("\r") && !text.contains("\n") {
            return .cr
        }
        return .lf
    }

    public static func convertLineEndings(in text: String, to target: LineEnding) -> String {
        // First normalize to \n
        let normalized = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        if target == .lf {
            return normalized
        } else if target == .crlf {
            return normalized.replacingOccurrences(of: "\n", with: "\r\n")
        } else {
            return normalized.replacingOccurrences(of: "\n", with: "\r")
        }
    }

    public static func encode(text: String, encoding: DocumentEncoding, lineEnding: LineEnding) -> Data? {
        let convertedText = convertLineEndings(in: text, to: lineEnding)
        var data = Data()

        switch encoding {
        case .utf8BOM:
            data.append(contentsOf: [0xEF, 0xBB, 0xBF])
            if let textData = convertedText.data(using: .utf8) {
                data.append(textData)
            }
            return data
        case .utf16LE:
            data.append(contentsOf: [0xFF, 0xFE])
            if let textData = convertedText.data(using: .utf16LittleEndian) {
                data.append(textData)
            }
            return data
        case .utf16BE:
            data.append(contentsOf: [0xFE, 0xFF])
            if let textData = convertedText.data(using: .utf16BigEndian) {
                data.append(textData)
            }
            return data
        default:
            return convertedText.data(using: encoding.stringEncoding)
        }
    }
}
