import Foundation
import S2JPackageDashboardCore

@MainActor
final class AppEnvironment {
    let loadDashboard: LoadDashboardUseCase

    init(loadDashboard: LoadDashboardUseCase) {
        self.loadDashboard = loadDashboard
    }

    static func live() -> AppEnvironment {
        let store: any LocalDataStore
        if let fileStore = try? FileLocalDataStore.defaultStore() {
            store = fileStore
        } else {
            store = InMemoryLocalDataStore()
        }
        let connectivity = SystemConnectivityMonitor()
        return AppEnvironment(
            loadDashboard: LoadDashboardUseCase(store: store, connectivity: connectivity)
        )
    }
}
