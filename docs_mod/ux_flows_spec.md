# S2J Package Dashboard - UX フロー仕様

**Status:** Draft

本仕様は、実装および実機テストを通じて継続的に更新する。

特に下記の UX Flow は MVP 実装前に確定する。

1. App Launch
2. Dashboard
3. Maintained Package
4. Favorite Package
5. Package Detail
6. Statistics
7. Refresh
8. Offline
9. Error Recovery
10. Authentication
11. Settings
12. 状態 Restoration

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、**User Experience Flow (UX Flow)** を定義します。

UX Flow とは、ユーザーが特定の目的を達成するために、

* 経由する画面・状態は、何か
* 実行する操作は、何か
* アプリケーションがどのように応答するか
* 成功・失敗・中断時にどの状態に遷移するか

を定義したものである。

本仕様では、個々の UI の外観や具体的な Navigation API は定義しない。

分離は `## シナリオ分担` を正本とする。

したがって、本仕様は iOS/iPadOS/Android で共通の UX 意味論を定義し、各 Platform における具体的な UI 表現は [`navigation_spec.md`](./navigation_spec.md)、[`screen_spec.md`](./screen_spec.md)、[`ui.md`](./ui.md) に委ねる。

## 目的

UX Flow は下記を目的とする。

1. ユーザーが主要な目的を迷わず達成できること
2. 操作の結果をユーザーが予測できること
3. Loading/Error/Empty/Offline 等の状態を明確に扱うこと
4. iPhone/iPad/Android で同一の目的・意味論を維持すること
5. Navigation UI と UX Flow を分離すること
6. Deep Link/状態 Restoration を考慮した Flow を定義すること
7. 実装において、期待するユーザー行動を明確にすること

## 非目的

本仕様は、Screen の具体 Layout、色/タイポグラフィ、Component の Visual Design、SwiftUI/Compose の具体実装を目的としない。

## 責務

ユーザーがどの画面・状態を経由し、何をすると、成功/失敗/中断でどこに行くかを正本として定義する。

## 非責務

ユースケースの目的は [`use_cases.md`](./use_cases.md)、ナビゲーションは [`navigation_spec.md`](./navigation_spec.md)、画面は [`screen_spec.md`](./screen_spec.md)、横断 UI は [`ui.md`](./ui.md)、復元対象は [`application_state.md`](./application_state.md)、遷移の形式は [`state_machine.md`](./state_machine.md)、向き / Window は [`ui-viewport.md`](./ui-viewport.md)、検証の種類は [`testing_spec.md`](./testing_spec.md)、共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md)、API/ストレージ/キャッシュ/Credential は各専門仕様を正本とする。

## シナリオ分担

| 問い | 正本 |
| --- | --- |
| 誰が何を達成するか | [`use_cases.md`](./use_cases.md) |
| どの状態をどの順で通るか | 本仕様 |
| その画面は何を出すか | [`screen_spec.md`](./screen_spec.md) |
| 行き先と戻り方 | [`navigation_spec.md`](./navigation_spec.md) |

## UX Flow の基本モデル

UX Flow は下記の形式で表現する。

1. User Goal
2. Entry Point
3. Initial 状態
4. User Action
5. アプリケーション Response
6. Next 状態/Destination
7. Goal Completion

エラーや中断が発生する場合は、別の Branch を持つ。

User Action の Result に応じて:

* Success → Next 状態
* Error → Error 状態
* Empty → Empty 状態
* Cancel → Previous 状態

## UX Flow と Navigation の責務分離

UX Flow は「どの状態をどの順で通るか」を定義する。表示構造 (Stack / Split / Compact) は [`navigation_spec.md`](./navigation_spec.md) を正本とする。同じ経路でも、iPhone の push と iPad の2ペインはナビゲーション側で変えてよい。

## Entry Point

アプリケーションへの入口は下記を想定する。

1. App Launch
2. Dashboard
3. Package List
4. Package Detail
5. Statistics
6. Settings
7. Deep Link
8. Notification / External Launch
9. 状態 Restoration

初期バージョンでは Notification / External Launch が存在しない場合でも、将来、追加可能な構造とする。

## App Launch Flow

### 1. 初回起動

経路: Launch → Local Configuration → Auth 状態確認 → Local Data → Dashboard。初回に認証を必須にしないことは [`authentication_spec.md`](./authentication_spec.md) を正本とする。

### 2. 既存ユーザー

経路: Launch → 状態 Restoration → 前回の Navigation。復元対象は [`application_state.md`](./application_state.md)、fallback Destination は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## Initial Data Load Flow

Dashboard 表示時に必要なデータが存在しない場合は、Provider から取得する。

