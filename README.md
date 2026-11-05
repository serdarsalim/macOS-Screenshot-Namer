# macOS Screenshot Namer

**Screenshots that name themselves.** The name comes from the app and window you captured, read the moment you hit the hotkey. Nothing leaves your Mac.

```
Screenshot 2026-11-04 at 11.37.32 AM.png   →   nudge-contacts-2026-11-04.png
```

| App | Window title | Filename |
|---|---|---|
| Nudge | Contacts | `nudge-contacts-2026-11-04.png` |
| Chrome | Inbox (12) - you@gmail.com - Gmail | `gmail-inbox-2026-11-04.png` |
| VS Code | index.ts, nudge | `code-index-ts-nudge-2026-11-04.png` |

Name first, date trailing, so typing `nudge` in Spotlight finds every shot of it.

## What you get

- Four modes: `area`, `clip`, `window`, `screen`
- `clip` copies the screenshot carrying its real filename, instead of pasting anonymous
- Unread counts, terminal sizes and email addresses stripped out of names
- Optional two or three words from Claude Haiku on what's on screen, a fraction of a cent per shot

Window titles ride on the Screen Recording permission screenshots already use, so there's nothing extra to grant. Every setting is in `~/.config/shotname/config.sh` and every line is optional.

## Install

```bash
git clone https://github.com/serdarsalim/shotname.git && cd shotname
mkdir -p ~/.config/shotname && cp config.example.sh ~/.config/shotname/config.sh
swiftc -O src/frontwindow.swift -o bin/frontwindow
swiftc -O src/pbimage.swift -o bin/pbimage
```

Put `bin/shotname` on your PATH, then bind it to a key: macOS Shortcuts, one Run Shell Script action, assign a shortcut in the details pane. Cmd+Shift+4 is the one you're replacing.

## License

[MIT](LICENSE)
