# S2J Package Dashboard - スクリーン仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、スクリーン・アーキテクチャーを定義します。

実装結果、iOS/iPadOS/Android のプラットフォーム UX、Kotlin Multiplatform アーキテクチャー、および関連仕様の変更に応じて更新する。

## 目的

本ドキュメントでは、各スクリーンの責務、表示内容、状態、Layout、Responsive Behavior および Accessibility 要件を定義する。

目的は、iPhone/iPad/Android において同一のアプリケーションのセマンティクスを維持しながら、各プラットフォームおよび Window Size に適したスクリーンを提供することである。

## 非目的

本仕様では下記を必須としない。

* iOS/Android で完全に同一のスクリーン・レイアウト
* スクリーン UI の KMP 化
* Compose Multiplatform によるスクリーン共有
* スクリーンからの API 直接アクセス
* スクリーンからのストレージ直接アクセス
* スクリーンからの Credential 直接アクセス
* 全スクリーンの3-pane 化
* ディープリンクの初期 Version での実装

## 責務

画面の責務・構成・画面固有の表示を正本とする。

## 非責務

Loading / Error / Empty / アクセシビリティ等の横断ルールは [`ui.md`](./ui.md)、Viewport は [`ui-viewport.md`](./ui-viewport.md)、ナビゲーションは [`navigation_spec.md`](./navigation_spec.md)、操作経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、目的は [`use_cases.md`](./use_cases.md)、指標の意味は [`statistics_spec.md`](./statistics_spec.md)、認証状態は [`authentication_spec.md`](./authentication_spec.md)、プライバシー方針は [`security_spec.md`](./security_spec.md)、状態の分類・復元は [`application_state.md`](./application_state.md)、層と Native UI は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md)、コンポーネント境界は [`component_spec.md`](./component_spec.md)、視覚 Token は [`design_spec.md`](./design_spec.md)、検証の種類は [`testing_spec.md`](./testing_spec.md)、ファイル名簿は [`specs.md`](./specs.md) を正本とする。

## シナリオ分担

| 問い | 正本 |
| --- | --- |
| 誰が何を達成するか | [`use_cases.md`](./use_cases.md) |
| どの状態をどの順で通るか | [`ux_flows_spec.md`](./ux_flows_spec.md) |
| その画面は何を出すか | 本仕様 |
| 行き先と戻り方 | [`navigation_spec.md`](./navigation_spec.md) |

## スクリーンの定義

スクリーンとは、「ナビゲーション上の一つの独立したアプリケーション Context」と定義する。

スクリーンは必ずしも1つの UI View と1対1で対応するとは限らない。

## スクリーン/View/コンポーネント

スクリーンはプラットフォーム View を持ち、View は UI コンポーネントを合成する。例: Package Detail スクリーンは PackageDetailView を持ち、Header / RepositoryInfo / MetricSummary / StatisticsChart / PackageActions に分解する。コンポーネント境界は [`component_spec.md`](./component_spec.md) を正本とする。本仕様は、スクリーンが何を示すかだけを定める。

## スクリーンの責務

スクリーンは、

* User Context
* 画面の状態
* Layout
* ナビゲーション Context
* コンポーネント Composition

を定義する。

## スクリーンの非責務

スクリーン自身は、

* Packagist API 通信
* GitHub API 通信
* Credential ストレージ
* キャッシュ・ストレージ
* スナップショット・ストレージ
* ドメイン Rule

を直接実装しない。

## スクリーン・アーキテクチャー

層の依存方向は [`architecture.md`](./architecture.md) を正本とする。本仕様は、スクリーンが ViewModel/Presentation 経由でユースケースを呼び、Provider に直接依存しないことだけを定める。

## Initial スクリーン

起動時の Root Destination は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、そのスクリーンが Dashboard の表示内容を持つことだけを定める。

## スクリーン List

初期 Version では下記のスクリーンを定義する。

