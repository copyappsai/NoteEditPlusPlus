import Foundation

public struct PersistedDocument: Codable {
    public let id: UUID
    public let title: String
    public let filePath: String?
    public let content: String
    public let isModified: Bool
    public let encoding: DocumentEncoding
    public let lineEnding: LineEnding
    public let syntaxLanguage: SyntaxLanguage
}

public struct PersistedSession: Codable {
    public let documents: [PersistedDocument]
    public let activeDocumentId: UUID?
    public let lastSavedDate: Date
}

@MainActor
public final class SessionManager {
    public static let shared = SessionManager()

    private var sessionDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("NoteEditPlusPlus", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var sessionFile: URL {
        sessionDirectory.appendingPathComponent("session.json")
    }

    public func saveSession(documents: [DocumentModel], activeId: UUID?) {
        let persistedDocs = documents.map { doc in
            PersistedDocument(
                id: doc.id,
                title: doc.title,
                filePath: doc.fileURL?.path,
                content: doc.content,
                isModified: doc.isModified,
                encoding: doc.encoding,
                lineEnding: doc.lineEnding,
                syntaxLanguage: doc.syntaxLanguage
            )
        }

        let session = PersistedSession(
            documents: persistedDocs,
            activeDocumentId: activeId,
            lastSavedDate: Date()
        )

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(session)
            try data.write(to: sessionFile, options: .atomic)
        } catch {
            print("Failed to save session: \(error)")
        }
    }

    public func loadSession() -> (documents: [DocumentModel], activeId: UUID?)? {
        guard FileManager.default.fileExists(atPath: sessionFile.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: sessionFile)
            let session = try JSONDecoder().decode(PersistedSession.self, from: data)
            let docs = session.documents.map { pDoc -> DocumentModel in
                let url = pDoc.filePath != nil ? URL(fileURLWithPath: pDoc.filePath!) : nil
                var language = pDoc.syntaxLanguage
                if language == .plainText {
                    if let u = url, SyntaxLanguage.detect(from: u) != .plainText {
                        language = SyntaxLanguage.detect(from: u)
                    } else if let detected = SyntaxLanguage.detect(fromContent: pDoc.content) {
                        language = detected
                    }
                }
                return DocumentModel(
                    id: pDoc.id,
                    title: pDoc.title,
                    fileURL: url,
                    content: pDoc.content,
                    isModified: pDoc.isModified,
                    encoding: pDoc.encoding,
                    lineEnding: pDoc.lineEnding,
                    syntaxLanguage: language
                )
            }
            return (docs, session.activeDocumentId)
        } catch {
            print("Failed to load session: \(error)")
            return nil
        }
    }
}
