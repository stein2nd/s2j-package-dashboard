# S2J Package Dashboard - コンポーネント仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、コンポーネント・アーキテクチャーを定義します。

UI/UX 仕様、Kotlin Multiplatform 構成、ドメイン・モデル、統計、ストレージ、キャッシュ、Authentication およびプラットフォーム Integration の設計進展に応じて更新する。

## 目的

本ドキュメントでは、UI / Presentation / ドメイン / プラットフォーム・コンポーネントの分類、責務、依存関係および再利用方針を定義する。

目的は、責務を分離し、Native UX を維持しながら、共通 Logic を KMP に移行可能なコンポーネント構造を実現することである。

## 非目的

本仕様では下記を必須としない。

* 全 UI コンポーネントの KMP 化
* Compose Multiplatform による UI 共有
* 全コンポーネントの独立 Package 化
* UI コンポーネントからの API 直接呼び出し
* UI コンポーネントによる Persistent ストレージ管理
* UI コンポーネントによる Credential 管理
* コンポーネント単位での独立 Versioning
* コンポーネント単位での外部公開

## 責務

コンポーネント境界、依存方向、再利用可能な UI/Presentation 単位を定義する。

## 非責務

画面構成は [`screen_spec.md`](./screen_spec.md)、ナビゲーションは [`navigation_spec.md`](./navigation_spec.md)、横断 UI は [`ui.md`](./ui.md)、視覚 Token は [`design_spec.md`](./design_spec.md)、Viewport は [`ui-viewport.md`](./ui-viewport.md)、層と I/O 境界は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md)、ファイル名簿は [`specs.md`](./specs.md) を正本とする。

## コンポーネントの定義

コンポーネントとは、「アプリケーションを構成する責務が明確な、独立した再利用可能な Software Unit」と定義する。

コンポーネントには下記を含む。

* ドメイン・コンポーネント
* アプリケーション・コンポーネント
* Presentation コンポーネント
* UI コンポーネント
* プラットフォーム・コンポーネント
* Infrastructure コンポーネント

## コンポーネントの基本原則

コンポーネントは下記を原則とする。

1. Single 責務を維持する
2. 明確な Public Interface を持つ
3. 不要なプラットフォーム Dependency を持たない
4. UI コンポーネントとドメイン Logic を混在させない
5. KMP 共有ロジックへの移行可能性を考慮する
6. プラットフォーム固有コンポーネントを無理に共有しない
7. コンポーネント間の依存方向を一方向にする
8. Circular Dependency を禁止する
9. UI コンポーネントは Native UX を尊重する
10. コンポーネント単位でテスト可能とする

## コンポーネント Classification

コンポーネントを下記の層に分類する。

* ドメイン
* アプリケーション
* Presentation
* UI
* プラットフォーム
* Infrastructure

## 層 Overview

論理層は [`architecture.md`](./architecture.md) を正本とする。本仕様は、コンポーネントを `## コンポーネント Classification` の層に割り当てることだけを定める。

## Dependency Direction

層の依存方向は [`architecture.md`](./architecture.md) を正本とする。本仕様は、UI → Presentation → アプリケーション → ドメイン とし、Infrastructure は Interface 経由とすることだけを定める。

## Dependency Rule

下記を禁止する。

* ドメイン → UI
* ドメイン → Presentation
* ドメイン → SwiftUI
* ドメイン → Compose

## プラットフォーム Dependency

Keychain / Keystore の HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、OS API (HTTP / Background / Notification / File System 含む) をプラットフォーム固有コンポーネントとして扱うことだけを定める。

## KMP 境界

共有対象の優先順位は [`architecture.md`](./architecture.md)、HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、コンポーネント分類上ドメイン / アプリケーション / リポジトリ Interface を共有候補とすることだけを定める。

## Native コンポーネント

Native UI は [`architecture.md`](./architecture.md) を正本とする。本仕様は、SwiftUI / Compose の View / ナビゲーション / Toolbar / Sheet / Alert / Window / プラットフォーム Settings を Native コンポーネントとして扱うことだけを定める。

## コンポーネント Sharing Principle

コンポーネントは、「共有可能であること」よりも、「責務が明確であること」を優先する。

## UI コンポーネント Sharing

iOS/iPadOS/Android で UI を共有することを必須としない。

## Logic コンポーネント Sharing

ドメイン/アプリケーション・ロジックは、可能な限り KMP 共有ロジックとして共有可能な構造にする。

