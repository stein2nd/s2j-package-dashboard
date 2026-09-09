# S2J Package Dashboard - 仕様書の起点

本プロジェクトの仕様は、下記のドキュメントに分散して定義しています。共通仕様に加え、アプリケーション固有の仕様を参照してください。

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、仕様書の入口および目次を定義します。本ファイルはその入口であり、共通仕様と個別仕様に案内する。

## 目的

本ドキュメントは、プロジェクト仕様の入口の目次である。共通仕様と、本リポジトリの個別仕様に案内する。

## 非目的

本ドキュメントは、個別仕様の本文を持たない。統合見取り図や分割方針の正本にならない。

## 責務

仕様ファイルの名簿、カテゴリー、参照資料リンクを維持する。現行ファイル一覧の正本である。

## 非責務

分割方針は [`spec_structure.md`](./spec_structure.md)、統合の見取り図は [`spec.md`](./spec.md)、各関心事の本文は各専門仕様を正本とする。

## 共通仕様

* [Xcode Common Specs (共通仕様)](https://github.com/stein2nd/xcode-common-specs/blob/main/docs/SPECS.md)

共通仕様と本仕様が競合する場合は、プロジェクト固有要件を確認してから適切な仕様を採用します。

## 関連仕様

ファイルの名簿は本節を正本とする。分割方針は [`spec_structure.md`](./spec_structure.md)、統合の見取り図は [`spec.md`](./spec.md) とする。各ファイルの責務本文は、そのファイルの「責務」節とする。関係の見取り図を本仕様に再掲しない。カテゴリーは [`spec_structure.md`](./spec_structure.md) の層分類に合わせる。

* 仕様構成
    * [仕様書の細分化](./spec_structure.md) — どの種類のファイルに何を置くか
    * [アプリケーション詳細仕様](./spec.md) — 統合の見取り図、競合時の優先 (個別を再掲しない)
* プロジェクト
    * [概要](./overview.md) — プロジェクトの存在理由、概要、基本情報。「何を作るか ?」
* アーキテクチャー
    * [アーキテクチャー](./architecture.md) — アーキテクチャー方針。「どう分割するか ?」
* ドメイン
    * [モデル定義仕様](./models_spec.md) — ドメイン型、Value オブジェクト、および外部/永続化/UI モデルとの層境界
    * [ドメイン・ルール仕様](./domain_rules.md) — 何が妥当か、何を混同してはいけないか
* 外部連携
    * [Packagist API 仕様](./api-packagist.md) — Packagist のエンドポイント、DTO、レート制限
    * [GitHub API 仕様](./api-github.md) — GitHub のエンドポイント、DTO、レート制限
* アプリケーション
    * [ユースケース仕様](./use_cases.md) — ユースケース仕様。「何を実現するか ?」
    * [アプリケーション状態の仕様](./application_state.md) — アプリケーション状態の仕様。「何を状態として保持するか ?」
    * [状態機械の仕様](./state_machine.md) — 状態/Event/Transition の形式仕様。「状態がどう遷移するか ?」
* プレゼンテーション
    * [UX フロー仕様](./ux_flows_spec.md) — UX フロー仕様。「どう操作されるか ?」
    * [ナビゲーション仕様](./navigation_spec.md) — ナビゲーション・アーキテクチャー
    * [スクリーン仕様](./screen_spec.md) — スクリーン・アーキテクチャー
    * [コンポーネント仕様](./component_spec.md) — コンポーネント・アーキテクチャー
    * [UI/UX 仕様](./ui.md) — 横断的な UI 振る舞い
    * [Viewport 整合性仕様](./ui-viewport.md) — Viewport 整合性仕様
    * [設計ブランディング仕様](./design_spec.md) — 設計・ブランディング仕様
* 永続化 / キャッシュ
    * [ローカル・ストレージ仕様](./storage_spec.md) — ローカル・ストレージ/スナップショット仕様
    * [キャッシュ仕様](./cache_spec.md) — TTL / Freshness / Invalidation
    * [iOS/iPadOS ストレージ仕様](./ios_spec.md) — ストレージの iOS/iPadOS 差分
    * [Android ストレージ仕様](./android_spec.md) — ストレージの Android 差分
* 統計
    * [統計情報の仕様](./statistics_spec.md) — 指標の意味、収集、可視化
* 認証・セキュリティ
    * [認証仕様](./authentication_spec.md) — 認証/クレデンシャル (資格情報) 仕様
    * [セキュリティ仕様](./security_spec.md) — セキュリティ・権限・プライバシー仕様
* プラットフォーム
    * [Kotlin Multiplatform (KMP) 仕様](./kmp_spec.md) — KMP 実施時のモジュール配置と移行段階
* テスト
    * [テスト仕様](./testing_spec.md) — 何をテストするか
    * [テスト結果](./test-results.md) — 自動生成されるテスト結果
* 運用
    * [リリース仕様](./release.md) — リリース条件
    * [CI/CD 仕様](./cicd.md) — CI/CD パイプライン

## 参照資料

* 仕様書の細分化
    * [SwiftUI - Apple Developer Documentation](https://developer.apple.com/documentation/SwiftUI)
    * [A New Default Project Structure for Kotlin Multiplatform - The JetBrains Blog](https://blog.jetbrains.com/kotlin/2026/05/new-kmp-default-structure/)
    * [Kotlin Multiplatform Wizard - JetBrains](https://kmp.jetbrains.com/templates/)
    * [Multiplatform ViewModel - Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-viewmodel.html)
* アプリケーション詳細仕様
    * [State holders and UI state | App architecture | Android Developers](https://developer.android.com/topic/architecture/ui-layer/stateholders?hl=en)
    * [Understanding the navigation stack | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack?language=objc)
* ユースケース仕様
    * [Understanding the navigation stack | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack?changes=_2.%2C_2.)
    * [Build a list-detail layout | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/list-detail)
    * [Restoring your app’s state with SwiftUI | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/restoring-your-app-s-state-with-swiftui?changes=_1)
    * [Get started with adaptive apps | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/get-started-with-adaptive-apps)
* データモデル仕様
    * [Packagist.org](https://packagist.org/apidoc?type=1)
    * [The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html)
    * [Packagist.org](https://packagist.org/apidoc)
    * [Recommended Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-project-recommended-structure.html)
* ドメイン・ルール仕様
    * [The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html)
    * [Aggregates: How to Model Complex Domains with Consistency and Cohesion | SAP](https://github.com/SAP/curated-resources-for-domain-driven-design/blob/main/blog/0003-how-to-model-aggregates.md)
* GitHub API 仕様
    * [REST API のレート制限 - GitHub Docs](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2026-03-10)
    * [リポジトリへのアクセス状況の確認 - GitHub Docs](https://docs.github.com/en/repositories/viewing-activity-and-data-for-your-repository/viewing-traffic-to-a-repository?apiVersion=2022-11-28)
    * [リポジトリ トラフィック用 REST API エンドポイント - GitHub Docs](https://docs.github.com/ja/rest/metrics/traffic)
    * [リポジトリの統計情報に関する REST API エンドポイント - GitHub Docs](https://docs.github.com/en/rest/metrics/statistics?apiVersion=2026-03-10&partner=null)
    * [GitHubのREST APIとGraphQL APIの比較 - GitHub Docs](https://docs.github.com/en/rest/about-the-rest-api/comparing-githubs-rest-api-and-graphql-api)
* コンポーネント仕様
    * [Recommended Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-project-recommended-structure.html)
    * [What is Kotlin Multiplatform | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/kmp-overview.html)
* ナビゲーション仕様
    * [Kotlin/KMP-App-Template-Native: Kotlin Multiplatform app template with native UI · GitHub](https://github.com/Kotlin/KMP-App-Template-Native)
    * [Navigation in Compose | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-navigation.html)
    * [Liquid Glass in a Compose Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/ios-liquid-glass.html)
    * [Split views | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/split-views?changes=_6)
    * [Sidebars | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/sidebars?changes=_6)
* スクリーン仕様
    * [NavigationSplitView | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/navigationsplitview?changes=_9)
    * [Build adaptive apps | Jetpack Compose | Android Developers](https://developer.android.com/develop/ui/compose/build-adaptive-apps?hl=en)
* アプリケーション状態の仕様
    * [Restoring your app’s state with SwiftUI | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/restoring-your-app-s-state-with-swiftui?changes=_1)
    * [Save UI states | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/saving-states?hl=en)
    * [Understanding the navigation stack | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack)
* 状態機械の仕様
    * [GitHub - ReSwift/ReSwift: Unidirectional Data Flow in Swift - Inspired by Redux · GitHub](https://github.com/reswift/reswift)
    * [StateFlow | kotlinx.coroutines – Kotlin Programming Language](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/-state-flow/)
    * [Reducer | Documentation](https://pointfreeco.github.io/swift-composable-architecture/0.40.0/documentation/composablearchitecture/reducer/)
* ローカル・ストレージ/スナップショット仕様
    * [SwiftData | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/)
    * [Create a multiplatform app using Ktor and SQLDelight | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-ktor-sqldelight.html)
    * [Getting Started - SQLDelight](https://sqldelight.github.io/sqldelight/2.0.0/multiplatform_sqlite/)
    * [ModelContainer | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/modelcontainer)
* キャッシュ仕様
    * [Accessing cached data | Apple Developer Documentation](https://developer.apple.com/documentation/foundation/accessing-cached-data?changes=_3)
* 統計/可視化の仕様
    * [Packagist.org](https://packagist.org/apidoc?page=3&type=composer)
    * [REST API endpoints for metrics - GitHub Docs](https://docs.github.com/en/rest/metrics)
    * [Viewing traffic to a repository - GitHub Docs](https://docs.github.com/en/repositories/viewing-activity-and-data-for-your-repository/viewing-traffic-to-a-repository?apiVersion=2022-11-28)
    * [リポジトリ トラフィック用 REST API エンドポイント - GitHubドキュメント](https://docs.github.com/ja/rest/metrics/traffic)
* 認証/クレデンシャル (資格情報) 仕様
    * [Packagist.org](https://packagist.org/apidoc?page=1&query=&type=metapackage)
    * [Best practices for creating an OAuth app - GitHub Docs](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/best-practices-for-creating-an-oauth-app)
    * [Keychain services | Apple Developer Documentation](https://developer.apple.com/documentation/security/keychain-services/)
    * [Keeping your API credentials secure - GitHub Docs](https://docs.github.com/en/rest/authentication/keeping-your-api-credentials-secure)
* セキュリティ・権限・プライバシー仕様
    * [OWASP MASVS - OWASP Mobile Application Security](https://mas.owasp.org/MASVS/)
    * [Apple Platform Security](https://help.apple.com/pdf/security/en_US/apple-platform-security-guide.pdf)
    * [Android Keystore system - Security - Android Developers](https://developer.android.com/privacy-and-security/keystore?authuser=1)
    * [About the Standard - OWASP Mobile Application Security](https://mas.owasp.org/MASVS/02-Frontispiece/)
* Kotlin Multiplatform 仕様
    * [Recommended Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-project-recommended-structure.html)
    * [What is Kotlin Multiplatform | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/kmp-overview.html)
    * [Choosing a configuration for your Kotlin Multiplatform project | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-project-configuration.html)
    * [Create your Kotlin Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-create-first-app.html)
    * [The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html)
    * [Integration with the SwiftUI framework | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-swiftui-integration.html)
    * [Create your Compose Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-multiplatform-create-first-app.html)
* UI/UX 仕様
    * [Compose Material 3 Adaptive | Jetpack - Android Developers](https://developer.android.com/jetpack/androidx/releases/compose-material3-adaptive)
    * [Layout | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/layout?changes=la)
    * [Build a list-detail layout | Adaptive Apps - Android Developers](https://developer.android.com/develop/adaptive-apps/guides/list-detail)
    * [Build adaptive apps | Jetpack Compose - Android Developers](https://developer.android.com/develop/ui/compose/build-adaptive-apps?hl=en)
    * [Accessibility - Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/accessibility)
    * [Tier 2 — Adaptive optimized | Adaptive Apps - Android Developers](https://developer.android.com/develop/adaptive-apps/quality-guidelines/adaptive-app-quality/tier-2)
    * [Canonical layouts | Adaptive Apps - Android Developers](https://developer.android.com/develop/adaptive-apps/guides/canonical-layouts)
* UX フロー仕様
    * [Navigation | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/navigation)
    * [Build a list-detail layout | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/list-detail)
    * [NavigationSplitView | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/navigationsplitview?changes=_9)
    * [Bringing robust navigation structure to your SwiftUI app | Apple Developer Documentation](https://developer.apple.com/documentation/SwiftUI/Bringing-robust-navigation-structure-to-your-swiftui-app)
    * [Get started with adaptive apps | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/get-started-with-adaptive-apps?hl=en)
* Viewport 整合性仕様
    * [Layout | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/layout?changes=la__1_8_1)
    * [Get started with adaptive apps | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/get-started-with-adaptive-apps?hl=en)
* iOS/iPadOS ストレージ仕様
    * [SwiftData | Apple Developer Documentation](https://developer.apple.com/documentation/SwiftData?changes=_4)
    * [SecItemAdd | Apple Developer Documentation](https://developer.apple.com/documentation/security/secitemadd%28_%3A_%3A%29?changes=_2_1&language=objc)
    * [Keychain services | Apple Developer Documentation](https://developer.apple.com/documentation/security/keychain-services)
    * [Restricting keychain item accessibility | Apple Developer Documentation](https://developer.apple.com/documentation/security/restricting-keychain-item-accessibility?changes=_7_1)
    * [Accessing Keychain Items with Face ID or Touch ID | Apple Developer Documentation](https://developer.apple.com/documentation/localauthentication/accessing-keychain-items-with-face-id-or-touch-id?changes=la_3)
    * [Using the keychain to manage user secrets | Apple Developer Documentation](https://developer.apple.com/documentation/security/using-the-keychain-to-manage-user-secrets?language=objc)
    * [Security | Apple Developer Documentation](https://developer.apple.com/documentation/security)
    * [Syncing model data across a person’s devices | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices?changes=_8)
    * [Preserving your app’s model data across launches | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
* Android ストレージ仕様
    * [データ ストレージとファイル ストレージの概要 | App data and files | Android Developers](https://developer.android.com/training/data-storage?authuser=108)
    * [アプリ固有のファイルにアクセスする | App data and files | Android Developers](https://developer.android.com/training/data-storage/app-specific)
    * [Room を使用してローカル データベースにデータを保存する | App data and files | Android Developers](https://developer.android.com/training/data-storage/room?hl=ja)
    * [アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore)
    * [セキュリティ ガイドライン | Security | Android Developers](https://developer.android.com/privacy-and-security/security-tips)
    * [アプリのセキュリティを強化する | Security | Android Developers](https://developer.android.com/privacy-and-security/security-best-practices)
* CI/CD 仕様
    * [Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
    * [runner-images/images/macos/xcode-27-Readme.md at main · actions/runner-images · GitHub](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-Readme.md)
    * [Deployments and environments · github/docs · GitHub](https://github.com/github/docs/blob/main/content/actions/reference/workflows-and-actions/deployments-and-environments.md)
* リリース仕様
    * [Releasing and maintaining actions - GitHub Docs](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/release-and-maintain-actions)
    * [TestFlight overview - Test a beta version - App Store Connect - Help - Apple Developer](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview)
    * [Distributing your app for beta testing and releases | Apple Developer Documentation](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
    * [Inspect app versions on the Latest releases and bundles page - Play Console Help](https://support.google.com/googleplay/android-developer/answer/9844279?hl=en)
    * [Prepare and roll out a release - Play Console Help](https://support.google.com/googleplay/android-developer/answer/9859348/prepare-and-roll-out-a-release?hl=en-GB)
* テスト仕様
    * [Swift Testing | Apple Developer Documentation](https://developer.apple.com/documentation/testing/)
    * [Testing APIs | Jetpack Compose | Android Developers](https://developer.android.com/develop/ui/compose/testing/apis)
    * [XCTest | Apple Developer Documentation](https://developer.apple.com/documentation/xctest/)
    * [Common patterns | Jetpack Compose | Android Developers](https://developer.android.com/develop/ui/compose/testing/common-patterns)
