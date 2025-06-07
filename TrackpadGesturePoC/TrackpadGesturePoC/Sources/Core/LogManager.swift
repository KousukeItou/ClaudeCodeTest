import Foundation
import os

class LogManager {
    static let shared = LogManager()
    
    private let logger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: "LogManager")
    private var isDebugEnabled = false
    
    private init() {}
    
    func enableDebugLogging(_ enabled: Bool) {
        isDebugEnabled = enabled
        if enabled {
            logger.info("Debug logging enabled")
        } else {
            logger.info("Debug logging disabled")
        }
    }
    
    func isDebugLoggingEnabled() -> Bool {
        return isDebugEnabled
    }
    
    func logDebug(_ message: String, category: String = "Debug") {
        if isDebugEnabled {
            let debugLogger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: category)
            debugLogger.debug("\(message)")
        }
    }
    
    func logInfo(_ message: String, category: String = "Info") {
        let infoLogger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: category)
        infoLogger.info("\(message)")
    }
    
    func logError(_ message: String, category: String = "Error") {
        let errorLogger = Logger(subsystem: "com.example.TrackpadGesturePopup", category: category)
        errorLogger.error("\(message)")
    }
}