## コンポーネント所有権

各コンポーネントには、明確な Owner 層を持たせる。

例:

* `PackageCard`: 
    * Owner: UI
* `PackageViewModel`: 
    * Owner: Presentation
* `RefreshPackage`: 
    * Owner: アプリケーション
* `Package`: 
    * Owner: ドメイン

## ドメイン・コンポーネント

ドメイン・コンポーネントは、Business Rule およびドメイン状態を表現する。

## ドメイン・モデル・コンポーネント

初期バージョンでは下記を想定する。

* `Package`
* `Repository`
* `Metric`
* `Statistic`
* `Snapshot`
* `Favorite`
* `MaintainedPackage`

## Value Object

必要に応じて Value Object を定義する。

例:

* `PackageIdentifier`
* `RepositoryIdentifier`
* `MetricType`
* `ProviderIdentifier`

## ドメイン・コンポーネント Rules

ドメイン・コンポーネントは下記に依存しない。

* SwiftUI
* Compose
* UIKit
* Android SDK
* Network
* File System

## アプリケーション・コンポーネント

アプリケーション・コンポーネントは、ドメイン・コンポーネントを組み合わせて User インテントを実行する。

## ユースケース・コンポーネント

代表的なユースケース:

* `LoadDashboard`
* `RefreshPackage`
* `AddFavorite`
* `RemoveFavorite`
* `DiscoverMaintainedPackages`
* `LoadPackageStatistics`
* `CaptureSnapshot`

## ユースケースの責務

ユースケースは、User インテントをアプリケーション Operation に落とし、ドメイン Operation を調整する。

## ユースケース Independence

ユースケースは、具体的な UI コンポーネントを知らない。

## Presentation コンポーネント

Presentation コンポーネントは、ドメイン/アプリケーション Data を UI が扱いやすい状態に変換する。

## Presentation モデル

Presentation コンポーネントがドメイン・モデルを Presentation モデルへ変換し、UI は Presentation モデルだけを扱う。層の向きは [`architecture.md`](./architecture.md) を正本とする。

## Presentation モデル Example

例:

`PackageSummaryViewState` が、

* `name`
* `version`
* `downloads`
* `stars`
* `isFavorite`
* `isMaintained`
* `lastUpdated`

等を保持する。

## ViewModel

ViewModel の層責務は [`architecture.md`](./architecture.md) を正本とする。本仕様は、ViewModel を Presentation コンポーネントとして扱うことだけを定める。

## ViewModel 責務

UI 状態の保持とユースケース呼び出しに限定する。詳細は [`architecture.md`](./architecture.md) を正本とする。

## ViewModel Non-goal

API URL / SQL / ドメイン Formula を ViewModel に置かないことは [`architecture.md`](./architecture.md) を正本とする。

## UI コンポーネント

UI コンポーネントは、Visual Representation と User Interaction を担当する。

## UI コンポーネント Example

代表的なコンポーネント:

* `DashboardView`
* `PackageListView`
* `PackageDetailView`
* `StatisticsView`
* `SettingsView`
* `FavoritePackageRow`
* `PackageCard`
* `MetricCard`
* `StatisticsChart`

## UI コンポーネント責務

UI コンポーネントは、渡された状態を Visual Representation にし、User Interaction を返す。

## UI コンポーネント Independence

UI コンポーネントは、プロバイダ API に直接アクセスしない。I/O の置き場所は [`architecture.md`](./architecture.md) を正本とする。

## UI コンポーネント Data Source

UI コンポーネントの Data Source は、基本的に Presentation 層とする。

## UI イベント

User Interaction は、Action として Presentation 層に通知する。

例:

* `onRefresh`
* `onFavorite`
* `onPackageSelected`
* `onRetry`

## コンポーネントイベント

コンポーネント間 Communication には、Callback/イベント/状態等を利用する。

## コンポーネント状態

UI コンポーネントは、必要最小限の Local 状態のみを保持する。

## 状態の所有権

状態の分類と SSoT は [`application_state.md`](./application_state.md) を正本とする。本仕様は、Global → アプリケーション / Presentation、画面 → ViewModel、Local UI → コンポーネントとすることだけを定める。

## 状態 Duplication

同一状態を複数コンポーネントで独立管理しない。SSoT は [`application_state.md`](./application_state.md) を正本とする。

## 「信頼できる唯一の情報源」(SSoT)

