// Puts an image file on the clipboard, carrying its name.
//
// A plain copied screenshot is anonymous: paste it anywhere and the receiving
// app invents a name or shows none. Writing a file reference instead means the
// real filename travels with it.
//
// With --file-only, the pixels are left off entirely. Apps offered both
// flavours take the pixels and never look at the file, losing the name exactly
// where it was wanted. The cost is that an app which cannot paste a file gets
// nothing, so this is a deliberate choice rather than a default.

import AppKit

guard CommandLine.arguments.count > 1 else { exit(1) }
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let fileOnly = CommandLine.arguments.contains("--file-only")

let pb = NSPasteboard.general
pb.clearContents()

let item = NSPasteboardItem()
item.setData(url.dataRepresentation, forType: .fileURL)

if !fileOnly {
    guard let data = try? Data(contentsOf: url) else { exit(1) }
    // The pixel flavour has to be declared as what it actually is.
    let type: NSPasteboard.PasteboardType =
        url.pathExtension.lowercased() == "webp"
            ? NSPasteboard.PasteboardType("org.webmproject.webp")
            : .png
    item.setData(data, forType: type)
}

pb.writeObjects([item])

// writeObjects returns before the pasteboard server has finished taking the
// file reference, and exiting now loses it about four times in five. The
// failure is silent, so wait for the name to read back before leaving.
let deadline = Date().addingTimeInterval(1.0)
while pb.data(forType: .fileURL) == nil && Date() < deadline {
    usleep(10_000)
}
