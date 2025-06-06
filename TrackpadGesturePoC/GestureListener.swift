import Foundation
import Combine

struct MultitouchFingerData {
    let identifier: Int32
    let x: Float
    let y: Float
    let pressure: Float
    let size: Float
}

struct TouchPoint {
    let x: Float
    let y: Float
    let timestamp: TimeInterval
}

struct FingerData {
    let id: Int32
    var points: [TouchPoint]
}

enum GestureType {
    case swipeLeft(fingers: Int)
    case swipeRight(fingers: Int)
    case swipeUp(fingers: Int)
    case swipeDown(fingers: Int)
    case pinchIn(fingers: Int)
    case pinchOut(fingers: Int)
    case rotateClockwise(fingers: Int)
    case rotateCounterClockwise(fingers: Int)
    case tap(fingers: Int)
    
    var description: String {
        switch self {
        case .swipeLeft(let fingers):
            return "\(fingers)本指左スワイプ"
        case .swipeRight(let fingers):
            return "\(fingers)本指右スワイプ"
        case .swipeUp(let fingers):
            return "\(fingers)本指上スワイプ"
        case .swipeDown(let fingers):
            return "\(fingers)本指下スワイプ"
        case .pinchIn(let fingers):
            return "\(fingers)本指ピンチイン"
        case .pinchOut(let fingers):
            return "\(fingers)本指ピンチアウト"
        case .rotateClockwise(let fingers):
            return "\(fingers)本指時計回り回転"
        case .rotateCounterClockwise(let fingers):
            return "\(fingers)本指反時計回り回転"
        case .tap(let fingers):
            return "\(fingers)本指タップ"
        }
    }
}

class GestureListener: ObservableObject {
    @Published var isListening = false
    @Published var lastGesture: String?
    
    private var currentFingers: [Int32: FingerData] = [:]
    private var gestureStartTime: TimeInterval = 0
    private let minSwipeDistance: Float = 0.1
    private let minPinchDistance: Float = 0.05
    private let minRotationAngle: Float = 0.2
    private let maxGestureDuration: TimeInterval = 2.0
    
    func startListening() {
        guard !isListening else { return }
        
        MultitouchBridge.shared().startListening { [weak self] fingersArray in
            let fingers = fingersArray.compactMap { value -> MultitouchFingerData? in
                var fingerData = MultitouchFingerData()
                value.getValue(&fingerData)
                return fingerData
            }
            
            DispatchQueue.main.async {
                self?.processFingerData(fingers)
            }
        }
        
        isListening = true
        print("ジェスチャ検出を開始しました")
    }
    
    func stopListening() {
        guard isListening else { return }
        
        MultitouchBridge.shared().stopListening()
        currentFingers.removeAll()
        isListening = false
        print("ジェスチャ検出を停止しました")
    }
    
    private func processFingerData(_ fingers: [MultitouchFingerData]) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if fingers.isEmpty {
            if !currentFingers.isEmpty {
                analyzeGesture()
                currentFingers.removeAll()
            }
            return
        }
        
        if currentFingers.isEmpty {
            gestureStartTime = currentTime
        }
        
        for finger in fingers {
            let touchPoint = TouchPoint(
                x: finger.x,
                y: finger.y,
                timestamp: currentTime
            )
            
            if var existingFinger = currentFingers[finger.identifier] {
                existingFinger.points.append(touchPoint)
                currentFingers[finger.identifier] = existingFinger
            } else {
                currentFingers[finger.identifier] = FingerData(
                    id: finger.identifier,
                    points: [touchPoint]
                )
            }
        }
        