`## 状態の所有権` を正本とする。

## Loading 状態

Loading / Refreshing / エラー / Empty / Stale の横断ルールは [`ui.md`](./ui.md) を正本とする。本仕様は、UI コンポーネントが Presentation 層から渡された状態を表現できることだけを定める。

## Stale 状態

Stale の意味は [`cache_spec.md`](./cache_spec.md)、表示は [`ui.md`](./ui.md) を正本とする。

## Refreshing 状態

既存 Data を消さない Refresh 表示は [`ui.md`](./ui.md) を正本とする。

## エラー状態

エラー UI の横断ルールは [`ui.md`](./ui.md) を正本とする。本仕様は、エラーを User Action に変換可能な形で Presentation 層から渡すことだけを定める。

## Empty 状態

Empty とエラーの区別は [`ui.md`](./ui.md) を正本とする。

## Partial Data

欠測と0の区別は [`domain_rules.md`](./domain_rules.md)、表示は [`ui.md`](./ui.md) を正本とする。本仕様は、Partial Data を受け取って表示できることだけを定める。

## Package コンポーネント

Package を UI で表示する場合、Package コンポーネントを利用可能とする。

## Package Row

Package List に出す項目は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、再利用可能な Package Row コンポーネントを用意し得ることだけを定める。

## Package Card

Package Card は、Dashboard 等で Package Summary を表示する再利用コンポーネントとする。画面上の置き場所は [`screen_spec.md`](./screen_spec.md) を正本とする。

## Package Detail

Package Detail の表示内容は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、Detail 用コンポーネントが Presentation 層から渡された内容を表示することだけを定める。

## Maintained Package

Maintained / Favorite の意味と独立性は [`domain_rules.md`](./domain_rules.md)、型は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、UI コンポーネントが両状態を混同して表示しないことだけを定める。

## Dashboard コンポーネント

Dashboard の画面構成は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、Dashboard が複数の Feature コンポーネントを組み合わせる Container であることだけを定める。

## Dashboard Container

Dashboard Container は、スクリーン-level コンポーネントとして扱う。

## Container/Presentational

可能な限り、Container と Presentational コンポーネントの責務を分離する。

## Presentational コンポーネント

Presentational コンポーネントは、ドメイン Logic を持たない。

## Container コンポーネント

Container コンポーネントは、ViewModel/アプリケーション状態を UI コンポーネントに渡す。

## 統計コンポーネント

統計コンポーネントは、Metric を Visualize する。

## Metric Card

Metric Card は、単一 Metric の Summary を表示する再利用コンポーネントとする。指標の意味は [`statistics_spec.md`](./statistics_spec.md)、画面上の置き場所は [`screen_spec.md`](./screen_spec.md) を正本とする。

## 統計 Chart

統計 Chart は、Historical Data を可視化する。

## Chart Data

