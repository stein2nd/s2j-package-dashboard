# S2J Package Dashboard - Kotlin Multiplatform 仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、Kotlin Multiplatform の実装境界および共有ロジック Migration を定義します。

Kotlin Multiplatform の仕様変更、iOS/iPadOS/Android 実装、共有ロジックの Migration 進捗、および各アーキテクチャー仕様の変更に応じて更新する。

## 目的

本ドキュメントでは、Kotlin Multiplatform 実施時の実装境界を定義する。対象は source set、expect/actual、モジュール構成、プラットフォーム Integration、段階的な Migration 手順である。

## 非目的

本仕様では下記を必須としない。

* Compose Multiplatform による UI 共有
* SwiftUI の Kotlin 化
* 既存 Swift Package の KMP 化
* Cloud Backend
* Cross-デバイス同期
* 共有 Credential ストレージ
* プラットフォーム API の完全抽象化
* すべての Code の Kotlin 化

## 責務

KMP 化の実施手順、モジュール配置、移行段階を正本とする。本仕様はアーキ方針を上書きしない。

## 非責務

アーキテクチャー方針、共有ロジックの対象と優先順位は [`architecture.md`](./architecture.md) を正本とする。不変条件は [`domain_rules.md`](./domain_rules.md)、ドメイン型 / ApplicationError は [`models_spec.md`](./models_spec.md)、キャッシュ方針は [`cache_spec.md`](./cache_spec.md)、永続化は [`storage_spec.md`](./storage_spec.md)、認証境界は [`authentication_spec.md`](./authentication_spec.md)、状態の分類・復元は [`application_state.md`](./application_state.md)、テスト戦略は [`testing_spec.md`](./testing_spec.md)、CI Job は [`cicd.md`](./cicd.md) を正本とする。

## 基本方針

基本アーキテクチャーは [`architecture.md`](./architecture.md) に従う。本仕様は KMP 化の実施手順に限定する。

## KMP の採用方針

KMP はアプリケーション全体を一度に Kotlin 化するための Migration Tool ではない。共有に移す順序は [`architecture.md`](./architecture.md) を正本とする。本仕様は、初期段階でドメイン/アプリケーション Logic から段階的に共有することだけを定める。

## Native UI Principle

UI を共有しない方針は [`architecture.md`](./architecture.md) を正本とする。本仕様では、その方針をモジュール配置として維持する。([What is Kotlin Multiplatform | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/kmp-overview.html))

## アーキテクチャー Overview

方針の正本は [`architecture.md`](./architecture.md) とする。本仕様のモジュール配置は、`commonMain` にドメイン / アプリケーション / 統計 / キャッシュ Policy / リポジトリ Interfaces / Validation / ユースケースを置き、SwiftUI / Compose とプラットフォーム・アダプタを iOS / Android 側に置く。

## 共有ロジック

共有ロジックとは、「iOS/iPadOS/Android でドメインのセマンティクスおよびアプリケーション挙動を共通化できる Kotlin Code」とする。対象と優先順位は [`architecture.md`](./architecture.md) を正本とする。本仕様では、それらを `commonMain` に載せる。

## 共有ロジックの優先順位

順序の方針は [`architecture.md`](./architecture.md) を正本とする。実施段階は本仕様の Migration Phase とする。

## UI は共有ロジックに含めない

[`architecture.md`](./architecture.md) の原則5に従い、SwiftUI / Jetpack Compose は共有ロジックに含めない。

## ドメイン層

ドメイン層は KMP の最優先の共有対象とする。型は [`models_spec.md`](./models_spec.md)、不変条件は [`domain_rules.md`](./domain_rules.md) を正本とし、可能な限り `commonMain` に移行する。ドメインが UI / ストレージ / HTTP に依存しないことは [`architecture.md`](./architecture.md) の依存関係の方向を正本とする。

## アプリケーション層

ユースケースの一覧と UI 非依存は [`architecture.md`](./architecture.md) を正本とする。KMP ではユースケースを `commonMain` に置き、プラットフォーム UI から直接ドメイン Object を操作しない。

## リポジトリ Interface

リポジトリ Interface は共有ロジックに配置可能とする。

例:

* `PackageRepository`
* `StatisticsRepository`
* `SnapshotRepository`

## リポジトリ Implementation

リポジトリの具体的な実装は、プラットフォームまたは Data 層に配置可能とする。共有 Interface に対して iOS Implementation と Android Implementation を置く。

## Dependency Inversion