* Dashboard
* Package List
* Package Detail
* 統計
* Settings
* About

## スクリーン Hierarchy

概念:

```text
S2J Package Dashboard
│
├── Dashboard
│
├── Packages
│   ├── Maintained Packages
│   ├── Favorite Packages
│   └── Package Detail
│       └── Statistics
│
├── Settings
│
└── About
```

## Dashboard スクリーン

Dashboard はアプリケーションの Primary スクリーンとする。

## Dashboard Purpose

Dashboard は、User が管理する Package および Favorite Package の状態を一目で把握するためのスクリーンとする。

## Dashboard Content

Dashboard では、下記を表示可能とする。

* Maintained Packages
* Favorite Packages
* 統計 Summary
* Recent Updates
* スナップショット Status

## Dashboard Priority

Dashboard の情報の優先順位:

1. Maintained パッケージ
2. Favorite パッケージ
3. Important 統計
4. Recent Changes
5. Secondary 情報

Package Detail の提示順は `## Package Detail Content` / `## Package Header` を正本とする。視覚上のタイポグラフィ対応は [`design_spec.md`](./design_spec.md) とする。

## Dashboard Layout

Compact では Dashboard の下に Maintained と Favorites を縦に並べる。

## Dashboard Regular Layout

Regular Width では、Maintained / Favorites / 統計 Summary を並列で表示可能とする。2/3-pane の分割は [`navigation_spec.md`](./navigation_spec.md)、到達性は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、画面がどの情報グループを見せるかだけを定める。

## Dashboard Empty 状態

Maintained Package が存在しない場合、Empty 状態を表示する。

## Dashboard エラー状態

Dashboard Data 取得に失敗した場合、エラー状態を表示する。

既存キャッシュが利用可能な場合は、キャッシュ Data を表示可能とする。

## Dashboard Refresh

Dashboard は Pull-to-Refresh 等の Native Refresh Interaction を利用可能とする。ジェスチャと既存データの維持は [`ui.md`](./ui.md) を正本とする。

## Dashboard Loading

初回 Loading 時には、必要に応じてスケルトン/Progress Indicator を表示する。

## Package List スクリーン

Package List スクリーンは、複数 Package を一覧表示する。

## Package List Categories

Package List には、

* Maintained
* Favorites

等の Category を持たせる。

## Maintained Packages

Maintained / Favorite の意味は [`domain_rules.md`](./domain_rules.md) を正本とする。本仕様は、Package List 上の表示カテゴリーだけを定める。

## Favorite Packages

Favorite の List 表示も、意味は [`domain_rules.md`](./domain_rules.md) を正本とする。

## Package List Row

Package Row には、必要に応じて下記を表示する。

* Package Name
* Description
* Current Version
* Downloads
* Favorite 状態

## Package List Sorting

Package List の Sort Criteria は、UI 仕様およびドメイン Rule に従う。

## Package List Filtering

Package List は、必要に応じて Filter を提供する。

## Package List Search

将来的に Package Search を提供可能な構造とする。

## Package List Empty

該当 Package が存在しない場合、`Empty` として扱う。

## Package List エラー

取得エラーと Empty の区別は [`ui.md`](./ui.md) を正本とする。本仕様は、Package List がその区別を表示することだけを定める。

## Package Detail スクリーン

Package Detail は、1つの Package について詳細情報を表示する。

## Package Detail Content

* Package Metadata
* リポジトリ
* Current Version
* Downloads
* 統計
* Favorite 状態
* Maintained 状態

## Package Header

Package Header には、

* Package Name
* Description
* Current Version

等を表示する。

## リポジトリ Information

リポジトリ Information には、

* GitHub リポジトリ
* Owner
* リポジトリ Name
* Default Branch

等を表示可能とする。

## Package Actions

Package Detail では、必要に応じて、

* Favorite
* Unfavorite
* Open Packagist
* Open GitHub
* Refresh

