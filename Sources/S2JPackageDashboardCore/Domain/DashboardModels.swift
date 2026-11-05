import Foundation

public enum SnapshotFreshness: String, Sendable, Codable {
    case fresh
    case stale
    case unknown
}

public struct StatisticsSummary: Hashable, Sendable, Codable {
    public let headline: String
    public let detail: String?

    public init(headline: String, detail: String? = nil) {
        self.headline = headline
        self.detail = detail
    }
}

/// ダッシュボードに表示する永続データのスナップショット。
public struct DashboardSnapshot: Hashable, Sendable, Codable {
    public let myPackages: [PackageListItem]
    public let favorites: [PackageListItem]
    public let statisticsSummary: StatisticsSummary?
    public let snapshotFreshness: SnapshotFreshness
    public let lastUpdatedAt: Date?

    public init(
        myPackages: [PackageListItem],
        favorites: [PackageListItem],
        statisticsSummary: StatisticsSummary?,
        snapshotFreshness: SnapshotFreshness,
        lastUpdatedAt: Date?
    ) {
        self.myPackages = myPackages
        self.favorites = favorites
        self.statisticsSummary = statisticsSummary
        self.snapshotFreshness = snapshotFreshness
        self.lastUpdatedAt = lastUpdatedAt
    }

    public static let empty = DashboardSnapshot(
        myPackages: [],
        favorites: [],
        statisticsSummary: nil,
        snapshotFreshness: .unknown,
        lastUpdatedAt: nil
    )
}

public enum DashboardFailure: Error, Equatable, Sendable {
    case storageUnavailable
    case underlyingMessage(String)
}
