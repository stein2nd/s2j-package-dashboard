# S2J Package Dashboard - Kotlin Multiplatform 仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、Kotlin Multiplatform の実装境界および共有ロジック移行を定義します。

Kotlin Multiplatform の仕様変更、iOS/iPadOS/Android 実装、共有ロジックの移行進捗、および各アーキテクチャー仕様の変更に応じて、更新します。

## 目的

本ドキュメントでは、Kotlin Multiplatform 実施時の実装境界を定義します。対象は、ソースセット、expect/actual、モジュール構成、プラットフォーム連携、段階的な移行手順です。

## 非目的

本仕様では、下記を必須としません。

* Compose Multiplatform (CMP) による UI 共有
* SwiftUI の Kotlin 化
* 既存 Swift パッケージの Kotlin Multiplatform (KMP) 化
* クラウド・バックエンド
* デバイス横断型同期
* 共有クレデンシャル (資格情報) ストレージ
* プラットフォーム API の完全抽象化
* すべてのコードの Kotlin 化

## 責務

Kotlin Multiplatform (KMP) 化の実施手順、モジュール配置、移行段階を正本とします。
本仕様は、アーキテクチャー方針を上書きしません。

## 非責務

アーキテクチャー方針、共有ロジックの対象と優先順位は [`architecture.md`](./architecture.md) を正本とします。
不変条件は [`domain_rules.md`](./domain_rules.md)、ドメイン型 / ApplicationError は [`models_spec.md`](./models_spec.md)、キャッシュ方針は [`cache_spec.md`](./cache_spec.md)、永続化は [`storage_spec.md`](./storage_spec.md)、認証境界は [`authentication_spec.md`](./authentication_spec.md)、状態の分類・復元は [`application_state.md`](./application_state.md)、テスト戦略は [`testing_spec.md`](./testing_spec.md)、CI ジョブは [`cicd.md`](./cicd.md) を正本とします。

## 基本方針

基本アーキテクチャーは [`architecture.md`](./architecture.md) に従います。本仕様は Kotlin Multiplatform (KMP) 化の実施手順に限定します。

## Kotlin Multiplatform (KMP) の採用方針

KMP は、アプリケーション全体を一度に Kotlin 化するための移行ツールではありません。共有に移す順序は [`architecture.md`](./architecture.md) を正本とします。
本仕様は、「初期段階で、ドメイン・ロジック/アプリケーション・ロジックから段階的に共有する」ことのみを定めます。

## ネイティブ UI の原則

UI を共有しない方針は [`architecture.md`](./architecture.md) を正本とします。
本仕様では、その方針をモジュール配置として維持します。

(参考: [What is Kotlin Multiplatform | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/kmp-overview.html))

## アーキテクチャーの概要

方針の正本は [`architecture.md`](./architecture.md) とします。
本仕様のモジュール配置は、下記の通りです。
Android は、今後のターゲットです。時期は [`overview.md`](./overview.md) を正本とします。
共有ロジック側に、ドメイン/アプリケーション/統計/キャッシュの方針/リポジトリ・インターフェース/検証/ユースケースを置き、iOS/iPadOS 側に SwiftUI とプラットフォーム・アダプタを置きます。Android 版に向けて、共有ロジックを Kotlin Multiplatform (KMP) に移設し、Android 側に Jetpack Compose とプラットフォーム・アダプタを置きます。

## 共有ロジック

共有ロジックとは、「iOS/iPadOS/Android でドメインのセマンティクスおよびアプリケーション挙動を共通化できる Kotlin コード」とします。対象と優先順位は [`architecture.md`](./architecture.md) を正本とします。
本仕様では、それらを共有ロジックに載せます。

## 共有ロジックの優先順位

順序の方針は [`architecture.md`](./architecture.md) を正本とします。
実施段階は、本仕様の移行フェーズとします。

## UI は、共有ロジックに含めない

[`architecture.md`](./architecture.md) の原則5に従い、SwiftUI は共有ロジックに含めません。初期バージョンの UI は、SwiftUI のみです。Android 版の開発に着手したあとの Jetpack Compose も、共有ロジックに含めません。時期は [`overview.md`](./overview.md) を正本とします。

