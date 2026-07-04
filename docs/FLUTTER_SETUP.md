# Flutter path for this machine

Flutter SDK location:

```
C:\Users\admin\AI Agent\flutter\bin\flutter.bat
```

Agent terminal command pattern (PowerShell):

```powershell
& "C:\Users\admin\AI Agent\flutter\bin\flutter.bat" <command>
```

Examples:

```powershell
cd "C:\Users\admin\AI Agent\dealdash\apps\mobile"
& "C:\Users\admin\AI Agent\flutter\bin\flutter.bat" pub get
& "C:\Users\admin\AI Agent\flutter\bin\flutter.bat" analyze
& "C:\Users\admin\AI Agent\flutter\bin\flutter.bat" run -d windows
```

## Optional: add Flutter to PATH

Add this folder to your Windows PATH so `flutter` works everywhere:

`C:\Users\admin\AI Agent\flutter\bin`

Then restart Cursor/terminal.

## Windows note

If plugin builds fail with symlink errors, enable **Developer Mode**:
`start ms-settings:developers`