キャッシュ/Local があれば Display。なければ Fetch して Display。

取得対象には下記を含む。

* Packagist package metadata
* Packagist download statistics
* GitHub リポジトリ metadata
* GitHub statistics
* Maintained Package information
* Favorite Package information

## Dashboard Flow

### 1. Dashboard 表示

Dashboard はユーザーが現在の Package 状況を把握するための起点とする。

Dashboard に何を出すかは [`screen_spec.md`](./screen_spec.md)、行き先は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本 Flow は、Dashboard を起点に Maintained / Favorite / Statistics / Settings へ進む経路だけを定義する。

## Maintained Package Flow

### 1. 管理パッケージの表示

経路: Dashboard → Maintained Packages → Package List。

ユーザーが Packagist 上で管理する Package を取得し、一覧表示する。

### 2. Package 選択

Package を選択すると Package Detail へ進む。表示内容は [`screen_spec.md`](./screen_spec.md) を正本とする。

## Favorite Package Flow

### 1. Favorite 追加

ユーザーは、自身が Maintainer ではない Package を Favorite として登録できる。

1. Package Detail
2. Add Favorite
3. Favorite 状態 = Active
4. Favorite Packages に出る

Favorite は Maintained Package とは独立した概念とする。

### 2. Favorite 削除

1. Package Detail
2. Remove Favorite
3. Confirm
4. Favorite 状態 = Inactive

削除後も Package 自体の情報は、他の参照元から取得可能であれば保持してよい。

Favorite の削除は Package の削除とは異なる。

## Package Search Flow

Package Search を実装する場合は下記の Flow とする。

1. Package List
2. Search
3. Query
4. Search Packagist
5. Result
6. Select
7. Package Detail

### Search Result が存在しない場合

1. Search
2. No Result
3. Empty 状態

### Network Error

1. Search
2. Network Error
3. Error 状態
4. Retry

Search の詳細仕様は [`api-packagist.md`](./api-packagist.md) を Source of Truth とする。

## Package Detail Flow

Package Detail は Package の情報を集約して表示する。何を出すかは [`screen_spec.md`](./screen_spec.md) を正本とする。本 Flow は、Detail へ入り、Statistics / 外部リポジトリ / Favorite へ進む経路だけを定義する。

外部リポジトリを開く場合は、Platform の標準的な外部 URL 遷移を使用する。

## Statistics Flow

### 1. Statistics 表示

1. Package Detail
2. Statistics
3. Select Period
4. Display Chart

対象となる期間の候補:

* `7 days`
* `30 days`
* `90 days`
* `1 year`
* All available

期間は実装時の UX および取得可能なスナップショット範囲に応じて調整する。

### 2. Statistics Source

Statistics は Provider ごとに Source を区別する。指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## Refresh Flow

### 1. Manual Refresh

ユーザーが明示的に Refresh を実行した場合:

1. Current 状態
2. Refresh
3. Refreshing
4. Fetch Latest
5. Update キャッシュ/スナップショット
6. Loaded

既存データが存在する場合、Refresh 中も可能な限り既存データを表示する。

Loaded → Refreshing でも既存データを表示 → New Data。

### 2. Refresh Failure

Refreshing → Network Error → Stale Data。

既存データが存在する場合は、データを完全に消去して Error Screen に置き換えるのではなく、既存データ + Stale/Error Indicator + Retry を同時表示する状態を優先する。

## Offline Flow

ネットワーク接続が利用できない場合でも、Local Data が存在する場合は可能な範囲でアプリケーションを利用可能とする。

Launch → Network Unavailable → Local Data Available → キャッシュ済み表示。

Local Data が存在しない場合:

Launch → Network Unavailable → No Local Data → Offline Empty/Error。

ユーザーには、

* Offline
* Last Updated
* Retry

を明示する。

## Error Recovery Flow

Error は「終了状態」ではなく、可能な限り Recovery Action を提供する。

* Retry
* Use キャッシュ
* Cancel / Back

エラーの種類に応じて Recovery Action を変更する。

### Network Error

* Retry
* Use キャッシュ Data

### Authentication Error

* Re-authenticate
* Open Settings

### Rate Limit

* Wait
* Retry Later
* Use キャッシュ Data

### Invalid Package

* Back
* Remove Package

## Authentication Flow

### 1. Authentication Required

実行内容: Authentication が必要な操作

1. User Action
2. Authentication Required
3. Auth UI
4. Authenticate
5. Return to Original Flow

認証後は、可能な限り元の操作を継続する。

### 2. Authentication Failure

Authenticate → Failure → Error → Retry または Cancel。

