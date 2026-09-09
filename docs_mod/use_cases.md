# S2J Package Dashboard - ユースケース仕様

**Status:** Draft

関連ファイルの名簿は [`specs.md`](./specs.md) を正本とする。本仕様の分担は `## 非責務` を正本とする。

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、**ユースケース** を定義します。

本仕様は、アプリケーション Layer / Domain Layer の設計およびテストケース定義の基準とする。

ユースケースは、ユーザーまたは外部 Actor が S2J Package Dashboard を利用して達成したい目的を、アプリケーションの振る舞いとして定義する。

本仕様では、ユースケース (何を達成するか)、UX Flow (どの操作・状態を経由するか)、Screen/UI (どう表示するか) を明確に区別する。経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、画面は [`screen_spec.md`](./screen_spec.md) を正本とする。

実装開始前に MVP ユースケースを確定し、各ユースケースについて Main Flow/Error Flow/Offline Flow を確定する。

実装後は、ユースケースをアプリケーション/Integration/UI Test のシナリオにマッピングする。

## 目的

本仕様の目的は下記とする。

1. S2J Package Dashboard の主要なユーザー目的を明確化する
2. アプリケーション Layer の責務を明確化する
3. Domain Logic と UI Logic を分離する
4. iOS/iPadOS/Android で共通するアプリケーション Behavior を定義する
5. KMP Shared Logic の候補を明確化する
6. UX Flow/Screen/API/Storage の仕様との境界を明確化する
7. テスト対象となる Business Scenario を明確化する

## 非目的

本仕様は、UI Layout、色/タイポグラフィ、SwiftUI/Compose 実装、Navigation API、API エンドポイント、Database スキーマ、キャッシュ TTL、Keychain/Keystore 設定を直接定義しない。

## 責務

ユーザーまたは外部 Actor が達成したい目的を定義する。正本とするのは Actor、Goal、事前条件、成功条件、失敗の種類である。

## 非責務

操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、画面の表示内容は [`screen_spec.md`](./screen_spec.md)、行き先と戻り方は [`navigation_spec.md`](./navigation_spec.md)、共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md)、遷移の形式は [`state_machine.md`](./state_machine.md)、復元対象は [`application_state.md`](./application_state.md)、横断 UI は [`ui.md`](./ui.md)、Viewport は [`ui-viewport.md`](./ui-viewport.md)、検証の種類は [`testing_spec.md`](./testing_spec.md)、エラー型は [`models_spec.md`](./models_spec.md) を正本とする。

## シナリオ分担

同一シナリオを次の4問に分ける。

| 問い | 正本 |
| --- | --- |
| 誰が何を達成するか | 本仕様 |
| どの状態をどの順で通るか | [`ux_flows_spec.md`](./ux_flows_spec.md) |
| その画面は何を出すか | [`screen_spec.md`](./screen_spec.md) |
| 行き先と戻り方 | [`navigation_spec.md`](./navigation_spec.md) |

## Actor

### 1. Primary Actor

#### User

S2J Package Dashboard を利用するユーザー。

主な目的:

* 自分が管理する Package を確認する
* Favorite Package を管理する
* Package の詳細を確認する
* Statistics を確認する
* 最新データを取得する
* Authentication を管理する
* Local Data を管理する

### 2. External Actors

#### Packagist

Package Metadata および Composer Package Statistics の提供元。扱う指標は [`statistics_spec.md`](./statistics_spec.md)、API の詳細は [`api-packagist.md`](./api-packagist.md) を正本とする。

#### GitHub

リポジトリ Metadata および GitHub Statistics の提供元。扱う指標は [`statistics_spec.md`](./statistics_spec.md)、API の詳細は [`api-github.md`](./api-github.md) を正本とする。

#### Operating System

下記を提供する Platform Actor とする。

* Secure Credential Storage
* アプリケーション Lifecycle
* Navigation
* Window / Viewport
* Accessibility
* バックアップ/ Restore
* Network Connectivity

Platform-specific implementation は下記を Source of Truth とする。

