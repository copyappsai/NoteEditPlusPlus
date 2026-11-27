import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var appState: AppState?

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for filename in filenames {
            let url = URL(fileURLWithPath: filename)
            Task { @MainActor in
                self.appState?.openDocument(from: url)
            }
        }
    }
}

@main
struct NoteEditApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup("NoteEdit++") {
            MainContentView(appState: appState)
                .onAppear {
                    appDelegate.appState = appState
                }
                .onOpenURL { url in
                    appState.openDocument(from: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    appState.saveSession()
                }
        }
        Settings {
            PreferencesView(appState: appState)
        }
        .commands {
            // App Info
            CommandGroup(replacing: .appInfo) {
                Button(appState.tr("about")) {
                    appState.isAboutVisible = true
                }
            }

            // File Menu Commands
            CommandGroup(replacing: .newItem) {
                Button(appState.tr("new_file")) {
                    appState.newDocument()
                }
                .keyboardShortcut("n", modifiers: .command)

                Button(appState.tr("open")) {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseDirectories = false
                    if panel.runModal() == .OK {
                        for url in panel.urls {
                            appState.openDocument(from: url)
                        }
                    }
                }
                .keyboardShortcut("o", modifiers: .command)

                Button(appState.tr("open_folder")) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK, let url = panel.url {
                        appState.workspaceURL = url
                        appState.isSidebarVisible = true
                    }
                }

                Divider()

                Button(appState.tr("save")) {
                    appState.saveActiveDocument()
                }
                .keyboardShortcut("s", modifiers: .command)

                Button(appState.tr("save_as")) {
                    appState.saveActiveDocument(as: true)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])

                Button(appState.tr("save_all")) {
                    appState.saveAllDocuments()
                }
                .keyboardShortcut("s", modifiers: [.command, .option])

                Divider()

                Button(appState.tr("close")) {
                    if let id = appState.activeDocumentId {
                        appState.closeDocument(id: id)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)

                Button(appState.tr("close_all")) {
                    appState.closeAllDocuments()
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])

                Divider()