認証情報を無効化している場合は、ユーザーに再認証を促す。

### 3. Credential Removal

Settings から認証情報を削除する場合:

1. Settings
2. Authentication
3. Remove Credential
4. Confirm
5. Credential Deleted

Credential の削除によって Local Package Data や Favorite Data を自動的に削除してはならない。

認証情報とアプリケーション Data は別の Lifecycle を持つ。

## Settings Flow

Settings の画面構成は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、Settings が Dashboard の主要データ操作とは別経路であることだけを定める。

## About Flow

About の表示内容は [`screen_spec.md`](./screen_spec.md)、コンポーネント境界は [`component_spec.md`](./component_spec.md) を正本とする。本仕様は、Settings から About へ進む経路だけを定める。

`S2J About Window` 自体を Package Dashboard の UX Flow に再実装しない。

## Deep Link Flow

将来的な Deep Link を考慮し、Package Identifier を外部から指定できる構造とする。

例:

`s2jpackagedashboard://package/vendor/package`

Flow:

1. Parse Route
2. Resolve Package
3. Package Detail

Package が Local Data に存在しない場合:

Resolve → Fetch → Package Detail。

取得に失敗した場合:

Package Not Found → Error。

Deep Link の URI Scheme / Universal Link / Android App Link の具体仕様は [`navigation_spec.md`](./navigation_spec.md) で定義する。

## 状態 Restoration Flow

アプリケーションが中断・再起動された場合、可能な範囲でユーザーが最後に見ていた状態を復元する。

対象は [`application_state.md`](./application_state.md) を正本とする。本 Flow は、Restore Navigation 状態 → Restore Local Data → Display → Optional Refresh の順序だけを定める。