共有ロジックは、Interface に依存し、Concrete Implementation に直接依存しない。

## プロバイダ Abstraction

Packagist/GitHub API は、共有ロジックから抽象化する。

* PackagistClient
* GitHubClient

等の Interface を定義可能とする。

## プロバイダ Implementation

プロバイダ Client の実装は、可能な限り KMP 共有ロジックに配置する。

ただし HTTP Stack 等のプラットフォーム固有 Dependency が必要な場合はアダプタを利用する。

## HTTP Abstraction

共有ロジックでは、HTTP Client そのものをドメイン Object として扱わない。

概念:

`HttpClient` Interface を定義し、

* iOS HTTP アダプタ
* Android HTTP アダプタ

から提供する構造を許容する。

## HTTP Implementation

HTTP Implementation には、プラットフォームに応じた Library を利用可能とする。

例:

* iOS: URLSession
* Android: OkHttp

ただし共有ロジックから直接プラットフォーム API に依存しない。

## Serialization

API DTO の Serialization は、KMP Compatible な Library を優先する。

候補: `kotlinx.serialization`

## DTO

プロバイダ Response DTO とドメイン・モデルの分離は [`models_spec.md`](./models_spec.md) を正本とする。KMP では DTO とマッパーを `commonMain` またはプロバイダ層に置く。

## ドメイン・マッパー

プロバイダ固有 Data をドメイン・モデルに変換する責務をマッパーに持たせる。

## エラー・モデル

共有ロジックでは、プラットフォーム固有 Exception をそのままドメイン・エラーとして扱わない。エラー境界の分類は [`architecture.md`](./architecture.md)、型は [`models_spec.md`](./models_spec.md) を正本とする。KMP では同名の共有型として `commonMain` に置く。

## 共有エラー

`ApplicationError` のケースは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、それらを `commonMain` の共有型として置くことだけを定める。

## プラットフォーム・エラー Mapping

プラットフォーム固有エラーは共有エラーへ Mapping する。

## ドメイン・エラー

ドメイン・エラー (`InvalidPackageIdentifier` / `InvalidMetric` / `InvalidSnapshot` / `InvalidStateTransition` 等) の意味は [`domain_rules.md`](./domain_rules.md) を正本とする。KMP では同名の共有型として `commonMain` に置く。

## Credential 境界

認証方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。KMP では Credential を `commonMain` のドメイン・モデルに含めない。

## Credential ストレージ

Credential ストレージの実装はプラットフォーム固有とする。共有ロジックには、Credential を取得するための抽象 Interface のみを置く。

## Authentication 境界

概念: 共有ロジックは `CredentialProvider` Interface のみを知り、iOS / Android Credential Storage がその Interface を実装する。Keychain / Keystore の HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。

## Credential Non-persistence

Credential を通常ストレージへ置かない方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。共有ロジックは Credential をキャッシュ/スナップショット/ドメイン・ストレージに保存しない。

## キャッシュ Policy の配置

キャッシュ方針は [`cache_spec.md`](./cache_spec.md)、不変条件は [`domain_rules.md`](./domain_rules.md)、永続化は [`storage_spec.md`](./storage_spec.md) を正本とする。KMP では Policy / セマンティクスを共有ロジックへ移行し、本仕様では語彙を再定義しない。キャッシュ・ストレージおよびスナップショット・ストレージの Technology はプラットフォーム固有でもよい。キャッシュと Historical スナップショットの分離は KMP 化後も維持する。

## キャッシュ Implementation

キャッシュ・ストレージ自体はプラットフォーム固有でもよい。共有は `CacheRepository`、実装は iOS/Android のキャッシュ・ストレージとする。

## ストレージ Abstraction

Persistent ストレージについては、必要に応じて共有リポジトリ Interface を定義する。

## ストレージ Implementation

ストレージ Implementation はプラットフォーム/Library に応じて選択可能とする。

候補:

* SQLDelight
* SQLite
* Room
* SwiftData

ただし共有ドメインはストレージ Technology を直接参照しない。

## SwiftData

現在の iOS 実装で SwiftData を利用する場合も、ドメイン・モデルを SwiftData モデルに直接結合しないことを基本とする。

## SQLDelight

将来的に KMP 共有ストレージが必要になった場合、SQLDelight 等の KMP-compatible ストレージを検討可能とする。

## UI 状態

UI 状態の分類は [`application_state.md`](./application_state.md) を正本とする。本仕様は、View 状態をプラットフォーム UI 側で管理することだけを定める。