* [`ios_spec.md`](./ios_spec.md)
* [`android_spec.md`](./android_spec.md)

## ユースケース Relationship

ユースケースは他のユースケースを Include / Extend できる。

たとえば: `UC-05: Package Detail` は `UC-23` (キャッシュ更新) と `UC-09` (Package 更新) を含み得る。`UC-12: Statistics Refresh` は `UC-14` (スナップショット保存) と `UC-23` を含み得る。`UC-16: Packagist Authentication` は `UC-20` (Authentication Status 確認) を含み得る。

ただし、Include / Extend の関係は実装上の Function Call 関係を意味しない。

## ユースケースと UX Flow の関係

ユースケースは目的、UX Flow は具体的な利用経路を表す。同じユースケースに対して複数の UX Flow が存在してよい。経路の正本は [`ux_flows_spec.md`](./ux_flows_spec.md) とする。

例: `UC-05: Package Detail を表示する` は、Dashboard から、検索から、Deep Link から、それぞれ異なる経路で達成できる。

## ユースケースと Screen の関係

1Screen が複数のユースケースを提供してもよい。

たとえば Package Detail は、表示 (UC-05)、Favorite 追加/削除 (UC-06/07)、リポジトリを開く (UC-08)、更新 (UC-09)、統計表示/更新 (UC-10/12) を提供し得る。画面の構成は [`screen_spec.md`](./screen_spec.md) を正本とする。

逆に、1ユースケースが複数 Screen にまたがってもよい。

たとえば Authentication は Settings → Authentication → System Authentication UI → Settings と複数 Screen にまたがり得る。画面と経路は [`screen_spec.md`](./screen_spec.md) / [`navigation_spec.md`](./navigation_spec.md) / [`authentication_spec.md`](./authentication_spec.md) を正本とする。

## ユースケースと API の関係

エンドポイントは [`api-packagist.md`](./api-packagist.md) / [`api-github.md`](./api-github.md) を正本とする。本仕様は、ユースケースがエンドポイントに直接依存せず、リポジトリ / Provider 抽象を介することだけを定める。

## ユースケースと Storage の関係

