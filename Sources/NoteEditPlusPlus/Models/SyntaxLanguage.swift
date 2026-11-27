import Foundation

public enum SyntaxLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case plainText = "Plain Text"
    case actionscript = "ActionScript"
    case ada = "Ada"
    case ansible = "Ansible"
    case apex = "Apex"
    case applescript = "AppleScript"
    case assembly = "Assembly (x86/ARM)"
    case astro = "Astro"
    case autohotkey = "AutoHotkey"
    case autoit = "AutoIt"
    case awk = "AWK"
    case batch = "Batch / CMD"
    case c = "C"
    case cpp = "C++"
    case csharp = "C#"
    case clojure = "Clojure"
    case cmake = "CMake"
    case cobol = "COBOL"
    case coffeescript = "CoffeeScript"
    case crystal = "Crystal"
    case css = "CSS"
    case d = "D"
    case dart = "Dart"
    case dockerfile = "Dockerfile"
    case elixir = "Elixir"
    case erlang = "Erlang"
    case fsharp = "F#"
    case fortran = "Fortran"
    case glsl = "GLSL / Shader"
    case go = "Go"
    case graphql = "GraphQL"
    case groovy = "Groovy"
    case haskell = "Haskell"
    case hcl = "HCL / Terraform"
    case html = "HTML"
    case ini = "INI / Config"
    case java = "Java"
    case javascript = "JavaScript"
    case json = "JSON"
    case julia = "Julia"
    case kotlin = "Kotlin"
    case latex = "LaTeX"
    case lisp = "Lisp / Scheme"
    case lua = "Lua"
    case makefile = "Makefile"
    case markdown = "Markdown"
    case matlab = "MATLAB / Octave"
    case nim = "Nim"
    case objectiveC = "Objective-C"
    case ocaml = "OCaml"
    case pascal = "Pascal / Delphi"
    case perl = "Perl"
    case php = "PHP"
    case powershell = "PowerShell"
    case prolog = "Prolog"
    case protobuf = "Protocol Buffers"
    case python = "Python"
    case qml = "QML"
    case r = "R"
    case ruby = "Ruby"
    case rust = "Rust"
    case sas = "SAS"
    case scala = "Scala"
    case scss = "SCSS / SASS"
    case shell = "Shell / Bash"
    case smalltalk = "Smalltalk"
    case solidity = "Solidity"
    case sql = "SQL"
    case svelte = "Svelte"
    case swift = "Swift"
    case tcl = "Tcl"
    case toml = "TOML"
    case typescript = "TypeScript"
    case visualBasic = "Visual Basic / VBS"
    case verilog = "Verilog / SystemVerilog"
    case vhdl = "VHDL"
    case vue = "Vue.js"
    case wgsl = "WGSL (WebGPU)"
    case xml = "XML / SVG"
    case yaml = "YAML"
    case zig = "Zig"

    public var id: String { rawValue }

    public static func detect(from url: URL) -> SyntaxLanguage {
        let filename = url.lastPathComponent.lowercased()
        if filename == "dockerfile" { return .dockerfile }
        if filename == "makefile" || filename == "gnumakefile" { return .makefile }
        if filename == "cmakelists.txt" { return .cmake }

        let ext = url.pathExtension.lowercased()
        switch ext {
        case "as": return .actionscript
        case "ada", "adb", "ads": return .ada
        case "scpt", "applescript": return .applescript
        case "asm", "s": return .assembly
        case "astro": return .astro
        case "ahk": return .autohotkey
        case "au3": return .autoit
        case "awk": return .awk
        case "bat", "cmd": return .batch
        case "c", "h": return .c
        case "cpp", "cxx", "cc", "hpp", "hxx", "hh": return .cpp
        case "cs": return .csharp
        case "clj", "cljs", "edn": return .clojure
        case "cmake": return .cmake
        case "cbl", "cob": return .cobol
        case "coffee": return .coffeescript
        case "cr": return .crystal
        case "css": return .css
        case "d": return .d
        case "dart": return .dart
        case "ex", "exs": return .elixir
        case "erl", "hrl": return .erlang
        case "fs", "fsi", "fsx": return .fsharp
        case "f", "f90", "f95": return .fortran
        case "glsl", "vert", "frag", "geom": return .glsl
        case "go": return .go
        case "gql", "graphql": return .graphql
        case "groovy", "gvy", "gradle": return .groovy
        case "hs", "lhs": return .haskell
        case "tf", "tfvars", "hcl": return .hcl
        case "html", "htm", "xhtml": return .html
        case "ini", "conf", "cfg", "env", "properties": return .ini
        case "java": return .java
        case "js", "mjs", "cjs": return .javascript
        case "json": return .json
        case "jl": return .julia
        case "kt", "kts": return .kotlin
        case "tex", "latex", "sty": return .latex
        case "lisp", "lsp", "scm", "ss": return .lisp
        case "lua": return .lua
        case "mk": return .makefile
        case "md", "markdown": return .markdown
        case "m" where filename.contains("matlab"): return .matlab
        case "m", "mm": return .objectiveC
        case "nim": return .nim
        case "ml", "mli": return .ocaml
        case "pas", "dpr": return .pascal
        case "pl", "pm": return .perl
        case "php", "phtml": return .php
        case "ps1", "psm1": return .powershell
        case "pro", "plg": return .prolog
        case "proto": return .protobuf
        case "py", "pyw": return .python
        case "qml": return .qml
        case "r", "rdata": return .r
        case "rb", "rake": return .ruby
        case "rs": return .rust
        case "sas": return .sas
        case "scala", "sc": return .scala
        case "scss", "sass": return .scss
        case "sh", "bash", "zsh", "fish": return .shell
        case "st": return .smalltalk
        case "sol": return .solidity
        case "sql", "psql": return .sql
        case "svelte": return .svelte
        case "swift": return .swift
        case "tcl": return .tcl
        case "toml": return .toml
        case "ts", "tsx": return .typescript
        case "vb", "vbs", "bas": return .visualBasic
        case "v", "vh", "sv", "svh": return .verilog
        case "vhd", "vhdl": return .vhdl
        case "vue": return .vue
        case "wgsl": return .wgsl
        case "xml", "plist", "svg", "xsd", "xsl": return .xml
        case "yml", "yaml": return .yaml
        case "zig": return .zig
        default: return .plainText
        }
    }

    public static func detect(fromContent content: String) -> SyntaxLanguage? {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let lower = trimmed.lowercased()

        // 1. Shebang
        if lower.hasPrefix("#!") {
            if lower.contains("python") { return .python }
            if lower.contains("node") { return .javascript }
            if lower.contains("perl") { return .perl }
            if lower.contains("ruby") { return .ruby }
            if lower.contains("bash") || lower.contains("sh") || lower.contains("zsh") { return .shell }
        }

        // 2. HTML / XML / SVG
        if lower.hasPrefix("<!doctype html") || lower.hasPrefix("<html") || lower.contains("<body") || lower.contains("<div") || lower.contains("<form") || lower.contains("<p>") || lower.contains("</div>") || lower.contains("</form>") || lower.contains("<script") || lower.contains("<style") {
            return .html
        }
        if lower.hasPrefix("<?xml") || lower.contains("<plist") || lower.contains("<svg") {
            return .xml
        }

        // 3. PHP
        if lower.contains("<?php") || lower.contains("<?=") {
            return .php
        }

        // 4. JSON
        if (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) || (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) {
            if trimmed.contains("\":") || trimmed.contains("\": ") {
                if (try? JSONSerialization.jsonObject(with: Data(trimmed.utf8), options: [])) != nil {
                    return .json
                }
            }
        }

        // 5. SQL
        if lower.contains("select ") && lower.contains(" from ") { return .sql }
        if lower.contains("insert into ") || lower.contains("create table ") || (lower.contains("update ") && lower.contains(" set ")) { return .sql }

        // 6. Swift
        if trimmed.contains("import SwiftUI") || trimmed.contains("import Foundation") || trimmed.contains("import AppKit") || trimmed.contains("import UIKit") {
            return .swift
        }

        // 7. Rust
        if trimmed.contains("fn main()") || trimmed.contains("use std::") || trimmed.contains("pub fn ") || trimmed.contains("let mut ") {
            return .rust
        }

        // 8. Go
        if trimmed.contains("package main") || trimmed.contains("func main()") || trimmed.contains("import \"fmt\"") {
            return .go
        }

        // 9. C / C++
        if trimmed.contains("#include <") || trimmed.contains("#include \"") || trimmed.contains("std::cout") || trimmed.contains("int main(") {
            return .cpp
        }

        // 10. Python
        if trimmed.contains("def ") && trimmed.contains(":") {
            if trimmed.contains("self") || trimmed.contains("print(") || trimmed.contains("return ") || trimmed.contains("import ") {
                return .python
            }
        }
        if trimmed.contains("import sys") || trimmed.contains("import os") || trimmed.contains("if __name__ == '__main__':") || trimmed.contains("if __name__ == \"__main__\":") {
            return .python
        }

        // 11. JavaScript / TypeScript
        if trimmed.contains("import React") || trimmed.contains("from 'react'") || trimmed.contains("from \"react\"") || trimmed.contains("export default") || trimmed.contains("console.log(") {
            return .javascript
        }
        if trimmed.contains("const ") || trimmed.contains("let ") || trimmed.contains("function ") {
            if trimmed.contains("=>") || trimmed.contains("document.") || trimmed.contains("window.") || trimmed.contains("require(") {
                return .javascript
            }
        }

        // 12. CSS
        if trimmed.contains(" {") && trimmed.contains(":") && trimmed.contains(";") && trimmed.contains("}") {
            if lower.contains("px") || lower.contains("margin") || lower.contains("padding") || lower.contains("color:") || lower.contains("background:") {
                return .css
            }
        }

        // 13. Dockerfile
        if trimmed.hasPrefix("FROM ") || (trimmed.contains("\nFROM ") && trimmed.contains("RUN ")) {
            return .dockerfile
        }

        // 14. Markdown
        if trimmed.hasPrefix("# ") || trimmed.contains("\n## ") || trimmed.contains("```") {
            return .markdown
        }

        // 15. YAML
        if trimmed.hasPrefix("---") || (trimmed.contains("\n") && trimmed.contains(": ") && !trimmed.contains(";")) {
            if let yRegex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9_\\-]+:\\s+", options: .anchorsMatchLines) {
                if yRegex.firstMatch(in: trimmed, range: NSRange(location: 0, length: (trimmed as NSString).length)) != nil {
                    return .yaml
                }
            }
        }

        return nil
    }

    public var keywords: Set<String> {
        switch self {
        case .swift:
            return ["import", "let", "var", "func", "class", "struct", "enum", "protocol", "extension", "guard", "if", "else", "switch", "case", "default", "for", "in", "while", "repeat", "return", "throw", "throws", "try", "catch", "defer", "public", "private", "fileprivate", "internal", "open", "static", "final", "mutating", "nonmutating", "init", "deinit", "subscript", "self", "Self", "super", "async", "await", "actor", "some", "any", "where"]
        case .python:
            return ["import", "from", "as", "def", "class", "return", "if", "elif", "else", "for", "while", "break", "continue", "pass", "yield", "lambda", "try", "except", "finally", "raise", "with", "assert", "global", "nonlocal", "async", "await", "True", "False", "None", "in", "is", "not", "and", "or"]
        case .javascript, .typescript, .vue, .svelte, .astro:
            return ["import", "export", "from", "default", "function", "class", "extends", "const", "let", "var", "return", "if", "else", "switch", "case", "for", "while", "do", "break", "continue", "try", "catch", "finally", "throw", "new", "this", "super", "typeof", "instanceof", "in", "of", "async", "await", "yield", "null", "undefined", "true", "false", "interface", "type", "enum", "as"]
        case .c, .cpp, .objectiveC:
            return ["auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto", "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while", "class", "namespace", "template", "typename", "public", "protected", "private", "virtual", "override", "final", "constexpr", "nullptr", "bool", "true", "false", "new", "delete", "this", "try", "catch", "throw"]
        case .csharp:
            return ["abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char", "checked", "class", "const", "continue", "decimal", "default", "delegate", "do", "double", "else", "enum", "event", "explicit", "extern", "false", "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit", "in", "int", "interface", "internal", "is", "lock", "long", "namespace", "new", "null", "object", "operator", "out", "override", "params", "private", "protected", "public", "readonly", "ref", "return", "sbyte", "sealed", "short", "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw", "true", "try", "typeof", "uint", "ulong", "unchecked", "unsafe", "ushort", "using", "virtual", "void", "volatile", "while", "var", "async", "await"]
        case .java, .kotlin, .scala, .groovy:
            return ["abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue", "default", "do", "double", "else", "enum", "extends", "final", "finally", "float", "for", "goto", "if", "implements", "import", "instanceof", "int", "interface", "long", "native", "new", "package", "private", "protected", "public", "return", "short", "static", "strictfp", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "try", "void", "volatile", "while", "val", "var", "fun"]
        case .rust:
            return ["as", "async", "await", "break", "const", "continue", "crate", "dyn", "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "self", "Self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while"]
        case .go:
            return ["break", "default", "func", "interface", "select", "case", "defer", "go", "map", "struct", "chan", "else", "goto", "package", "switch", "const", "fallthrough", "if", "range", "type", "continue", "for", "import", "return", "var", "true", "false", "nil", "iota"]
        case .ruby, .crystal:
            return ["def", "end", "class", "module", "if", "elsif", "else", "unless", "while", "until", "for", "in", "do", "return", "yield", "self", "super", "nil", "true", "false", "and", "or", "not", "begin", "rescue", "ensure", "raise"]
        case .php:
            return ["function", "class", "public", "private", "protected", "static", "extends", "implements", "return", "if", "else", "elseif", "while", "for", "foreach", "as", "switch", "case", "default", "break", "continue", "echo", "new", "try", "catch", "finally", "throw", "null", "true", "false"]
        case .shell, .batch, .powershell:
            return ["if", "then", "else", "elif", "fi", "case", "esac", "for", "while", "until", "do", "done", "in", "function", "return", "exit", "echo", "set", "export", "local", "shift", "source"]
        case .sql:
            return ["SELECT", "FROM", "WHERE", "INSERT", "INTO", "UPDATE", "DELETE", "JOIN", "LEFT", "RIGHT", "INNER", "OUTER", "GROUP", "BY", "ORDER", "HAVING", "LIMIT", "OFFSET", "CREATE", "TABLE", "DROP", "ALTER", "ADD", "PRIMARY", "KEY", "FOREIGN", "REFERENCES", "INDEX", "AND", "OR", "NOT", "IN", "IS", "NULL", "LIKE", "BETWEEN", "UNION", "ALL", "AS", "DISTINCT", "COUNT", "SUM", "AVG", "MIN", "MAX"]
        case .zig:
            return ["const", "var", "fn", "pub", "return", "if", "else", "switch", "while", "for", "break", "continue", "struct", "enum", "union", "error", "try", "catch", "defer", "errdefer", "unreachable", "async", "await", "suspend", "resume"]
        case .lua:
            return ["and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"]
        case .dart:
            return ["abstract", "as", "assert", "async", "await", "break", "case", "catch", "class", "const", "continue", "default", "do", "dynamic", "else", "enum", "export", "extends", "external", "factory", "false", "final", "finally", "for", "get", "if", "implements", "import", "in", "is", "late", "library", "new", "null", "part", "required", "rethrow", "return", "set", "static", "super", "switch", "sync", "this", "throw", "true", "try", "typedef", "var", "void", "while", "with", "yield"]
        case .dockerfile:
            return ["FROM", "RUN", "CMD", "LABEL", "EXPOSE", "ENV", "ADD", "COPY", "ENTRYPOINT", "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD", "STOPSIGNAL", "HEALTHCHECK", "SHELL"]
        case .html, .xml:
            return ["html", "head", "body", "title", "meta", "link", "script", "style", "div", "span", "p", "a", "img", "form", "input", "button", "label", "select", "option", "textarea", "table", "tr", "td", "th", "tbody", "thead", "ul", "ol", "li", "h1", "h2", "h3", "h4", "h5", "h6", "header", "footer", "nav", "section", "article", "aside", "main", "canvas", "svg", "iframe", "video", "audio", "source", "class", "id", "name", "type", "value", "placeholder", "required", "action", "method", "href", "src", "alt", "rel", "target", "width", "height", "style"]
        case .css, .scss:
            return ["color", "background", "background-color", "font-size", "font-family", "font-weight", "text-align", "margin", "margin-top", "margin-bottom", "margin-left", "margin-right", "padding", "padding-top", "padding-bottom", "padding-left", "padding-right", "border", "border-radius", "width", "height", "max-width", "min-width", "display", "flex", "grid", "position", "top", "bottom", "left", "right", "z-index", "overflow", "opacity", "box-shadow", "transition", "transform", "cursor", "important"]
        case .json:
            return ["true", "false", "null"]
        default:
            return []
        }
    }
}
