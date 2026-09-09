# S2J Package Dashboard - アプリケーション状態の仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、アプリケーション状態のライフサイクル、保持範囲、保存・復元方針を定義します。

復元対象と優先順位の正本は本仕様とする。状態遷移は [`state_machine.md`](./state_machine.md) を正本とする。

## 目的

本仕様は、S2J Package Dashboard におけるアプリケーション状態の定義、ライフサイクル、保持範囲、保存・復元方針を定める。

復元対象、優先順位、保持しないものの正本は本仕様とする。Restoration の状態遷移は [`state_machine.md`](./state_machine.md) を正本とする。

目的は、「ユーザーがアプリケーションを離れる前に行っていた操作を、可能な限り自然に再開できること」とする。

## 非目的

本仕様では下記を要求しない。

* すべての UI 状態の完全な復元
* Scroll Position の完全な復元
* API Response の状態 Restoration
* Network Request の再開
* 非同期 Task の復元
* Credential の状態 Restoration
* キャッシュの完全な復元
* Application 状態の Cloud 同期
* iOS / Android 間の Application 状態同期

特に、「アプリケーションを再起動したら完全に同じ内部状態に戻す」ことを目的としない。

## 責務

実行中および再起動時に必要な状態の分類・保持・復元対象を定義する。対象は Lifecycle、Navigation、Selection、Search / Filter、Statistics Display、Loading、Refresh、Error、Offline / Stale、Authentication、Window / Presentation、Restoration Data とする。

## 非責務

