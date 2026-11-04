# shotname

Take a screenshot that names itself.

```
Screenshot 2026-11-04 at 11.37.32 AM.png   →   nudge-contacts-2026-11-04.png
```

The name comes from the app you were in and the title of the window you were
looking at, both grabbed the instant you press the hotkey. That part is free,
instant, and never leaves the Mac. A model can optionally add two or three
words about what is actually on screen.

Name first, date trailing. The date is there for when the file leaves the Mac
and loses its metadata, not for sorting — Finder already sorts on Date Created.
Putting the name first means typing `nudge` in Spotlight finds every shot of it.

## What it produces

| App | Window title | Filename |
|---|---|---|
| Nudge | Contacts | `nudge-contacts-2026-11-04.png` |
| Chrome | Contacts \| Nudge | `contacts-nudge-2026-11-04.png` |
| Chrome | Inbox (12) - you@gmail.com - Gmail | `inbox-gmail-2026-11-04.png` |
| Terminal | slm — -zsh — 120x30 | `terminal-slm-zsh-2026-11-04.png` |
| VS Code | index.ts — nudge | `code-index-ts-nudge-2026-11-04.png` |

Unread counts, terminal dimensions, and email addresses are filtered out. An
email address in a window title would otherwise end up in a filename you paste
into Slack.

Two shots of the same screen on the same day get `-2`, `-3`, and so on.

## Install

```bash
mkdir -p ~/.config/shotname && cp config.example.sh ~/.config/shotname/config.sh
```

Then put `bin/shotname` on your PATH, or call it by its full path.

### The hotkey

There is no daemon and no menu bar app. macOS Shortcuts gives you a global
hotkey for free:

1. Shortcuts → File → New Shortcut, name it "Screenshot".
2. Add one action: **Run Shell Script**, set the shell to `/bin/bash`, and put
   the full path to `bin/shotname` in it.
3. In the shortcut's details pane, assign a keyboard shortcut. Something that
   isn't already taken — Cmd+Shift+5 is the screenshot toolbar, Cmd+Shift+4 is
   the plain capture you are replacing.

### The permission

Reading window titles needs Accessibility. Without it, shotname still works but
names files from the app alone — `nudge-2026-11-04.png` instead of
`nudge-contacts-2026-11-04.png`.

System Settings → Privacy & Security → Accessibility → add **Shortcuts**.

## Letting a model describe the screen

Set `DETAIL_SOURCE="anthropic"` in your config and export an
`ANTHROPIC_API_KEY`. Each capture is downscaled to 768px before it is sent,
which keeps the cost to a fraction of a cent.

```
nudge-contacts-empty-state-2026-11-04.png
autotakt-pricing-429-error-2026-11-04.png
```

This sends your screenshots to an API. Screenshots of client dashboards are
client data, so decide that deliberately rather than by default.

Apple's on-device model is not an option here: it is text-only on macOS 27, with
no image input in the SDK. Making it work would mean running OCR first and
naming from the extracted text, which reads badly on dashboards and is a far
bigger build.

## Why not WebP

Screenshots are flat UI and text. Lossless WebP saves about 25% and lossy WebP
puts ringing artifacts around text, which is the one thing a screenshot of an
error message cannot afford. Not worth a dependency. PNG stays.
