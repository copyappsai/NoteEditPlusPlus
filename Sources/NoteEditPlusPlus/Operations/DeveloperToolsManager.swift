import Foundation
import CryptoKit

public struct DeveloperToolsManager: Sendable {
    
    // MARK: - JSON Tools
    
    public static func formatJSON(_ text: String, indent: Int = 4) -> String? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        guard let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]) else {
            return nil
        }
        guard var prettyString = String(data: prettyData, encoding: .utf8) else { return nil }
        
        if indent != 2 {
            let targetIndent = String(repeating: " ", count: indent)
            prettyString = prettyString.replacingOccurrences(of: "  ", with: targetIndent)
        }
        return prettyString
    }
    
    public static func minifyJSON(_ text: String) -> String? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        guard let compactData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else {
            return nil
        }
        return String(data: compactData, encoding: .utf8)
    }
    
    // MARK: - XML Tools
    
    public static func formatXML(_ text: String) -> String {
        var formatted = ""
        var level = 0
        let parts = text.replacingOccurrences(of: ">", with: ">\n").replacingOccurrences(of: "<", with: "\n<").components(separatedBy: "\n")
        
        for rawPart in parts {
            let part = rawPart.trimmingCharacters(in: .whitespaces)
            if part.isEmpty { continue }
            
            if part.hasPrefix("</") {
                level = max(0, level - 1)
            }
            
            let indent = String(repeating: "    ", count: level)
            formatted += indent + part + "\n"
            
            if part.hasPrefix("<") && !part.hasPrefix("</") && !part.hasSuffix("/>") && !part.hasPrefix("<?") && !part.hasPrefix("<!") {
                level += 1
            }
        }
        return formatted.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }
    
    // MARK: - Base64 Encoding / Decoding
    
    public static func base64Encode(_ text: String) -> String {
        return text.data(using: .utf8)?.base64EncodedString() ?? text
    }
    
    public static func base64Decode(_ text: String) -> String? {
        guard let data = Data(base64Encoded: text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - URL Encoding / Decoding
    
    public static func urlEncode(_ text: String) -> String {
        return text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
    }
    
    public static func urlDecode(_ text: String) -> String {
        return text.removingPercentEncoding ?? text
    }
    
    // MARK: - Hash Generation (SHA-256, MD5)
    
    public static func sha256Hex(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return "" }
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    public static func md5Hex(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return "" }
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
