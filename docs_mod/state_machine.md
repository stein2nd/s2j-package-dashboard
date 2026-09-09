# S2J Package Dashboard - 状態機械の仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、Application 状態機械の形式、状態、Event、Transition、Effect および Reducer の責務を定義します。何を保持・復元するかは [`application_state.md`](./application_state.md)、どう遷移するかは本仕様を正本とする。

## 目的

本仕様は、Application 状態機械の形式、状態、Event、Transition、Effect および Reducer の責務を定義する。目的は、状態の変更経路を明示的かつ予測可能にすることである。

何を状態として保持・復元するかは [`application_state.md`](./application_state.md) を正本とする。本仕様は、どう遷移するかを正本とする。

## 非目的

本仕様では下記を要求しない。

* TCA/Redux 等の特定フレームワークの採用
* 単一 Store の強制
* 全 Screen の状態を一つの巨大な状態に統合すること
* 全 UI Local 状態の状態機械化
* Network Request 自体を状態として永続化すること
* 非同期 Task の復元
* Platform-specific Navigation API の共通化

## 責務

状態 / Event / Transition / Reducer / Effect、Restoration 遷移、Launch および各部分の状態機械を定義する。

## 非責務

状態の詳細構造は [`application_state.md`](./application_state.md) を正本とする。Derived / Transient を保存しないことも同仕様を正本とする。検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。`ApplicationError` の型は [`models_spec.md`](./models_spec.md) を正本とする。ドメイン・モデル、リポジトリ/API 実装、SwiftUI/Compose、SwiftData/Room、Keychain/Keystore は各専門仕様を正本とする。

## Design Principles

状態機械は下記の原則に従う。

### 1. Single Direction

状態の変更方向は一方向とする。User / System → Event → Reducer → 状態 → View。View が直接 Domain Data やリポジトリを変更してはならない。

### 2. Single Source of Truth

Application 状態に含まれる値の重複禁止は [`application_state.md`](./application_state.md) を正本とする。本仕様は、Reducer が導出値を Stored 状態として持たないことだけを定める。

### 3. Pure 状態 Transition

Reducer は状態と Event から次の状態を決定する。

`(State, Event) → NewState`

同一の状態と Event に対して、同一の NewState を生成することを原則とする。

Reducer は Network、File System、Database、Clock、Random Number Generator 等の外部依存を直接操作してはならない。

### 4. Side Effect Separation

Network Request や Persistence 等の I/O は Effect/Command として状態 Transition から分離する。Event → Reducer が New 状態と Effect を出し、Effect の結果は Event として Reducer に戻す。この構造により、非同期処理の結果も通常の Event として状態機械に戻す。

## Terminology

| Term | Definition |
| --- | --- |
| 状態 | 現在の Application の状態 |
| Event | 状態機械に入力される事象 |
| Transition | 状態から別の状態への遷移 |
| Reducer | Event に応じて状態を更新する処理 |
| Effect | 状態 Transition の結果として外部 I/O 等を実行する処理 |
| Command | Effect に実行を依頼する宣言的な命令 |
| Store | 現在の状態を保持し Event を処理する実行主体 |
| Selector | 状態から必要な派生値を取得する処理 |
| Invariant | 状態が常に満たすべき条件 |
| Restoration | 保存された状態から Application 状態を再構築する処理 |

## 状態

Application 状態の詳細な構造は `application_state.md` で定義する。

本状態機械が扱うフィールド群の意味と復元対象は [`application_state.md`](./application_state.md) を正本とする。

状態は可能な限り Value Semantics を持つ immutable value として扱う。

実装言語やフレームワークの都合により内部的に mutable なしくみを利用してもよいが、外部から観測される状態 Transition は immutable value の置換として扱う。

## Event

Event は状態機械に入力される事象を表す。

Event は下記のカテゴリーに分類する。User / Lifecycle / Navigation / Data / Network / Authentication / Restoration / System Event。各カテゴリーの例は下記とする。

### 1. User Event

ユーザー操作によって発生する。

例:

* `OpenPackage(packageID)`
* `SelectPackage(packageID)`
* `AddFavorite(packageID)`
* `RemoveFavorite(packageID)`
* `Search(query)`
* `ChangeStatisticsPeriod(period)`
* `Refresh`
* `Retry`
* `OpenSettings`
* `OpenAbout`

### 2. Lifecycle Event

Application/Scene の状態変化を表す。