## 共有 UI 状態

同一セマンティクスが必要な Application 状態は共有ロジックで提供可能とする。何を保持するかは [`application_state.md`](./application_state.md) を正本とする。

## UI モデル

共有ドメイン・モデルをそのまま UI に公開することを必須としない。必要に応じてドメイン・モデルを Presentation Model に変換する。

## SwiftUI Integration

iOS/iPadOS では、SwiftUI が KMP 共有ロジックを利用する。経路は SwiftUI → Swift アダプタ/ViewModel → KMP フレームワーク → 共有ユースケース。

## Android Integration

Android では、Jetpack Compose が KMP 共有ロジックを利用する。経路は Compose → Android ViewModel/アダプタ → 共有ユースケース。

## iOS フレームワーク

KMP 共有 モジュールは、iOS アプリケーションから利用可能なフレームワークとして提供する。

KMP では共有モジュールを iOS フレームワークとして生成し、Xcode Project から利用する構成が公式にサポートされている。([Choosing a configuration for your Kotlin Multiplatform project | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-project-configuration.html))

## Android Library

Android アプリケーションは、KMP 共有モジュールを Android Library として利用する。

## Build System

KMP 共有モジュールの Build には Gradle を利用する。

Kotlin 公式の KMP 構成でも、共有モジュールは Gradle で管理され、iOS アプリケーション側は Xcode Project として構成できる。([Create your Kotlin Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-create-first-app.html))

## Xcode Project

iOS/iPadOS アプリケーションでは、Xcode Project (`iosApp/*.xcodeproj`) を引き続き使用する。

または将来的に、`*.xcworkspace` 等を利用可能とする。

## Swift Package

KMP Migration 後も、既存の Swift Package をすべて即時廃止する必要はない。

## Existing S2J コンポーネント

既存の、

