import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard
    case packages
    case statistics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "ダッシュボード"
        case .packages: "パッケージ"
        case .statistics: "統計"
        case .settings: "設定"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .packages: "shippingbox"
        case .statistics: "chart.xyaxis.line"
        case .settings: "gearshape"
        }
    }
}
