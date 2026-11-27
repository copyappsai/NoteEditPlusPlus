import SwiftUI

public struct PreferencesView: View {
    @Bindable var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        TabView {
            // General Settings
            Form {
                Section(appState.tr("pref_appearance")) {
                    Picker(appState.tr("ui_language") + ":", selection: $appState.uiLanguage) {
                        ForEach(UILanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }

                    Picker(appState.tr("theme") + ":", selection: $appState.theme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }

                    Picker(appState.tr("pref_font"), selection: $appState.fontName) {
                        Text("SF Mono").tag("SF Mono")
                        Text("Menlo").tag("Menlo")
                        Text("Monaco").tag("Monaco")
                        Text("Courier New").tag("Courier New")
                    }

                    Slider(value: $appState.fontSize, in: 9...28, step: 1) {
                        Text("\(appState.tr("pref_font_size")): \(Int(appState.fontSize)) pt")
                    }
                }

                Section(appState.tr("pref_editor_behavior")) {
                    Picker(appState.tr("pref_tab_size"), selection: $appState.tabSize) {
                        Text("2 \(appState.tr("pref_spaces"))").tag(2)
                        Text("4 \(appState.tr("pref_spaces")) (\(appState.tr("pref_default")))").tag(4)
                        Text("8 \(appState.tr("pref_spaces"))").tag(8)
                    }

                    Toggle(appState.tr("word_wrap"), isOn: $appState.isWordWrapEnabled)
                    Toggle(appState.tr("invisibles"), isOn: $appState.showInvisibleCharacters)
                    Toggle(appState.tr("pref_bracket_match"), isOn: $appState.highlightMatchingBrackets)
                }

                Section(appState.tr("pref_new_file_defaults")) {
                    Picker(appState.tr("pref_default_line_ending"), selection: $appState.defaultLineEnding) {
                        ForEach(LineEnding.allCases) { ending in
                            Text(ending.displayName).tag(ending)
                        }
                    }

                    Picker(appState.tr("pref_default_encoding"), selection: $appState.defaultEncoding) {
                        ForEach(DocumentEncoding.allCases) { enc in
                            Text(enc.rawValue).tag(enc)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label(appState.tr("pref_general"), systemImage: "gearshape")
            }
        }
        .frame(width: 480, height: 420)
    }
}
