import XCTest
@testable import TrackpadGesturePoC

final class TrackpadGesturePoCTests: XCTestCase {
    
    var gestureListener: GestureListener!
    
    override func setUpWithError() throws {
        gestureListener = GestureListener()
    }
    
    override func tearDownWithError() throws {
        gestureListener.stopListening()
        gestureListener = nil
    }
    
    func testGestureListenerInitialization() throws {
        XCTAssertFalse(gestureListener.isListening)
        XCTAssertNil(gestureListener.lastGesture)
    }
    
    func testStartListening() throws {
        gestureListener.startListening()
        XCTAssertTrue(gestureListener.isListening)
    }
    
    func testStopListening() throws {
        gestureListener.startListening()
        gestureListener.stopListening()
        XCTAssertFalse(gestureListener.isListening)
    }
    
    func testMultiplexStartListening() throws {
        gestureListener.startListening()
        let firstState = gestureListener.isListening
        
        gestureListener.startListening()
        let secondState = gestureListener.isListening
        
        XCTAssertTrue(firstState)
        XCTAssertTrue(secondState)
    }
    
    func testGestureTypeDescriptions() throws {
        let swipeLeft = GestureType.swipeLeft(fingers: 3)
        XCTAssertEqual(swipeLeft.description, "3本指左スワイプ")
        
        let pinchIn = GestureType.pinchIn(fingers: 2)
        XCTAssertEqual(pinchIn.description, "2本指ピンチイン")
        
        let rotateClockwise = GestureType.rotateClockwise(fingers: 2)
        XCTAssertEqual(rotateClockwise.description, "2本指時計回り回転")
        
        let tap = GestureType.tap(fingers: 4)
        XCTAssertEqual(tap.description, "4本指タップ")
    }
    
    func testTouchPointCreation() throws {
        let touchPoint = TouchPoint(x: 0.5, y: 0.3, timestamp: CFAbsoluteTimeGetCurrent())
        XCTAssertEqual(touchPoint.x, 0.5)
        XCTAssertEqual(touchPoint.y, 0.3)
        XCTAssertGreaterThan(touchPoint.timestamp, 0)
    }
    
    func testFingerDataCreation() throws {
        let touchPoint = TouchPoint(x: 0.5, y: 0.3, timestamp: CFAbsoluteTimeGetCurrent())
        let fingerData = FingerData(id: 1, points: [touchPoint])
        
        XCTAssertEqual(fingerData.id, 1)
        XCTAssertEqual(fingerData.points.count, 1)
        XCTAssertEqual(fingerData.points.first?.x, 0.5)
    }
    
    func testMultitouchBridgeSharedInstance() throws {
        let bridge1 = MultitouchBridge.shared()
        let bridge2 = MultitouchBridge.shared()
        
        XCTAssertTrue(bridge1 === bridge2, "MultitouchBridge should be a singleton")
    }
    
    func testMultitouchBridgeInitialState() throws {
        let bridge = MultitouchBridge.shared()
        XCTAssertFalse(bridge.isListening())
    }
}