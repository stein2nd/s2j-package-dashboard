import Foundation

private struct PersistedPayload: Codable {
    var myPackages: [MyPackage]
    var favorites: [Favorite]
    var statisticsSummary: StatisticsSummary?
    var snapshotFreshness: SnapshotFreshness
    var lastUpdatedAt: Date?
}

/// Application Support 上の JSON によるローカル・ファースト永続化。
public actor FileLocalDataStore: LocalDataStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(directoryURL: URL, fileName: String = "local-data.json") {
        fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public static func defaultStore() throws -> FileLocalDataStore {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let appDir = base.appendingPathComponent("S2JPackageDashboard", isDirectory: true)
        try FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return FileLocalDataStore(directoryURL: appDir)
    }

    public func loadDashboardSnapshot() async throws -> DashboardSnapshot {
        let payload = try readPayload()
        return DashboardSnapshot(
            myPackages: payload.myPackages.map { PackageListItem(name: $0.packageName) },
            favorites: payload.favorites.map { PackageListItem(name: $0.packageName) },
            statisticsSummary: payload.statisticsSummary,
            snapshotFreshness: payload.snapshotFreshness,
            lastUpdatedAt: payload.lastUpdatedAt
        )
    }

    public func saveMyPackages(_ packages: [MyPackage]) async throws {
        var payload = try readPayload()
        payload.myPackages = packages
        payload.lastUpdatedAt = Date()
        try writePayload(payload)
    }

    public func saveFavorites(_ favorites: [Favorite]) async throws {
        var payload = try readPayload()
        payload.favorites = favorites
        payload.lastUpdatedAt = Date()
        try writePayload(payload)
    }

    private func readPayload() throws -> PersistedPayload {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return PersistedPayload(
                myPackages: [],
                favorites: [],
                statisticsSummary: nil,
                snapshotFreshness: .unknown,
                lastUpdatedAt: nil
            )
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(PersistedPayload.self, from: data)
    }

    private func writePayload(_ payload: PersistedPayload) throws {
        let data = try encoder.encode(payload)
        try data.write(to: fileURL, options: [.atomic])
    }
}