* `AppLaunching`
* `AppActive`
* `AppInactive`
* `AppBackground`

### 3. Navigation Event

Navigation の変更を表す。

* `Navigate(destination)`
* `NavigateBack`
* `PopToRoot`
* `Present(destination)`
* `Dismiss`
* `OpenDeepLink(destination)`

### 4. Data Event

リポジトリ/API から返された結果を表す。

* `DataLoaded(data)`
* `DataLoadFailed(error)`

* `PackageLoaded(package)`
* `PackageLoadFailed(error)`

* `StatisticsLoaded(statistics)`
* `StatisticsLoadFailed(error)`

### 5. Network Event

Network 状態の変化を表す。

* `NetworkAvailable`
* `NetworkUnavailable`

Network 状態を直接 UI 状態に書き込むのではなく、必要な Application 状態に Reducer を通して反映する。

### 6. Authentication Event

認証状態の変化を表す。

* `AuthenticationRequested(provider)`
* `AuthenticationSucceeded(provider, account)`
* `AuthenticationFailed(provider, error)`
* `AuthenticationExpired(provider)`
* `AuthenticationRemoved(provider)`

Credential Secret 自体を Event Payload に含めない。

### 7. Restoration Event

状態 Restoration に関連する Event。

* `RestoreRequested`
* `RestoreSucceeded(state)`
* `RestoreFailed(error)`
* `RestoreDiscarded(reason)`

## Event Naming

Event は「発生した事象」を表す名前とする。

推奨:

* `RefreshRequested`
* `PackageSelected`
* `StatisticsLoaded`
* `AuthenticationSucceeded`

避ける:

* `SetLoadingTrue`
* `ChangeInternalFlag`
* `UpdateBoolean`

Event は UI 実装ではなく Application Behavior を表現する。

## Event Payload

Event Payload は状態 Transition に必要な最小限の情報のみを持つ。

例:

`PackageSelected( packageID: PackageIdentifier )`

Package Object 全体を Event Payload に含める必要がない場合、`PackageSelected( package: Package )` とはしない。

原則として Identifier を優先する。

## Transition

Transition は、`Current State + Event → Next State` として定義する。

例: idle + DataLoadRequested → loading。loading + DataLoaded → loaded。loading + DataLoadFailed → error。詳細は `## Transition Table` を正本とする。

## Transition Table

主要な状態 Transition を下記のように定義する。

| Current 状態 | Event | Next 状態 |
| --- | --- | --- |
| launching | AppActive | active |
| active | AppInactive | inactive |
| inactive | AppActive | active |
| active | AppBackground | background |
| background | AppActive | active |
| idle | DataLoadRequested | loading |
| loading | DataLoaded | loaded |
| loading | DataLoadFailed | error |
| loaded | RefreshRequested | refreshing |
| refreshing | DataLoaded | loaded |
| refreshing | DataLoadFailed | stale + error |
| error | RetryRequested | loading |
| stale | RefreshRequested | refreshing |
| empty | RefreshRequested | refreshing |
| unauthenticated | AuthenticationRequested | authenticating |
| authenticating | AuthenticationSucceeded | authenticated |
| authenticating | AuthenticationFailed | unauthenticated + error |
| authenticated | AuthenticationExpired | expired |
| expired | AuthenticationRequested | authenticating |

この表は基本的な状態 Transition を示すものであり、個々の Feature 状態機械が必要に応じて詳細化する。

## 状態機械 Hierarchy

Application 全体を単一の巨大な状態機械として実装する必要はない。

下記の階層を許可する。`ApplicationStateMachine` の下に Navigation / Package / Statistics / Authentication / Data / Restoration の Sub-状態機械を置いてよい。各 Sub-状態機械は Application 状態の一部を担当する。

ただし、Sub-状態機械間で同一の状態を二重管理してはならない。

## Reducer

Reducer は Event を状態 Transition に変換する。

概念的な形式:

`reduce( state: ApplicationState, event: Event ) -> TransitionResult`

`TransitionResult` は概念的に `state` と `effects` を持つ。

例:

`reduce( state: .loaded, event: .refreshRequested )`

結果:

* `state`: `.refreshing`
* `effects`: `.refreshPackageData`

## Reducer Responsibilities

Reducer は下記を担当する。

* Event の解釈
* 状態 Transition
* 状態 Invariant の維持
* Effect の生成
* Invalid Event の無視または Error 化

