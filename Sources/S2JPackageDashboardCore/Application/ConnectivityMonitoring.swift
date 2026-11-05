import Foundation

public protocol ConnectivityMonitoring: Sendable {
    func isOnline() async -> Bool
}

public struct AlwaysOnlineConnectivityMonitor: ConnectivityMonitoring {
    public init() {}

    public func isOnline() async -> Bool { true }
}