                Button(appState.tr("print")) {
                    appState.printActiveDocument()
                }
                .keyboardShortcut("p", modifiers: .command)
            }

            // Find Menu Commands
            CommandGroup(after: .textEditing) {
                Divider()
                Button(appState.tr("find_replace")) {
                    appState.findReplaceState.isVisible.toggle()
                }
                .keyboardShortcut("f", modifiers: .command)

                Button(appState.tr("find_in_files")) {
                    appState.isFindInFilesVisible.toggle()
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])

                Button(appState.tr("compare")) {
                    appState.isCompareVisible.toggle()
                }

                Button(appState.tr("find_next")) {
                    appState.findReplaceState.performFindNext?()
                }
                .keyboardShortcut("g", modifiers: .command)

                Button(appState.tr("find_prev")) {
                    appState.findReplaceState.performFindPrevious?()
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
            }

            // View Menu Commands
            CommandGroup(after: .toolbar) {
                Divider()
                Toggle(appState.tr("sidebar"), isOn: $appState.isSidebarVisible)
                    .keyboardShortcut("b", modifiers: [.command, .option])

                Toggle(appState.tr("dual_view"), isOn: $appState.isDualViewEnabled)
                    .keyboardShortcut("d", modifiers: [.command, .option])

                Toggle(appState.tr("invisibles"), isOn: $appState.showInvisibleCharacters)

                Toggle(appState.tr("word_wrap"), isOn: $appState.isWordWrapEnabled)

                Divider()
                Menu(appState.tr("theme")) {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            appState.theme = theme
                        } label: {
                            HStack {
                                Text(theme.rawValue)
                                if appState.theme == theme {
                                    Text("✓")
                                }
                            }
                        }
                    }
                }

                Divider()
                Button(appState.tr("zoom_in")) {
                    appState.fontSize = min(36, appState.fontSize + 1)
                }
                .keyboardShortcut("+", modifiers: .command)

                Button(appState.tr("zoom_out")) {
                    appState.fontSize = max(8, appState.fontSize - 1)
                }
                .keyboardShortcut("-", modifiers: .command)

                Button(appState.tr("zoom_reset")) {
                    appState.fontSize = 13
                }
                .keyboardShortcut("0", modifiers: .command)
            }

            // Line Operations Menu
            CommandMenu(appState.tr("lines")) {
                Button(appState.tr("dup_line")) {
                    appState.performAction(.duplicateLine)
                }
                .keyboardShortcut("d", modifiers: .command)

                Button(appState.tr("del_line")) {
                    appState.performAction(.deleteLine)
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])

                Divider()

                Button(appState.tr("move_up")) {
                    appState.performAction(.moveLineUp)
                }
                .keyboardShortcut(.upArrow, modifiers: .option)

                Button(appState.tr("move_down")) {
                    appState.performAction(.moveLineDown)
                }
                .keyboardShortcut(.downArrow, modifiers: .option)

                Button(appState.tr("join_lines")) {
                    appState.performAction(.joinLines)
                }
                .keyboardShortcut("j", modifiers: .command)

                Divider()

                Button(appState.tr("sort_asc")) {
                    appState.performAction(.sortAscending)
                }

                Button(appState.tr("sort_desc")) {
                    appState.performAction(.sortDescending)
                }

                Button(appState.tr("sort_num")) {
                    appState.performAction(.sortNumeric)
                }

                Divider()

                Button(appState.tr("remove_dups")) {
                    appState.performAction(.removeDuplicates)
                }

                Button(appState.tr("remove_empty")) {
                    appState.performAction(.removeEmptyLines)
                }

                Button(appState.tr("trim_trailing")) {
                    appState.performAction(.trimTrailing)
                }

                Button(appState.tr("trim_leading")) {
                    appState.performAction(.trimLeading)
                }

                Button(appState.tr("trim_both")) {
                    appState.performAction(.trimBoth)
                }
            }

            // Text Conversions Menu
            CommandMenu(appState.tr("convert")) {
                Button(appState.tr("uppercase")) {
                    appState.performAction(.toUppercase)
                }
                .keyboardShortcut("u", modifiers: [.command, .shift])

                Button(appState.tr("lowercase")) {
                    appState.performAction(.toLowercase)
                }
                .keyboardShortcut("u", modifiers: .command)

                Button(appState.tr("title_case")) {
                    appState.performAction(.toTitleCase)
                }

                Button(appState.tr("invert_case")) {
                    appState.performAction(.invertCase)
                }

                Divider()

                Button(appState.tr("tabs_to_spaces")) {
                    appState.performAction(.tabsToSpaces)
                }

                Button(appState.tr("spaces_to_tabs")) {
                    appState.performAction(.spacesToTabs)
                }

                Divider()

                Button(appState.tr("insert_date")) {
                    appState.performAction(.insertDate)
                }

                Button(appState.tr("insert_datetime")) {
                    appState.performAction(.insertDateTime)
                }
            }

            // Bookmarks Menu
            CommandMenu(appState.tr("bookmarks")) {
                Button(appState.tr("toggle_bookmark")) {
                    appState.toggleBookmarkOnActiveLine()
                }
                .keyboardShortcut("m", modifiers: .command)

                Button(appState.tr("next_bookmark")) {
                    appState.nextBookmark()
                }
                .keyboardShortcut("]", modifiers: [.command, .option])

                Button(appState.tr("prev_bookmark")) {
                    appState.prevBookmark()
                }
                .keyboardShortcut("[", modifiers: [.command, .option])

                Divider()

                Button(appState.tr("clear_bookmarks")) {
                    appState.clearBookmarks()
                }

                Button(appState.tr("copy_bookmarked")) {
                    appState.copyBookmarkedLines()
                }

                Button(appState.tr("del_bookmarked")) {
                    appState.deleteBookmarkedLines()
                }
            }

            // Developer Tools Menu
            CommandMenu(appState.tr("tools")) {
                Button(appState.tr("format_json")) {
                    appState.formatActiveJSON()
                }

                Button(appState.tr("minify_json")) {
                    appState.minifyActiveJSON()
                }

                Button(appState.tr("format_xml")) {
                    appState.formatActiveXML()
                }

                Divider()

                Button(appState.tr("b64_encode")) {
                    appState.base64EncodeActive()
                }

                Button(appState.tr("b64_decode")) {
                    appState.base64DecodeActive()
                }

                Divider()

                Button(appState.tr("url_encode")) {
                    appState.urlEncodeActive()
                }

                Button(appState.tr("url_decode")) {
                    appState.urlDecodeActive()
                }

                Divider()

                Button(appState.tr("copy_sha256")) {
                    if let doc = appState.activeDocument {
                        let hash = DeveloperToolsManager.sha256Hex(doc.content)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(hash, forType: .string)
                    }
                }

                Button(appState.tr("copy_md5")) {
                    if let doc = appState.activeDocument {
                        let hash = DeveloperToolsManager.md5Hex(doc.content)
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(hash, forType: .string)
                    }
                }
            }

            // UI Language Menu
            CommandMenu(appState.tr("ui_language")) {
                ForEach(UILanguage.allCases) { lang in
                    Button {
                        appState.uiLanguage = lang
                    } label: {
                        HStack {
                            Text(lang.displayName)
                            if appState.uiLanguage == lang {
                                Text("✓")
                            }
                        }
                    }
                }
            }

            // Document Encoding & Language Menus
            CommandMenu(appState.tr("encoding")) {
                if let doc = appState.activeDocument {
                    ForEach(DocumentEncoding.allCases) { enc in
                        Button {
                            appState.convertEncoding(for: doc, to: enc)
                        } label: {
                            HStack {
                                Text(enc.rawValue)
                                if doc.encoding == enc {
                                    Text("✓")
                                }
                            }
                        }
                    }
                }
            }

            CommandMenu(appState.tr("language")) {
                if let doc = appState.activeDocument {
                    ForEach(SyntaxLanguage.allCases) { lang in
                        Button {
                            doc.syntaxLanguage = lang
                        } label: {
                            HStack {
                                Text(lang.rawValue)
                                if doc.syntaxLanguage == lang {
                                    Text("✓")
                                }
                            }
                        }
                    }
                }
            }

            // Help Menu
            CommandGroup(replacing: .help) {
                Button(appState.tr("noteedit_help")) {
                    appState.isHelpVisible = true
                }
                .keyboardShortcut("?", modifiers: .command)

                Button(appState.tr("shortcuts")) {
                    appState.isHelpVisible = true
                }

                Divider()

                Button(appState.tr("about")) {
                    appState.isAboutVisible = true
                }
            }
        }
    }
}
