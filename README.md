To setup
---

1. Install [AutoHotkey v2 Beta](https://www.autohotkey.com/download/ahk-v2.exe)
1. Open this folder as a workspace in VS Code
1. Install all recommended extensions
1. Open the command palette (`Ctrl`+`Shift`+`P`)
1. Search for `Tasks: Run Task` and select it

For ARM (cont.)
---

1. Run the task `Configure single line comment symbol for ARM language extension`
1. In the `language-configuration.json` file, set the `lineComment` value to `;`

For RISC-V (cont.)
---
1. Run the task `Configure single line comment symbol for RISC-V language extension (json)`
1. In the `language-configuration.json` file, set the `lineComment` value to `;`
1. Run the task `Configure single line comment symbol for RISC-V language extension (tmLanguage)`
1. In the `riscv.tmLanguage` file, look for `single command` and then change as follows:

```diff
      <!-- single command -->
      <dict>
        <key>begin</key>
-        <string>\/\/</string>
+        <string>;</string>
        <key>end</key>
        <string>\n</string>
        <key>name</key>
        <string>comment.line.double-slash</string>
      </dict>
```
