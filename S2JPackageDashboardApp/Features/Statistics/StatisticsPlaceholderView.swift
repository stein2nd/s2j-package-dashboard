import SwiftUI

struct StatisticsPlaceholderView: View {
    var body: some View {
        ContentUnavailableView {
            Label("統計", systemImage: "chart.xyaxis.line")
        } description: {
            Text("ダウンロード統計や履歴の可視化は、Packagist / GitHub 連携実装後に表示します。")
        }
        .navigationTitle("統計")
    }
}