## ドメイン層

ドメイン層は Kotlin Multiplatform (KMP) の最優先の共有対象とします。型は [`models_spec.md`](./models_spec.md)、不変条件は [`domain_rules.md`](./domain_rules.md) を正本とし、可能な限り、共有ロジックに移行します。ドメインが UI /ストレージ/ HTTP に依存しないことは [`architecture.md`](./architecture.md) の依存関係の方向を正本とします。

## アプリケーション層

ユースケースの一覧と UI 非依存は [`architecture.md`](./architecture.md) を正本とします。
Kotlin Multiplatform (KMP) ではユースケースを共有ロジックに置き、プラットフォーム UI から直接ドメイン・オブジェクトを操作しません。

## リポジトリ・インターフェース

リポジトリ・インターフェースは、共有ロジックに配置可能とします。

例:

* `PackageRepository`
* `StatisticsRepository`
* `SnapshotRepository`

## リポジトリの実装

リポジトリの具体的な実装は、プラットフォームまたはデータ層に配置可能とします。共有インターフェースに対して iOS 実装と Android 実装を置きます。

## 依存関係の反転

共有ロジックは、インターフェースに依存し、具象実装に直接依存しません。

## プロバイダの抽象化

Packagist/GitHub API は、共有ロジックから抽象化します。下記のインターフェースを定義可能とします。

* PackagistClient
* GitHubClient

## プロバイダの実装

プロバイダ・クライアントの実装は、可能な限り、Kotlin Multiplatform (KMP) 共有ロジックに配置します。

ただし、HTTP スタック等のプラットフォーム固有の依存関係が必要な場合は、アダプタを利用します。

## HTTP の抽象化

共有ロジックでは、HTTP クライアント自体をドメイン・オブジェクトとして扱いません。

概念:

HttpClient インターフェースを定義し、下記から提供する構造を許容します。

* iOS HTTP アダプタ
* Android HTTP アダプタ

## HTTP 実装

HTTP 実装には、下記のようにプラットフォームに応じた、ライブラリを利用可能とします。ただし、共有ロジックから直接プラットフォーム API に依存しません。

* iOS: URLSession
* Android: OkHttp

## 直列化

API データ転送オブジェクト (DTO) の直列化は、Kotlin Multiplatform (KMP) 互換なライブラリを優先します。

候補: `kotlinx.serialization`

## データ転送オブジェクト (DTO)

プロバイダ・レスポンス DTO とドメイン・モデルの分離は [`models_spec.md`](./models_spec.md) を正本とします。
Kotlin Multiplatform (KMP) では、DTO とマッパーを共有ロジックまたはプロバイダ層に置きます。

## ドメイン・マッパー

プロバイダ固有データを、ドメイン・モデルに変換する責務をマッパーに持たせます。

## エラーのモデル

共有ロジックでは、プラットフォーム固有の例外をそのままドメイン・エラーとして扱いません。エラー境界の分類は [`architecture.md`](./architecture.md)、型は [`models_spec.md`](./models_spec.md) を正本とします。
Kotlin Multiplatform (KMP) では、同名の共有型として共有ロジックに置きます。

## 共有エラー

`ApplicationError` のケースは [`models_spec.md`](./models_spec.md) を正本とします。
本仕様は、「それらを共有ロジックの共有型として置く」ことのみを定めます。

## プラットフォーム・エラーのマッピング

プラットフォーム固有のエラーは、共有エラーにマッピングします。

## ドメイン・エラー

ドメイン・エラー (`InvalidPackageIdentifier` / `InvalidMetric` / `InvalidSnapshot` / `InvalidStateTransition` 等) の意味は [`domain_rules.md`](./domain_rules.md) を正本とします。
Kotlin Multiplatform (KMP) では、同名の共有型として、共有ロジックに置きます。

## クレデンシャル (資格情報) 境界

認証方針は [`authentication_spec.md`](./authentication_spec.md) を正本とします。
Kotlin Multiplatform (KMP) では、クレデンシャル (資格情報) を共有ロジックのドメイン・モデルに含めません。

## クレデンシャル (資格情報) ストレージ

