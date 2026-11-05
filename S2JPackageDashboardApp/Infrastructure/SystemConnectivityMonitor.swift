import Foundation
import Network
import S2JPackageDashboardCore

final class SystemConnectivityMonitor: ConnectivityMonitoring, @unchecked Sendable {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.s2j.package-dashboard.connectivity")
    private var online = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.online = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    func isOnline() async -> Bool {
        online
    }
}
