import AppKit
import os

class PopupController {
    private let logger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: "PopupController")
    private var currentWindow: NSWindow?
    private let animationDuration: TimeInterval = 0.15
    private let displayDuration: TimeInterval = 1.0
    private let fadeOutDuration: TimeInterval = 0.25
    
    func showGesture(_ gesture: DetectedGesture) {
        DispatchQueue.main.async { [weak self] in
            self?.dismissCurrentPopup()
            self?.createAndShowPopup(for: gesture)
        }
    }
    
    private func createAndShowPopup(for gesture: DetectedGesture) {
        guard let screen = NSScreen.main else { return }
        
        let windowSize = NSSize(width: 300, height: 80)
        let screenFrame = screen.frame
        let windowOrigin = NSPoint(
            x: screenFrame.midX - windowSize.width / 2,
            y: screenFrame.midY - windowSize.height / 2
        )
        
        let windowFrame = NSRect(origin: windowOrigin, size: windowSize)
        
        let window = NSPanel(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.level = .statusBar
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        let contentView = PopupView(gesture: gesture)
        window.contentView = contentView
        
        window.alphaValue = 0.0
        window.orderFrontRegardless()
        
        currentWindow = window
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 1.0
        }) { [weak self] in
            self?.schedulePopupDismissal()
        }
        
        logger.debug("Showing popup for gesture: \(gesture.displayText)")
    }
    
    private func schedulePopupDismissal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) { [weak self] in
            self?.dismissCurrentPopup()
        }
    }
    
    private func dismissCurrentPopup() {
        guard let window = currentWindow else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = fadeOutDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0.0
        }) { [weak self] in
            window.close()
            self?.currentWindow = nil
        }
    }
}

private class PopupView: NSView {
    private let gesture: DetectedGesture
    
    init(gesture: DetectedGesture) {
        self.gesture = gesture
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.95).cgColor
        layer?.cornerRadius = 12
        
        let textField = NSTextField(labelWithString: gesture.displayText)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = NSFont.systemFont(ofSize: 18, weight: .medium)
        textField.textColor = .controlTextColor
        textField.alignment = .center
        
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        let shadowColor = NSColor.black.withAlphaComponent(0.3)
        let shadowOffset = CGSize(width: 0, height: -2)
        let shadowBlur: CGFloat = 8
        
        context.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor.cgColor)
        
        let roundedRect = NSBezierPath(roundedRect: bounds, xRadius: 12, yRadius: 12)
        NSColor.controlBackgroundColor.withAlphaComponent(0.95).setFill()
        roundedRect.fill()
    }
}