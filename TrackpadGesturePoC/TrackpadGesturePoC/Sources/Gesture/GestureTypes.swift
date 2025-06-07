import Foundation

enum GestureType: String, CaseIterable {
    case swipeUp = "Swipe ↑"
    case swipeDown = "Swipe ↓"
    case swipeLeft = "Swipe ←"
    case swipeRight = "Swipe →"
    case pinchIn = "Pinch In"
    case pinchOut = "Pinch Out"
    case rotateClockwise = "Rotate ↻"
    case rotateCounterclockwise = "Rotate ↺"
    case tap = "Tap"
    case unknown = "Unknown"
}

struct DetectedGesture {
    let type: GestureType
    let fingerCount: Int
    let timestamp: Date
    
    var displayText: String {
        return "\(fingerCount)-finger \(type.rawValue)"
    }
}

struct FingerPoint {
    let x: Float
    let y: Float
    let identifier: Int
    let timestamp: Date
}

class TouchFrame {
    let fingers: [FingerPoint]
    let timestamp: Date
    
    init(fingers: [FingerPoint], timestamp: Date = Date()) {
        self.fingers = fingers
        self.timestamp = timestamp
    }
}