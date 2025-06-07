import AppKit
import os

@main
struct TrackpadGesturePoCApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        
        let delegate = AppDelegate()
        app.delegate = delegate
        
        app.run()
    }
}