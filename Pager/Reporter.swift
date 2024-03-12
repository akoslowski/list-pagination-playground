import Foundation
import OSLog

/// Wrapper for logging vs. printing in SwiftUI previews. OSLog output is not displayed in Xcode's debug console (Xcode 15.3 RC2).
/// This approach is not recommended in production code. Use Logger instances directly without any wrapper!
struct Reporter {
    private let category: String
    private let subsystem: String
    private let defaultLogger: Logger
    private let isRunningInSwiftUIPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
        self.defaultLogger = Logger(subsystem: subsystem, category: category)
    }

    func log(_ message: String) {
        if isRunningInSwiftUIPreview {
            let timestamp = Date().formatted(date: .omitted, time: .standard)
            let paddedTimestamp = "\(timestamp)".padding(toLength: 8, withPad: " ", startingAt: 0)
            print("\(paddedTimestamp) [\(subsystem)|\(category)] \(message)")
        } else {
            // **Warning**: Wrapping the call breaks jump-to-file in the debug console.
            defaultLogger.notice("\(.init(stringLiteral: message))")
        }
    }
}
