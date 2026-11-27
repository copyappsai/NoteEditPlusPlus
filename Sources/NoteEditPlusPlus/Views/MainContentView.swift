import SwiftUI

public struct MainContentView: View {
    @Bindable var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            ToolbarView(appState: appState)

            // Main Workspace Layout
            HSplitView {
                // Collapsible Workspace Sidebar
                if appState.isSidebarVisible {
                    WorkspaceSidebarView(appState: appState)
                        .transition(.move(edge: .leading))
                }

                // Center Editor Area
                VStack(spacing: 0) {
                    // Notepad++ style tabs
                    TabBarView(appState: appState)

                    // Find & Replace collapsible panel
                    if appState.findReplaceState.isVisible {
                        FindReplaceView(appState: appState)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Dual View or Single View
                    if appState.isDualViewEnabled {
                        HSplitView {
                            primaryEditorView
                            secondaryEditorView
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        primaryEditorView
                    }

                    // Collapsible Find In Files Results Panel
                    if appState.isFindInFilesVisible {
                        FindInFilesView(appState: appState)
                            .transition(.move(edge: .bottom))
                    }

                    // Collapsible Compare Diff Panel
                    if appState.isCompareVisible {
                        CompareView(appState: appState)
                            .transition(.move(edge: .bottom))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Notepad++ style status bar
            StatusBarView(appState: appState)
        }
        .frame(minWidth: 800, minHeight: 500)
        .sheet(isPresented: $appState.isAboutVisible) {
            AboutView(appState: appState)
        }
        .sheet(isPresented: $appState.isHelpVisible) {
            HelpView(appState: appState)
        }
    }

    @ViewBuilder
    private var primaryEditorView: some View {
        ZStack {
            if let activeDoc = appState.activeDocument {
                NativeEditorView(
                    document: activeDoc,
                    appState: appState,
                    isWordWrapEnabled: appState.isWordWrapEnabled,
                    fontSize: appState.fontSize,
                    findReplaceState: appState.findReplaceState
                )
                .id(activeDoc.id)
            } else {
                emptyStatePlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var secondaryEditorView: some View {
        ZStack {
            if let secDoc = appState.secondaryDocuments.first(where: { $0.id == appState.secondaryActiveDocumentId }) ?? appState.secondaryDocuments.first {
                NativeEditorView(
                    document: secDoc,
                    appState: appState,
                    isWordWrapEnabled: appState.isWordWrapEnabled,
                    fontSize: appState.fontSize,
                    findReplaceState: appState.findReplaceState
                )
                .id("sec_\(secDoc.id)")
            } else if let activeDoc = appState.activeDocument {
                // Clone of active document
                NativeEditorView(
                    document: activeDoc,
                    appState: appState,
                    isWordWrapEnabled: appState.isWordWrapEnabled,
                    fontSize: appState.fontSize,
                    findReplaceState: appState.findReplaceState
                )
                .id("clone_\(activeDoc.id)")
            } else {
                emptyStatePlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStatePlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text(appState.tr("no_open_doc"))
                .font(.headline)
                .foregroundStyle(.secondary)
            Button(appState.tr("new_doc_cmd")) {
                appState.newDocument()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
