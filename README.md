# macOS Screenshot Namer

Take a screenshot that names itself, from the app and window you captured.

```
Screenshot 2026-11-04 at 11.37.32 AM.png   →   nudge-contacts-2026-11-04.png
```

The name comes from the app you were in and the title of the window you were
looking at, both read the instant you press the hotkey. That part is free,
instant, and never leaves the Mac. A model can optionally add two or three
words about what is actually on screen.

Name first, date trailing. Typing `nudge` in Spotlight then finds every shot of
it. The date is there for when the file leaves the Mac and loses its metadata,
not for sorting, since Finder already sorts on Date Created.

## What you get

- Filenames built from the app and window title, with unread counts, terminal
  dimensions and email addresses filtered out
- A clipboard mode that carries the real filename with it, so a pasted
  screenshot is not anonymous
- A window mode that names the window you actually clicked, not whatever was in
  front of it
- Optional two or three words from Claude Haiku on what is on screen, for a
  fraction of a cent per capture

Needs macOS and the Xcode command line tools to build two small Swift helpers.
`cwebp` is optional.

## What it produces

| App | Window title | Filename |
|---|---|---|
| Nudge | Contacts | `nudge-contacts-2026-11-04.png` |
| Chrome | Contacts \| Nudge | `nudge-contacts-2026-11-04.png` |
| Chrome | Inbox (12) - you@gmail.com - Gmail | `gmail-inbox-2026-11-04.png` |
| Chrome | a YouTube talk | `youtube-kevin-systrom-finding-2026-11-04.png` |
| Terminal | slm — -zsh — 120x30 | `terminal-slm-zsh-2026-11-04.png` |
| VS Code | index.ts — nudge | `code-index-ts-nudge-2026-11-04.png` |

An email address in a window title would otherwise end up in a filename you
paste into Slack, so it gets stripped.

Two shots of the same screen on the same day get `-2`, `-3`, and so on.

## The four modes

```bash
shotname area      # drag a region, save to the Desktop
shotname clip      # drag a region, copy it carrying its name
shotname window    # click a window, save to the Desktop
shotname screen    # the whole screen, no prompt
```

`clip` is the interesting one. A normally copied screenshot is anonymous: paste
it and the receiving app invents a name or shows none. This puts a reference to
the saved file on the clipboard instead, so the real name travels with it.

Only the file reference, deliberately. An app offered both a file and raw pixels
takes the pixels and never reads the name, which is exactly the case this exists
for. Set `CLIP_FILE_ONLY="no"` for anything that cannot accept a pasted file.

Clipboard captures are lossless webp, roughly half the size of the PNG with
identical pixels. They live in `CLIP_DIR` and each one replaces the last,
because the clipboard only ever points at the newest. Files saved to the Desktop
stay PNG, where lossless webp saves about 25% and is not worth a dependency.

## Install

```bash
git clone https://github.com/serdarsalim/shotname.git
cd shotname
mkdir -p ~/.config/shotname && cp config.example.sh ~/.config/shotname/config.sh
swiftc -O src/frontwindow.swift -o bin/frontwindow
swiftc -O src/pbimage.swift -o bin/pbimage
```

Then put `bin/shotname` on your PATH, or call it by its full path. Without the
compiled helpers it still runs, but names files from the app alone.

Every setting lives in `~/.config/shotname/config.sh` and every line of it is
optional.

### The hotkey

There is no daemon and no menu bar app. macOS Shortcuts gives you a global
hotkey for free:

1. Shortcuts, then File, then New Shortcut. Name it "Screenshot".
2. Add one action, Run Shell Script, set the shell to `/bin/bash`, and put the
   full path to `bin/shotname` in it.
3. In the shortcut's details pane, assign a keyboard shortcut. Pick something
   free: Cmd+Shift+5 is the screenshot toolbar and Cmd+Shift+4 is the plain
   capture you are replacing.

### The permission

There is nothing to grant by hand. Window titles are read through `CGWindowList`,
which rides on the same Screen Recording permission `screencapture` already
needs, so one grant covers both. The first time your shortcut runs, macOS asks
for it. Click Allow and you are done.

## Letting a model describe the screen

Set `DETAIL_SOURCE="anthropic"` in your config and export an `ANTHROPIC_API_KEY`.
Each capture is downscaled to 768px before it is sent, which keeps the cost to a
fraction of a cent.

```
nudge-contacts-empty-state-2026-11-04.png
autotakt-pricing-429-error-2026-11-04.png
```

This sends your screenshots to an API. Screenshots of client dashboards are
client data, so decide that deliberately rather than by default.

Apple's on-device model is not an option here. It is text-only on macOS 27, with
no image input in the SDK, so using it would mean running OCR first and naming
from the extracted text, which reads badly on dashboards.

## The launchd watcher

`bin/shotname-watch` renames screenshots macOS saved by itself, so the built-in
Cmd+Shift+4 produces named files too. You do not need it if the hotkey above
works for you, and it carries one hard limitation: a launchd agent cannot see
`~/Desktop`, so your screenshot location has to be a plain folder.

```bash
defaults write com.apple.screencapture location ~/Screenshots
```

Then edit the placeholders in `launchd/com.serdarsalim.shotname.watch.plist`,
copy it to `~/Library/LaunchAgents/`, and load it:

```bash
launchctl bootstrap gui/$UID ~/Library/LaunchAgents/com.serdarsalim.shotname.watch.plist
```

## Debugging

Every run writes one line to `~/.config/shotname/log`. A hotkey that silently
does nothing and a script that ran and found nothing look identical from the
outside, and the log is what tells them apart.

## Five things macOS does that cost me an afternoon

Each of these fails silently. Nothing errors, nothing logs, and the obvious
implementation looks like it works. If you are building something similar, this
list is the useful part of the repository.

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