Reducer は下記を担当しない。

* HTTP Request
* Database Query
* File I/O
* Keychain/Keystore Access
* SwiftUI View 操作
* Compose UI 操作
* Navigation Controller の直接操作
* Alert の直接表示

## Effect

Effect は状態機械の外部で実行される処理を表す。

代表例: FetchPackage / FetchStatistics / SaveFavorite / RemoveFavorite / SaveSnapshot / LoadPersistedState / SaveRestorableState / Authenticate / OpenExternalURL。

Effect の完了結果は Event として Store に戻す。Effect → External System → Result → Event → Reducer。

## Effect Must Not Mutate 状態 Directly

Effect は Application 状態を直接変更してはならない。Bad: Effect が `state.isLoading = false` を書く。Good: Effect が `DataLoaded` Event を出し、Reducer が状態を更新する。これにより、すべての状態 Change を Event と Transition として追跡可能にする。

## Command

Effect の実行内容を宣言的に表現する場合、Command を使用する。

例:

* `Command.fetchPackage(packageID)`
* `Command.fetchStatistics(packageID, period)`
* `Command.saveFavorite(packageID)`
* `Command.deleteFavorite(packageID)`

Command 自体は I/O 実装を持たない。

Platform-specific executor が Command を実行し、その結果を Event に変換する。

## Async Operation

非同期処理は下記の形式を基本とする。Event → Reducer → 状態 = Loading かつ Effect = Fetch → リポジトリ → Success / Failure Event → Reducer → 状態 = Loaded / Error。詳細は `### 4. Side Effect Separation` を正本とする。非同期の処理中に View が直接状態を変更してはならない。

## Request Identity

同時に複数の Request が存在する可能性がある場合、Request Identity を使用する。

例:

* `RequestID`
* `PackageID`
* `StatisticsPeriod`

Response Event に Request Identity を含める。

`StatisticsLoaded( requestID, packageID, period, statistics )`

Reducer は現在の状態と Request Identity を比較する。

## Stale Response Protection

古い Request の Response によって新しい状態が上書きされないようにする。

例:

`Request A`、`Request B` の順で開始された場合、B completed なら State = B、後から完了した A は Ignore とする。

必要に応じて下記のいずれかを採用する。

* Latest Wins
* Request ID Matching
* Cancellation
* Request Coalescing

Feature ごとの選択は個別仕様で定義する。

## Refresh Concurrency

同一対象への Refresh が複数回要求された場合、重複 Request を抑制する。

基本方針: Refreshing 中の追加 RefreshRequested は No-op とする。

ただし、明示的な再実行を許可する Feature では別途定義してよい。

基本的には同一 Package / 同一 Statistics Period に対して Request を一つにする。

## Cancellation

不要になった非同期処理は Cancellation を許可する。

例: Package A の Fetch 中にユーザーが Package B へ移ったら Fetch A を Cancel し Fetch B を開始する。Cancellation は通常の Error と区別する。Cancelled ≠ Failed。ユーザーが別の画面に移動しただけで、画面上に Error を表示してはならない。

## Error Event

`ApplicationError` の型は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、Error を ApplicationError に正規化し、Provider 固有 Error を UI Layer に直接伝播させないことだけを定める。

## Error Transition

代表的な Error Transition: Loading + NetworkUnavailable → Error / Offline。Refreshing + NetworkUnavailable → Loaded / Stale。Loading + AuthenticationRequired → Unauthenticated。詳細は `## Transition Table` を正本とする。既存データが存在する場合は、可能な限りデータを保持する。

## Error Recovery

Error Recovery は Event として表現する。Error + RetryRequested → Loading。既存データがある場合は Stale + RetryRequested → Refreshing。

## Navigation Transition

Navigation も Event と状態の関係として扱う。行き先と戻り方は [`navigation_spec.md`](./navigation_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) を正本とする。本仕様は、例として `Dashboard` + `PackageSelected(id)` → `PackageDetail(id)`、`PackageDetail(id)` + `NavigateBack` → `PackageList` とすることだけを定める。Navigation UI の具体的な実装は Platform Layer に委ねる。

## Deep Link Transition

Deep Link は Event として状態機械に入力する。経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、URI は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、`DeepLinkReceived(url)` → Parse → `OpenPackage(packageID)` → Navigation 状態、とすることだけを定める。不正な Deep Link は無視または Error Event に変換する。

