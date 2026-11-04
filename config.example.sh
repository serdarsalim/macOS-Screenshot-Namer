# shotname config — copy to ~/.config/shotname/config.sh and edit.
# Every line is optional; anything you leave out keeps its default.

# Where finished screenshots land.
DEST="$HOME/Desktop"

# Clipboard captures need a real file on disk, because the filename is what
# the clipboard carries. Once pasted it is dead weight, so each capture
# replaces the last. Raise CLIP_KEEP if you want a short history instead.
CLIP_DIR="$HOME/Pictures/shotname"
CLIP_KEEP=1

# webp or png. webp here is lossless, so text stays sharp, and still lands
# around half the size on flat UI. Needs cwebp; falls back to png without it.
CLIP_FORMAT="webp"

# Put only the file reference on the clipboard, no pixels. Apps offered both
# take the pixels and never read the name, which defeats the point. Set this
# to "no" if you paste into something that cannot accept a file.
CLIP_FILE_ONLY="yes"

# How many words of the window title to keep after the junk is filtered out.
MAX_TITLE_WORDS=4
# Browser page titles get their own budget, since the site name leads.
MAX_PAGE_WORDS=6

# Who describes what is actually on screen, beyond the app and window title.
#   none      — app and window title only. Free, instant, nothing leaves the Mac.
#   anthropic — asks Claude Haiku for two or three words. Needs ANTHROPIC_API_KEY.
#   apple     — not built: Apple's on-device model cannot see images on this Mac.
DETAIL_SOURCE="none"

# Only read when DETAIL_SOURCE is "anthropic".
ANTHROPIC_MODEL="claude-haiku-5-5"
# export ANTHROPIC_API_KEY="sk-ant-..."

# What a bare `shotname` does, with no mode argument.
#   area   — drag a region, save to DEST (the usual Cmd+Shift+4 behaviour)
#   clip   — drag a region, put it on the clipboard carrying its name
#   window — click a window, save to DEST
#   screen — whole screen, no prompt
CAPTURE_MODE="area"

# Apps whose own name is noise, because the window title already says the site.
SKIP_APP_NAME_FOR="Google Chrome|Safari|Firefox|Arc|Brave Browser|Microsoft Edge"
