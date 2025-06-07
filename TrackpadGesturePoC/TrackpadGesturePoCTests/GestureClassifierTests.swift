import XCTest
@testable import TrackpadGesturePoC

final class GestureClassifierTests: XCTestCase {
    var classifier: GestureClassifier!
    
    override func setUp() {
        super.setUp()
        classifier = GestureClassifier()
    }
    
    override func tearDown() {
        classifier = nil
        super.tearDown()
    }
    
    func testSwipeRightDetection() {
        let startFingers = [
            FingerPoint(x: 0.2, y: 0.5, identifier: 1, timestamp: Date()),
            FingerPoint(x: 0.25, y: 0.5, identifier: 2, timestamp: Date()),
            FingerPoint(x: 0.3, y: 0.5, identifier: 3, timestamp: Date())
        ]
        
        let endFingers = [
            FingerPoint(x: 0.6, y: 0.5, identifier: 1, timestamp: Date()),
            FingerPoint(x: 0.65, y: 0.5, identifier: 2, timestamp: Date()),
            FingerPoint(x: 0.7, y: 0.5, identifier: 3, timestamp: Date())
        ]
        
        let startFrame = TouchFrame(fingers: startFingers)
        let endFrame = TouchFrame(fingers: endFingers)
        
        classifier.processFrame(startFrame)
        classifier.processFrame(endFrame)
        classifier.processFrame(TouchFrame(fingers: []))
        
        let gesture = classifier.getDetectedGesture()
        XCTAssertNotNil(gesture)
        XCTAssertEqual(gesture?.type, .swipeRight)
        XCTAssertEqual(gesture?.fingerCount, 3)
    }
    
    func testPinchOutDetection() {
        let startFingers = [
            FingerPoint(x: 0.4, y: 0.4, identifier: 1, timestamp: Date()),
            FingerPoint(x: 0.5, y: 0.5, identifier: 2, timestamp: Date()),
            FingerPoint(x: 0.6, y: 0.6, identifier: 3, timestamp: Date())
        ]
        
        let endFingers = [
            FingerPoint(x: 0.2, y: 0.2, identifier: 1, timestamp: Date()),
            FingerPoint(x: 0.5, y: 0.5, identifier: 2, timestamp: Date()),
            FingerPoint(x: 0.8, y: 0.8, identifier: 3, timestamp: Date())
        ]
        
        let startFrame = TouchFrame(fingers: startFingers)
        let endFrame = TouchFrame(fingers: endFingers)
        
        classifier.processFrame(startFrame)
        classifier.processFrame(endFrame)
        classifier.processFrame(TouchFrame(fingers: []))
        
        let gesture = classifier.getDetectedGesture()
        XCTAssertNotNil(gesture)
        XCTAssertEqual(gesture?.type, .pinchOut)
    }
    
    func testTapDetection() {
        let fingers = [
            FingerPoint(x: 0.5, y: 0.5, identifier: 1, timestamp: Date()),
            FingerPoint(x: 0.51, y: 0.51, identifier: 2, timestamp: Date()),
            FingerPoint(x: 0.52, y: 0.52, identifier: 3, timestamp: Date()),
            FingerPoint(x: 0.53, y: 0.53, identifier: 4, timestamp: Date())
        ]
        
        let frame = TouchFrame(fingers: fingers)
        
        classifier.processFrame(frame)
        classifier.processFrame(TouchFrame(fingers: []))
        
        let gesture = classifier.getDetectedGesture()
        XCTAssertNotNil(gesture)
        XCTAssertEqual(gesture?.type, .tap)
        XCTAssertEqual(gesture?.fingerCount, 4)
    }
}