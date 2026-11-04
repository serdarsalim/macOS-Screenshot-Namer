// Prints "<app name>\t<window title>" for the frontmost window.
//
// This reads titles through CGWindowList, which rides on the Screen Recording
// permission that screencapture already needs. The obvious route — System
// Events via AppleScript — would demand a separate Accessibility grant, which
// means hunting through System Settings for a pane Apple hides well.

import AppKit
import CoreGraphics

let app = NSWorkspace.shared.frontmostApplication
let appName = app?.localizedName ?? ""
let appPid = app?.processIdentifier ?? -1

func frontTitle() -> String {
    let opts = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements)
    guard let windows = CGWindowListCopyWindowInfo(opts, kCGNullWindowID) as? [[String: Any]] else {
        return ""
    }
    // The list comes back front to back. Layer 0 is a normal window; menus,
    // the Dock and overlays sit on other layers and would win otherwise.
    for w in windows {
        guard (w[kCGWindowLayer as String] as? Int) == 0,
              (w[kCGWindowOwnerPID as String] as? Int32) == appPid,
              let title = w[kCGWindowName as String] as? String,
              !title.isEmpty
        else { continue }
        return title
    }
    return ""
}

print("\(appName)\t\(frontTitle())")
