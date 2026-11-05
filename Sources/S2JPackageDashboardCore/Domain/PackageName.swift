import Foundation

/// Composer パッケージの完全修飾名 (`vendor/package`)。
public struct PackageName: Hashable, Sendable, Codable {
    public let vendor: String
    public let package: String

    public var fullName: String { "\(vendor)/\(package)" }

    public init?(fullName: String) {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2,
              !parts[0].isEmpty,
              !parts[1].isEmpty
        else {
            return nil
        }
        vendor = String(parts[0])
        package = String(parts[1])
    }

    public init(vendor: String, package: String) {
        self.vendor = vendor
        self.package = package
    }
}
