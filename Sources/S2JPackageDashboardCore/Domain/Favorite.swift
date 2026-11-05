import Foundation

/// ユーザーが登録したお気に入りパッケージ参照。
public struct Favorite: Hashable, Sendable, Codable {
    public let packageName: PackageName
    public let addedAt: Date
    public let updatedAt: Date

    public init(packageName: PackageName, addedAt: Date, updatedAt: Date) {
        self.packageName = packageName
        self.addedAt = addedAt
        self.updatedAt = updatedAt
    }
}