        if currentTime - gestureStartTime > maxGestureDuration {
            analyzeGesture()
            currentFingers.removeAll()
        }
    }
    
    private func analyzeGesture() {
        guard !currentFingers.isEmpty else { return }
        
        let fingerCount = currentFingers.count
        guard fingerCount >= 3 else { return }
        
        if let gesture = detectSwipe() {
            publishGesture(gesture)
        } else if let gesture = detectPinch() {
            publishGesture(gesture)
        } else if let gesture = detectRotation() {
            publishGesture(gesture)
        } else if let gesture = detectTap() {
            publishGesture(gesture)
        }
    }
    
    private func detectSwipe() -> GestureType? {
        var totalDeltaX: Float = 0
        var totalDeltaY: Float = 0
        var validFingers = 0
        
        for finger in currentFingers.values {
            guard finger.points.count >= 2 else { continue }
            
            let firstPoint = finger.points.first!
            let lastPoint = finger.points.last!
            
            let deltaX = lastPoint.x - firstPoint.x
            let deltaY = lastPoint.y - firstPoint.y
            
            totalDeltaX += deltaX
            totalDeltaY += deltaY
            validFingers += 1
        }
        
        guard validFingers >= 3 else { return nil }
        
        let avgDeltaX = totalDeltaX / Float(validFingers)
        let avgDeltaY = totalDeltaY / Float(validFingers)
        
        let absX = abs(avgDeltaX)
        let absY = abs(avgDeltaY)
        
        if absX > minSwipeDistance && absX > absY * 2 {
            return avgDeltaX > 0 ? .swipeRight(fingers: validFingers) : .swipeLeft(fingers: validFingers)
        } else if absY > minSwipeDistance && absY > absX * 2 {
            return avgDeltaY > 0 ? .swipeDown(fingers: validFingers) : .swipeUp(fingers: validFingers)
        }
        
        return nil
    }
    
    private func detectPinch() -> GestureType? {
        guard currentFingers.count >= 2 else { return nil }
        
        let fingerArray = Array(currentFingers.values)
        guard fingerArray.count >= 2,
              fingerArray[0].points.count >= 2,
              fingerArray[1].points.count >= 2 else { return nil }
        
        let finger1Start = fingerArray[0].points.first!
        let finger1End = fingerArray[0].points.last!
        let finger2Start = fingerArray[1].points.first!
        let finger2End = fingerArray[1].points.last!
        
        let startDistance = distance(finger1Start, finger2Start)
        let endDistance = distance(finger1End, finger2End)
        
        let deltaDistance = endDistance - startDistance
        
        if abs(deltaDistance) > minPinchDistance {
            return deltaDistance > 0 ? .pinchOut(fingers: currentFingers.count) : .pinchIn(fingers: currentFingers.count)
        }
        
        return nil
    }
    
    private func detectRotation() -> GestureType? {
        guard currentFingers.count >= 2 else { return nil }
        
        let fingerArray = Array(currentFingers.values)
        guard fingerArray.count >= 2,
              fingerArray[0].points.count >= 2,
              fingerArray[1].points.count >= 2 else { return nil }
        
        let finger1Start = fingerArray[0].points.first!
        let finger1End = fingerArray[0].points.last!
        let finger2Start = fingerArray[1].points.first!
        let finger2End = fingerArray[1].points.last!
        
        let startAngle = angle(finger1Start, finger2Start)
        let endAngle = angle(finger1End, finger2End)
        
        var deltaAngle = endAngle - startAngle
        if deltaAngle > Float.pi {
            deltaAngle -= 2 * Float.pi
        } else if deltaAngle < -Float.pi {
            deltaAngle += 2 * Float.pi
        }
        
        if abs(deltaAngle) > minRotationAngle {
            return deltaAngle > 0 ? .rotateCounterClockwise(fingers: currentFingers.count) : .rotateClockwise(fingers: currentFingers.count)
        }
        
        return nil
    }
    
    private func detectTap() -> GestureType? {
        var maxMovement: Float = 0
        
        for finger in currentFingers.values {
            guard finger.points.count >= 2 else { continue }
            
            let firstPoint = finger.points.first!
            let lastPoint = finger.points.last!
            
            let movement = distance(firstPoint, lastPoint)
            maxMovement = max(maxMovement, movement)
        }
        
        if maxMovement < 0.02 {
            return .tap(fingers: currentFingers.count)
        }
        
        return nil
    }
    
    private func distance(_ p1: TouchPoint, _ p2: TouchPoint) -> Float {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    private func angle(_ p1: TouchPoint, _ p2: TouchPoint) -> Float {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return atan2(dy, dx)
    }
    
    private func publishGesture(_ gesture: GestureType) {
        let gestureString = gesture.description
        print("検出されたジェスチャ: \(gestureString)")
        lastGesture = gestureString
    }
}