ユースケースは Storage Implementation に直接依存しない。永続化 HOW は [`storage_spec.md`](./storage_spec.md) / [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、ユースケースから見た Storage をリポジトリ Interface として抽象化することだけを定める。

## ユースケースと KMP

共有対象と優先順位は [`architecture.md`](./architecture.md)、HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、ユースケースの Goal / 成功条件がプラットフォーム UI に依存しないことだけを定める。

### Candidate

共有候補の一覧は [`architecture.md`](./architecture.md) の共有ロジック対象を正本とする。

## Platform-specific ユースケース

Navigation / Deep Link / Orientation / About Window 等の HOW は [`navigation_spec.md`](./navigation_spec.md) / [`ui-viewport.md`](./ui-viewport.md) / [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、それらの Goal の意味論を共通化できる場合に共有対象としてよいことだけを定める。

## ユースケース状態 Model

遷移の形式は [`state_machine.md`](./state_machine.md) を正本とする。本仕様は、ユースケース実行を Idle / Executing / Success / Failure / Cancelled として扱い、オフライン時は Local Data を結果として返してよいことだけを定める。

## ユースケース Result

ユースケースの Result は UI 表示そのものを返さない。Domain / アプリケーション Model、または `Result<T, ApplicationError>` を返す。SwiftUI.View / Composable / NavigationStack / Alert / Sheet / Toast を返してはならない。

## Error Model

エラー型は [`models_spec.md`](./models_spec.md)、境界の分類は [`architecture.md`](./architecture.md) を正本とする。本仕様は、ユースケースが `ApplicationError` を返し、Provider-specific Exception を UI に直接公開しないことだけを定める。

## Idempotency

可能なユースケースは Idempotent に設計する。

たとえば Favorite の追加:

`Add Favorite` を二回実行しても `Favorite = true` という一つの状態になることを基本とする。スナップショットの Deduplication は [`domain_rules.md`](./domain_rules.md) を正本とする。

## Concurrency

同一ユースケースが短時間に複数回実行された場合の挙動を定義する。

たとえば `Refresh`:

`Refresh`、`Refresh`、`Refresh` が同時実行される場合、`Request 1`、`Request 2`、`Request 3` を無制限に Provider に送信してはならない。

必要に応じて、

* Deduplication
* Request Coalescing
* Cancellation
* Latest Request Wins

等を採用する。

具体的なキャッシュ/ Request Policy は [`cache_spec.md`](./cache_spec.md) を Source of Truth とする。

## Accessibility

アクセシビリティは [`ui.md`](./ui.md) を正本とする。本仕様は、主要ユースケースの Goal が Accessibility 操作でも達成できることだけを定める。

## Adaptive UI

Viewport / List-Detail は [`ui-viewport.md`](./ui-viewport.md) / [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、ユースケースの Goal が Viewport Size に依存しないことだけを定める。

## 状態 Restoration

復元対象は [`application_state.md`](./application_state.md) を正本とする。本仕様は、中断したユースケース Context (例: Package / Period) を可能な範囲で再開し、古い Remote Data を「最新」として扱わないことだけを定める。

## ユースケース Acceptance Criteria

すべてのユースケースは下記を定義する。

* [ ] ID
* [ ] Name
* [ ] Goal
* [ ] Primary Actor
* [ ] Preconditions
* [ ] Main Flow
* [ ] Alternative Flow
* [ ] Error Flow
* [ ] Postconditions
* [ ] Related Specifications

必要に応じて下記も定義する。

* [ ] Invariants
* [ ] Concurrency
* [ ] Offline Behavior
* [ ] Accessibility
* [ ] 状態 Restoration

## ユースケース Classification

ユースケースを下記に分類する。

* UC-01 - UC-09: Package 管理
* UC-10 - UC-15: Statistics
* UC-16 - UC-20: Authentication
* UC-21 - UC-25: Storage/Offline
* UC-26 - UC-30: Navigation/状態
* UC-31～: アプリケーション Administration

ユースケース ID は将来的に追加できるものとする。

## ユースケース一覧

| ID | ユースケース | Primary Actor | 経路の正本 |
| --- | --- | --- | --- |
| UC-01 | Dashboard を表示する | User | App Launch / Dashboard / Offline Flow |
| UC-02 | Managed Package を取得する | User | Maintained Package Flow |
| UC-03 | Package List を表示する | User | Dashboard / Maintained / Favorite Package Flow |
| UC-04 | Package を検索する | User | Package Search Flow |
| UC-05 | Package Detail を表示する | User | Package Detail Flow |
| UC-06 | Favorite を追加する | User | Favorite Package Flow |
| UC-07 | Favorite を削除する | User | Favorite Package Flow |
| UC-08 | リポジトリを開く | User | Package Detail Flow |
| UC-09 | Package を更新する | User | Refresh Flow |
| UC-10 | Statistics を表示する | User | Statistics Flow |
| UC-11 | Statistics Period を変更する | User | Statistics Flow |
| UC-12 | Statistics を Refresh する | User | Statistics Flow / Refresh Flow |
| UC-13 | Historical Statistics を表示する | User | Statistics Flow |
| UC-14 | Statistics スナップショットを保存する | System | Refresh Flow (生成の不変条件は domain_rules) |
| UC-15 | Statistics Source を確認する | User | Statistics Flow (表示は screen_spec) |
| UC-16 | Packagist Authentication を設定する | User | Authentication Flow / Settings Flow |
| UC-17 | GitHub Authentication を設定する | User | Authentication Flow / Settings Flow |
| UC-18 | Credential を更新する | User | Authentication Flow / Settings Flow |
| UC-19 | Credential を削除する | User | Authentication Flow / Settings Flow |
| UC-20 | Authentication Status を確認する | User | Authentication Flow |
| UC-21 | Local Data を表示する | User | App Launch / Offline Flow |
| UC-22 | Offline Data を利用する | User | Offline Flow |
| UC-23 | キャッシュを更新する | System | Refresh Flow (TTL は cache_spec) |
| UC-24 | Local Data を削除する | User | Data Deletion Flow |
| UC-25 | Storage を Reset する | User | Data Deletion Flow |
| UC-26 | Navigation 状態を復元する | System | 状態 Restoration Flow |
| UC-27 | Deep Link から Package を表示する | User | Deep Link Flow |
| UC-28 | Back Navigation を実行する | User | Back Navigation Flow |
| UC-29 | Orientation / Window Size Change に対応する | System | Orientation Change / Window Resize Flow |
| UC-30 | アプリケーション状態を復元する | System | 状態 Restoration Flow |
| UC-31 | Settings を変更する | User | Settings Flow |
| UC-32 | About を表示する | User | About Flow |
| UC-33 | Error から復旧する | User | Error Recovery Flow |
| UC-34 | Data Export を実行する | User | MVP 対象外。将来は Settings Flow |
| UC-35 | Data Import を実行する | User | MVP 対象外。将来は Settings Flow |

## MVP ユースケース

初期 MVP では、下記を優先する。

### Priority-1

* UC-01: Dashboard
* UC-02: Managed Package
* UC-03: Package List
* UC-05: Package Detail
* UC-06: Add Favorite
* UC-07: Remove Favorite
* UC-09: Refresh Package
* UC-10: Statistics
* UC-11: Statistics Period
* UC-12: Refresh Statistics
* UC-13: Historical Statistics
* UC-21: Local Data
* UC-22: Offline
* UC-33: Error Recovery

### Priority-2

* UC-04: Package Search
* UC-16: Packagist Authentication
* UC-17: GitHub Authentication
* UC-18: Credential Update
* UC-19: Credential Delete
* UC-20: Authentication Status
* UC-26: 状態 Restoration
* UC-27: Deep Link
* UC-31: Settings
* UC-32: About

### Future

* UC-34: Data Export
* UC-35: Data Import
* Cloud 同期
* External 同期
* Cross-platform データ同期

## ユースケース Test Matrix

| ユースケース | Normal | Empty | Error | Offline | Auth | Restore |
| --- | --- | --- | --- | --- | --- | --- |
| UC-01: Dashboard | ✓ | ✓ | ✓ | ✓ | - | ✓ |
| UC-02: Managed Package | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| UC-03: Package List | ✓ | ✓ | - | ✓ | - | ✓ |
| UC-04: Search | ✓ | ✓ | ✓ | ✓ | - | - |
| UC-05: Detail | ✓ | ✓ | ✓ | ✓ | - | ✓ |
| UC-06: Favorite | ✓ | - | ✓ | ✓ | - | - |
| UC-07: Unfavorite | ✓ | - | ✓ | ✓ | - | - |
| UC-09: Refresh | ✓ | - | ✓ | ✓ | ✓ | - |
| UC-10: Statistics | ✓ | ✓ | ✓ | ✓ | - | ✓ |
| UC-12: Statistics Refresh | ✓ | - | ✓ | ✓ | ✓ | - |
| UC-13: Historical | ✓ | ✓ | - | ✓ | - | ✓ |
| UC-16: Packagist Auth | ✓ | - | ✓ | - | ✓ | - |
| UC-17: GitHub Auth | ✓ | - | ✓ | - | ✓ | - |
| UC-22: Offline | ✓ | ✓ | ✓ | ✓ | - | - |
| UC-26: Navigation Restore | ✓ | - | ✓ | - | - | ✓ |
| UC-33: Error Recovery | ✓ | - | ✓ | ✓ | ✓ | - |

## UC-01: Dashboard を表示する

### Goal

ユーザーが Package Dashboard の現在の状態を把握する。

### Preconditions

* アプリケーションが起動している
* Local Data を利用可能

### Success

Maintained / Favorite / 統計サマリの現状が把握できる。ローカルがなければ初回取得として扱える。オフラインならローカル表示として扱える。

操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の App Launch / Dashboard / Offline Flow を正本とする。画面の表示内容は [`screen_spec.md`](./screen_spec.md) を正本とする。

### Alternative

* Local Data がない: 初回取得として扱う。
* Network が使えない: ローカルを表示し、オフラインであることを誤認させない。

### Related

* [`ux_flows_spec.md`](./ux_flows_spec.md)
* [`screen_spec.md`](./screen_spec.md)
* [`storage_spec.md`](./storage_spec.md)

## UC-02: Managed Package を取得する

### Goal

ユーザーが Packagist 上で管理している Package を取得する。

### Preconditions

* Packagist の情報を取得可能である
* 必要な Authentication が設定されている場合、その Credential が有効である

### Success

管理対象 Package がローカルに正規化されて保持され、一覧から確認できる。公開情報だけで足りる場合は Authentication を要求しない。認証失敗は再認証可能な失敗として扱う。

操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Maintained Package Flow を正本とする。

## UC-03: Package List を表示する

### Goal

ユーザーが Package の一覧を確認する。

### Success

Maintained / Favorite 等の分類で一覧を確認できる。空なら Empty として扱い、偽の行を出さない。

分類と行の表示は [`screen_spec.md`](./screen_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Dashboard / Maintained / Favorite Package Flow を正本とする。

## UC-04: Package を検索する

### Goal

ユーザーが Package Name または Search Query から Package を探す。

### Success

妥当な Query に対して検索結果を得られる。結果なしは Empty、通信失敗は Retry 可能な Error とする。

操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Package Search Flow を正本とする。API は [`api-packagist.md`](./api-packagist.md) とする。

## UC-05: Package Detail を表示する

### Goal

ユーザーが特定 Package の詳細情報を確認する。

### Success

選択した Package の詳細を確認できる。未取得/Stale は再取得し、見つからない場合は Error / Empty とする。

表示内容は [`screen_spec.md`](./screen_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Package Detail Flow を正本とする。

## UC-06: Favorite を追加する

### Goal

ユーザーが Package を Favorite として登録する。

### Success

Package が Favorite として登録され、Favorite 一覧に現れる。

### Postconditions

* Package が Favorite として登録される
* Favorite Package List に表示される

### Invariant

Favorite と Maintained は独立である。関係の正しさは [`domain_rules.md`](./domain_rules.md) を正本とする。

操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Favorite Package Flow を正本とする。

## UC-07: Favorite を削除する

### Goal

ユーザーが Favorite を解除する。

### Success

Favorite 関係だけが外れ、Package Data 自体は残る。確認が必要な場合は確認後に削除する。

### Postconditions

* Favorite Relationship が削除される
* Package Data 自体は削除されない

操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Favorite Package Flow を正本とする。

## UC-08: リポジトリを開く

### Goal

Package に関連付けられたリポジトリを確認する。

### Success

正規化されたリポジトリ URL を、プラットフォームの標準的な外部 URL 遷移で開く。アプリケーションは外部リポジトリの Web UI を内部で再実装しない。

URL の正規化は [`domain_rules.md`](./domain_rules.md) / [`api-github.md`](./api-github.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Package Detail Flow を正本とする。

## UC-09: Package を更新する

### Goal

Package の Local Data を最新状態に更新する。

### Success

最新データを取得して保持し、UI に反映する。既存データがある間は Refresh 中も可能な限り既存データを表示する。

操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Refresh Flow を正本とする。

## UC-10: Statistics を表示する

### Goal

Package の現在および過去の Statistics を確認する。

### Success

スナップショットと最新指標から Statistics を確認できる。指標の意味は [`statistics_spec.md`](./statistics_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Statistics Flow、画面は [`screen_spec.md`](./screen_spec.md) を正本とする。

## UC-11: Statistics Period を変更する

### Goal

ユーザーが Statistics の表示期間を変更する。

候補:

* `7 days`
* `30 days`
* `90 days`
* `1 year`
* All

### Success

選択した期間の利用可能データだけでチャートが更新される。存在しない期間を Zero として扱わない。不変条件は [`domain_rules.md`](./domain_rules.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Statistics Flow を正本とする。

## UC-12: Statistics を Refresh する

### Goal

最新 Statistics を取得する。

### Success

プロバイダ取得に成功したらスナップショットを保存し、チャートを更新する。失敗時は既存データと Stale 表示を残し、Retry できる。

生成の不変条件は [`domain_rules.md`](./domain_rules.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Statistics Flow / Refresh Flow を正本とする。

## UC-13: Historical Statistics を表示する

### Goal

スナップショットにもとづいて Statistics の推移を確認する。

### Success

期間内のスナップショット時系列を確認できる。

### Invariant

スナップショットの Collection Time と Metric を維持する。Missing Data を Zero に変換しない。正本は [`domain_rules.md`](./domain_rules.md)。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Statistics Flow を正本とする。

## UC-14: Statistics スナップショットを保存する

### Actor

System

### Goal

将来の Historical Statistics を構築するため、取得した Metric をスナップショットとして保存する。

### Success

検証済みの取得結果がスナップショットとして永続化される。

### Invariant

スナップショットは原則 Immutable とする。既存スナップショットを上書きしない。正本は [`domain_rules.md`](./domain_rules.md)。永続化は [`storage_spec.md`](./storage_spec.md)。

経路上は [`ux_flows_spec.md`](./ux_flows_spec.md) の Refresh Flow に付随する。

## UC-15: Statistics Source を確認する

### Goal

ユーザーが表示されている Metric の Source と Collection Time を確認する。

### Success

各 Metric について Source (Packagist / GitHub) と Collected 時刻が省略されない。表示は [`screen_spec.md`](./screen_spec.md)、意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## UC-16: Packagist Authentication を設定する

### Goal

Packagist の Authentication が必要な機能を利用できる状態にする。

### Success

Credential を検証して Secure Storage に保存し、認証済みとして扱える。Password の保存を基本としない。必要な場合は SAFE Token を優先する。

方針は [`authentication_spec.md`](./authentication_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Authentication Flow / Settings Flow を正本とする。

## UC-17: GitHub Authentication を設定する

### Goal

GitHub の authenticated API access が必要な機能を利用できる状態にする。

### Success

最小権限で認可し、検証済み Credential を Secure Storage に保存する。

具体仕様は [`api-github.md`](./api-github.md) / [`authentication_spec.md`](./authentication_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Authentication Flow / Settings Flow を正本とする。

## UC-18: Credential を更新する

### Goal

既存 Credential を新しい Credential に変更する。

### Success

新しい Credential の検証に成功してから置換する。Invalid な新 Credential によって、既存の有効 Credential を先に破壊しない。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Authentication Flow / Settings Flow を正本とする。

## UC-19: Credential を削除する

### Goal

ユーザーが保存済み Credential を削除する。

### Success

確認のうえ Secure Storage から Credential だけを削除する。

### Postconditions

* Credential は Secure Storage から削除される
* Package Data は削除されない
* Favorite は削除されない
* Statistics スナップショットは削除されない

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Authentication Flow / Settings Flow を正本とする。

## UC-20: Authentication Status を確認する

### Goal

ユーザーまたはアプリケーションが Authentication 状態を確認する。

### Success

次の状態を Credential の実体と区別して確認できる。

* Not Configured
* Configured
* Authenticated
* Invalid
* Expired
* Revoked

状態の意味は [`authentication_spec.md`](./authentication_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Authentication Flow を正本とする。

## UC-21: Local Data を表示する

### Goal

Network に依存せず、保存済み Local Data を表示する。

### Success

Package / Favorite / スナップショット / Settings をローカルから表示できる。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の App Launch / Offline Flow を正本とする。

## UC-22: Offline Data を利用する

### Goal

Network が利用できない状態でも、既存 Local Data を利用する。

### Success

ローカルがある場合はそれを表示し、Offline と Last Updated を示して最新データであると誤認させない。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Offline Flow を正本とする。

## UC-23: キャッシュを更新する

### Actor

System

### Goal

API Request の不要な再実行を抑制する。

### Success

Fresh ならキャッシュを使い、Stale なら再取得する。TTL / Freshness は [`cache_spec.md`](./cache_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Refresh Flow を正本とする。

## UC-24: Local Data を削除する

### Goal

ユーザーが指定した Local Data を削除する。

対象:

* Package Data
* Favorite
* Statistics スナップショット
* キャッシュ

### Success

確認のうえ指定データを削除する。Credential は本ユースケースに含めない (UC-19)。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Data Deletion Flow を正本とする。

## UC-25: Storage を Reset する

### Goal

アプリケーションの Local 状態を初期状態に戻す。

### Success

確認のうえ Local Data を削除し、初期状態に戻る。Credential の削除を含める場合はユーザーに明示する。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Data Deletion Flow を正本とする。

## UC-26: Navigation 状態を復元する

### Actor

System

### Goal

アプリケーション再起動後、可能な限りユーザーが最後に見ていた Navigation Context を復元する。

### Success

妥当な Navigation 状態を復元する。対象がない/不正なら `Dashboard` を Default Destination とする。

保持対象は [`application_state.md`](./application_state.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の状態 Restoration Flow、Destination は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## UC-27: Deep Link から Package を表示する

### Goal

外部から指定された Package を直接表示する。

### Success

Identifier を解決して Package Detail を表示する。未所持なら取得してから表示する。Invalid / Not Found は Error とする。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Deep Link Flow、Route は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## UC-28: Back Navigation を実行する

### Goal

ユーザーが現在の Navigation Context から前の Context に戻る。

### Success

前の Context に戻れる。Multi-Pane では Back が「前の Screen」と一致しないことがあり、List-Detail の選択変更は同一 UX Context 内の変更として扱ってよい。

経路の意味は [`ux_flows_spec.md`](./ux_flows_spec.md) の Back Navigation Flow、実装は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## UC-29: Orientation / Window Size Change に対応する

### Actor

System

### Goal

Viewport が変化しても、現在の UX Context を維持する。

### Success

表示構造が変わっても、同じ Package Detail を「開き直した」ことにはならない。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Orientation Change / Window Resize Flow、Layout は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## UC-30: アプリケーション状態を復元する

### Actor

System

### Goal

アプリケーションの中断/Process Termination 等の後に、可能な範囲で以前の状態を復元する。

対象:

* Navigation 状態
* Selected Package
* Statistics Period
* Filter
* Sort Order
* Split View Selection

### Success

復元対象として定義された状態が、可能な範囲で戻る。何を残すかは [`application_state.md`](./application_state.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の状態 Restoration Flow を正本とする。

## UC-31: Settings を変更する

### Goal

ユーザーがアプリケーション Preferences を変更する。

対象例:

* Statistics Period
* Refresh Policy
* Display Preference
* Sort Order
* Appearance

### Success

妥当な設定が永続化され、即座に適用される。設定変更によってアプリケーション Data を削除しない。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Settings Flow を正本とする。

## UC-32: About を表示する

### Goal

ユーザーがアプリケーション情報を確認する。

### Success

既存の S2J About Window でアプリケーション情報を確認できる。実装詳細は既存パッケージの仕様に従う。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の About Flow を正本とする。

## UC-33: Error から復旧する

### Goal

ユーザーがエラー発生後にアプリケーションを利用可能な状態に戻す。

### Error Categories

* Network Error
* Authentication Error
* Rate Limit
* Provider Error
* Data Error
* Persistence Error

### Success

失敗理由が分かり、次のいずれかで復旧できる。Retry / Use Local Data / Re-authenticate / Open Settings / Back。

経路は [`ux_flows_spec.md`](./ux_flows_spec.md) の Error Recovery Flow、横断表示は [`ui.md`](./ui.md) を正本とする。

## UC-34: Data Export を実行する

### Goal

ユーザーが Local Data または Statistics を外部 File として保存する。

### Initial Scope

MVP では必須としない。

### Success (将来)

対象データを選び、Credential を含めない File を System Share / Save で保存できる。

## UC-35: Data Import を実行する

### Goal

Export 済みのアプリケーション Data を Import する。

### Initial Scope

MVP では必須としない。

### Success (将来)

File を検証、Preview した後で Import する。不正な File によって既存データを破壊しない。
