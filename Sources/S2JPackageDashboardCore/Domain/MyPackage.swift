import Foundation

/// Packagist アカウントから取得した管理対象パッケージへの参照。
public struct MyPackage: Hashable, Sendable, Codable {
    public let packageName: PackageName

    public init(packageName: PackageName) {
        self.packageName = packageName
    }
}
