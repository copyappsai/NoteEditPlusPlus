import SwiftUI
import AppKit

public struct StatusBarView: View {
    @Bindable var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        HStack(spacing: 0) {
            if let doc = appState.activeDocument {
                // Segment 1: Length & Lines
                StatusBarSegment {
                    Text("\(appState.tr("length")): \(doc.characterCount)   \(appState.tr("lines_stat")): \(doc.lineCount)")
                }
                .frame(minWidth: 150, alignment: .leading)

                // Segment 2: Cursor Position & Selection
                StatusBarSegment {
                    if doc.selectionLength > 0 {
                        Text("\(appState.tr("ln")): \(doc.cursorLine)   \(appState.tr("col")): \(doc.cursorColumn)   \(appState.tr("sel")): \(doc.selectionLength) | \(doc.selectionLines) \(appState.tr("lines_stat"))")
                    } else {
                        Text("\(appState.tr("ln")): \(doc.cursorLine)   \(appState.tr("col")): \(doc.cursorColumn)   \(appState.tr("sel")): 0")
                    }
                }
                .frame(minWidth: 170, alignment: .leading)

                Spacer()

                // Segment 3: Line Ending (CRLF / LF / CR)
                StatusBarSegment {
                    Menu {
                        ForEach(LineEnding.allCases) { ending in
                            Button {
                                appState.convertLineEnding(for: doc, to: ending)
                            } label: {
                                HStack {
                                    Text(ending.displayName)
                                    if doc.lineEnding == ending {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(doc.lineEnding.displayName)
                            .font(.system(size: 11))
                    }
                    .menuStyle(.borderlessButton)
                }
                .frame(width: 140)

                // Segment 4: Encoding (UTF-8, Windows-1250, etc.)
                StatusBarSegment {
                    Menu {
                        ForEach(DocumentEncoding.allCases) { enc in
                            Button {
                                appState.convertEncoding(for: doc, to: enc)
                            } label: {
                                HStack {
                                    Text(enc.rawValue)
                                    if doc.encoding == enc {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(doc.encoding.rawValue)
                            .font(.system(size: 11))
                    }
                    .menuStyle(.borderlessButton)
                }
                .frame(width: 150)

                // Segment 5: Syntax Language
                StatusBarSegment {
                    Menu {
                        ForEach(SyntaxLanguage.allCases) { lang in
                            Button {
                                doc.syntaxLanguage = lang
                            } label: {
                                HStack {
                                    Text(lang.rawValue)
                                    if doc.syntaxLanguage == lang {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(doc.syntaxLanguage.rawValue)
                            .font(.system(size: 11))
                    }
                    .menuStyle(.borderlessButton)
                }
                .frame(width: 120)

                // Segment 6: Insert / Overwrite mode
                StatusBarSegment {
                    Text(appState.isOvertypeMode ? "OVR" : "INS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            appState.isOvertypeMode.toggle()
                        }
                }
                .frame(width: 45)
            } else {
                Text(appState.tr("no_open_doc"))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                Spacer()
            }
        }
        .frame(height: 22)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Divider(), alignment: .top
        )
    }
}

private struct StatusBarSegment<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack {
            content()
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 6)
        .frame(maxHeight: 18)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.35), lineWidth: 0.5)
        )
        .padding(.horizontal, 2)
    }
}
