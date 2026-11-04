# shotname config — copy to ~/.config/shotname/config.sh and edit.
# Every line is optional; anything you leave out keeps its default.

# Where finished screenshots land.
DEST="$HOME/Desktop"

# How many words of the window title to keep after the junk is filtered out.
MAX_TITLE_WORDS=4

# Who describes what is actually on screen, beyond the app and window title.
#   none      — app and window title only. Free, instant, nothing leaves the Mac.
#   anthropic — asks Claude Haiku for two or three words. Needs ANTHROPIC_API_KEY.
#   apple     — not built: Apple's on-device model cannot see images on this Mac.
DETAIL_SOURCE="none"

# Only read when DETAIL_SOURCE is "anthropic".
ANTHROPIC_MODEL="claude-haiku-5-5"
# export ANTHROPIC_API_KEY="sk-ant-..."

# interactive — drag a region, the usual Cmd+Shift+4 behaviour
# window      — click a window
# screen      — whole screen, no prompt
CAPTURE_MODE="interactive"

# Apps whose own name is noise, because the window title already says the site.
SKIP_APP_NAME_FOR="Google Chrome|Safari|Firefox|Arc|Brave Browser|Microsoft Edge"
