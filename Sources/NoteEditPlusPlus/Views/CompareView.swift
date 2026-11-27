import SwiftUI

public struct CompareView: View {
    @Bindable var appState: AppState
    @State private var selectedDocAId: UUID?
    @State private var selectedDocBId: UUID?
    @State private var diffSummary: DiffSummary?

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Controls
            HStack(spacing: 12) {
                Text(appState.tr("compare_title"))
                    .font(.system(size: 13, weight: .bold))

                Spacer()

                // Doc A Picker
                Picker(appState.tr("doc_1"), selection: $selectedDocAId) {
                    Text(appState.tr("choose")).tag(nil as UUID?)
                    ForEach(appState.documents) { doc in
                        Text(doc.title).tag(doc.id as UUID?)
                    }
                }
                .frame(width: 180)

                // Doc B Picker
                Picker(appState.tr("doc_2"), selection: $selectedDocBId) {
                    Text(appState.tr("choose")).tag(nil as UUID?)
                    ForEach(appState.documents) { doc in
                        Text(doc.title).tag(doc.id as UUID?)
                    }
                }
                .frame(width: 180)

                Button(appState.tr("compare_title")) {
                    runCompare()
                }
                .disabled(selectedDocAId == nil || selectedDocBId == nil || selectedDocAId == selectedDocBId)

                Spacer()

                Button {
                    appState.isCompareVisible = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(Divider(), alignment: .bottom)

            // Diff Result Content
            if let summary = diffSummary {
                // Summary Bar
                HStack(spacing: 16) {
                    Text("\(appState.tr("added")): \(summary.addedCount)")
                        .foregroundStyle(.green)
                    Text("\(appState.tr("removed")): \(summary.removedCount)")
                        .foregroundStyle(.red)
                    Text("\(appState.tr("unchanged")): \(summary.unchangedCount)")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .overlay(Divider(), alignment: .bottom)

                // Lines List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(summary.lines) { line in
                            DiffLineRow(line: line)
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text(appState.tr("compare_prompt"))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .frame(minHeight: 280, maxHeight: 420)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            if selectedDocAId == nil, let first = appState.documents.first {
                selectedDocAId = first.id
            }
            if selectedDocBId == nil, appState.documents.count > 1 {
                selectedDocBId = appState.documents[1].id
            }
        }
    }

    private func runCompare() {
        guard let idA = selectedDocAId, let idB = selectedDocBId,
              let docA = appState.documents.first(where: { $0.id == idA }),
              let docB = appState.documents.first(where: { $0.id == idB }) else { return }

        diffSummary = DocumentCompareManager.compare(textA: docA.content, textB: docB.content)
    }
}

private struct DiffLineRow: View {
    let line: DiffLine

    var body: some View {
        HStack(spacing: 8) {
            // Line number A
            Text(line.lineNumA.map { "\($0)" } ?? " ")
                .frame(width: 40, alignment: .trailing)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)

            // Line number B
            Text(line.lineNumB.map { "\($0)" } ?? " ")
                .frame(width: 40, alignment: .trailing)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)

            // Operation marker (+, -, ~, space)
            Text(marker)
                .frame(width: 14)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(markerColor)

            // Content
            Text(line.textB ?? line.textA ?? "")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 6)
        .frame(height: 20)
        .background(backgroundColor)
    }

    private var marker: String {
        switch line.type {
        case .added: return "+"
        case .removed: return "-"
        case .modified: return "~"
        case .unchanged: return " "
        }
    }

    private var markerColor: Color {
        switch line.type {
        case .added: return .green
        case .removed: return .red
        case .modified: return .orange
        case .unchanged: return .secondary
        }
    }

    private var textColor: Color {
        switch line.type {
        case .added: return Color(red: 0.1, green: 0.6, blue: 0.1)
        case .removed: return Color(red: 0.8, green: 0.2, blue: 0.2)
        case .modified: return Color(red: 0.8, green: 0.5, blue: 0.1)
        case .unchanged: return .primary
        }
    }

    private var backgroundColor: Color {
        switch line.type {
        case .added: return Color.green.opacity(0.12)
        case .removed: return Color.red.opacity(0.12)
        case .modified: return Color.orange.opacity(0.12)
        case .unchanged: return Color.clear
        }
    }
}
