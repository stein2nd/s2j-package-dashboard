import Foundation

public struct DashboardLoadResult: Sendable, Equatable {
    public let snapshot: DashboardSnapshot
    public let isOffline: Bool
    public let isFirstLaunch: Bool

    public init(snapshot: DashboardSnapshot, isOffline: Bool, isFirstLaunch: Bool) {
        self.snapshot = snapshot
        self.isOffline = isOffline
        self.isFirstLaunch = isFirstLaunch
    }
}

/// UC-01: ダッシュボードを表示する。
public struct LoadDashboardUseCase: Sendable {
    private let store: any LocalDataStore
    private let connectivity: any ConnectivityMonitoring

    public init(store: any LocalDataStore, connectivity: any ConnectivityMonitoring) {
        self.store = store
        self.connectivity = connectivity
    }

    public func execute() async throws -> DashboardLoadResult {
        let online = await connectivity.isOnline()
        do {
            let snapshot = try await store.loadDashboardSnapshot()
            let isFirstLaunch = snapshot.myPackages.isEmpty
                && snapshot.favorites.isEmpty
                && snapshot.statisticsSummary == nil
            return DashboardLoadResult(
                snapshot: snapshot,
                isOffline: !online,
                isFirstLaunch: isFirstLaunch
            )
        } catch {
            throw DashboardFailure.storageUnavailable
        }
    }
}
