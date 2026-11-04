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

## Five things macOS does that cost us an afternoon

Each of these fails silently. Nothing errors, nothing logs, and the obvious
implementation looks like it works. If you are building something similar,
this list is the useful part of this repository.

**Window titles over AppleScript need a permission you will not find.** Asking
System Events for the front window title requires an Accessibility grant,
controlled by a pane buried under Privacy & Security below Camera, sharing its
name with the unrelated Accessibility settings for VoiceOver and zoom. Reading
the same titles through `CGWindowList` instead rides on the Screen Recording
permission screenshots already need, so there is nothing extra to grant.

**The window title macOS publishes is already truncated.** Long titles arrive
cut mid-word with an ellipsis: `Six must…e strategies`. The full text never
reaches you, and the fragment it leaves behind becomes a word in your filename.
Browsers know the real title and will tell you over AppleScript.

**The clipboard loses a file reference if you exit immediately.** `writeObjects`
returns before the pasteboard server has finished taking it. Measured here at
one success in five. The pixels always survive, so a paste looks fine while the
name is gone. Poll until the name reads back before exiting.

**An app offered both pixels and a file takes the pixels.** It never looks at
the file, so the name is dropped in exactly the case you added it for. Offering
the file alone is the only way to force it, and it costs you anything that
cannot accept a pasted file.

**A launchd agent sees `~/Desktop` as empty.** The directory reports as readable
and lists zero files, so a watcher finds nothing to do and exits cleanly, every
time. Measured 0/5 against the Desktop and 5/5 against a plain folder. There is
no permission the agent can request.

## What it produces

| App | Window title | Filename |
|---|---|---|
| Nudge | Contacts | `nudge-contacts-2026-11-04.png` |
| Chrome | Contacts \| Nudge | `nudge-contacts-2026-11-04.png` |
| Chrome | Inbox (12) - you@gmail.com - Gmail | `gmail-inbox-2026-11-04.png` |
| Chrome | a YouTube talk | `youtube-kevin-systrom-finding-2026-11-04.png` |
| Terminal | slm — -zsh — 120x30 | `terminal-slm-zsh-2026-11-04.png` |
| VS Code | index.ts — nudge | `code-index-ts-nudge-2026-11-04.png` |

Unread counts, terminal dimensions, and email addresses are filtered out. An
email address in a window title would otherwise end up in a filename you paste
into Slack.

Two shots of the same screen on the same day get `-2`, `-3`, and so on.

## Three modes

```bash
shotname area      # drag a region → saved to the Desktop, named
shotname clip      # drag a region → clipboard, carrying its name
shotname window    # click a window → saved to the Desktop, named
```

`clip` is the interesting one. A normally copied screenshot is anonymous —
paste it and the receiving app invents a name or shows none. This puts a
reference to the saved file on the clipboard instead, so the real name travels
with it.

Only the file reference, deliberately. Offered both a file and raw pixels, an
app takes the pixels and never reads the name, which is exactly the case this
exists for. `CLIP_FILE_ONLY="no"` puts the pixels back for anything that
cannot accept a pasted file.

Clipboard captures are lossless webp, roughly half the size of the PNG with
identical pixels. Lossy webp would have been smaller still and is the wrong
trade here: it rings around small type, and screenshots are text as often as
they are pictures.

Those files live in `CLIP_DIR` rather than on the Desktop, and each capture
replaces the last. The clipboard only ever points at the newest one, so older
ones could never be pasted again anyway — keeping them would just be a pile.

`window` works out which window you clicked by matching the captured image
against the on-screen window sizes, rather than assuming the frontmost one.
Clicking a background window would otherwise name the file after whatever
happened to be in front.

## Install

```bash
mkdir -p ~/.config/shotname && cp config.example.sh ~/.config/shotname/config.sh
swiftc -O src/frontwindow.swift -o bin/frontwindow
swiftc -O src/pbimage.swift -o bin/pbimage
```

Then put `bin/shotname` on your PATH, or call it by its full path. Without the
compiled helper it still runs, but names files from the app alone.

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

There is nothing to grant by hand. Window titles are read through
`CGWindowList`, which rides on the same Screen Recording permission
`screencapture` already needs, so one grant covers both.

The obvious route — asking System Events for the title over AppleScript —
needs a separate Accessibility grant, and the pane that controls it is buried
under Privacy & Security below Camera, sharing its name with the unrelated
Accessibility settings for VoiceOver and zoom. That is why this uses the
window list instead.

The first time your shortcut runs, macOS asks for Screen Recording. Click
Allow and you are done.

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
