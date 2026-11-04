// Prints "<app name>\t<window title>".
//
// Default: the frontmost window. With "--match <width>x<height>": the window
// whose on-screen size matches an image of those pixel dimensions, which is
// how window-capture mode finds out what was actually clicked. screencapture
// -w lets you pick any window, not necessarily the one in front, so assuming
// the frontmost would confidently name the file after the wrong thing.
//
// Titles come from CGWindowList, which rides on the Screen Recording
// permission screencapture already needs. Asking System Events over
// AppleScript would want a separate Accessibility grant.

import AppKit
import CoreGraphics

func windows() -> [[String: Any]] {
    let opts = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements)
    return CGWindowListCopyWindowInfo(opts, kCGNullWindowID) as? [[String: Any]] ?? []
}

func name(of w: [String: Any]) -> (String, String) {
    let owner = w[kCGWindowOwnerName as String] as? String ?? ""
    let title = w[kCGWindowName as String] as? String ?? ""
    return (owner, title)
}

// Bounds are in points; a capture of the same window is in pixels, so it is
// the point size times the display scale. Checking both covers Retina and not.
func matches(_ w: [String: Any], width: Double, height: Double) -> Bool {
    guard let b = w[kCGWindowBounds as String] as? [String: Any],
          let bw = b["Width"] as? Double, let bh = b["Height"] as? Double
    else { return false }
    for scale in [2.0, 1.0] {
        if abs(bw * scale - width) <= 2 && abs(bh * scale - height) <= 2 { return true }
    }
    return false
}

var result = ("", "")

if CommandLine.arguments.count > 2, CommandLine.arguments[1] == "--match" {
    let parts = CommandLine.arguments[2].split(separator: "x").compactMap { Double($0) }
    if parts.count == 2 {
        for w in windows() where (w[kCGWindowLayer as String] as? Int) == 0 {
            if matches(w, width: parts[0], height: parts[1]) { result = name(of: w); break }
        }
    }
}

// No match, or no --match asked for: fall back to the frontmost window.
if result.0.isEmpty {
    let app = NSWorkspace.shared.frontmostApplication
    let pid = app?.processIdentifier ?? -1
    result.0 = app?.localizedName ?? ""
    for w in windows() {
        guard (w[kCGWindowLayer as String] as? Int) == 0,
              (w[kCGWindowOwnerPID as String] as? Int32) == pid,
              let t = w[kCGWindowName as String] as? String, !t.isEmpty
        else { continue }
        result.1 = t
        break
    }
}

print("\(result.0)\t\(result.1)")
