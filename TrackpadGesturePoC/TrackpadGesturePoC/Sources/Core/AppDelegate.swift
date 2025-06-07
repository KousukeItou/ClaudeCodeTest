import AppKit
import os

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var gestureListener: GestureListener?
    private var popupController: PopupController?
    private let logger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: "AppDelegate")
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupGestureListener()
        setupPopupController()
        
        logger.info("TrackpadGesturePoC launched successfully")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        gestureListener?.stopListening()
        logger.info("TrackpadGesturePoC terminated")
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "hand.tap", accessibilityDescription: "Trackpad Gesture")
            button.image?.isTemplate = true
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About TrackpadGesturePoC", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Toggle Debug Log", action: #selector(toggleDebugLog), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    private func setupGestureListener() {
        gestureListener = GestureListener()
        gestureListener?.onGestureDetected = { [weak self] gesture in
            self?.popupController?.showGesture(gesture)
        }
        
        do {
            try gestureListener?.startListening()
        } catch {
            logger.error("Failed to start gesture listener: \(error.localizedDescription)")
            showErrorAndExit("Failed to initialize multitouch support. This app requires macOS with multitouch API support.")
        }
    }
    
    private func setupPopupController() {
        popupController = PopupController()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "TrackpadGesturePoC"
        alert.informativeText = "Version 1.0\nA proof-of-concept for trackpad gesture detection on macOS."
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    @objc private func toggleDebugLog() {
        let logManager = LogManager.shared
        logManager.enableDebugLogging(!logManager.isDebugLoggingEnabled())
        
        if let menuItem = statusItem?.menu?.item(withTitle: "Toggle Debug Log") {
            menuItem.state = logManager.isDebugLoggingEnabled() ? .on : .off
        }
        
        logger.info("Debug logging \(logManager.isDebugLoggingEnabled() ? "enabled" : "disabled")")
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    private func showErrorAndExit(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.runModal()
        NSApplication.shared.terminate(nil)
    }
}