Chart Data は Presentation 層から提供する。派生の算出を UI で行わないことは [`architecture.md`](./architecture.md) / [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## Chart のセマンティクス

指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、Chart コンポーネントが Formula を持たないことだけを定める。

## Chart Rendering

Native UI は [`architecture.md`](./architecture.md) を正本とする。本仕様は、統計 Data を共有し、描画を SwiftUI Chart / Compose Chart に委譲することだけを定める。

## Chart Accessibility

Textual Summary は [`ui.md`](./ui.md) を正本とする。本仕様は、Chart コンポーネントが画像扱いにせず Accessibility Representation を出せることだけを定める。

## Accessibility

Label / Value / Hint / Role は [`ui.md`](./ui.md) を正本とする。本仕様は、UI コンポーネントがそれらを受け取って提供できることだけを定める。

## Dynamic Type

Dynamic Type / Font Scaling は [`ui.md`](./ui.md) を正本とする。本仕様は、コンポーネントが固定 Font Size 前提にならないことだけを定める。

## Font Scaling

`## Dynamic Type` を正本とする。

## 操作領域

最小サイズは [`ui.md`](./ui.md)、到達可能性は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## ポインタ (カーソル) Interaction

ポインタ / キーボードの横断ルールは [`ui.md`](./ui.md) を正本とする。本仕様は、コンポーネントが Touch 専用前提にならないことだけを定める。

## キーボード Interaction

`## ポインタ (カーソル) Interaction` を正本とする。

## Landscape

横向きを第一級の Layout 状態として扱う。向き変更時の Layout / 到達可能性は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Viewport

到達可能性、スクロール到達、水平オーバーフロー、セーフエリア、Size Class は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様はコンポーネント境界だけを定義する。

iPhone / iPad / Android Tablet の画面構成は [`screen_spec.md`](./screen_spec.md)、ナビゲーション構造は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## Insets

コンポーネントが独自に固定 Inset を Hard-code しすぎない。

## Responsive コンポーネント

コンポーネントは、特定デバイスの Pixel Size に過度に依存しない。

## コンポーネント Size

コンポーネントの Size は、可能な限り Content/Constraint から決定する。

## Fixed Width

Fixed Width は、必要性が明確な場合のみ使用する。

## ナビゲーション コンポーネント

行き先と戻り方は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、ナビゲーション UI がプラットフォーム固有コンポーネントであることだけを定める。

* iOS/iPadOS: SwiftUI ナビゲーション Pattern
* Android: Jetpack Compose ナビゲーション等の Native Pattern

Visual Representation はプラットフォーム固有でよい。

## Modal コンポーネント

Modal / Sheet / Dialog の行き先は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、これらがプラットフォーム Native UX の UI コンポーネントであることだけを定める。

## Destructive Action

確認 UI の横断ルールは [`ui.md`](./ui.md) を正本とする。本仕様は、Destructive Action 用コンポーネントを Confirmation なしで完了させないことだけを定める。

## Feedback コンポーネント

Loading / エラー / オフライン / Stale / Refresh の表示は [`ui.md`](./ui.md) を正本とする。本仕様は、それらの状態を受け取る Feedback コンポーネントを用意し得ることだけを定める。

## キャッシュ・コンポーネント

キャッシュそのものを UI コンポーネントとして扱わない。

キャッシュは Infrastructure/アプリケーション Concern である。

## Authentication コンポーネント

Authentication UI の横断ルールは [`ui.md`](./ui.md)、方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、Authentication UI がプラットフォーム固有コンポーネントであること、Credential を UI 状態に保持しないことだけを定める。

## Settings コンポーネント

Settings の画面構成は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、Settings コンポーネントが User Preference を編集することだけを定める。

## Settings 責務

Settings コンポーネントは、ドメイン Rule を直接変更しない。ドメイン Rule は [`domain_rules.md`](./domain_rules.md) を正本とする。

## Existing S2J コンポーネント

既存 S2J コンポーネントを KMP 共有ロジックに移植する必要はない。

## About コンポーネント

About 画面は、既存の [S2J About Window](https://github.com/stein2nd/s2j-about-window) を利用可能とする。

### S2J About Window

[S2J About Window](https://github.com/stein2nd/s2j-about-window) は、iOS/iPadOS の Native UI コンポーネントとして扱う。

KMP 共有ロジックへの移植を必須としない。

## Source List コンポーネント

[S2J Source List](https://github.com/stein2nd/s2j-source-list) は、Package/リポジトリ/Favorite 等のナビゲーション UI コンポーネントとして利用可能とする。

### S2J Source List

[S2J Source List](https://github.com/stein2nd/s2j-source-list) は、iOS/iPadOS Native UI コンポーネントとして扱う。

## コンポーネント Package Structure

モジュール配置は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、UI 側 `Components/` の責務分割だけを定める。

### SwiftUI コンポーネント

`Components/` は Package / Statistics / Common / Navigation / Feedback に分ける。

### Android コンポーネント

Android 側も `ui/` / `screens/` / `components/` / `viewmodel/` に分ける。

## 共有ロジック・コンポーネント

共有モジュールの source set 配置は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、ドメイン / アプリケーション / 統計 / キャッシュ / リポジトリをコンポーネント分類上の共有候補とすることだけを定める。

## コンポーネント Naming

コンポーネント名は、責務を表す名前とする。

良い例:

* `PackageRow`
* `StatisticsChart`
* `PackageDetailView`
* `RefreshPackage`

### Generic Naming

下記のような過度に Generic な名前を避ける。

* Manager
* Helper
* Util
* Common
* Data
* Thing

### View Naming

SwiftUI では、View コンポーネントには原則として `...View` を利用する。

### Compose Naming

Compose では、Composable Function 名を UI の意味に合わせる。

### ViewModel Naming

`...ViewModel` を基本とする。

### ユースケース Naming

ユースケースは `Verb + Object` を基本とする。

例:

* `RefreshPackage`
* `AddFavorite`
* `CaptureSnapshot`

## コンポーネント Interface

コンポーネントの Interface は必要最小限とする。

## コンポーネント・インプット

UI コンポーネントには、必要な Data のみを渡す。

## コンポーネント・アウトプット

UI コンポーネントは、User Action を Callback/イベントとして返す。

## コンポーネント Coupling

コンポーネント間の直接 Dependency を最小化する。

## Parent-child Dependency

Parent コンポーネントが Child コンポーネントを組み立てる。

Child コンポーネントが Parent コンポーネントに直接依存しない。

## コンポーネント Composition

複雑なスクリーンは、小さな Feature コンポーネントに分解する。画面の構成例は [`screen_spec.md`](./screen_spec.md) を正本とする。

## コンポーネント Size

コンポーネントが巨大化した場合、責務ごとに分割する。

## コンポーネント Granularity

コンポーネントを細かく分割しすぎない。

再利用性だけを理由に意味のないコンポーネントを作らない。

## Reusability

コンポーネントの再利用性は、Semantic Reuse を優先する。

## Copy & Paste

単純な UI Fragment を過剰に共通コンポーネント化しない。

## Design Tokens

Color/Typography/Spacing 等の Design Token は [`design_spec.md`](./design_spec.md) を「信頼できる情報源 (SoT)」とする。

## コンポーネント Styling

コンポーネント内でブランディング Rule を Hard-code しない。

## Theme

Theme はプラットフォーム UI 側で管理する。

### iOS Theme

SwiftUI では、Environment/Theme 等を利用可能とする。

### Android Theme

Compose では、Material Theme 等を利用可能とする。

## プラットフォーム横断型 Design

完全に同一 Visual Design は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、コンポーネントの Visual 一致を要求しないことだけを定める。

## 共有のセマンティクス

Feature / Refresh / Favorite / Maintained の意味はドメイン仕様を正本とする。Metric は [`statistics_spec.md`](./statistics_spec.md)、エラーは [`ui.md`](./ui.md) を正本とする。本仕様は、コンポーネント境界がそれらの意味を再定義しないことだけを定める。

## プラットフォーム UX

ナビゲーション Chrome は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、コンポーネントがプラットフォーム固有 Chrome を抽象化して共有しないことだけを定める。

## Accessibility のセマンティクス

Label / Value / Hint の横断ルールは [`ui.md`](./ui.md) を正本とする。本仕様は、セマンティクスをプラットフォーム間で可能な限り統一することだけを定める。

## ローカライズ

UI String の Hard-code 禁止は [`ui.md`](./ui.md) を正本とする。本仕様は、コンポーネントが固定文字列を埋め込まないことだけを定める。

## String Resources

* iOS: `Localizable.xcstrings` 等を利用する。
* Android: `strings.xml` 等を利用する。

## Date Formatting

日付/数値の視覚書式は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、書式化を Presentation / UI 側で行うことだけを定める。

## Number Formatting

`## Date Formatting` を正本とする。

## Loading Accessibility

Loading / エラーの通知は [`ui.md`](./ui.md) を正本とする。本仕様は、状態変化を Accessibility に渡せることだけを定める。

## エラー Accessibility

色だけで伝えないことは [`ui.md`](./ui.md) を正本とする。

## Color Dependency

`## エラー Accessibility` を正本とする。

## Animation

Animation は情報伝達を阻害しない。

## オリエンテーション・トランジション

向き変更時の Layout / スクロール位置は [`ui-viewport.md`](./ui-viewport.md)、ナビゲーション状態の維持は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、コンポーネントが視覚的 Jump を起こさないことだけを定める。

## コンポーネント Testing

UI コンポーネントは、可能な範囲で独立テスト可能とする。

## ドメイン・コンポーネント Testing

ドメイン・コンポーネントは、KMP Common テストでテストする。

## Presentation Testing

ViewModel/Presentation Logic は、プラットフォーム UI なしでテスト可能とする。

## UI Testing

UI 挙動は、プラットフォーム UI テストで検証する。

## スナップショット Testing

Visual 回帰テストを必要に応じて導入する。

## Accessibility Testing

Accessibility Label/Role/Value 等をテスト可能とする。

## 画面の向きテスト

Portrait / Landscape / Compact / Regular の確認項目は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様のテストではコンポーネント単体の表示と Interaction を確認する。

## Viewport Testing

Viewport の確認項目は [`ui-viewport.md`](./ui-viewport.md) の Test Matrix / Acceptance Criteria を正本とする。

## iPhone Testing

初期リファレンス・デバイスは [`ui-viewport.md`](./ui-viewport.md) の Reference Devices を正本とする。

## iPad Testing

iPad の初期リファレンス・デバイスも [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Android Testing

Android の初期リファレンス・デバイスも [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## デバイス Independence

特定リファレンス・デバイスだけを前提にしないことは [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## スクリーンショット・レビュー

向き / 長い Name / 大きな数値の判定は [`ui-viewport.md`](./ui-viewport.md)、テスト種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様の Visual レビューでは、Missing Data / エラー / Loading などコンポーネント状態を確認する。

## Long Text

長い Package / リポジトリ Name の扱いは [`ui-viewport.md`](./ui-viewport.md) を正本とする。コンポーネントは固定長前提で設計しない。

## Large Numbers

大きな数値の表示幅は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Dynamic Content

API から取得する Data を固定長 UI として設計しない。

## Network 状態

View がネットワークを直接判定しないことは [`ui.md`](./ui.md) / [`architecture.md`](./architecture.md) を正本とする。本仕様は、Network 状態でコンポーネント Layout 自体を切り替えないことだけを定める。

## Refresh Interaction

既存 Content を維持する Refresh は [`ui.md`](./ui.md) を正本とする。本仕様は、Refresh をコンポーネント内のドメイン処理にしないことだけを定める。

## Retry Interaction

Retry UI は [`ui.md`](./ui.md) を正本とする。本仕様は、Retry Action を Presentation へ渡すことだけを定める。

## コンポーネント・エラー境界

UI コンポーネントのエラー状態がアプリケーション全体を破壊しない構造を目指す。

## コンポーネント Lifecycle

コンポーネント Lifecycle は、プラットフォーム UI フレームワークの Lifecycle を尊重する。

## Resource Lifecycle

I/O の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様は、UI コンポーネントが Network / Database を直接管理しないことだけを定める。

## Cancellation

非同期の制御は [`architecture.md`](./architecture.md) を正本とする。本仕様は、UI 消滅時に不要な処理を Cancel できることだけを定める。

## Background Operation

Background スナップショットは [`statistics_spec.md`](./statistics_spec.md) / [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、収集を UI Lifecycle から独立させることだけを定める。

## コンポーネント Dependency Injection

必要な Dependency は、Constructor/Environment/DI 等で明示的に提供する。

## Hidden Global Dependency

Global Singleton への過度な依存を避ける。

## Singleton

Singleton は、アプリケーション-wide Resource 等、明確な理由がある場合のみ利用する。

## コンポーネント Documentation

再利用コンポーネントには、最低限、下記を文書化する。

* Purpose
* インプット
* アウトプット
* 状態
* イベント
* Dependencies
* プラットフォーム
* Accessibility

## コンポーネント API

Public コンポーネント API は、必要最小限にする。

## Internal コンポーネント

アプリケーション内部だけで利用するコンポーネントは、Public Package API として公開しない。

## 共有 コンポーネント

将来 KMP 共有 UI に移行するコンポーネントは、`sharedUI` への移行可能性を考慮する。

ただし、初期バージョンでは Native UI を優先する。

## 共有 UI Non-goal

本仕様では、Compose Multiplatform による UI 共有を必須としない。

## Native-first Principle

* iOS/iPadOS: SwiftUI-first
* Android: Jetpack Compose-first

とする。

## KMP Logic-first Principle

KMP では、Logic Sharing を UI Sharing より優先する。

## Existing コンポーネント Reuse

既存の S2J コンポーネントを可能な限り再利用する。

### S2J About Window Integration

About 画面では、[S2J About Window](https://github.com/stein2nd/s2j-about-window) を利用可能とする。

### S2J Source List Integration

Source List では、[S2J Source List](https://github.com/stein2nd/s2j-source-list) を利用可能とする。

## Package Dashboard コンポーネント Tree

画面構成は [`screen_spec.md`](./screen_spec.md)、到達経路は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、スクリーンを Feature コンポーネント (PackageRow / MetricCard 等) へ分解することだけを定める。

## コンポーネント to ユースケース Mapping

例:

* PackageListView → `LoadDashboard`
* Refresh ボタン → `RefreshPackage`
* Favorite ボタン → `AddFavorite` / `RemoveFavorite`
* StatisticsView → `LoadPackageStatistics`

## コンポーネント to ドメイン Mapping

* PackageRow ← Package
* MetricCard ← Metric/Statistic
* StatisticsChart ← Historical スナップショット
* FavoriteButton ← Favorite 状態

## コンポーネント Dependency Example

依存の向きは [`architecture.md`](./architecture.md) を正本とする。例: PackageDetailView → ViewModel → `LoadPackageDetail` → PackageRepository → Packagist/GitHub。

## コンポーネント境界 Example

UI コンポーネントは Packagist API に直接依存しない。推奨経路は View → ViewModel → ユースケース → リポジトリ → プロバイダとする。

## コンポーネント Data フロー

データは プロバイダ → リポジトリ → ドメイン → ユースケース → ViewModel → UI コンポーネント の向きとする。層の正本は [`architecture.md`](./architecture.md) である。

## User Action フロー

User Action は UI コンポーネント → ViewModel → ユースケース → ドメイン/リポジトリ → 状態 Update → UI とする。遷移の形式は [`state_machine.md`](./state_machine.md) を正本とする。

## Refresh フロー

データの流れは [`architecture.md`](./architecture.md)、Refresh の見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、Refresh 操作がユースケースを起動し、コンポーネントがキャッシュ / スナップショット Policy を持たないことだけを定める。

## コンポーネント and キャッシュ

UI コンポーネントはキャッシュ Policy を直接実装しない。

## コンポーネント and スナップショット

UI コンポーネントはスナップショット・ストレージを直接操作しない。

## コンポーネント and Authentication

UI コンポーネントは Credential ストレージを直接操作しない。

## コンポーネント and セキュリティ

セキュリティ機密 Operation は UI コンポーネント外に委譲する。

## コンポーネント and Analytics

Analytics イベントを UI コンポーネントに Hard-code しすぎない。

## コンポーネント Versioning

独立 Package として公開するコンポーネントには、Semantic Versioning を適用可能とする。

## Internal コンポーネント Versioning

アプリケーション内部コンポーネントは、アプリケーション・バージョンとともに管理する。

## Breaking Change

Public コンポーネント API 変更は Breaking Change として扱う。

## コンポーネント Removal

コンポーネント削除時には、使用箇所を確認してから削除する。

## コンポーネント Duplication

同一のセマンティクスを持つコンポーネントを複数実装しない。

## コンポーネント Refactoring

コンポーネント Refactoring では、

* 挙動
* Accessibility
* Layout
* 状態
* Dependency

への影響を確認する。

## コンポーネント・パフォーマンス

コンポーネントは、不要な再描画/Recomposition を可能な範囲で避ける。

## Lazy Rendering

Lazy Rendering の横断方針は [`ui.md`](./ui.md) を正本とする。本仕様は、長い Package List コンポーネントが全件を UI Tree に載せないことだけを定める。

## Large Dataset

大量データの保持上限は [`storage_spec.md`](./storage_spec.md) を正本とする。本仕様は、大量 Package を一度に UI Tree に生成しないことだけを定める。

## Pagination

プロバイダ/リポジトリが Pagination を必要とする場合、Pagination Logic は UI コンポーネントに置かない。

## Infinite スクロール

Infinite スクロールを採用する場合も、Pagination 状態は Presentation/アプリケーション側で管理する。

## Search コンポーネント

Package Search UI が必要になった場合、Search インプットと Search Result を分離する。

## Filter コンポーネント

Filter UI は、Filter 状態を Presentation 層に通知する。

## Sort コンポーネント

Sort UI は、Sort Criteria をアプリケーション/Presentation に渡す。

## Search/Filter/Sort

これらを UI コンポーネント内のドメイン Rule として実装しない。

## コンポーネント Composition Rules

スクリーンは Container / コンポーネント / Section の階層で構成可能とする。階層の正本は `## コンポーネント Hierarchy` とする。

## スクリーン

スクリーンは、ナビゲーション単位または Feature 単位の最上位 UI コンポーネントとする。

## Section

Section は、スクリーン内の Semantic Group である。

## Primitive コンポーネント

ボタン/Label/Icon 等の Primitive は、Design System コンポーネントとして扱う。

## Design System

Design System コンポーネントは、[`design_spec.md`](./design_spec.md) と整合させる。

## コンポーネント Hierarchy

階層は スクリーン → Section → Feature コンポーネント → Primitive コンポーネント を基本とする。

## Primitive vs Feature

Primitive:

* ボタン
* Text
* Icon
* Divider

Feature:

* `PackageCard`
* `MetricCard`
* `StatisticsChart`

とする。

## コンポーネントのセマンティクス

コンポーネント名・構造は、Visual Appearance ではなく Semantic Role を優先する。

## Generic Card

単に、CardView という名前だけで Feature コンポーネントを表現しない。

必要に応じて、

* PackageCard
* MetricCard
* RepositoryCard

とする。

## Accessibility Tree

コンポーネント Hierarchy が Accessibility Tree としても意味のある構造になるよう設計する。

## コンポーネント Testing マトリックス

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、コンポーネントが Normal / Loading / Empty / エラー / Stale / Long Text / Large Number / Dynamic Type / Landscape / Accessibility を検討対象とすることだけを定める。

## UI 回帰

既存コンポーネントを変更した場合、主要スクリーンの Visual 回帰を確認する。

## デバイス回帰

対象デバイスは [`ui-viewport.md`](./ui-viewport.md) の Reference Devices を正本とする。

## Viewport 回帰

Portrait / Landscape およびオーバーフロー / 到達可能性の確認は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様の回帰ではコンポーネント単体の表示を確認する。

## コンポーネント Accessibility

Label / Value / Hint は [`ui.md`](./ui.md) を正本とする。本仕様は、コンポーネントが Visual だけでなく Semantic 情報を持つことだけを定める。

## コンポーネント状態 Restoration

復元する状態は [`application_state.md`](./application_state.md) を正本とする。本仕様は、ナビゲーション / 向き変更後にコンポーネントが表示用状態を失わないことだけを定める。

## コンポーネント Persistence

永続化は [`storage_spec.md`](./storage_spec.md) を正本とする。本仕様は、UI コンポーネントが Persistent ストレージを直接管理しないことだけを定める。

## 状態 Restoration 境界

復元する状態は [`application_state.md`](./application_state.md) を正本とする。本仕様は、Restoration をアプリケーション / Presentation 層で管理することだけを定める。

## コンポーネント Lifecycle 境界

コンポーネント Lifecycle と Data Lifecycle を分離する。Network Request を UI Lifecycle に直接結合しないことは `## Resource Lifecycle` を正本とする。

## Network Lifecycle

`## Resource Lifecycle` を正本とする。

## コンポーネント・エラー Isolation

一つの Feature コンポーネントのエラーが他 Feature の UI を不必要に破壊しない。

## コンポーネント Loading Isolation

一つのコンポーネントの Loading がスクリーン全体を Block しない構造を可能な範囲で採用する。

## コンポーネント Documentation

再利用コンポーネントの文書化項目は前述の同名節を正本とする。本節は、仕様変更時に関連 Documentation を更新することだけを定める。

## Related 仕様

ファイル名簿は [`specs.md`](./specs.md) を正本とする。本仕様の分担は `## 非責務` を正本とする。

## 仕様の責務

各ファイルの責務は当該ファイルを正本とする。分割方針は [`spec_structure.md`](./spec_structure.md) を正本とする。本仕様はコンポーネント境界だけを定める。

## コンポーネント and KMP 境界

Logic / Presentation / UI の置き場所は [`architecture.md`](./architecture.md) / [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、Native UI コンポーネントと Presentation コンポーネントの境界だけを定める。

## Migration Candidate

KMP 移行候補は [`architecture.md`](./architecture.md) / [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、Presentation / Native UI コンポーネントを共有対象にしないことだけを定める。

## Non-migration Candidate

KMP に移行しない対象は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、Native UI コンポーネントをプラットフォーム内再利用とすることだけを定める。

## Native コンポーネント Reuse

Native コンポーネントは、そのプラットフォーム内での再利用を優先する。

## プラットフォーム横断型 Semantic Reuse

プラットフォーム横断型で共有する必要があるものは、UI コンポーネントではなくドメイン/アプリケーションのセマンティクスを優先して共有する。

## 最終的なコンポーネント・アーキテクチャー

層と Native UI の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様は、その置き場所に合わせてコンポーネント境界を切ることだけを定める。

## 最終原則

責務の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様は、コンポーネント境界をその置き場所に合わせて切ることだけを定める。既存 S2J About Window / Source List の再利用は `## Existing コンポーネント Reuse` を正本とする。