等を提供する。外部 URL の開き方と Refresh の見え方は [`ui.md`](./ui.md) を正本とする。

## Package Detail Loading

Package Detail は、ナビゲーション後に Data を Lazy Load 可能とする。

## Package Detail キャッシュ

キャッシュ Data が存在する場合、Remote Data 取得前に表示可能とする。Freshness / Stale の判定は [`cache_spec.md`](./cache_spec.md)、Stale の見え方は [`ui.md`](./ui.md) を正本とする。

## Package Detail エラー

Data 取得に失敗した場合、

* エラー
* Retry

を提供可能とする。

## Package Detail Offline

Offline 時でも、キャッシュ Data が利用可能であれば Package Detail を表示可能とする。

## 統計スクリーン

統計スクリーンは、Package の統計情報を時系列で可視化する。キー指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## 統計 Scope

統計は、選択された Package を対象とする。

## 統計 Content

表示する Metric の意味と対象は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本節は、Summary / Chart / Period など画面上の置き場所だけを定義する。

## 統計 Summary

主要 Metric は、Summary Card として表示可能とする。

## 統計 Chart

Historical Data は、Chart コンポーネントで可視化する。

Chart は Touch / ポインタで操作可能とする。Data Point 選択時は Date / Value / Source を表示する。ジェスチャは Tap / Drag / Pinch / スクロールを必要な場合に限定する。水平スクロールが必要な場合の到達可能性は [`ui-viewport.md`](./ui-viewport.md) に従う。

## 統計 Period

統計では、必要に応じて Period を選択可能とする。期間にデータがない場合の扱いは [`statistics_spec.md`](./statistics_spec.md) を正本とする。

例:

* `7 Days`
* `30 Days`
* `90 Days`
* `1 Year`
* All

## 統計 Data Availability

Metric ごとに取得可能な期間が異なる場合、その違いを考慮する。

## 統計 Missing Data

欠測を0にしないことは [`domain_rules.md`](./domain_rules.md)、Chart 上の Gap は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、統計画面が欠測期間を隠して連続値に見せないことだけを定める。

## 統計 Partial Data

一部 Metric のみ取得できた場合、取得できた Metric を表示可能とする。Partial Failure の見え方は [`ui.md`](./ui.md) を正本とする。

## 統計スナップショット

Long-term 統計は、スナップショット・データを利用する。

## 統計 Refresh

統計 Refresh では、既存 Chart を可能な限り維持する。既存データの維持は [`ui.md`](./ui.md) を正本とする。

## 統計 Loading

Chart 表示中の Loading は [`ui.md`](./ui.md) を正本とする。本仕様は、統計画面が意味のない空白だけにならないことだけを定める。

## 統計エラー

Retry 可能なエラー UI は [`ui.md`](./ui.md) を正本とする。本仕様は、統計取得エラーを画面固有の Retry 状態として出すことだけを定める。

## Settings スクリーン

Settings は、アプリケーションおよび Data Source に関する設定を管理する。

## Settings Content

初期 Version では、

* Packagist Account
* Authentication
* Refresh Policy
* ストレージ
* Privacy
* About

等を候補とする。

## Credential Settings