クレデンシャル ストレージの実装は、プラットフォーム固有とします。共有ロジックには、クレデンシャルを取得するための抽象インターフェースのみを置きます。

## 認証境界

概念: 共有ロジックは `CredentialProvider` インターフェースのみを知り、iOS / Android クレデンシャル (資格情報) ストレージがそのインターフェースを実装します。Keychain / Keystore の HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とします。

## クレデンシャル (資格情報) 非永続化

クレデンシャルを通常ストレージに置かない方針は [`authentication_spec.md`](./authentication_spec.md) を正本とします。
共有ロジックは、クレデンシャルをキャッシュ/スナップショット/ドメイン・ストレージに保存しません。

## キャッシュの方針の配置

キャッシュ方針は [`cache_spec.md`](./cache_spec.md)、不変条件は [`domain_rules.md`](./domain_rules.md)、永続化は [`storage_spec.md`](./storage_spec.md) を正本とします。
Kotlin Multiplatform (KMP) では、方針/セマンティクスを共有ロジックに移行し、本仕様では、語彙を再定義しません。キャッシュ・ストレージおよびスナップショット・ストレージの技術はプラットフォーム固有でもかまいません。キャッシュと履歴スナップショットの分離は、KMP 化後も維持します。

## キャッシュの実装

キャッシュ・ストレージ自体は、プラットフォーム固有でもかまいません。共有は `CacheRepository`、実装は iOS/Android のキャッシュ・ストレージとします。

## ストレージの抽象化

永続化ストレージについては、必要に応じて、共有リポジトリ・インターフェースを定義します。

## ストレージの実装

ストレージの実装は、プラットフォーム/ライブラリに応じて、選択可能とします。ただし、共有ドメインはストレージ技術を直接参照しません。

候補:

* SQLDelight
* SQLite
* Room
* SwiftData

## SwiftData

現在の iOS 実装で SwiftData を利用する場合も、ドメイン・モデルを SwiftData モデルに直接結合しないことを基本とします。

## SQLDelight

将来的に、Kotlin Multiplatform (KMP) 共有ストレージが必要になった場合、SQLDelight 等の KMP 互換ストレージを検討可能とします。

## UI の状態

UI の状態の分類は [`application_state.md`](./application_state.md) を正本とします。
本仕様は、「ビューの状態を、プラットフォーム UI 側で管理する」ことのみを定めます。

## 共有 UI の状態

同一セマンティクスが必要なアプリケーション状態は、共有ロジックで提供可能とします。何を保持するかは [`application_state.md`](./application_state.md) を正本とします。

## UI モデル

共有ドメイン・モデルを、そのまま UI に公開することを必須としません。必要に応じて、ドメイン・モデルを UI モデルに変換します。

## SwiftUI 連携

iOS/iPadOS では、SwiftUI が Kotlin Multiplatform (KMP) 共有ロジックを利用します。経路は SwiftUI → Swift アダプタ/ViewModel → KMP フレームワーク→共有ユースケース。

## Android 連携

Android は、今後のターゲットです。初期バージョンの UI は、SwiftUI のみです。Android 版の開発に着手したタイミングで、Jetpack Compose が Kotlin Multiplatform (KMP) 共有ロジックを利用します。時期は [`overview.md`](./overview.md) を正本とします。経路は Compose → Android ViewModel/アダプタ→共有ユースケース。

## iOS フレームワーク

Kotlin Multiplatform (KMP) 共有モジュールは、iOS アプリケーションから利用可能なフレームワークとして提供します。

KMP では、共有モジュールを iOS フレームワークとして生成し、Xcode プロジェクトから利用する構成が公式にサポートされています。

(参考: [Choosing a configuration for your Kotlin Multiplatform project | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-project-configuration.html))

## Android ライブラリ

Android アプリケーションは、Kotlin Multiplatform (KMP) 共有モジュールを Android ライブラリとして利用します。

## ビルドシステム

Kotlin Multiplatform (KMP) 共有モジュールのビルドには Gradle を利用します。

Kotlin 公式の KMP 構成でも、共有モジュールは Gradle で管理され、iOS アプリケーション側は Xcode プロジェクトとして構成できます。

(参考: [Create your Kotlin Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-create-first-app.html))

## Xcode プロジェクト