## 状態 Invariants

状態機械は下記の Invariant を維持する。

### 1. Selection Invariant

`selectedPackage != null` の場合、Package Identifier は正規化済みでなければならない。

### 2. Loading Invariant

`loadState == loading` の場合、初期ロード Request が存在する。

ただし、Request Object 自体を Persistent 状態に保存してはならない。

### 3. Refresh Invariant

`refreshState == refreshing` の場合、対象となる Refresh Operation が存在する。

### 4. Credential Invariant

Credential Secret を状態に入れないことは [`application_state.md`](./application_state.md) / [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、Transition 後にその不変条件を `assertValidState` できることだけを定める。

### 5. Navigation Invariant

ナビゲーション・パスに存在する Destination は、現在の Application Version で解釈可能でなければならない。

## Derived 状態

導出して保存しないことは [`application_state.md`](./application_state.md) を正本とする。本仕様は、Reducer が `isLoading` / `isRefreshing` / `hasError` 等を Stored 状態として持たないことだけを定める。

## Event Ordering

Event は Store によって順序付けられる。

基本的には、Event A → Reducer → 状態 A → Event B → Reducer → 状態 B とし、同一 Store に対する状態 Mutation が並行して実行されないようにする。

## Thread Safety

状態 Mutation は単一の Serialization Context で実行する。

Platform 実装では、

* iOS: Main Actor / actor isolation 等
* Android: Coroutine / StateFlow 等

を利用してよい。

ただし、Thread / Coroutine Context の選択によって状態 Transition の意味が変化してはならない。

## Store

Store は Application 状態機械の実行主体である。

概念的には、状態 / Reducer / Effect Executor / Event Dispatcher を持つ。

処理順序: `dispatch(Event)` → Reducer → New 状態 → Publish 状態 → Execute Effects → Effect Result → `dispatch(Event)`。

## Store Responsibilities

Store は下記を担当する。

* Current 状態の保持
* Event の Dispatch
* Reducer の実行
* 状態の Publish
* Effect の起動
* Effect Result の Event 化
* Event Ordering

Store は下記を担当しない。

* UI Layout
* API Client の詳細
* Database の詳細
* Credential の直接管理
* Platform-specific Navigation UI

## 状態 Observation

UI は状態を Observe する。Store → 状態 → Selector → View。View は必要な状態のみを購読してよい。

たとえば Package Detail Screen は、`PackageDetailState` だけを購読してよい。

## Selector

Selector は Application 状態から Presentation に必要な値を導出する。例: ApplicationState → Selector → PackageDetailViewState。Selector は Pure Function とする。

また、Selector は状態を変更してはならない。

## Presentation 状態

Application 状態と View 状態は区別する。見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、Application 状態 → Presentation → View 状態 → SwiftUI / Compose とし、View 専用の表示情報を Application 状態に逆流させないことだけを定める。

たとえば、

```text
Application State:
    statisticsPeriod = monthly
    statistics = ...

View State:
    chartData = ...
    periodLabel = "Monthly"
    showEmptyState = false
```

View 専用の表示情報を Application 状態に逆流させない。

## Platform Boundary

共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、状態 / Event / Reducer / Transition / Effect 定義を Core に置き、SwiftUI / Compose / SceneStorage / SavedStateHandle / Effect Executor をプラットフォームに置くことだけを定める。

## KMP Compatibility

HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、状態機械 Core が SwiftUI / Compose API に依存しないことだけを定める。

## Serialization

復元対象は [`application_state.md`](./application_state.md) を正本とする。本仕様は、Restorable 状態の Serialization Model と Runtime 状態を分離し、Runtime 状態を永続化フォーマットとして固定しないことだけを定める。

## 状態 Restoration Transition

復元対象と優先順位は [`application_state.md`](./application_state.md) を正本とする。本節は Restoration の遷移のみを定義する。

状態 Restoration は下記の状態機械とする。restoration.idle + RestoreRequested → restoration.loading。loading から RestoreSucceeded → restored、RestoreDiscarded → discarded、RestoreFailed → failed。

Restoration Failure 後も Application 自体は Default 状態で起動可能とする。

## Application Launch

起動の経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、Root は [`navigation_spec.md`](./navigation_spec.md)、復元対象は [`application_state.md`](./application_state.md) を正本とする。本仕様は、Launching から RestoreRequested / LoadLocalData / CheckAuthentication が並行し得ることだけを定める。

Application Launch の基本 Transition: Launching から RestoreRequested / LoadLocalData / CheckAuthentication が分岐し、Active へ進む。

これらは独立した Effect として並行実行してよい。

ただし、Navigation 状態の復元など依存関係がある処理は順序を明示する。

## Package Loading 状態機械

Package Data は下記の状態機械を基本とする。idle + LoadRequested → loading。loading + LoadSucceeded → loaded、NoData → empty、LoadFailed → error。

Existing Local Data が存在する場合: idle + LocalDataAvailable → loaded / stale。stale + RefreshRequested → refreshing。refreshing + Success → loaded、Failure → stale。

## Statistics 状態機械

Statistics は Package Data とは独立した状態機械とする。idle + StatisticsRequested → loading。loading + StatisticsLoaded → loaded、StatisticsFailed → error。

Period Change: loaded + StatisticsPeriodChanged → loading。既存 Snapshot が利用可能な場合、PeriodChanged → Local Snapshot → loaded / stale → Remote Refresh。

## Favorite 状態機械

Favorite の追加・削除は idempotent とする。

### Add

`notFavorite` + `AddFavorite` → `favorite`。すでに Favorite でも `AddFavorite` は `favorite` のままとする。

### Remove

`favorite` + `RemoveFavorite` → `notFavorite`。すでに notFavorite でも `RemoveFavorite` は `notFavorite` のままとする。

同じ Event が複数回発生しても、最終状態 が invalid にならないこと。

## Authentication 状態機械

認証状態は下記を基本とする。許可される状態の一覧は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、unauthenticated + AuthenticationRequested → authenticating、Succeeded → authenticated、Failed → unauthenticated とすることだけを定める。

Credential Expiration: authenticated + AuthenticationExpired → expired。expired + AuthenticationRequested → authenticating。

Credential Secret を Event Payload に含めないことは [`application_state.md`](./application_state.md) / [`security_spec.md`](./security_spec.md) を正本とする。

## Invalid Event

現在の状態では意味を持たない Event を受信した場合の処理を定義する。

基本方針: Invalid Event は状態を変更しない。例: loading 中の AddFavorite が Package ID を持たず処理不能な場合。ただし、ユーザー操作のフィードバックが必要な場合は、状態を変えずに Error Effect を出してよい。

## Event Idempotency

下記の Event は可能な限り idempotent にする。

* AddFavorite
* RemoveFavorite
* MarkRead 相当の操作
* Refresh の request coalescing
* Authentication removal
* 状態 restoration discard

同じ Event を複数回処理しても、状態が不正な状態に進まないこと。

## Transition Logging

Debug Build では状態 Transition を追跡可能にしてよい。

例:

```text
[StateMachine]
状態: loaded
Event: RefreshRequested
状態: refreshing
Effect: FetchPackage
```

ただし、Secret を Log に出力してはならない。禁止対象は [`security_spec.md`](./security_spec.md) を正本とする。

## Testing

検証項目は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、状態機械が外部 I/O なしで、Given 状態 / When Event / Then 状態の形式で検証できることだけを定める。

## Reducer Test

遷移表は `## Transition Table` を正本とする。検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、Reducer を Table-driven に検証できる純関数として設計することだけを定める。

## Invariant Test

ドメイン不変条件は [`domain_rules.md`](./domain_rules.md)、Credential を状態に入れないことは [`application_state.md`](./application_state.md) / [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、各 Transition 後に `assertValidState` できることだけを定める。

## Effect Test

検証項目は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、Effect を Reducer から分離し、結果を Event で戻すことだけを定める。

## Property-based/Invariant Testing

可能な範囲で状態機械の Property Test を導入する。

例:

`AddFavorite(AddFavorite(state))` を何回実行しても、`isFavorite == true` であること。

また、`RemoveFavorite(RemoveFavorite(state))` を何回実行しても、`isFavorite == false` であること。

## Acceptance Criteria

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。状態の分類・復元は [`application_state.md`](./application_state.md) を正本とする。本仕様の合格条件は、Reducer が I/O を持たず、Effect が結果を Event で戻し、Core がプラットフォーム API に依存しないこととする。

## Summary

一方向データフローと Reducer / Effect の分離は `## Design Principles` を正本とする。本仕様は、同一の Transition Semantics を SwiftUI / Compose / KMP commonMain で共有できることだけを再掲する。
