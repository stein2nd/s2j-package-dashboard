import SwiftUI

struct PackagesPlaceholderView: View {
    var body: some View {
        ContentUnavailableView {
            Label("パッケージ", systemImage: "shippingbox")
        } description: {
            Text("管理対象とお気に入りの一覧、検索、詳細は今後の実装で追加します。")
        }
        .navigationTitle("パッケージ")
    }
}