iOS/iPadOS アプリケーションでは、Xcode プロジェクト (`iosApp/*.xcodeproj`) を引き続き使用します。または、将来的に、`*.xcworkspace` 等を利用可能とします。

## Swift パッケージ

Kotlin Multiplatform (KMP) 移行後も、既存の Swift パッケージをすべて即時廃止する必要はありません。

## 既存 S2J コンポーネント

既存の下記については、SwiftUI コンポーネントとして、iOS/iPadOS UI 層で利用可能とします。

* [S2J About Window](https://github.com/stein2nd/s2j-about-window)
* [S2J Source List](https://github.com/stein2nd/s2j-source-list)

## S2J About Window

[S2J About Window](https://github.com/stein2nd/s2j-about-window) は、基本的に、UI コンポーネントとして扱います。そのため、SwiftUI 側に置く構成を維持可能とします。

## S2J Source List

[S2J Source List](https://github.com/stein2nd/s2j-source-list) についても、UI/プレゼンテーション・コンポーネントとして SwiftUI 側に配置可能とします。

## 共有ロジックと既存コンポーネント

既存 S2J コンポーネントを、Kotlin Multiplatform (KMP) 化する必要はありません。

KMP 化の対象は、プラットフォーム横断型で意味を共有する、ドメイン・ロジック/アプリケーション・ロジックを優先します。

## UI コンポーネント境界

下記は、ネイティブ UI として維持可能とします。

* About Window
* ソースリスト
* ナビゲーション
* ツールバー
* チャート
* シート
* アラート
* 設定

## 統計計算

統計計算は、共有ロジックの有力な対象とします。指標の意味とフォーミュラは [`statistics_spec.md`](./statistics_spec.md) を正本とし、Kotlin Multiplatform (KMP) ではその計算を共有ロジックに移行可能とします。

## チャートのレンダリング

チャートのレンダリング自体は、共有ロジックに含めません。

* 共有: 統計計算
* iOS: SwiftUI チャート
* Android: Compose チャート

## 時刻

共有ロジックでは、プラットフォーム固有の日付 API への直接依存を避けます。

ドメイン上では、下記の抽象概念を利用します。

* Instant
* クロック

## タイムゾーン

ドメイン・ロジックは、表示タイムゾーンに依存しません。

## ロケール

共有ロジックは、UI ロケール/言語に依存しません。

## フォーマット

日付/数値のビジュアル書式は [`design_spec.md`](./design_spec.md) を正本とします。
Kotlin Multiplatform (KMP) では、フォーマットを共有ドメインに置かず、プラットフォーム UI 側で行います。

## ローカライズ

翻訳済み文字列自体を、ドメイン・ロジックに埋め込みません。

## 並行処理

共有ロジックでは、プラットフォーム固有のスレッド API への直接依存を避けます。

## コルーチン

非同期処理には、Kotlin Multiplatform (KMP) 互換なコルーチン設計を利用可能とします。

## メインスレッド

UI スレッド/メインスレッドへの切替は、プラットフォーム UI 層で責務を持つことを基本とします。

## フロー

共有状態ストリームには、Kotlin のフロー等を利用可能とします。ただし、iOS 側の Swift API との相互運用性を考慮します。

## Swift 相互運用性

共有 Kotlin API は、Swift から利用しやすい公開 API として設計します。

## Swift 対応 API

Swift 側で過度に Kotlin 固有概念を意識しなくて済む API を優先します。

## 公開 API

Kotlin Multiplatform (KMP) 共有モジュールの公開 API は、アプリケーション内部の実装詳細を公開しません。

## Kotlin の命名

Kotlin 側では Kotlin コーディング規約に従います。

Swift からの利用時に自然になるよう、公開 API を設計します。

## データ・タイプ

共有公開 API では、プラットフォーム固有のデータ・タイプを、可能な限り、避けます。下記を共有モデルに含めません。

例:

* UIColor
* 色
* UIView
* UIImage
* コンテキスト
* アクティビティ

## 画像

パッケージ・アイコン等の画像データについては、共有ロジックでは、URL/識別子等のプラットフォームに依存しない表現を優先します。

## URL

URL を共有モデルに持たせる場合も、プラットフォーム固有の URL オブジェクトではなく、直列化表現を検討します。

## UUID

UUID は、プラットフォーム固有のオブジェクトに依存しません。

必要に応じて、文字列等のプラットフォームに依存しない表現を使用します。

## JSON

JSON スキーマは、プロバイダ API 層で扱い、ドメイン・モデルに JSON 構造を漏らしません。

## API バージョン

プロバイダ API バージョンは、ドメイン・モデル・バージョンと分離します。

## テスト

Kotlin Multiplatform (KMP) 共有ロジックには、共通テストを配置します。`commonTest` でドメイン・ロジック/アプリケーション・ロジックを検証します。何を、どのレベルでテストするかは [`testing_spec.md`](./testing_spec.md) を正本とします。

KMP ではソースセットごとにテストを持たせる構成が可能であり、`commonTest` は共有ロジックの共通テストに適します。

(参考: [The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html))

## プラットフォーム・テスト

プラットフォーム固有の機能性は `iosTest` / `androidTest` 等で検証します。UI テストは XCTest/XCUITest または Compose UI テスト等のプラットフォーム固有のテストとします。

## 決定論的テスト

共有ロジックは、固定クロック/固定インプットを利用して、決定論的テスト可能とします。

## プラットフォーム固有のコード

プラットフォーム固有として許容するものは [`architecture.md`](./architecture.md) の「プラットフォーム固有」を正本とします。
Kotlin Multiplatform (KMP) ではそれらを `iosMain` / `androidMain` またはアダプタに置きます。

## expect/actual

プラットフォーム固有の API が必要な場合、`expect`/`actual` の利用を検討します。

Kotlin Multiplatform (KMP) では、共通コードに期待する宣言を置き、プラットフォーム・ソースセット で `actual` 実装を提供できます。

(参考: [Create your Kotlin Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-create-first-app.html))

## 「インターフェース」ファースト

ただし、複雑なプラットフォームの依存関係では、単純な `expect`/`actual` より、インターフェース + プラットフォーム実装を優先します。

## 依存関係の注入

プラットフォーム実装は、依存関係の注入によって、共有ロジックに提供可能とします。

概念:

* 共有: interface CredentialStore
* iOS: KeychainCredentialStore
* Android: KeystoreCredentialStore

## コンポジション・ルート

プラットフォーム・アプリケーションのエントリー・ポイントで、依存関係を組み立てます。

* iOS: App.swift
* Android: アプリケーション/アクティビティ

## iOS エントリー・ポイント

下記から、共有アプリケーション・ロジックに依存関係を渡します。

概念:

```text
@main
struct S2JPackageDashboardApp: App {
    ...
}
```

## Android エントリー・ポイント

Android アプリケーション・エントリー・ポイントから、共有ロジックに依存関係を渡します。

## 共有モジュールの構造

推奨構成:

```text
sharedLogic/
├── build.gradle.kts
└── src/
    ├── commonMain/
    ├── commonTest/
    ├── androidMain/
    ├── androidUnitTest/
    ├── iosMain/
    └── iosTest/
```

Kotlin Multiplatform (KMP) では、共有ロジックに共有コード、`androidMain`/`iosMain` にプラットフォーム固有のコードを配置する構造が基本となります。

(参考: [Create your Kotlin Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-create-first-app.html))

## アプリケーションの構造

将来的な構成:

```text
s2j-package-dashboard/
│
├── androidApp/
│
├── iosApp/
│
├── sharedLogic/
│
├── docs/
│
├── docs_mod/
│
├── gradle/
│
├── build.gradle.kts
├── settings.gradle.kts
└── gradlew
```

## iOS アプリケーション

```text
iosApp/
├── S2JPackageDashboard/
│   ├── App.swift
│   ├── Views/
│   ├── ViewModels/
│   └── Components/
│
└── S2JPackageDashboard.xcodeproj
```

## Android アプリケーション

```text
androidApp/
└── src/
    ├── main/
    │   ├── kotlin/
    │   └── res/
    └── test/
```

## 共有ドメインの構造

```text
sharedLogic/src/commonMain/
└── kotlin/
    └── com/
        └── s2j/
            └── packagedashboard/
                ├── domain/
                ├── application/
                ├── statistics/
                ├── cache/
                ├── repository/
                └── error/
```

## プラットフォームの構造

```text
sharedLogic/src/
├── iosMain/
│   └── kotlin/
│       └── ...
│
└── androidMain/
    └── kotlin/
        └── ...
```

## 共通ソースセット

共有ロジックには、全プラットフォームで共通化可能なコードのみを配置します。

## プラットフォーム・ソースセット

`iosMain`/`androidMain` には、そのプラットフォームでしか成立しないコードを配置します。

## プラットフォーム漏洩なし

共有ロジック から、下記を参照しません。

* UIKit
* Android SDK
* SwiftUI
* Compose

## 中間ソースセット

将来的に、複数 Apple ターゲット等を追加する場合、必要に応じて、中間ソースセットを利用します。

Kotlin Multiplatform (KMP) では `appleMain` 等の階層型ソースセットを利用して、Apple 系ターゲット間でコードを共有できます。

(参考: [The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html))

## iOS デバイス/シミュレーター

iOS では、下記のターゲットを考慮します。

* `iosArm64`
* `iosSimulatorArm64`

通常、デバイスと Apple Silicon シミュレーターで同じ iOS 固有ロジックを利用できるため、`iosMain` への集約を基本とします。

(参考: [The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html))

## Android ターゲット

Android は、今後のターゲットです。時期は [`overview.md`](./overview.md) を正本とします。初期バージョンの主要共有ターゲットにはしません。初期バージョンの UI は、SwiftUI のみです。

Android 版の開発に着手したタイミングで、共有ロジックを Kotlin Multiplatform (KMP) に移設し、UI を「iOS/iPadOS: SwiftUI」と「Android: Jetpack Compose」に分けます。Android UI は共有ロジックに含めません。

## ターゲットの独立性

ドメイン・ロジックは、下記のターゲット差を意識しません。

* `iosArm64`
* `iosSimulatorArm64`
* `android`

## ビルドシステム設定 (Configuration)

デバッグ/リリース等のビルドシステム設定は、プラットフォーム側で管理します。

共有ロジックに、UI ビルドシステム設定を持ち込みません。

## システム設定 (Configuration)

環境システム設定は、共有ロジックに直接ハードコーディングしません。

## API エンドポイント

本番/開発等のエンドポイントは、システム設定 (Configuration) として注入します。

## Secrets

API Secret/Token をソースコードにハードコーディングしません。

## ログ記録

共有ロジックでは、プラットフォーム中立なログ記録インターフェースを利用可能とします。

## プラットフォーム・ログ記録

下記のプラットフォーム・ログ記録にアダプタ経由で接続可能とします。

* iOS: `OSLog`
* Android: `Logcat`

## アナリティクス

アナリティクス SDK は、共有ドメインに直接導入しません。

必要な場合は、インターフェースを利用します。

## 通知

ローカル/プッシュ通知は、プラットフォーム固有の機能性とします。

## バックグラウンド処理

バックグラウンド・タスクは、プラットフォーム固有の機能性とします。

共有ロジックでは、スナップショット・コレクション・ユースケース等を提供し、実行スケジューラは、プラットフォーム側が担当します。

## iOS バックグラウンド

iOS バックグラウンド実行は、iOS 側のスケジュール設定/バックグラウンド API から、共有ユースケースを呼び出します。

## Android バックグラウンド

Android バックグラウンド実行は、Android 側のスケジュール設定 API から、共有ユースケースを呼び出します。

## 同期

デバイス横断型同期は、初期バージョンでは、必須としません。

## クラウド・バックエンド

Kotlin Multiplatform (KMP) 導入自体を理由として、クラウド・バックエンドを追加しません。

## 外部バックエンド

外部バックエンドが必要になった場合、別アーキテクチャーとして検討します。

## 共有ロジック・リポジトリ

初期バージョンでは、共有ロジックをアプリケーション・リポジトリ内に置きます。

## Separate Kotlin Multiplatform (KMP) リポジトリ

共有ロジックが複数アプリケーションで再利用される場合、独立リポジトリ化を検討します。

## バージョン管理

共有ロジックには、必要に応じて、独立バージョンを付与します。

## バージョンの互換性

iOS アプリケーション/Android アプリケーションと、共有ロジック版の互換性を管理します。

## API の互換性

共有モジュールの公開 API 変更は、破壊的変更として扱います。

## 移行戦略

Kotlin Multiplatform (KMP) 移行は、Big Bang 移行を避けます。

## 移行フェーズ: 0

現在の Swift アーキテクチャーを整理します。Swift 側で下記を分離し、プラットフォームの依存関係を明確にします。

* ドメイン
* アプリケーション
* データ
* UI

層の意味は [`architecture.md`](./architecture.md) を正本とします。
本節は、「フェーズ0でその分離を Swift 実装に反映する」ことのみを定めます。

## 移行フェーズ: 1

ドメイン・モデルを Kotlin に移行します。

対象:

* パッケージ
* リポジトリ
* 指標
* スナップショット

## 移行フェーズ: 2

ドメイン・ルールを Kotlin に移行します。

## 移行フェーズ: 3

統計計算を Kotlin に移行します。

## 移行フェーズ: 4

ユースケースを Kotlin に移行します。

## 移行フェーズ: 5

リポジトリ・インターフェースを Kotlin に移行します。

## 移行フェーズ: 6

キャッシュの方針を Kotlin に移行します。

## 移行フェーズ: 7

必要に応じて、プロバイダ・クライアントを Kotlin Multiplatform (KMP) 化します。

## 移行フェーズ: 8

プラットフォーム固有のアダプタを整理します。

## 移行フェーズ: 9

Swift 側の重複ロジックを削除します。

## 移行フェーズ: 10

Android アプリケーションを、共有ロジックに接続します。

## 移行の成功条件

移行成功の基準は、iOS/iPadOS/Android が「同じドメイン・ルール」「同じ統計結果」「同じキャッシュのセマンティクス」を共有することです。

ルールの正本は [`domain_rules.md`](./domain_rules.md) / [`statistics_spec.md`](./statistics_spec.md) / [`cache_spec.md`](./cache_spec.md) とします。本節は、「Kotlin Multiplatform (KMP) 化後もその一致を維持する」ことのみを定めます。

## 挙動の同等性

iOS/iPadOS/Android で、「同じインプットに対するドメイン結果が一致する」ことを基本とします。

## UI の同等性

UI の完全一致を要求しない方針は [`architecture.md`](./architecture.md) を正本とします。
本仕様は、「セマンティクスを共有し、ビジュアル・デザインをプラットフォームに合わせる配置を維持する」ことのみを定めます。

## ネイティブ UX

ネイティブ UX は [`architecture.md`](./architecture.md) / [`ui.md`](./ui.md) を正本とします。
本仕様は、「共有ロジックが、プラットフォームのインタラクション・パターンを上書きしない」ことのみを定めます。

## 共有デザイントークン

デザイントークンは [`design_spec.md`](./design_spec.md) を正本とします。

## Compose Multiplatform (CMP)

CMP による UI 共有は、将来的な選択肢とします。

初期バージョンの UI は、SwiftUI のみです。Android 版の開発に着手したタイミングで、UI は「iOS/iPadOS: SwiftUI」と「Android: Jetpack Compose」に分けます。時期は [`overview.md`](./overview.md) を正本とします。

CMP は、SwiftUI との相互運用も可能で、既存ネイティブ UI から段階的に導入できます。

(参考: [Integration with the SwiftUI framework | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-swiftui-integration.html))

## UI 移行の独立性

Kotlin Multiplatform (KMP) 導入と、Compose Multiplatform (CMP) 導入を、同一プロジェクトとして扱いません。

下記の違いがあります。

* KMP: ロジック共有
* CMP: UI 共有

## Kotlin Multiplatform (KMP) は、Compose を意味しない

Kotlin Multiplatform を採用しても、iOS UI を Compose に変更する必要はありません。初期バージョンの UI は SwiftUI のみです。Android 版の開発に着手したタイミングで、「iOS/iPadOS: SwiftUI」と「Android: Jetpack Compose」に分けます。時期は [`overview.md`](./overview.md)、置き方は [`architecture.md`](./architecture.md) を正本とします。

## 既存 Swift コード

Kotlin Multiplatform (KMP) 移行前の Swift コードを、無理に Kotlin に移植しません。

## 移行候補

Kotlin に移行する候補は [`architecture.md`](./architecture.md) の共有ロジック対象を正本とします。
初期段階で移行しないものは、同仕様のプラットフォーム固有および UI です。

## 共有コンポーネントの方針

既存 Swift パッケージを、Kotlin Multiplatform (KMP) 共有モジュールに移植することは必須ではありません。[S2J About Window](https://github.com/stein2nd/s2j-about-window) / [S2J Source List](https://github.com/stein2nd/s2j-source-list) の扱いは、前述の [既存 S2J コンポーネント](#既存-s2j-コンポーネント) に従います。

## コード再利用の原則

コードの共有自体を目的としません。下記を優先します。

* 正確性
* 保守性
* ネイティブ UX
* テスト容易性
* 長期の移植性

## Kotlin Multiplatform (KMP) の依存関係の方針

共有モジュールでは、KMP 互換の依存関係を優先します。

## プラットフォームの依存関係の方針

プラットフォーム固有の依存関係は、プラットフォーム・ソースセットまたはアダプタに閉じ込めます。

## 依存関係の方向

依存関係の方向と禁止依存は [`architecture.md`](./architecture.md) を正本とします。
Kotlin Multiplatform (KMP) では、プラットフォーム・アダプタが共有インターフェースを実装し、依存関係グラフはエントリー・ポイント (前述の [コンポジション・ルート](#コンポジションルート)) で完成させます。

## テスト境界

共有ロジック・テストは、プラットフォーム UI なしで実行可能とします。

## CI

いつ、どのジョブが走るかは [`cicd.md`](./cicd.md) を正本とします。
本仕様は、「Kotlin Multiplatform (KMP) 化後に、共有ユニットテストと iOS / Android ビルドが必要である」ことだけを定めます。

## CI プラットフォーム

iOS ビルドには、macOS/Xcode が必要です。

Kotlin Multiplatform (KMP) プロジェクトでも、iOS ビルド・ツールチェーンは Xcode を使用します。

(参考: [Create your Compose Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-multiplatform-create-first-app.html))

## ドキュメント

Kotlin Multiplatform (KMP) 移行に伴う方針変更は [`architecture.md`](./architecture.md) に反映します。個別関心事は、各専門仕様を正本とします。
入口は [`specs.md`](./specs.md) とします。

## 仕様の優先順位

アーキテクチャー方針は [`architecture.md`](./architecture.md) を優先します。Kotlin Multiplatform (KMP) 仕様と既存仕様が競合した場合、ドメインのセマンティクスをプラットフォーム実装より優先します。

## プラットフォームの、意味論的な乖離なし

プラットフォーム差によって、同一ドメイン操作の意味を変更しません。

## プラットフォーム固有のプレゼンテーション

プラットフォーム差を許容するプレゼンテーションは [`architecture.md`](./architecture.md) の「プラットフォーム固有」を正本とします。
本仕様は、「それらを `iosMain` / `androidMain` またはアダプタに置く」ことのみを定めます。

## プラットフォーム固有の挙動

バックグラウンド・スケジュール設定/通知/クレデンシャル (資格情報) ストレージ/HTTP スタック/ファイルシステムも [`architecture.md`](./architecture.md) の「プラットフォーム固有」を正本とします。
本仕様は、「ドメインのセマンティクスを変更しない」ことのみを定めます。

## Kotlin Multiplatform (KMP) 境界 概要

境界と共有対象の正本は [`architecture.md`](./architecture.md)、モジュール配置は [アーキテクチャーの概要](#アーキテクチャーの概要) を正本とします。
本仕様は、「共有ロジックとプラットフォーム・アダプタの境界を、その配置に合わせて切る」ことのみを定めます。

## 最終原則

Kotlin Multiplatform (KMP) の目的 (ドメイン/アプリケーション挙動の共有、UI はネイティブ) は [`architecture.md`](./architecture.md) を正本とします。
本仕様は、「その方針をソースセット/アダプタ配置として維持する」ことのみを定めます。
