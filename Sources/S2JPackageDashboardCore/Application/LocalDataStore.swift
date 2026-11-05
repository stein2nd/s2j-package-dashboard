import Foundation

/// 端末内のパッケージ関連データへのアクセス境界。
public protocol LocalDataStore: Sendable {
    func loadDashboardSnapshot() async throws -> DashboardSnapshot
    func saveMyPackages(_ packages: [MyPackage]) async throws
    func saveFavorites(_ favorites: [Favorite]) async throws
}

public actor InMemoryLocalDataStore: LocalDataStore {
    private var snapshot: DashboardSnapshot

    public init(snapshot: DashboardSnapshot = .empty) {
        self.snapshot = snapshot
    }

    public func loadDashboardSnapshot() async throws -> DashboardSnapshot {
        snapshot
    }

    public func saveMyPackages(_ packages: [MyPackage]) async throws {
        let items = packages.map { PackageListItem(name: $0.packageName) }
        snapshot = DashboardSnapshot(
            myPackages: items,
            favorites: snapshot.favorites,
            statisticsSummary: snapshot.statisticsSummary,
            snapshotFreshness: snapshot.snapshotFreshness,
            lastUpdatedAt: snapshot.lastUpdatedAt
        )
    }

    public func saveFavorites(_ favorites: [Favorite]) async throws {
        let items = favorites.map { PackageListItem(name: $0.packageName) }
        snapshot = DashboardSnapshot(
            myPackages: snapshot.myPackages,
            favorites: items,
            statisticsSummary: snapshot.statisticsSummary,
            snapshotFreshness: snapshot.snapshotFreshness,
            lastUpdatedAt: snapshot.lastUpdatedAt
        )
    }
}
