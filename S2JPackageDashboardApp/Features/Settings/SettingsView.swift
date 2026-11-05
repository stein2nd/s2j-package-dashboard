import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    PackagistCredentialPlaceholderView()
                } label: {
                    Label("Packagist 認証", systemImage: "key")
                }
            } footer: {
                Text("UC-16: 管理対象パッケージの取得に Packagist のクレデンシャル (資格情報) を使用します。")
            }

            Section("アプリケーション") {
                LabeledContent("バージョン", value: "0.0.4")
            }
        }
        .navigationTitle("設定")
    }
}

private struct PackagistCredentialPlaceholderView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Packagist 認証", systemImage: "key")
        } description: {
            Text("Keychain への保存と Packagist API 連携は、次の実装ステップで追加します。")
        }
        .navigationTitle("Packagist 認証")
        .navigationBarTitleDisplayMode(.inline)
    }
}
