import Foundation
import os

class GestureClassifier {
    private let logger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: "GestureClassifier")
    private var frameHistory: [TouchFrame] = []
    private let maxHistorySize = 20
    private var lastGestureDetection: Date = Date.distantPast
    private let minGestureDuration: TimeInterval = 0.1
    private let maxGestureDuration: TimeInterval = 2.0
    
    func processFrame(_ frame: TouchFrame) {
        frameHistory.append(frame)
        
        if frameHistory.count > maxHistorySize {
            frameHistory.removeFirst()
        }
        
        if frame.fingers.isEmpty && frameHistory.count > 1 {
            detectGestureFromHistory()
        }
    }
    
    func getDetectedGesture() -> DetectedGesture? {
        return lastDetectedGesture
    }
    
    private var lastDetectedGesture: DetectedGesture?
    
    private func detectGestureFromHistory() {
        guard frameHistory.count >= 2 else { return }
        
        let firstFrame = frameHistory.first { !$0.fingers.isEmpty }
        let lastNonEmptyFrame = frameHistory.last { !$0.fingers.isEmpty }
        
        guard let startFrame = firstFrame,
              let endFrame = lastNonEmptyFrame,
              startFrame !== endFrame else { return }
        
        let duration = endFrame.timestamp.timeIntervalSince(startFrame.timestamp)
        guard duration >= minGestureDuration && duration <= maxGestureDuration else { return }
        
        let fingerCount = max(startFrame.fingers.count, endFrame.fingers.count)
        guard fingerCount >= 3 else { return }
        
        let gestureType = classifyGesture(from: startFrame, to: endFrame)
        
        lastDetectedGesture = DetectedGesture(
            type: gestureType,
            fingerCount: fingerCount,
            timestamp: Date()
        )
        
        frameHistory.removeAll()
    }
    
    private func classifyGesture(from startFrame: TouchFrame, to endFrame: TouchFrame) -> GestureType {
        guard startFrame.fingers.count >= 2 && endFrame.fingers.count >= 2 else {
            return .tap
        }
        
        let startCentroid = calculateCentroid(startFrame.fingers)
        let endCentroid = calculateCentroid(endFrame.fingers)
        
        let deltaX = endCentroid.x - startCentroid.x
        let deltaY = endCentroid.y - startCentroid.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        let startDistance = averageDistanceFromCentroid(startFrame.fingers, centroid: startCentroid)
        let endDistance = averageDistanceFromCentroid(endFrame.fingers, centroid: endCentroid)
        let scaleChange = endDistance / startDistance
        
        let rotation = calculateRotation(from: startFrame.fingers, to: endFrame.fingers)
        
        if abs(rotation) > 0.3 {
            return rotation > 0 ? .rotateClockwise : .rotateCounterclockwise
        } else if abs(scaleChange - 1.0) > 0.2 {
            return scaleChange > 1.0 ? .pinchOut : .pinchIn
        } else if distance > 0.1 {
            if abs(deltaX) > abs(deltaY) {
                return deltaX > 0 ? .swipeRight : .swipeLeft
            } else {
                return deltaY > 0 ? .swipeDown : .swipeUp
            }
        } else {
            return .tap
        }
    }
    
    private func calculateCentroid(_ fingers: [FingerPoint]) -> (x: Float, y: Float) {
        let sumX = fingers.reduce(0) { $0 + $1.x }
        let sumY = fingers.reduce(0) { $0 + $1.y }
        return (x: sumX / Float(fingers.count), y: sumY / Float(fingers.count))
    }
    
    private func averageDistanceFromCentroid(_ fingers: [FingerPoint], centroid: (x: Float, y: Float)) -> Float {
        let distances = fingers.map { finger in
            let dx = finger.x - centroid.x
            let dy = finger.y - centroid.y
            return sqrt(dx * dx + dy * dy)
        }
        return distances.reduce(0, +) / Float(distances.count)
    }
    
    private func calculateRotation(from startFingers: [FingerPoint], to endFingers: [FingerPoint]) -> Float {
        guard startFingers.count >= 2 && endFingers.count >= 2 else { return 0 }
        
        let startCentroid = calculateCentroid(startFingers)
        let endCentroid = calculateCentroid(endFingers)
        
        let startAngle = atan2(startFingers[0].y - startCentroid.y, startFingers[0].x - startCentroid.x)
        let endAngle = atan2(endFingers[0].y - endCentroid.y, endFingers[0].x - endCentroid.x)
        
        var angleDiff = endAngle - startAngle
        if angleDiff > Float.pi {
            angleDiff -= 2 * Float.pi
        } else if angleDiff < -Float.pi {
            angleDiff += 2 * Float.pi
        }
        
        return angleDiff
    }
}