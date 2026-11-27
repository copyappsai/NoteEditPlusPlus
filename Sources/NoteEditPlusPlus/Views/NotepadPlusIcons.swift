import SwiftUI

public struct NotepadPlusIcons {
    // New Document: White document with folded corner
    public struct NewDocIcon: View {
        public var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.9, green: 0.92, blue: 0.95))
                    .overlay(
                        Image(systemName: "doc")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(red: 0.4, green: 0.5, blue: 0.65))
                    )
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(red: 0.1, green: 0.65, blue: 0.2))
                    .offset(x: 2, y: 2)
            }
        }
    }

    // Open: Classic Yellow Manila Folder
    public struct OpenFolderIcon: View {
        public var body: some View {
            Image(systemName: "folder.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 0.96, green: 0.76, blue: 0.25))
                .overlay(
                    Image(systemName: "folder")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 0.75, green: 0.55, blue: 0.15))
                )
        }
    }

    // Save: Classic Blue 3.5" Floppy Disk
    public struct FloppyDiskIcon: View {
        var isModified: Bool = false

        public var body: some View {
            ZStack {
                // Disk body
                RoundedRectangle(cornerRadius: 2)
                    .fill(isModified ? Color(red: 0.85, green: 0.2, blue: 0.2) : Color(red: 0.12, green: 0.40, blue: 0.82))
                    .frame(width: 16, height: 16)

                // Metal shutter top
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.88))
                        .frame(width: 10, height: 6)
                    Spacer()
                    // Label area bottom
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 11, height: 6)
                }
                .frame(width: 16, height: 16)
                .padding(.vertical, 1)
            }
        }
    }

    // Save All: Triple Floppy Disks
    public struct SaveAllDisksIcon: View {
        public var body: some View {
            ZStack {
                FloppyDiskIcon(isModified: false)
                    .scaleEffect(0.85)
                    .offset(x: -3, y: -2)
                FloppyDiskIcon(isModified: false)
                    .scaleEffect(0.9)
                    .offset(x: 0, y: 0)
                FloppyDiskIcon(isModified: false)
                    .scaleEffect(0.95)
                    .offset(x: 3, y: 2)
            }
            .frame(width: 20, height: 18)
        }
    }

    // Close: Document with Red X
    public struct CloseDocIcon: View {
        public var body: some View {
            ZStack(alignment: .center) {
                Image(systemName: "doc")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Color.red)
            }
        }
    }

    // Close All: Stack with Red X
    public struct CloseAllIcon: View {
        public var body: some View {
            ZStack(alignment: .center) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(Color.red)
            }
        }
    }

    // Cut: Red Scissors
    public struct CutScissorsIcon: View {
        public var body: some View {
            Image(systemName: "scissors")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 0.85, green: 0.25, blue: 0.25))
        }
    }

    // Copy: Twin Documents
    public struct CopyDocsIcon: View {
        public var body: some View {
            Image(systemName: "doc.on.doc.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.85))
        }
    }

    // Paste: Clipboard
    public struct PasteClipIcon: View {
        public var body: some View {
            Image(systemName: "clipboard.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 0.70, green: 0.50, blue: 0.25))
        }
    }

    // Undo: Blue Curved Left Arrow
    public struct UndoArrowIcon: View {
        public var body: some View {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.15, green: 0.45, blue: 0.85))
        }
    }

    // Redo: Blue Curved Right Arrow
    public struct RedoArrowIcon: View {
        public var body: some View {
            Image(systemName: "arrow.uturn.forward")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.15, green: 0.45, blue: 0.85))
        }
    }

    // Find: Binoculars
    public struct FindBinocularsIcon: View {
        public var body: some View {
            Image(systemName: "binoculars.fill")
                .font(.system(size: 13))
                .foregroundStyle(Color(red: 0.20, green: 0.45, blue: 0.75))
        }
    }

    // Replace: Binoculars with Exchange Arrows
    public struct ReplaceArrowsIcon: View {
        public var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: "binoculars")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.20, green: 0.45, blue: 0.75))
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color(red: 0.10, green: 0.65, blue: 0.25))
                    .offset(x: 4, y: 3)
            }
        }
    }

    // Word Wrap: Classic Notepad++ Return Arrow
    public struct WordWrapIcon: View {
        public var body: some View {
            Image(systemName: "arrow.turn.down.left")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.85))
        }
    }

    // Show Invisibles: Blue Pilcrow ¶
    public struct PilcrowIcon: View {
        public var body: some View {
            Text("¶")
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(Color(red: 0.15, green: 0.35, blue: 0.75))
        }
    }
}
