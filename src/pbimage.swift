// Puts an image file on the clipboard twice over: once as pixels, once as a
// file reference carrying its name.
//
// This is the whole point of clipboard mode. A plain copied screenshot is
// anonymous — paste it anywhere and the receiving app invents "image.png" or
// nothing at all. Writing the file reference alongside the pixels means apps
// that understand files (Claude, Slack, Mail) show the real filename, while
// apps that only understand pixels paste exactly as they always did.
//
// Both flavours are written eagerly. A promised flavour dies when this process
// exits, which is immediately.

import AppKit

guard CommandLine.arguments.count > 1 else { exit(1) }
let url = URL(fileURLWithPath: CommandLine.arguments[1])
guard let png = try? Data(contentsOf: url) else { exit(1) }

// Clear first, then build the item. An item constructed before the pasteboard
// is cleared loses its file-URL flavour by the time it is written.
let pb = NSPasteboard.general
pb.clearContents()

let item = NSPasteboardItem()
item.setData(png, forType: .png)
item.setData(url.dataRepresentation, forType: .fileURL)

pb.writeObjects([item])

// writeObjects returns before the pasteboard server has finished taking both
// flavours, and exiting now loses the file reference about four times in five.
// The pixels always survive, so the failure is silent: you paste and get an
// anonymous image. Wait for the name to actually be readable before leaving.
let deadline = Date().addingTimeInterval(1.0)
while pb.data(forType: .fileURL) == nil && Date() < deadline {
    usleep(10_000)
}
