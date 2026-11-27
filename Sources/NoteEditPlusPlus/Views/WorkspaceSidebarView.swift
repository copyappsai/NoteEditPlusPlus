import SwiftUI

public struct WorkspaceItem: Identifiable, Hashable, Sendable {
    public var id: String { url.path }
    public let url: URL
    public let isDirectory: Bool
    public var children: [WorkspaceItem]?

    public init(url: URL, isDirectory: Bool, children: [WorkspaceItem]? = nil) {
        self.url = url
        self.isDirectory = isDirectory
        self.children = children
    }
}

public struct WorkspaceSidebarView: View {
    @Bindable var appState: AppState
    @State private var filterText: String = ""
    @State private var workspaceItems: [WorkspaceItem] = []

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header / Folder Picker
            HStack {
                Image(systemName: "folder")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(appState.workspaceURL?.lastPathComponent ?? appState.tr("workspace_title"))
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                Spacer()

                Button {
                    chooseFolder()
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .help(appState.tr("open_folder_help"))

                Button {
                    loadWorkspace()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
                .help(appState.tr("refresh"))
            }
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(Divider(), alignment: .bottom)

            // Filter Bar
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                TextField(appState.tr("filter_placeholder"), text: $filterText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(Divider(), alignment: .bottom)

            // File Tree List
            if workspaceItems.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 28))
                        .foregroundStyle(.tertiary)
                    Text(appState.tr("no_folder_open"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(appState.tr("open_folder_btn")) {
                        chooseFolder()
                    }
                    .font(.caption)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(filteredItems(workspaceItems), id: \.id) { item in
                        WorkspaceItemRow(item: item, onSelectFile: { url in
                            appState.openDocument(from: url)
                        })
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .frame(minWidth: 180, idealWidth: 220, maxWidth: 350)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadWorkspace()
        }
        .onChange(of: appState.workspaceURL) { _, _ in
            loadWorkspace()
        }
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            appState.workspaceURL = url
        }
    }

    private func loadWorkspace() {
        guard let rootURL = appState.workspaceURL else {
            workspaceItems = []
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let items = self.scanDirectory(url: rootURL)
            DispatchQueue.main.async {
                self.workspaceItems = items
            }
        }
    }

    nonisolated private func scanDirectory(url: URL) -> [WorkspaceItem] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey, .isHiddenKey],
            options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
        ) else { return [] }

        var result: [WorkspaceItem] = []
        for case let fileURL as URL in enumerator {
            let isDir = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            let children = isDir ? scanDirectory(url: fileURL) : nil
            result.append(WorkspaceItem(url: fileURL, isDirectory: isDir, children: children))
        }

        // Sort: directories first, then alphabetical
        return result.sorted {
            if $0.isDirectory != $1.isDirectory {
                return $0.isDirectory && !$1.isDirectory
            }
            return $0.url.lastPathComponent.localizedCaseInsensitiveCompare($1.url.lastPathComponent) == .orderedAscending
        }
    }

    private func filteredItems(_ items: [WorkspaceItem]) -> [WorkspaceItem] {
        if filterText.isEmpty { return items }
        return items.compactMap { item in
            if item.isDirectory {
                let filteredChildren = filteredItems(item.children ?? [])
                if !filteredChildren.isEmpty || item.url.lastPathComponent.localizedCaseInsensitiveContains(filterText) {
                    var copy = item
                    copy.children = filteredChildren
                    return copy
                }
                return nil
            } else {
                return item.url.lastPathComponent.localizedCaseInsensitiveContains(filterText) ? item : nil
            }
        }
    }
}

private struct WorkspaceItemRow: View {
    let item: WorkspaceItem
    let onSelectFile: (URL) -> Void
    @State private var isExpanded = false

    var body: some View {
        if item.isDirectory {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let children = item.children {
                    ForEach(children, id: \.id) { child in
                        WorkspaceItemRow(item: child, onSelectFile: onSelectFile)
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: isExpanded ? "folder.fill" : "folder")
                        .foregroundStyle(Color.accentColor)
                    Text(item.url.lastPathComponent)
                        .font(.system(size: 11))
                }
            }
        } else {
            Button {
                onSelectFile(item.url)
            } label: {
                HStack(spacing: 5) {
                    fileIcon(for: item.url)
                    Text(item.url.lastPathComponent)
                        .font(.system(size: 11))
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func fileIcon(for url: URL) -> some View {
        let ext = url.pathExtension.lowercased()
        let iconName: String
        let color: Color

        switch ext {
        case "swift":
            iconName = "swift"
            color = .orange
        case "html", "htm", "xml":
            iconName = "chevron.left.forwardslash.chevron.right"
            color = .blue
        case "json":
            iconName = "curlybraces"
            color = .yellow
        case "js", "ts":
            iconName = "applescript"
            color = .yellow
        case "py":
            iconName = "terminal"
            color = .green
        case "md", "txt":
            iconName = "doc.text"
            color = .secondary
        default:
            iconName = "doc"
            color = .secondary
        }

        return Image(systemName: iconName)
            .foregroundStyle(color)
            .font(.system(size: 11))
    }
}
