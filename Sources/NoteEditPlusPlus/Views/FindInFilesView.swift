import SwiftUI

public struct FindInFilesView: View {
    @Bindable var appState: AppState
    @State private var options = FindInFilesOptions()
    @State private var results: [FileSearchResult] = []
    @State private var isSearching = false
    @State private var searchPerformed = false

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(appState.tr("find_in_files"))
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button {
                    appState.isFindInFilesVisible = false
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

            // Search Fields
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(appState.tr("find_what")).frame(width: 80, alignment: .trailing).font(.system(size: 12))
                    TextField(appState.tr("find_placeholder"), text: $options.query)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { startSearch() }

                    Button(appState.tr("search")) {
                        startSearch()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(options.query.isEmpty || isSearching)
                }

                HStack(spacing: 8) {
                    Text(appState.tr("filter")).frame(width: 80, alignment: .trailing).font(.system(size: 12))
                    TextField("*.swift, *.txt, *.*", text: $options.fileFilter)
                        .textFieldStyle(.roundedBorder)

                    Spacer().frame(width: 75)
                }

                HStack(spacing: 8) {
                    Text(appState.tr("folder")).frame(width: 80, alignment: .trailing).font(.system(size: 12))
                    Text(options.directoryURL.path)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .font(.system(size: 11, design: .monospaced))
                        .padding(.horizontal, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 22)
                        .background(Color(NSColor.controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Button(appState.tr("browse")) {
                        browseFolder()
                    }
                }

                // Options Row
                HStack(spacing: 16) {
                    Toggle(appState.tr("match_case"), isOn: $options.matchCase)
                    Toggle(appState.tr("whole_word"), isOn: $options.wholeWord)
                    Toggle(appState.tr("regex"), isOn: $options.useRegex)
                    Toggle(appState.tr("recursive"), isOn: $options.recursive)
                    Spacer()
                }
                .font(.system(size: 11))
                .padding(.leading, 88)
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(Divider(), alignment: .bottom)

            // Results List
            if isSearching {
                VStack(spacing: 8) {
                    Spacer()
                    ProgressView(appState.tr("searching"))
                    Spacer()
                }
            } else if results.isEmpty && searchPerformed {
                VStack(spacing: 8) {
                    Spacer()
                    Text(appState.tr("no_results"))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List(results) { result in
                    Button {
                        appState.openDocument(from: result.fileURL)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .foregroundStyle(.secondary)
                            Text(result.fileURL.lastPathComponent)
                                .fontWeight(.semibold)
                            Text(":\(result.lineNumber)")
                                .foregroundStyle(.secondary)
                            Text(result.lineContent)
                                .lineLimit(1)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(minHeight: 250, maxHeight: 380)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            if let ws = appState.workspaceURL {
                options.directoryURL = ws
            }
        }
    }

    private func startSearch() {
        guard !options.query.isEmpty else { return }
        isSearching = true
        searchPerformed = true
        results.removeAll()

        Task {
            let res = FindInFilesManager.search(options: options)
            await MainActor.run {
                self.results = res
                self.isSearching = false
            }
        }
    }

    private func browseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            options.directoryURL = url
        }
    }
}
