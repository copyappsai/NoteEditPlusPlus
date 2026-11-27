import SwiftUI
import AppKit

public struct TabBarView: View {
    @Bindable var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(appState.documents) { doc in
                        ClassicTabItemView(
                            doc: doc,
                            isActive: appState.activeDocumentId == doc.id,
                            onSelect: {
                                appState.activeDocumentId = doc.id
                            },
                            onClose: {
                                appState.closeDocument(id: doc.id)
                            },
                            appState: appState
                        )
                    }
                }
                .padding(.leading, 4)
                .padding(.top, 2)
            }

            // New Tab '+' button
            Button(action: {
                appState.newDocument()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .help(appState.tr("new_file") + " (Cmd+N)")
            .padding(.trailing, 6)
        }
        .frame(height: 30)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
}

private struct ClassicTabItemView: View {
    var doc: DocumentModel
    var isActive: Bool
    var onSelect: () -> Void
    var onClose: () -> Void
    var appState: AppState

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 6) {
            // Iconic Notepad++ Floppy Disk icon: Blue when saved, RED when modified!
            NotepadPlusIcons.FloppyDiskIcon(isModified: doc.isModified)
                .scaleEffect(0.9)

            Text(doc.title)
                .font(.system(size: 12, weight: isActive ? .medium : .regular))
                .lineLimit(1)
                .foregroundStyle(isActive ? Color.primary : Color.secondary)

            // Close 'X' button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(isHovered || isActive ? Color.secondary : Color.clear)
                    .frame(width: 14, height: 14)
                    .background(isHovered ? Color.gray.opacity(0.2) : Color.clear)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close " + doc.title)
        }
        .padding(.horizontal, 8)
        .frame(height: 27)
        .background(
            isActive
                ? Color(NSColor.textBackgroundColor)
                : (isHovered ? Color.gray.opacity(0.15) : Color(NSColor.controlBackgroundColor).opacity(0.7))
        )
        .overlay(
            // Top highlight line for active tab
            Rectangle()
                .fill(isActive ? (doc.isModified ? Color.red : Color(red: 0.95, green: 0.55, blue: 0.15)) : Color.clear)
                .frame(height: 2),
            alignment: .top
        )
        .overlay(
            // Subtle border around tabs
            Rectangle()
                .stroke(Color.gray.opacity(0.25), lineWidth: 0.5)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button(appState.tr("close")) { onClose() }
            Button(appState.tr("close_all")) {
                for other in appState.documents where other.id != doc.id {
                    appState.closeDocument(id: other.id)
                }
            }
            Divider()
            Button(appState.tr("save")) {
                appState.activeDocumentId = doc.id
                appState.saveActiveDocument()
            }
            Button(appState.tr("dual_view")) {
                appState.activeDocumentId = doc.id
                appState.cloneActiveToSecondaryView()
            }
            if let url = doc.fileURL {
                Divider()
                Button(appState.tr("copy_path")) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.path, forType: .string)
                }
                Button(appState.tr("reveal_in_finder")) {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
        }
    }
}