Apple の SwiftUI navigation でも NavigationPath 等を用いた navigation 状態の保持と状態 restoration が navigation architecture の一部として扱われている。([Bringing robust navigation structure to your SwiftUI app | Apple Developer Documentation](https://developer.apple.com/documentation/SwiftUI/Bringing-robust-navigation-structure-to-your-swiftui-app))

Android でも adaptive navigation では Window Size の変化を含む configuration change に対する continuity が重要であり、selected content 等を保存・復元する設計が想定されている。([Build a list-detail layout | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/list-detail))

## Orientation Change Flow

Orientation Change は UX Flow 上の新しい Screen 遷移とはみなさない。同じ Screen/状態を維持したまま Presentation Layout のみを変更する。向き / サイズクラスは [`ui-viewport.md`](./ui-viewport.md) を正本とする。本 Flow は、iPad の Portrait Detail が Landscape で List + Detail になっても Navigation Flow の変更ではなく Adaptive Layout の変更として扱うことだけを定める。

## Window Resize Flow

iPadOS / Android の Window Size が変化した場合も、Orientation Change と同様に Screen / UX Context を維持する。サイズクラスと Multi Pane / Single Pane は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本 Flow は、Window Resize を新しい Screen 遷移とみなさないことだけを定める。

Android の adaptive app では Expanded Window で複数 Pane、Compact / Medium では単一 Pane とする List-Detail パターンが公式に定義されている。([Get started with adaptive apps | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/get-started-with-adaptive-apps?hl=en))

## Back Navigation Flow

Back 操作は、ユーザーが直前の UX Context に戻るために使用する。行き先と戻り方は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本 Flow は、Back が「前の UX Context に戻る」こと、および Multi-Pane では Back が必ずしも前画面を意味しないことだけを定める。

たとえば Expanded Layout で Package List と Package Detail が同時に表示されている場合、Detail の変更は同一 UX Context 内の Selection Change として扱うことができる。

したがって Back の具体的な挙動は Platform Navigation Model に従う。

## Cancel Flow

ユーザーが操作をキャンセルした場合は、変更前の状態を可能な限り維持する。

対象:

* Authentication
* Add Favorite
* Remove Favorite
* Settings Change
* Search
* Filter
* Confirmation Dialog

Cancel は destructive action の確定とは異なる。

## Confirmation Flow

破壊的または不可逆な操作には Confirmation を使用する。

対象例:

* Credential Removal
* Favorite Removal
* Local Data Removal
* スナップショット Data Removal

基本 Flow:

User Action → Confirmation。Confirm なら Execute、Cancel なら Return。

単純な Navigation や一時的な Filter Change に Confirmation を要求しない。

## Data Deletion Flow

Local Data を削除する場合:

1. Settings
2. Storage
3. Delete Local Data
4. Confirmation
5. Delete
6. Completion

Storage Reset も同じ経路とする。Reset は初期状態へ戻す確認付き操作であり、Credential を含める場合は明示する。

削除対象は、アプリケーション Data と Credentials を明確に区別する。Credential の削除と Local Data の削除を一つの操作として暗黙に結合しない。対象の正本は [`storage_spec.md`](./storage_spec.md) / [`authentication_spec.md`](./authentication_spec.md) とする。

## UX 状態 Model

状態の分類は [`application_state.md`](./application_state.md)、遷移は [`state_machine.md`](./state_machine.md)、見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、各 UX 状態にユーザーが次に取れる Primary Action を対応づけることだけを定める。

| 状態 | Primary Action |
| --- | --- |
| Idle | Load |
| Loading | Wait |
| Loaded | Navigate/Refresh |
| Refreshing | Wait/Continue Viewing |
| Empty | Add/Search |
| Stale | Refresh |
| Offline | Retry/Use Local Data |
| Error | Retry/Back |
| AuthenticationRequired | Authenticate |

## Primary User Goals

主要 Goal と、対応するユースケース / Flow は下記とする。Goal そのものの正本は [`use_cases.md`](./use_cases.md)、経路は本仕様の各 Flow とする。

| Goal | ユースケース | Flow |
| --- | --- | --- |
| 自分の Package を確認する | UC-01 / UC-02 / UC-03 / UC-05 | App Launch / Dashboard / Maintained Package Flow |
| Package の統計を確認する | UC-10 / UC-11 | Statistics Flow |
| 気になる Package を登録する | UC-04 / UC-06 | Package Search / Favorite Package Flow |
| Package の最新状態を確認する | UC-09 | Refresh Flow |
| 過去の統計推移を確認する | UC-13 | Statistics Flow |
| オフラインでも直近の情報を見る | UC-21 / UC-22 | Offline Flow |
| 認証情報を管理する | UC-16〜 UC-19 | Authentication Flow / Settings Flow |

## UX Flow Error Handling Principles

エラーの見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、Error のあとに Explain と Recover (Retry / Existing Data / Settings / Back) を経路として示すことだけを定める。内部 API エラーや Stack Trace を直接表示しない。

## Loading Experience

Loading の見え方は [`ui.md`](./ui.md)、Refreshing の保持は [`application_state.md`](./application_state.md) を正本とする。本仕様は、Initial Load と既存データあり Refresh を別経路とし、既存データを消してから Loading に切り替えないことだけを定める。

## Empty 状態

Empty の見え方は [`ui.md`](./ui.md)、画面固有の Empty 文言は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、Empty を Error と区別し、可能な場合に次の Action を経路として示すことだけを定める。

## UX Flow と Data Lifecycle

永続化 / キャッシュ / 統計の Lifecycle は [`storage_spec.md`](./storage_spec.md) / [`cache_spec.md`](./cache_spec.md) / [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、ユーザーが何を見るかの経路だけを定める。

## UX Flow と Provider

Provider 固有の API 詳細を UX Flow に記述しない。Refresh は「最新の Package Data を取り、画面を更新する」と表現し、Packagist / GitHub の呼び出し順は [`api-packagist.md`](./api-packagist.md) / [`api-github.md`](./api-github.md) を正本とする。

## UX Flow and KMP

共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md)、Native Navigation は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、UX の意味論 (インテント / 経路 / 状態) を共有し、Toolbar / Sheet / Tab 等の表現をプラットフォームに委ねることだけを定める。

## Accessibility Flow

アクセシビリティは [`ui.md`](./ui.md) を正本とする。本仕様は、主要 Goal の経路が Accessibility 操作でも成立することだけを定める。

## UX Flow Test Scenarios

検証の種類は [`testing_spec.md`](./testing_spec.md)、向き / Window は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、各主要 Flow に下記パスがあることだけを定める。

### Normal

Entry → Action → Success

### Empty

Entry → No Data → Empty

### Error

Entry → Failure → Error → Retry

### Offline

Entry → No Network → Local Data

### Authentication

Entry → Authentication Required → Authenticate → Resume

### Cancellation

Entry → Action → Cancel → Previous 状態

### Rotation

Rotate 後も Same UX Context。Layout は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

### Window Resize

Resize 後も Same UX Context。Layout は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Acceptance Criteria

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。向き / Window 変更後の Layout は [`ui-viewport.md`](./ui-viewport.md)、復元対象は [`application_state.md`](./application_state.md)、アクセシビリティは [`ui.md`](./ui.md)、認証の許可状態は [`authentication_spec.md`](./authentication_spec.md)、Back の経路は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、主要 Goal の Entry / Success / Empty / Error / Offline / Cancel パスが定義されていることだけを判定する。