Secret を常時表示しないこと、および UI に出してよい状態は [`authentication_spec.md`](./authentication_spec.md) を正本とする。マスクと漏洩面は [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、Credential 設定セクションを Settings に置くことだけを定める。

## Authentication 状態

UI に出してよい状態は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、Settings でサービス単位の接続状態を見せることだけを定める。

## ストレージ Settings

Local ストレージの状態を必要に応じて確認可能とする。キャッシュ Clear およびローカル・データ削除の確認 UI は、[`ui.md`](./ui.md) の Destructive Action 方針と、[`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) に従う。

## Privacy Settings

Privacy 関連設定は、[`security_spec.md`](./security_spec.md) に従う。

## About スクリーン

About スクリーンでは、アプリケーション Information を表示する。

## About コンポーネント

既存 S2J About Window のコンポーネント境界は [`component_spec.md`](./component_spec.md) を正本とする。本仕様は、About スクリーンでそれを利用することだけを定める。

## About Content

* アプリケーション Name
* Version
* Build
* Copyright
* Licenses
* Open Source

等を表示可能とする。

## 画面の状態

状態の分類は [`application_state.md`](./application_state.md)、見え方は [`ui.md`](./ui.md)、遷移は [`state_machine.md`](./state_machine.md) を正本とする。本仕様は、各スクリーンがそれらの状態を持つことだけを定める。

## Stale 状態

Stale の分類は [`application_state.md`](./application_state.md)、判定は [`cache_spec.md`](./cache_spec.md)、見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、各スクリーンがキャッシュ表示時に Stale を表現できることだけを定める。

## 画面の状態の所有権

状態の分類と SSoT は [`application_state.md`](./application_state.md) を正本とする。本仕様は、画面状態を ViewModel / プレゼンテーション層が管理することだけを定める。

## Local UI 状態

UI Local 状態の分類は [`application_state.md`](./application_state.md) を正本とする。本仕様は、スクロール位置等を UI コンポーネントが管理してよいことだけを定める。

## 画面の状態 Persistence

永続化の境界は [`application_state.md`](./application_state.md) を正本とする。本仕様は、画面が Persistent ストレージに直接保存しないことだけを定める。

## ナビゲーション状態

ナビゲーション状態は、[`navigation_spec.md`](./navigation_spec.md) に従う。

## スクリーン Identity

スクリーンは、ナビゲーション Destination によって識別可能とする。

## スクリーン Route

スクリーン Route には、必要最小限の Identifier のみを渡す。

## Package Detail Route

`PackageDetail(packageIdentifier)` を基本とする。

## 統計 Route

`Statistics(packageIdentifier)` を基本とする。

## スクリーン Data Loading

スクリーンは、Route Parameter から Data を取得する。

## No Large Route Payload

Route に大量の Package Data や統計 Data を埋め込まない。

## スクリーン Composition

スクリーンは、[`component_spec.md`](./component_spec.md) で定義されたコンポーネントを組み合わせて構築する。

## スクリーン/コンポーネント境界

```text
スクリーン
├── Section
│   └── Feature コンポーネント
└── Feature コンポーネント
```

を基本とする。

## スクリーン固有コンポーネント

特定スクリーンでしか利用しないコンポーネントを無理に Global コンポーネントに昇格させない。

## 共有コンポーネント

複数スクリーンで意味的に再利用するコンポーネントは、共有コンポーネントとして扱う。

## スクリーン・レイアウト

スクリーン・レイアウトは、下記を考慮する。

* Window Size
* 画面の向き
* セーフエリア
* Dynamic Type
* Accessibility
* キーボード
* ポインタ (カーソル)

## Compact Layout

サイズクラスは [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、Compact Width で情報を縦方向に置くことだけを定める。

## Regular Layout

サイズクラスは [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、Regular Width で複数 Section を並列し得ることだけを定める。

## Large Layout

Large Window では、単純な余白拡大ではなく Information Grouping を改善する。

## iPhone Layout

`## Compact Layout` および [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## iPhone Landscape

Landscape 時の到達可能性は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、iPhone Landscape でも Single-column の情報階層を維持することだけを定める。

## iPad Layout

2-pane / 3-pane のナビゲーションは [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、「広い Viewport で複数の情報領域を同時に出すことが可能」だけを定める。

## iPad Two-pane

2-pane のナビゲーションは [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、広い Viewport で Source List と Content (Package Detail) を同時に出せることだけを定める。

## iPad Three-pane

3-pane のナビゲーションは [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、Source List / Package List / Package Detail を同時に出せることだけを定める。

## iPad Compact Collapse

iPad の Window が狭くなった場合、複数 Pane を Stack に Collapse 可能とする。

SwiftUI の `NavigationSplitView` も iPhone 等の Compact Size では Column を Stack に Collapse する。([NavigationSplitView | Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/navigationsplitview?changes=_9))

## Android Layout

Android では、Window Size に応じてスクリーン・レイアウトをアダプティブに変更する。

## Android Compact

Compact Width では、Single-column/ナビゲーション Bar を基本候補とする。

## Android Large

Large Width では、ナビゲーション Rail/Drawer/List-Detail 等を利用可能とする。

## Android アダプティブ・ナビゲーション

Android では、Window Size Class に応じてナビゲーション UI を変更可能とする。

2026年時点の Android 公式アダプティブ UI でも、Window Size に応じたナビゲーション変更と List-Detail 等の Canonical Layout が推奨されている。([Build adaptive apps | Jetpack Compose | Android Developers](https://developer.android.com/develop/ui/compose/build-adaptive-apps?hl=en))

## Android NavigationSuite

Android では、必要に応じて `Material 3` アダプティブの `NavigationSuiteScaffold` を利用可能とする。

## スクリーン・ナビゲーション

スクリーン間ナビゲーションは、[`navigation_spec.md`](./navigation_spec.md) に従う。

## スクリーン Entry Point

各スクリーンには、明確な Entry Point を定義する。

## スクリーン Exit

Back ナビゲーションによって、User が直前の Context に戻れることを保証する。

## スクリーン Restoration

向き変更や Window Size 変更によって、現在のスクリーンを不必要に Reset しない。

## スクリーン Restoration

アプリケーション再起動時には、必要に応じてスクリーン Context を復元する。

## Invalid 画面の状態

復元できない画面の状態は、安全なスクリーンに Fallback する。

## スクリーン Refresh

スクリーン Refresh では、スクリーン Context を維持する。

## スクリーン Refresh Example

Refresh 後も同じスクリーン Context (例: Package Detail) を維持する。Refresh の結果として Dashboard へ戻さない。

## スクリーン・エラー境界

スクリーン内の Data 取得エラーが、アプリケーション全体を停止させない。

## スクリーン・エラー UI

エラー UI は、

* Message
* Retry
* Optional Details

を提供可能とする。

## Empty スクリーン

Empty 状態は、User が次に取るべき Action を可能な範囲で提示する。

## Empty Maintained

Empty の型は [`ui.md`](./ui.md) を正本とする。本仕様は、Maintained が0件のときに Empty を出すことだけを定める。

## Empty Favorites

Empty の型は [`ui.md`](./ui.md) を正本とする。本仕様は、Favorite が0件のときに追加方法を案内し得ることだけを定める。

## Offline スクリーン

オフライン時の既存表示は [`ui.md`](./ui.md)、キャッシュは [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、キャッシュがあればスクリーンを出せることだけを定める。

## Offline Indicator

見え方は [`ui.md`](./ui.md) を正本とする。

## Stale Indicator

`## Stale 状態` および [`ui.md`](./ui.md) を正本とする。

## Last Updated

Freshness 文言は [`ui.md`](./ui.md) を正本とする。本仕様は、統計 / Package Detail に取得時刻を出し得ることだけを定める。

## Data Freshness

判定は [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、スクリーンが Freshness を判定しないことだけを定める。

## スクリーン・パフォーマンス

スクリーン表示時に不要な重い処理を同期実行しない。

## Lazy Loading

大量 Package/統計 Data は、必要に応じて Lazy Load する。

## Long Package Name

Long Package Name / リポジトリ Name / Large Number でもスクリーンの意味が破綻しないこと。Layout 破綻の判定は [`ui-viewport.md`](./ui-viewport.md)、識別不能な省略をしないことは [`ui.md`](./ui.md) を正本とする。

## Missing Data

欠測と0の区別は [`domain_rules.md`](./domain_rules.md)、表示は [`ui.md`](./ui.md) を正本とする。本仕様は、各スクリーンがその区別を表示することだけを定める。

## ローカライズ

ローカライズ方針は [`ui.md`](./ui.md) / [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、各スクリーンの User-facing Text がその方針に従うことだけを定める。

## Dynamic Type

Font Size 適応は [`ui.md`](./ui.md)、大きい Text での Layout 破綻は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Font Scaling

大きい Font での到達可能性は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Accessibility

各スクリーンは、Accessibility Tree として意味のある構造を提供する。

## スクリーン Title

スクリーン Title は、現在の Context を明確にする。

## ナビゲーション Title

ナビゲーション Title は、[`navigation_spec.md`](./navigation_spec.md) に従う。

## Accessibility Heading

Section Header は、Accessibility Heading として識別可能とする。

## スクリーン・アクション

主要 Action は、Accessibility からも到達可能とする。

## スクリーン Color のセマンティクス

Status を Color だけで表現しない。

## スクリーン Animation

Animation は、スクリーン Content の理解を妨げない。

## オリエンテーション・トランジション

向き変更時の Intermediate Layout 禁止とスクロール位置の維持は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、「各スクリーンの構成が、向き変更後も意味の維持が可能」だけを定める。

## 選択

iPad/Tablet の List-Detail 構成では、現在選択されている Item を明確に表示する。

## 選択同期

Source List / Package List / Detail の選択整合は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、同時表示時に選択中 Item が各領域で一致して見えることだけを定める。

## スクリーン Viewport

到達可能性、スクロール到達、水平オーバーフロー、セーフエリア、操作領域は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は各スクリーンの構成だけを定義する。

## キーボード

Hardware キーボード使用時も、主要 Action にアクセス可能とする。

## ポインタ (カーソル)

iPadOS/Android Tablet では、ポインタ (カーソル) Interaction を考慮する。

## スクリーンの構成例

Package Detail:

```text
PackageDetailScreen
│
├── PackageHeader
│   ├── PackageName
│   ├── Description
│   └── Version
│
├── RepositoryInfo
│
├── MetricSummary
│   ├── Downloads
│   ├── Stars
│   └── Releases
│
├── StatisticsChart
│
└── PackageActions
```

## Dashboard の構成例

```text
DashboardScreen
│
├── MaintainedSection
│   └── PackageList
│
├── FavoritesSection
│   └── PackageList
│
└── StatisticsSummarySection
    └── MetricCards
```

## 統計の構成例

Statistics Screen は PackageHeader / PeriodSelector / MetricSelector / MetricSummary / StatisticsChart で構成する。指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## Settings の構成例

セクション一覧は `## Settings Content` を正本とする。

## About の構成例

About は `S2J About Window` をホストする。内容は `## About Content` を正本とする。

## スクリーン/KMP 境界

スクリーンは、KMP 共有ロジックを直接ではなくプレゼンテーション層経由で利用する。

## KMP 共有ロジック

共有対象の優先順位は [`architecture.md`](./architecture.md) を正本とする。本仕様は、スクリーンが共有ロジックをプレゼンテーション層経由で利用することだけを定める。

## プラットフォーム UI

スクリーンの Visual Representation はプラットフォーム Native UI で実装する。

* iOS/iPadOS: SwiftUI
* Android: Jetpack Compose

## プラットフォーム横断型 UI の要件なし

Visual Structure の完全一致は要求しない。Pixel 非同一は [`design_spec.md`](./design_spec.md) / [`ui.md`](./ui.md) を正本とする。

## 共有スクリーンのセマンティクス

下記はプラットフォーム間で可能な限り統一する。

* スクリーン Purpose
* Information Hierarchy
* User Action

Metric Meaning は [`statistics_spec.md`](./statistics_spec.md)、ナビゲーション Meaning は [`navigation_spec.md`](./navigation_spec.md)、エラー Meaning は [`ui.md`](./ui.md) を正本とする。

## プラットフォーム固有スクリーン・レイアウト

ナビゲーション Container / Toolbar / Tab / Sidebar 等は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、スクリーン内 Layout がプラットフォーム固有でよいことだけを定める。

## iOS ネイティブ・スクリーン

iOS/iPadOS スクリーンは、SwiftUI Native Pattern を優先する。

## Android ネイティブ・スクリーン

Android スクリーンは、Jetpack Compose Native Pattern を優先する。

## スクリーンテスト

各スクリーンは、最低限、下記の状態をテストする。

* Initial
* Loading
* Loaded
* Refreshing
* Empty
* エラー
* Offline
* Stale

## スクリーン向きテスト

向き / 幅 / Size Class の確認は [`ui-viewport.md`](./ui-viewport.md) の Test Matrix を正本とする。本仕様のテストでは各スクリーンの構成と表示内容を確認する。

## iPhone リファレンス

初期リファレンス・デバイスは [`ui-viewport.md`](./ui-viewport.md) の Reference Devices を正本とする。

## iPad リファレンス

iPad の初期リファレンス・デバイスも [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Android リファレンス

Android の初期リファレンス・デバイスも [`ui-viewport.md`](./ui-viewport.md) を正本とする。

具体的なデバイス・モデルは別途定義する。

## スクリーン・テスト・マトリックス

| -- | iPhone | iPad | Android |
| --- | --- | --- | --- |
| Dashboard | ✓ | ✓ | ✓ |
| Package List | ✓ | ✓ | ✓ |
| Package Detail | ✓ | ✓ | ✓ |
| 統計 | ✓ | ✓ | ✓ |
| Settings | ✓ | ✓ | ✓ |
| About | ✓ | ✓ | ✓ |

## 画面の向きテスト・マトリックス

向きおよび Size Class の組み合わせは [`ui-viewport.md`](./ui-viewport.md) の Viewport Test Matrix を正本とする。本仕様のマトリックスは、どのスクリーンを対象にするかだけを定義する。

## Viewport テスト

Viewport の確認項目は [`ui-viewport.md`](./ui-viewport.md) の Test Matrix / Acceptance Criteria を正本とする。本仕様のテストでは、各スクリーンの構成と表示内容を確認する。

## Long Content テスト

長い Package Name / Description 等の表示確認は各スクリーンで行う。Layout 破綻の判定は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## ナビゲーション・テスト

スクリーン・ナビゲーションは、[`navigation_spec.md`](./navigation_spec.md) で定義されたナビゲーション・フローをテストする。

## Dashboard フロー

経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、Back は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様のテストでは、Dashboard の表示内容と画面固有の状態のみを確認する。

## スクリーン回帰

スクリーン・レイアウト変更時には、主要スクリーンの Visual 回帰を確認する。

## スクリーンショット・レビュー

向き / Size Class / Long Content の判定は [`ui-viewport.md`](./ui-viewport.md)、テスト種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様の Visual レビューでは、Loading / エラー / Empty など画面固有の状態を確認する。

## スクリーン・パフォーマンス

スクリーン Transition 中に不要な Main Thread Blocking を発生させない。

## 初期レンダリング

スクリーンの初期 Visual を可能な限り早く表示する。

## 真っ白なスクリーン

Blank / 全面スケルトン禁止は [`ui.md`](./ui.md) を正本とする。本仕様は、各スクリーンが Data 取得中に意味のない空白だけを出さないことだけを定める。

## スケルトン

スケルトンの使い方は [`ui.md`](./ui.md) を正本とする。本仕様は、使う場合にそのスクリーンの Content Layout に近付けることだけを定める。

## スクリーン・メモリ

スクリーン・ナビゲーションによって不要な Data を無期限に保持しない。

## 大規模リスト

Lazy Rendering は [`ui.md`](./ui.md) を正本とする。本仕様は、Package List が大量になっても全件を一度に描画しないことだけを定める。

## チャート・パフォーマンス

表示用 Range への絞り込みは [`ui.md`](./ui.md) を正本とする。指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## スクリーン・データ契約

各スクリーンは、必要なデータ契約を明確にする。

例:

* `PackageDetailScreen`:
    * インプット:
        * `PackageIdentifier`
    * アウトプット:
        * User Actions

## スクリーン・インプット

スクリーン・インプットは、必要最小限とする。

## スクリーン・アウトプット

スクリーンから外部に通知する Action は、Semantic Event として定義する。

## スクリーン・アクション例

* `onRefresh`
* `onFavorite`
* `onOpenRepository`
* `onOpenPackagist`
* `onOpenStatistics`

## スクリーン・アクション所有権

Action のビジネスロジックは、スクリーンではなくユースケースに委譲する。

## スクリーン・エラー契約

スクリーン・エラーは、プレゼンテーション層が UI で表現可能な状態に変換する。

## スクリーン・ローディング契約

Loading 状態もプレゼンテーション層から提供する。

## スクリーン・ローカライズ

スクリーン内の Text は、ローカライズ Resource から取得する。

## スクリーン・ブランディング

視覚 Token / ブランディングは [`design_spec.md`](./design_spec.md) を正本とする。本仕様の分担は `## 非責務` を正本とする。

## スクリーン UI

横断 UI は [`ui.md`](./ui.md)、Viewport は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は画面の責務・構成・画面固有の表示だけを定める。

## スクリーン・コンポーネント

[`component_spec.md`](./component_spec.md) を正本とする。

## スクリーン・ナビゲーション

[`navigation_spec.md`](./navigation_spec.md) を正本とする。

## スクリーン・ドメイン

[`domain_rules.md`](./domain_rules.md) を正本とする。

## スクリーン統計

[`statistics_spec.md`](./statistics_spec.md) を正本とする。

## スクリーン・ストレージ

[`storage_spec.md`](./storage_spec.md) を正本とする。

## スクリーン・キャッシュ

[`cache_spec.md`](./cache_spec.md) を正本とする。

## スクリーン・セキュリティ

[`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) を正本とする。

## スクリーン API

[`api-packagist.md`](./api-packagist.md) / [`api-github.md`](./api-github.md) を正本とする。

## スクリーン・モデル

[`models_spec.md`](./models_spec.md) を正本とする。

## スクリーン KMP

[`architecture.md`](./architecture.md) / [`kmp_spec.md`](./kmp_spec.md) を正本とする。

## スクリーン・アーキテクチャー

ファイル名簿は [`specs.md`](./specs.md) を正本とする。本仕様の分担は `## 非責務` を正本とする。

## スクリーン仕様の責務

本仕様の責務は `## 責務` を正本とする。画面が何を出し、どの状態と Action を持つかを定義する。

## コンポーネント仕様の責務

[`component_spec.md`](./component_spec.md) を正本とする。

## ナビゲーション仕様の責務

[`navigation_spec.md`](./navigation_spec.md) を正本とする。

## UI 仕様の責務

[`ui.md`](./ui.md) を正本とする。

## デザイン仕様の責務

[`design_spec.md`](./design_spec.md) を正本とする。

## 最終的なスクリーン・アーキテクチャー

画面の並びと行き先は [`navigation_spec.md`](./navigation_spec.md)、層の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様は各画面の表示内容だけを定める。

## プラットフォーム・スクリーン・アーキテクチャー

Native UI は [`architecture.md`](./architecture.md) を正本とする。本仕様は画面の意味を共通化し、表現をプラットフォームに適応させることだけを定める。

## 最終原則

スクリーンの意味は共通化し、表現はプラットフォームに適応させる。Native UI の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様はスクリーンをナビゲーション Context として定義し、ビジネスロジックを直接保持しないことだけを定める。
