import Foundation
import os

enum GestureError: Error {
    case multitouchNotSupported
    case deviceCreationFailed
}

class GestureListener {
    private let logger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: "GestureListener")
    private var device: MTDeviceRef?
    private var isListening = false
    private let gestureClassifier = GestureClassifier()
    private var lastGestureTime: Date = Date.distantPast
    private let gestureDebounceInterval: TimeInterval = 0.3
    
    var onGestureDetected: ((DetectedGesture) -> Void)?
    
    deinit {
        stopListening()
    }
    
    func startListening() throws {
        guard !isListening else { return }
        
        device = MTDeviceCreateDefault()
        guard device != nil else {
            throw GestureError.deviceCreationFailed
        }
        
        let callback: MTContactCallbackFunction = { deviceID, data, numFingers, timestamp, frame in
            guard let gestureListener = GestureListener.sharedInstance else { return 0 }
            gestureListener.handleTouchCallback(data: data, numFingers: numFingers, timestamp: timestamp)
            return 0
        }
        
        GestureListener.sharedInstance = self
        MTRegisterContactFrameCallback(device, callback)
        MTDeviceStart(device, 0)
        
        isListening = true
        logger.info("Gesture listening started")
    }
    
    func stopListening() {
        guard isListening, let device = device else { return }
        
        MTDeviceStop(device)
        MTDeviceRelease(device)
        self.device = nil
        isListening = false
        GestureListener.sharedInstance = nil
        
        logger.info("Gesture listening stopped")
    }
    
    private func handleTouchCallback(data: UnsafeMutablePointer<MultitouchFingerData>?, numFingers: Int, timestamp: Double) {
        guard let data = data, numFingers > 0 else { return }
        
        var fingers: [FingerPoint] = []
        for i in 0..<numFingers {
            let finger = data[i]
            fingers.append(FingerPoint(
                x: finger.x,
                y: finger.y,
                identifier: finger.identifier,
                timestamp: Date()
            ))
        }
        
        let frame = TouchFrame(fingers: fingers)
        
        DispatchQueue.main.async { [weak self] in
            self?.gestureClassifier.processFrame(frame)
            
            if let gesture = self?.gestureClassifier.getDetectedGesture() {
                self?.handleDetectedGesture(gesture)
            }
        }
    }
    
    private func handleDetectedGesture(_ gesture: DetectedGesture) {
        let now = Date()
        guard now.timeIntervalSince(lastGestureTime) > gestureDebounceInterval else {
            return
        }
        
        lastGestureTime = now
        logger.debug("Detected gesture: \(gesture.displayText)")
        onGestureDetected?(gesture)
    }
    
    private static weak var sharedInstance: GestureListener?
}