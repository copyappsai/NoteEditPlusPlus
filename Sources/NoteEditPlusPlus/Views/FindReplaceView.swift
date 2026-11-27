import SwiftUI

public struct FindReplaceView: View {
    @Bindable var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        let state = appState.findReplaceState
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                // Find input
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    TextField(appState.tr("find_placeholder"), text: $appState.findReplaceState.findText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .onSubmit {
                            state.performFindNext?()
                        }

                    if !state.findText.isEmpty {
                        Button {
                            appState.findReplaceState.findText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 6)
                .frame(height: 24)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .frame(maxWidth: 260)

                // Navigation buttons
                Button(appState.tr("find_next")) {
                    state.performFindNext?()
                }
                .keyboardShortcut("g", modifiers: .command)
                .font(.system(size: 11))

                Button(appState.tr("find_prev")) {
                    state.performFindPrevious?()
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
                .font(.system(size: 11))

                Button(appState.tr("count")) {
                    state.performCount?()
                }
                .font(.system(size: 11))

                Spacer()

                // Close button
                Button {
                    appState.findReplaceState.isVisible = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }

            // Replace input and options row
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    TextField(appState.tr("replace_placeholder"), text: $appState.findReplaceState.replaceText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .onSubmit {
                            state.performReplace?()
                        }

                    if !state.replaceText.isEmpty {
                        Button {
                            appState.findReplaceState.replaceText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 6)
                .frame(height: 24)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .frame(maxWidth: 260)

                Button(appState.tr("replace")) {
                    state.performReplace?()
                }
                .font(.system(size: 11))

                Button(appState.tr("replace_all")) {
                    state.performReplaceAll?()
                }
                .font(.system(size: 11))

                Divider().frame(height: 16)

                // Search options toggles
                Toggle(appState.tr("match_case"), isOn: $appState.findReplaceState.matchCase)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))

                Toggle(appState.tr("whole_word"), isOn: $appState.findReplaceState.wholeWord)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))

                Toggle(appState.tr("regex"), isOn: $appState.findReplaceState.useRegex)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))

                Toggle(appState.tr("wrap_around"), isOn: $appState.findReplaceState.wrapAround)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))

                Spacer()

                // Status message
                if !state.statusMessage.isEmpty {
                    Text(state.statusMessage)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.95))
        .overlay(
            Divider(), alignment: .bottom
        )
    }
}