* [S2J About Window](https://github.com/stein2nd/s2j-about-window)
* [S2J Source List](https://github.com/stein2nd/s2j-source-list)

等については、SwiftUI コンポーネントとして iOS/iPadOS UI 層で利用可能とする。

## S2J About Window

[S2J About Window](https://github.com/stein2nd/s2j-about-window) は、基本的に UI コンポーネントとして扱う。そのため、SwiftUI 側に置く構成を維持可能とする。

## S2J Source List

[S2J Source List](https://github.com/stein2nd/s2j-source-list) についても、UI/Presentation コンポーネントとして SwiftUI 側に配置可能とする。

## 共有ロジック and Existing コンポーネント

既存 S2J コンポーネントを KMP 化する必要はない。

KMP 化の対象は、プラットフォーム横断型で意味を共有するドメイン/アプリケーション Logic を優先する。

## UI コンポーネント境界

下記は Native UI として維持可能とする。

* About Window
* Source List
* ナビゲーション
* Toolbar
* Charts
* Sheet
* Alert
* Settings

## 統計計算

統計計算は共有ロジックの有力な対象とする。指標の意味と Formula は [`statistics_spec.md`](./statistics_spec.md) を正本とし、KMP ではその計算を `commonMain` に移行可能とする。

## Chart Rendering

Chart Rendering そのものは共有ロジックに含めない。

* Shared: 統計計算
* iOS: SwiftUI Chart
* Android: Compose Chart

## Time

共有ロジックでは、プラットフォーム固有 Date API への直接依存を避ける。

ドメイン上では、

* Instant
* Clock

等の抽象概念を利用する。

## Timezone

ドメイン Logic は Display Timezone に依存しない。

## Locale

共有ロジックは UI Locale/Language に依存しない。

## Formatting

日付/数値の視覚書式は [`design_spec.md`](./design_spec.md) を正本とする。KMP では Formatting を共有ドメインに置かず、プラットフォーム UI 側で行う。

## ローカライズ

Localized String そのものをドメイン Logic に埋め込まない。

## Concurrency

共有ロジックでは、プラットフォーム固有 スレッド API への直接依存を避ける。

## Coroutines

非同期処理には、KMP-compatible な Coroutine 設計を利用可能とする。

## Main スレッド

UI スレッド/Main スレッドへの切替は、プラットフォーム UI 層で責務を持つことを基本とする。

## フロー

共有状態 Stream には、Kotlin フロー等を利用可能とする。

ただし iOS 側の Swift API との Interoperability を考慮する。

## Swift Interoperability

共有 Kotlin API は、Swift から利用しやすい Public API として設計する。

## Swift-friendly API

Swift 側で過度に Kotlin 固有概念を意識しなくて済む API を優先する。

## Public API

KMP 共有 モジュールの Public API は、アプリケーション内部の Implementation Detail を公開しない。

## Kotlin Naming

Kotlin 側では Kotlin Coding Convention に従う。

Swift からの利用時に自然になるよう、Public API を設計する。

## Data Types

共有 Public API では、プラットフォーム固有 Data Type を可能な限り避ける。

例:

* UIColor
* Color
* UIView
* UIImage
* Context
* アクティビティ

等を共有モデルに含めない。

## Image

Package Icon 等の Image Data については、共有ロジックでは URL/Identifier 等のプラットフォーム-neutral Representation を優先する。

## URL

URL を共有モデルに持たせる場合も、プラットフォーム固有 URL Object ではなく Serializable Representation を検討する。

## UUID

UUID はプラットフォーム固有 Object に依存しない。

必要に応じて String 等のプラットフォーム-neutral Representation を使用する。

## JSON

JSON スキーマはプロバイダ API 層で扱い、ドメイン・モデルに JSON 構造を漏らさない。

## API バージョン

プロバイダ API バージョンは、ドメイン・モデル・バージョンと分離する。

## Testing

KMP 共有ロジックには Common テストを配置する。`commonTest` でドメイン/アプリケーション Logic を検証する。何を、どのレベルでテストするかは [`testing_spec.md`](./testing_spec.md) を正本とする。

KMP では Source Set ごとにテストを持たせる構成が可能であり、`commonTest` は共有ロジックの共通テストに適する。([The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html))

## プラットフォーム・テスト

プラットフォーム固有 Functionality は `iosTest` / `androidTest` 等で検証する。UI テストは XCTest/XCUITest または Compose UI テスト等のプラットフォーム固有テストとする。

## Deterministic テスト

共有ロジックは固定 Clock/Fixed インプットを利用して Deterministic テスト可能とする。

## プラットフォーム固有 Code

プラットフォーム固有として許容するものは [`architecture.md`](./architecture.md) の「プラットフォーム固有」を正本とする。KMP ではそれらを `iosMain` / `androidMain` またはアダプタに置く。

## expect/actual

プラットフォーム固有 API が必要な場合、`expect`/`actual` の利用を検討する。

KMP では Common Code に期待する Declaration を置き、プラットフォーム Source Set で `actual` 実装を提供できる。([Create your Kotlin Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-create-first-app.html))

## Interface First

ただし Complex なプラットフォーム Dependency では、単純な `expect`/`actual` より Interface + プラットフォーム Implementation を優先する。

## Dependency Injection

プラットフォーム Implementation は、Dependency Injection によって共有ロジックに提供可能とする。

概念:

* Shared: interface CredentialStore
* iOS: KeychainCredentialStore
* Android: KeystoreCredentialStore

## Composition Root

プラットフォーム アプリケーション Entry Point で Dependency を組み立てる。

* iOS: App.swift
* Android: アプリケーション/アクティビティ

## iOS Entry Point

概念:

```text
@main
struct S2JPackageDashboardApp: App {
    ...
}
```

から共有アプリケーション Logic に Dependency を渡す。

## Android Entry Point

Android アプリケーション Entry Point から共有ロジックに Dependency を渡す。

## 共有モジュール Structure

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

KMP では `commonMain` に共有 Code、`androidMain`/`iosMain` にプラットフォーム固有 Code を配置する構造が基本となる。([Create your Kotlin Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-create-first-app.html))

## アプリケーション Structure

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

## 共有ドメイン Structure

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

## プラットフォーム Structure

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

## Common Source Set

`commonMain` には、全プラットフォームで共通化可能な Code のみを配置する。

## プラットフォーム Source Set

`iosMain`/`androidMain` には、そのプラットフォームでしか成立しない Code を配置する。

## No プラットフォーム Leakage

`commonMain` から、

* UIKit
* Android SDK
* SwiftUI
* Compose

等を参照しない。

## Intermediate Source Set

将来的に複数 Apple Target 等を追加する場合、必要に応じて Intermediate Source Set を利用する。

KMP では `appleMain` 等の Hierarchical Source Set を利用して Apple 系 Target 間で Code を共有できる。([The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html))

## iOS デバイス/シミュレーター

iOS では、

* `iosArm64`
* `iosSimulatorArm64`

等の Target を考慮する。

通常、デバイスと Apple Silicon シミュレーターで同じ iOS 固有 Logic を利用できるため、`iosMain` への集約を基本とする。([The basics of Kotlin Multiplatform project structure | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html))

## Android Target

初期バージョンでは Android を主要共有 Target の一つとする。

## Target Independence

ドメイン Logic は、

* `iosArm64`
* `iosSimulatorArm64`
* `android`

の Target 差を意識しない。

## Build Configuration

Debug/Release 等の Build Configuration はプラットフォーム側で管理する。

共有ロジックに UI Build Configuration を持ち込まない。

## Configuration

Environment Configuration は共有ロジックに直接 Hard-code しない。

## API エンドポイント

Production/Development 等のエンドポイントは、Configuration として注入する。

## Secrets

API Secret/Token を Source Code に Hard-code しない。

## Logging

共有ロジックでは、プラットフォーム-neutral Logging Interface を利用可能とする。

## プラットフォーム Logging

* iOS: `OSLog`
* Android: `Logcat`

等のプラットフォーム Logging にアダプタ経由で接続可能とする。

## Analytics

Analytics SDK は共有ドメインに直接導入しない。

必要な場合は Interface を利用する。

## Notifications

Local/Push Notification はプラットフォーム固有 Functionality とする。

## Background Processing

Background Task はプラットフォーム固有 Functionality とする。

共有ロジックでは、スナップショット Collection ユースケース等を提供し、実行 Scheduler はプラットフォーム側が担当する。

## iOS Background

iOS Background Execution は、iOS 側の Scheduling/Background API から共有ユースケースを呼び出す。

## Android Background

Android Background Execution は、Android 側の Scheduling API から共有ユースケースを呼び出す。

## 同期

Cross-デバイス同期は、初期バージョンでは必須としない。

## Cloud Backend

KMP 導入自体を理由として、Cloud Backend を追加しない。

## External Backend

External Backend が必要になった場合、別アーキテクチャーとして検討する。

## 共有ロジック・リポジトリ

初期バージョンでは、共有ロジックをアプリケーション・リポジトリ内に置く。

## Separate KMP リポジトリ

共有ロジックが複数アプリケーションで再利用される場合、独立リポジトリ化を検討する。

## Versioning

共有ロジックには、必要に応じて独立バージョンを付与する。

## バージョン Compatibility

iOS アプリケーション/Android アプリケーションと共有ロジック版の Compatibility を管理する。

## API Compatibility

共有 モジュールの Public API 変更は、Breaking Change として扱う。

## Migration Strategy

KMP Migration は Big Bang Migration を避ける。

## Migration Phase: 0

現在の Swift アーキテクチャーを整理する。Swift 側でドメイン / アプリケーション / Data / UI を分離し、プラットフォーム Dependency を明確にする。層の意味は [`architecture.md`](./architecture.md) を正本とする。本節は、Phase-0でその分離を Swift 実装に反映することだけを定める。

## Migration Phase: 1

ドメイン・モデルを Kotlin に移行する。

対象:

* Package
* リポジトリ
* Metric
* スナップショット

## Migration Phase: 2

ドメイン Rule を Kotlin に移行する。

## Migration Phase: 3

統計計算を Kotlin に移行する。

## Migration Phase: 4

ユースケースを Kotlin に移行する。

## Migration Phase: 5

リポジトリ Interface を Kotlin に移行する。

## Migration Phase: 6

キャッシュ Policy を Kotlin に移行する。

## Migration Phase: 7

必要に応じてプロバイダ Client を KMP 化する。

## Migration Phase: 8

プラットフォーム固有アダプタを整理する。

## Migration Phase: 9

Swift 側の重複 Logic を削除する。

## Migration Phase: 10

Android アプリケーションを共有ロジックに接続する。

## Migration Success Criteria

Migration 成功の基準: iOS/iPadOS/Android が同じドメイン Rule、同じ統計 Result、同じキャッシュのセマンティクスを共有すること。ルールの正本は [`domain_rules.md`](./domain_rules.md) / [`statistics_spec.md`](./statistics_spec.md) / [`cache_spec.md`](./cache_spec.md) とする。本節は、KMP 化後もその一致を維持することだけを定める。

## Behavioral Parity

iOS/iPadOS/Android で、同じインプットに対するドメイン Result が一致することを基本とする。

## UI Parity

UI の完全一致を要求しない方針は [`architecture.md`](./architecture.md) を正本とする。本仕様は、セマンティクスを共有し Visual Design をプラットフォームに合わせる配置を維持することだけを定める。

## Native UX

Native UX は [`architecture.md`](./architecture.md) / [`ui.md`](./ui.md) を正本とする。本仕様は、共有ロジックがプラットフォーム Interaction Pattern を上書きしないことだけを定める。

## 共有 Design Tokens

Design Token は [`design_spec.md`](./design_spec.md) を正本とする。

## Compose Multiplatform

Compose Multiplatform による UI 共有は将来的な選択肢とする。

初期バージョンでは Native SwiftUI/Jetpack Compose を優先する。

Compose Multiplatform は SwiftUI との相互運用も可能で、既存 Native UI から段階的に導入できる。([Integration with the SwiftUI framework | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-swiftui-integration.html))

## UI Migration Independence

KMP 導入と Compose Multiplatform 導入を同一 Project として扱わない。

* KMP: Logic Sharing
* Compose Multiplatform: UI Sharing

とする。

## KMP does not imply Compose

Kotlin Multiplatform を採用しても、iOS UI を Compose に変更する必要はない。SwiftUI / Jetpack Compose を First-class とする方針は [`architecture.md`](./architecture.md) を正本とする。

## Existing Swift Code

KMP Migration 前の Swift Code を無理に Kotlin に移植しない。

## Migration Candidate

Kotlin に移行する Candidate は [`architecture.md`](./architecture.md) の共有ロジック対象を正本とする。初期段階で移行しないものは、同仕様のプラットフォーム固有および UI である。

## 共有コンポーネント Policy

既存 Swift Package を KMP 共有モジュールに移植することは必須ではない。S2J About Window / Source List の扱いは前述の Existing S2J コンポーネントに従う。

## Code Reuse Principle

Code を共有すること自体を目的としない。

下記を優先する。

* Correctness
* Maintainability
* Native UX
* Testability
* Long-term Portability

## KMP Dependency Policy

共有モジュールでは、KMP-compatible Dependency を優先する。

## プラットフォーム Dependency Policy

プラットフォーム固有 Dependency は、プラットフォーム Source Set またはアダプタに閉じ込める。

## Dependency Direction

依存関係の方向と禁止依存は [`architecture.md`](./architecture.md) を正本とする。KMP では、プラットフォーム・アダプタが共有 Interface を実装し、Dependency Graph は Entry Point (前述の Composition Root) で完成させる。

## Testing 境界

共有ロジック・テストはプラットフォーム UI なしで実行可能とする。

## CI

いつどの Job が走るかは [`cicd.md`](./cicd.md) を正本とする。本仕様は、KMP 化後に共有 Unit テストと iOS / Android Build が必要なことだけを定める。

## CI プラットフォーム

iOS Build には macOS/Xcode が必要である。

KMP Project でも iOS Build Toolchain は Xcode を使用する。([Create your Compose Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-multiplatform-create-first-app.html))

## Documentation

KMP Migration に伴う方針変更は [`architecture.md`](./architecture.md) に反映する。個別関心事は各専門仕様を正本とする。入口は [`specs.md`](./specs.md) とする。

## 仕様 Priority

アーキテクチャー方針は [`architecture.md`](./architecture.md) を優先する。KMP 仕様と既存仕様が競合した場合、ドメインのセマンティクスをプラットフォーム Implementation より優先する。

## No プラットフォーム Semantic Divergence

プラットフォーム差によって、同一ドメイン Operation の意味を変更しない。

## プラットフォーム固有 Presentation

プラットフォーム差を許容する Presentation は [`architecture.md`](./architecture.md) の「プラットフォーム固有」を正本とする。本仕様は、それらを `iosMain` / `androidMain` またはアダプタに置くことだけを定める。

## プラットフォーム固有挙動

Background Scheduling / Notification / Credential ストレージ / HTTP Stack / File System も同節を正本とする。本仕様は、ドメインのセマンティクスを変更しないことだけを定める。

## KMP 境界 Summary

境界と共有対象の正本は [`architecture.md`](./architecture.md)、モジュール配置は `## アーキテクチャー Overview` を正本とする。本仕様は、共有ロジックとプラットフォーム・アダプタの境界をその配置に合わせて切ることだけを定める。

## 最終原則

KMP の目的 (ドメイン/アプリケーション挙動の共有、UI は Native) は [`architecture.md`](./architecture.md) を正本とする。本仕様は、その方針を source set / アダプタ配置として維持することだけを定める。
