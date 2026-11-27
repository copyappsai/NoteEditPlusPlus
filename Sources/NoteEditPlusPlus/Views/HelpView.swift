import SwiftUI

public struct HelpView: View {
    @Bindable var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                if let appIcon = NSApp.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(appState.tr("noteedit_help"))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Version 1.0.0 • Native macOS • Developed by Varga Márk")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text(appState.tr("help")).tag(0)
                Text(appState.tr("shortcuts")).tag(1)
                Text(appState.tr("privacy")).tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()

            // Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if selectedTab == 0 {
                        helpOverviewSection
                    } else if selectedTab == 1 {
                        shortcutsSection
                    } else {
                        privacySecuritySection
                    }
                }
                .padding(20)
            }
            .frame(maxHeight: 380)

            Divider()

            // Footer
            HStack {
                Text("Copyright © 2026 Varga Márk. All rights reserved.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(appState.tr("close_dialog")) {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.regular)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 580, height: 520)
    }

    // MARK: - Sections

    @ViewBuilder
    private var helpOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            helpCard(
                icon: "sparkles",
                title: "Native Apple Silicon Performance",
                description: "Built with pure Swift 6 and AppKit/SwiftUI. Instant startup, sub-millisecond typing latency, and minimal memory footprint."
            )

            helpCard(
                icon: "chevron.left.forwardslash.chevron.right",
                title: "Rich Syntax Highlighting & Auto-Indentation",
                description: "Over 90 programming languages recognized automatically with smart indentation, brace expansion on Enter, and real-time code suggestions."
            )

            helpCard(
                icon: "rectangle.split.2x1",
                title: "Dual View & Tabbed Editing",
                description: "Work with multiple files side by side. Split tabs, clone documents, compare differences, and search across whole project folders."
            )

            helpCard(
                icon: "globe",
                title: "32 Interface Languages & Unicode Support",
                description: "Full UI localization in 32 languages without language mixing. Comprehensive encoding detection (UTF-8, ISO-8859, Windows-1252, etc.)."
            )
        }
    }

    @ViewBuilder
    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            shortcutCategory(title: "File Operations", items: [
                ("New File", "⌘N"),
                ("Open File...", "⌘O"),
                ("Save", "⌘S"),
                ("Save As...", "⇧⌘S"),
                ("Save All", "⌥⌘S"),
                ("Print...", "⌘P"),
                ("Close Tab", "⌘W"),
                ("Close All", "⇧⌘W")
            ])

            shortcutCategory(title: "Editing & Smart Indent", items: [
                ("Undo / Redo", "⌘Z / ⇧⌘Z"),
                ("Cut / Copy / Paste", "⌘X / ⌘C / ⌘V"),
                ("Duplicate Line", "⌘D"),
                ("Delete Line", "⇧⌘K"),
                ("Move Line Up / Down", "⌥↑ / ⌥↓"),
                ("Join Lines", "⌘J"),
                ("Toggle Bookmark", "⌘M"),
                ("Next / Prev Bookmark", "⌥⌘] / ⌥⌘[")
            ])

            shortcutCategory(title: "Search & View", items: [
                ("Find and Replace", "⌘F"),
                ("Find in Files", "⇧⌘F"),
                ("Find Next / Previous", "⌘G / ⇧⌘G"),
                ("Toggle Sidebar", "⌥⌘B"),
                ("Toggle Dual View", "⌥⌘D"),
                ("Zoom In / Out / Reset", "⌘+ / ⌘- / ⌘0")
            ])
        }
    }

    @ViewBuilder
    private var privacySecuritySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            helpCard(
                icon: "lock.shield",
                title: "100% Apple Sandbox Compliant",
                description: "NoteEdit++ runs strictly inside the macOS App Sandbox. It only accesses files and directories that you explicitly choose to open or save."
            )

            helpCard(
                icon: "hand.raised",
                title: "Zero Telemetry & Zero Data Collection",
                description: "Your code and documents never leave your Mac. No network connections, no analytics, no external servers."
            )

            helpCard(
                icon: "checkmark.seal",
                title: "Hardened Runtime & Secure Code Signing",
                description: "Fully notarization-ready with macOS Hardened Runtime, signed with Apple-standard entitlements and reverse-DNS identifier."
            )
        }
    }

    private func helpCard(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.15), lineWidth: 1))
    }

    private func shortcutCategory(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            ForEach(items, id: \.0) { item in
                HStack {
                    Text(item.0)
                        .font(.subheadline)
                    Spacer()
                    Text(item.1)
                        .font(.system(.subheadline, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(NSColor.controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
            }
        }
        .padding(10)
        .background(Color(NSColor.textBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.15), lineWidth: 1))
    }
}
