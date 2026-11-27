import SwiftUI
import AppKit

public struct ToolbarView: View {
    @Bindable var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        HStack(spacing: 2) {
            // New Document
            ToolbarCustomButton(tooltip: appState.tr("new_file") + " (Cmd+N)") {
                appState.newDocument()
            } content: {
                NotepadPlusIcons.NewDocIcon()
            }

            // Open Document
            ToolbarCustomButton(tooltip: appState.tr("open") + " (Cmd+O)") {
                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = true
                panel.canChooseDirectories = false
                if panel.runModal() == .OK {
                    for url in panel.urls {
                        appState.openDocument(from: url)
                    }
                }
            } content: {
                NotepadPlusIcons.OpenFolderIcon()
            }

            // Save Document (Blue Floppy Disk)
            ToolbarCustomButton(tooltip: appState.tr("save") + " (Cmd+S)") {
                appState.saveActiveDocument()
            } content: {
                NotepadPlusIcons.FloppyDiskIcon(isModified: appState.activeDocument?.isModified ?? false)
            }

            // Save All (Stack of Floppy Disks)
            ToolbarCustomButton(tooltip: appState.tr("save_all") + " (Cmd+Option+S)") {
                appState.saveAllDocuments()
            } content: {
                NotepadPlusIcons.SaveAllDisksIcon()
            }

            // Close Active
            ToolbarCustomButton(tooltip: appState.tr("close") + " (Cmd+W)") {
                if let id = appState.activeDocumentId {
                    appState.closeDocument(id: id)
                }
            } content: {
                NotepadPlusIcons.CloseDocIcon()
            }

            // Close All
            ToolbarCustomButton(tooltip: appState.tr("close_all") + " (Cmd+Shift+W)") {
                appState.closeAllDocuments()
            } content: {
                NotepadPlusIcons.CloseAllIcon()
            }

            ToolbarDivider()

            // Cut / Copy / Paste
            ToolbarCustomButton(tooltip: appState.tr("cut") + " (Cmd+X)") {
                NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
            } content: {
                NotepadPlusIcons.CutScissorsIcon()
            }

            ToolbarCustomButton(tooltip: appState.tr("copy") + " (Cmd+C)") {
                NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
            } content: {
                NotepadPlusIcons.CopyDocsIcon()
            }

            ToolbarCustomButton(tooltip: appState.tr("paste") + " (Cmd+V)") {
                NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
            } content: {
                NotepadPlusIcons.PasteClipIcon()
            }

            ToolbarDivider()

            // Undo / Redo
            ToolbarCustomButton(tooltip: appState.tr("undo") + " (Cmd+Z)") {
                NSApp.sendAction(Selector(("undo:")), to: nil, from: nil)
            } content: {
                NotepadPlusIcons.UndoArrowIcon()
            }

            ToolbarCustomButton(tooltip: appState.tr("redo") + " (Cmd+Shift+Z)") {
                NSApp.sendAction(Selector(("redo:")), to: nil, from: nil)
            } content: {
                NotepadPlusIcons.RedoArrowIcon()
            }

            ToolbarDivider()

            // Find (Binoculars)
            ToolbarCustomButton(tooltip: appState.tr("find_replace") + " (Cmd+F)", isActive: appState.findReplaceState.isVisible) {
                appState.findReplaceState.isVisible.toggle()
            } content: {
                NotepadPlusIcons.FindBinocularsIcon()
            }

            // Replace (Binoculars with arrows)
            ToolbarCustomButton(tooltip: appState.tr("find_in_files") + " (Cmd+Shift+F)", isActive: appState.isFindInFilesVisible) {
                appState.isFindInFilesVisible.toggle()
            } content: {
                NotepadPlusIcons.ReplaceArrowsIcon()
            }

            // Compare documents
            ToolbarCustomButton(tooltip: appState.tr("compare"), isActive: appState.isCompareVisible) {
                appState.isCompareVisible.toggle()
            } content: {
                Image(systemName: "arrow.left.and.right.square.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.3, green: 0.6, blue: 0.3))
            }

            ToolbarDivider()

            // Zoom in / Zoom out
            ToolbarCustomButton(tooltip: appState.tr("zoom_in") + " (Cmd++)") {
                appState.fontSize = min(36, appState.fontSize + 1)
            } content: {
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.accentColor)
            }

            ToolbarCustomButton(tooltip: appState.tr("zoom_out") + " (Cmd+-)") {
                appState.fontSize = max(8, appState.fontSize - 1)
            } content: {
                Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.accentColor)
            }

            // Word wrap (Classic Notepad++ return arrow)
            ToolbarCustomButton(tooltip: appState.tr("word_wrap"), isActive: appState.isWordWrapEnabled) {
                appState.isWordWrapEnabled.toggle()
            } content: {
                NotepadPlusIcons.WordWrapIcon()
            }

            // Show invisibles (Classic Pilcrow ¶)
            ToolbarCustomButton(tooltip: appState.tr("invisibles"), isActive: appState.showInvisibleCharacters) {
                appState.showInvisibleCharacters.toggle()
            } content: {
                NotepadPlusIcons.PilcrowIcon()
            }

            ToolbarDivider()

            // Workspace Sidebar toggle
            ToolbarCustomButton(tooltip: appState.tr("sidebar") + " (Cmd+Option+B)", isActive: appState.isSidebarVisible) {
                appState.isSidebarVisible.toggle()
            } content: {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.primary)
            }

            // Dual view toggle
            ToolbarCustomButton(tooltip: appState.tr("dual_view") + " (Cmd+Option+D)", isActive: appState.isDualViewEnabled) {
                appState.isDualViewEnabled.toggle()
            } content: {
                Image(systemName: "rectangle.split.2x1")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.primary)
            }

            // Bookmark toggle
            ToolbarCustomButton(tooltip: appState.tr("toggle_bookmark") + " (Cmd+M)") {
                appState.toggleBookmarkOnActiveLine()
            } content: {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.15, green: 0.55, blue: 0.95))
            }

            // Format JSON
            ToolbarCustomButton(tooltip: appState.tr("format_json")) {
                appState.formatActiveJSON()
            } content: {
                Text("{ }")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(Color(red: 0.95, green: 0.45, blue: 0.1))
            }

            Spacer()
        }
        .padding(.horizontal, 6)
        .frame(height: 32)
        .background(
            LinearGradient(
                colors: [Color(NSColor.controlBackgroundColor), Color(NSColor.windowBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Divider(), alignment: .bottom
        )
    }
}

private struct ToolbarCustomButton<Content: View>: View {
    var tooltip: String
    var isActive: Bool = false
    var action: () -> Void
    @ViewBuilder var content: () -> Content

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            content()
                .frame(width: 24, height: 24)
                .background(
                    isActive
                        ? Color.accentColor.opacity(0.2)
                        : (isHovered ? Color.gray.opacity(0.18) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isActive ? Color.accentColor : (isHovered ? Color.gray.opacity(0.4) : Color.clear), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .buttonStyle(.plain)
        .help(tooltip)
        .accessibilityLabel(tooltip)
        .onHover { isHovered = $0 }
    }
}

private struct ToolbarDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 1, height: 18)
            .padding(.horizontal, 3)
    }
}