状態遷移は [`state_machine.md`](./state_machine.md) を正本とする。状態の見え方 (Loading / エラー / Empty) は [`ui.md`](./ui.md) を正本とする。Fresh / Stale の判定は [`cache_spec.md`](./cache_spec.md)、認証状態は [`authentication_spec.md`](./authentication_spec.md) を正本とする。永続データの保存 HOW は [`storage_spec.md`](./storage_spec.md) / [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。KMP の source set / 移行手順は [`kmp_spec.md`](./kmp_spec.md)、向き変更時の Layout は [`ui-viewport.md`](./ui-viewport.md)、Root Destination は [`navigation_spec.md`](./navigation_spec.md)、検証の種類は [`testing_spec.md`](./testing_spec.md)、ファイル名簿は [`specs.md`](./specs.md) を正本とする。Package ドメイン・モデル、API Response、Persistent Package Data、統計スナップショット、Credential Secret、キャッシュ Data は各専門仕様を正本とする。

## 状態 Classification

Application 状態は、保存期間と責務にもとづき下記に分類する。

| Category | Description | Example |
| --- | --- | --- |
| Persistent Data | ユーザーまたはアプリケーションが永続的に保持するデータ | Package、Favorite、スナップショット |
| Restorable Application 状態 | 再開時に復元することで UX を維持する状態 | ナビゲーション・パス、selected package |
| セッション状態 | 現在のアプリケーション・セッション中のみ必要な状態 | Loading、Refreshing |
| UI Local 状態 | 特定 View / Component 内だけで必要な状態 | 展開状態、Focus |
| Derived 状態 | 他の状態から算出可能な状態 | `isRefreshing` |
| Transient Event | 一度だけ処理されるイベント | Retry、Open URL |

Application 状態と Persistent Data を混同してはならない。

特に、UI 状態を復元するためだけに Package 本体や Statistics スナップショットを Application 状態として保存してはならない。

## Application 状態 Model

Application 状態は概念的に下記の構造を持つ。

* lifecycle: `launching` / `active` / `inactive` / `background`
* navigation: `root` / `path` / `presentedDestination`
* selection: `selectedPackage` / `selectedStatistic`
* query: `searchQuery` / `filters`
* statistics: `period` / `source`
* data: `loadState` / `refreshState` / `staleState`
* authentication: `packagist` / `github`
* restoration: `version` / `restorationStatus`

これは実装上の単一 `ApplicationState` struct/class を必須とするものではない。

各 Platform の実装では、適切な状態 Holder/ViewModel/Scene 状態等に分割してよい。

ただし、**状態の意味論は Platform 間で一致させる**。

## Application Lifecycle 状態

Application Lifecycle 状態は、アプリケーションが現在どの状態にあるかを表す。値は launching / active / inactive / background とする。遷移は [`state_machine.md`](./state_machine.md) を正本とする。本仕様は分類だけを定める。

### 1. Launching

アプリケーションが起動し、初期状態を構築している状態。

この状態では下記を行う。

1. Persistent Data の読み込み
2. Restorable Application 状態の読み込み
3. Authentication 状態の確認
4. キャッシュ 状態の確認
5. 初期 Navigation 状態の構築
6. 必要な Data Fetch の開始

### 2. Active

ユーザーがアプリケーションを操作可能な状態。

通常の Application 状態遷移はこの状態で発生する。

### 3. Inactive

アプリケーションが一時的に操作対象ではない状態。

例:

* System UI 表示
* Scene transition
* 一時的な割り込み

この状態になっただけで Application 状態を破棄してはならない。

### 4. Background

アプリケーションがバックグラウンドに移行した状態。

Background 移行時には、必要な Restorable Application 状態を保存可能な状態にしておく。

ただし、OS によるバックグラウンド実行や保存タイミングを保証してはならない。

## Navigation 状態

Navigation 状態は、ユーザーが現在どの Application Context にいるかを表す。到達可能な経路は [`navigation_spec.md`](./navigation_spec.md) / [`ux_flows_spec.md`](./ux_flows_spec.md) を正本とする。本仕様は、Navigation 状態が Identifier を保持することだけを定める。

Navigation 状態には少なくとも下記を含む。

* Current Root
* ナビゲーション・パス
* Selected Destination
* Presented Modal / Sheet
* Deep Link Destination

Navigation 状態は Domain Data そのものではなく、**Domain Data を参照するための Identifier** を保持する。

たとえば Package Detail を復元する場合、

* Good:
    * PackageIdentifier = "vendor/package"
* Bad:
    * PackageDetailViewModel 全体
    * Package API Response 全体

とする。

Apple の SwiftUI でも `NavigationStack` のパスはアプリケーションが管理可能な状態として扱え、ナビゲーション・パスの復元がサポートされている。([Understanding the navigation stack | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/understanding-the-navigation-stack))

## Selection 状態

Selection 状態は、現在ユーザーが選択している対象を表す。

例:

`selectedPackage = vendor/package`

選択対象は可能な限り Identifier で保持する。

### 1. Package Selection

Package Detail を表示している場合、`selectedPackageID` を保持する。

Package の詳細データ自体はリポジトリから取得する。

### 2. Invalid Selection

復元対象 Package が存在しない場合、`selectedPackageID` を破棄し、親 Destination へ fallback する。

存在しない Package を復元するために古い API Response を Application 状態に保持してはならない。

## Search and Filter 状態

検索画面で入力された状態を保持する。

対象:

* Search Query
* Filter
* Sort Order
* Selected Scope

例:

`searchQuery = "wordpress"`
`filter = "all"`
`sortOrder = "name"`

Search Result 自体は Application 状態として保存しない。

検索条件のみを復元し、必要に応じてリポジトリ/キャッシュから結果を再構築する。

## Statistics Display 状態

Statistics Screen の表示条件を保持する。

例:

`statisticsPeriod = monthly`
`statisticsSource = packagist`

対象:

* Statistics Period
* Statistics Source
* Selected Metric
* Selected Package

一方、Statistics の実データは Persistent Data/キャッシュ/スナップショットの責務とする。Application 状態が持つのは period / source 等の表示条件であり、スナップショット本体は [`storage_spec.md`](./storage_spec.md) を正本とする。

## Data Loading 状態

Data Loading 状態は、現在のデータ取得処理の状態を表す。値は idle / loading / loaded / empty / error とする。遷移は [`state_machine.md`](./state_machine.md) を正本とする。本仕様は分類だけを定める。

### 1. Loading

初回データ取得中。

### 2. Loaded

要求したデータが取得済み。

### 3. Empty

要求は成功したが表示対象データが存在しない。

### 4. Error

データ取得に失敗した。

Error 状態には必要に応じて正規化された `ApplicationError` を保持する。

## Refresh 状態

Refresh は Loading と区別する。遷移の形式は [`state_machine.md`](./state_machine.md)、既存データの見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、Refreshing をセッション状態として持ち、失敗しても既存データを破棄しないことだけを定める。

## Stale 状態

Fresh / Stale / Unavailable の判定は [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、表示中データが Stale であることを「Application 状態として持つことが可能である」こと、「Stale を Error と混同しない」ことだけを定める。

## Offline 状態

オフライン時の既存表示は [`ui.md`](./ui.md)、キャッシュ利用は [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、Offline を「Application 状態として持つことが可能である」こと、「Error と同一視しない」ことだけを定める。

## Authentication 状態

UI に出してよい状態は [`authentication_spec.md`](./authentication_spec.md) を正本とする。保存 HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、Credential の値ではなく `isAuthenticated` / `accountIdentifier` / `credentialStatus` 等の非秘密情報を Application 状態として持つことだけを定める。

## 状態 Restoration

状態 Restoration は、アプリケーションが中断された後にユーザーが以前の操作地点に戻れることを目的とする。何を復元するかは本節、どう遷移するかは [`state_machine.md`](./state_machine.md) の「状態 Restoration Transition」を正本とする。SceneStorage / SavedStateHandle の実装は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。

本仕様は、Restorable 状態を Identifier / Query / Selection / Navigation 等の軽量情報に限り、大規模データは Persistent Storage / キャッシュから再構築することだけを定める。

## 状態 Restoration Priority

復元対象には優先順位を設ける。

### Priority-1: Must Restore

* Current Package
* Navigation Context
* Search Query
* Statistics Period
* Selected Filter
* In-progress user input that is explicitly required

### Priority-2: Should Restore

* Selected Metric
* Sort Order
* Selected Tab
* Presentation-related selection

### Priority-3: May Restore

* Scroll Position
* Expanded / Collapsed UI 状態
* Temporary presentation preferences

### Do Not Restore

* Loading 状態
* Refreshing 状態
* Network Error Object
* Request Object
* Task / Coroutine / async operation
* Credential Secret
* API Response Object
* キャッシュ contents
* Statistics スナップショット itself

## Restoration and Data Reload

Application 状態の復元と Data の復元を分離する。Identifier を復元したあと、`Repository.find` で Local Data を引き、必要なら Remote Fetch する。キャッシュ利用は [`cache_spec.md`](./cache_spec.md) を正本とする。

Application 状態が復元されたことを理由に、古い API Response をそのまま再利用してはならない。

Local キャッシュが利用可能な場合はキャッシュ Policy に従って利用する。

## 状態 Versioning

Restorable Application 状態には Version を持たせる。

例:

`stateVersion = 1`

アプリケーション更新によって状態 Schema が変更された場合、格納済み状態の Version を判定する。Compatible なら Restore、Migratable なら Migrate して Restore、Incompatible なら破棄して Default 状態にする。

古い状態を無理に復元して不整合を発生させるよりも、復元可能性を判定し、安全に初期状態に fallback することを優先する。

## Invalid Restoration

復元された状態が現在のデータと整合しない場合は、安全な fallback を行う。

復元した Package ID が存在しなければ Package Detail を外し、Package List へ戻す。復元したナビゲーション・パスに未知の Destination があれば無効パスを捨て、最も近い有効な親を復元する。

アプリケーション起動を失敗させる原因となる状態 Restoration は許可しない。

## Orientation and Window Size Changes

Layout の再計算と中間 Layout 禁止は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、向き / Window Size 変更で Selected Package / Navigation / Search / Period / Filter を破棄しないことだけを定める。

## iPad Multi-Window

複数 Scene の Layout は [`ui-viewport.md`](./ui-viewport.md)、ナビゲーションは [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、Navigation / Selection を Scene 単位で持ち、Persistent Data と混同しないことだけを定める。

## Android Configuration Change

向き / サイズ変更の Layout は [`ui-viewport.md`](./ui-viewport.md)、SavedStateHandle は [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、Configuration Change 後も Screen 状態を維持し、大規模データは Local Persistence から再構築することだけを定める。

## KMP Boundary

共有対象の優先順位は [`architecture.md`](./architecture.md)、source set / モジュール配置は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、Application 状態の意味論 (Selection / Query / Period / Loading 等) がプラットフォームに依存しないことだけを定める。

## 状態 Transition

遷移の形式は [`state_machine.md`](./state_machine.md) を正本とする。本仕様は、Application 状態が Event で変わり、I/O を状態そのものに混ぜないことだけを定める。

## Derived 状態

他の状態から算出可能な値は、原則として保存しない。例: `isRefreshing` は `refreshState == refreshing` から導出する。Reducer が Stored 状態にしないことは [`state_machine.md`](./state_machine.md) を正本とする。

## Transient Event

一度きりの操作は Event であり、Restorable Application 状態に含めない。Event / Effect の形式は [`state_machine.md`](./state_machine.md) を正本とする。本仕様は、Retry / Open URL / Confirmation / Navigate 等を永続化しないことだけを定める。

## Persistence Boundary

保存先の実装は、永続データ [`storage_spec.md`](./storage_spec.md) / [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md)、キャッシュ [`cache_spec.md`](./cache_spec.md)、Credential [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、Restorable Application 状態と Persistent Data を同一ストアに混ぜないことだけを定める。

## Security

Restorable Application 状態に Credential を入れないことは [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、Restoration スナップショット / ログ / Analytics / Crash Report に Secret を含めないことだけを定める。

## 状態 Restoration Failure

状態 Restoration に失敗した場合、Application は可能な限り通常起動に fallback する。失敗時の遷移は [`state_machine.md`](./state_machine.md) を正本とする。

状態 Restoration Failure は、それ自体を致命的な Application Error として扱わない。

## Default 状態

Restoration Data がないときの Root Destination は [`navigation_spec.md`](./navigation_spec.md)、Initial スクリーンの表示内容は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、Selection / Search / Filter を空、Load / Refresh を idle、認証は現在状態を読み、Data はローカルから読むことだけを定める。Statistics Period の初期値は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## Relationship to Other Specifications

ファイル名簿は [`specs.md`](./specs.md)、統合の見取り図は [`spec.md`](./spec.md) を正本とする。本仕様の分担は `## 非責務` を正本とする。

## Acceptance Criteria

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様の合格条件は、状態の分類、`## 状態 Restoration Priority`、`## 状態 Restoration Failure` が実装されていることとする。向き / Window 変更後の Layout は [`ui-viewport.md`](./ui-viewport.md)、Credential を Restoration に入れないことは [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) を正本とする。KMP の判定は、Restoration Semantics がプラットフォーム Restoration API に依存しないことだけとする。
