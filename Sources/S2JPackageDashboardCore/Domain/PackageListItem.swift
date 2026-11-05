import Foundation

/// 一覧表示用のパッケージ要約。ドメイン `Package` の軽量ビュー。
public struct PackageListItem: Hashable, Sendable, Identifiable, Codable {
    public var id: String { name.fullName }

    public let name: PackageName
    public let summary: String?

    public init(name: PackageName, summary: String? = nil) {
        self.name = name
        self.summary = summary
    }
}
