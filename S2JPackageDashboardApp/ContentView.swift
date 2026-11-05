import SwiftUI

/// 互換用。エントリは `RootView` を使用します。
struct ContentView: View {
    var body: some View {
        RootView(environment: AppEnvironment.live())
    }
}
