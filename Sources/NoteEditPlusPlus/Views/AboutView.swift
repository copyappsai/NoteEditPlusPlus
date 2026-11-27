import SwiftUI

public struct AboutView: View {
    @Bindable var appState: AppState
    @Environment(\.dismiss) private var dismiss

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 16) {
            // App Icon Mascot
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

            VStack(spacing: 4) {
                Text("NoteEdit++")
                    .font(.system(size: 22, weight: .bold))
                Text("Version 1.0.0 (Native Apple Silicon)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Text(appState.tr("about_desc"))
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 320)

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(appState.tr("developer")).bold()
                    Spacer()
                    Text("Varga Márk")
                        .fontWeight(.semibold)
                }
                HStack {
                    Text(appState.tr("technology")).bold()
                    Spacer()
                    Text("Swift 6 + AppKit / SwiftUI")
                }
                HStack {
                    Text(appState.tr("architecture")).bold()
                    Spacer()
                    Text("Universal Mach-O arm64")
                }
                HStack {
                    Text(appState.tr("syntax_support")).bold()
                    Spacer()
                    Text("90+ languages")
                }
                HStack {
                    Text(appState.tr("lang_localization")).bold()
                    Spacer()
                    Text("32 languages")
                }
            }
            .font(.system(size: 11))
            .frame(width: 280)

            Text("Copyright © 2026 Varga Márk. All rights reserved.")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)

            Button(appState.tr("close_dialog")) {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(24)
        .frame(width: 380)
    }
}
