# S2J Package Dashboard - UI/UX 仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、UI/UX の振る舞いを定義します。

iOS/iPadOS/Android 実装、Usability テスト、アクセシビリティ・テスト、Kotlin Multiplatform (KMP) 移行等に応じて更新する。

## 目的

本ドキュメントでは、S2J Package Dashboard の横断的な UI/UX 振る舞いを定義する。対象は Loading / Error / Empty / オフライン / Stale、共通インタラクション、アクセシビリティ、ローカライズ、Reduce Motion、Focus、プラットフォーム・ネイティブ UI の原則である。

## 非目的

本仕様は、画面構成、ナビゲーション Hierarchy、Viewport 整合性の正本になることを目的としない。

## 責務

全画面に共通する UI 状態表示、Destructive Action、アクセシビリティ/ローカライズ/Reduce Motion の横断ルールを正本とする。

## 非責務

* 画面の責務と構成: [`screen_spec.md`](./screen_spec.md)
* ナビゲーション: [`navigation_spec.md`](./navigation_spec.md)
* Viewport 整合性: [`ui-viewport.md`](./ui-viewport.md)
* 操作経路: [`ux_flows_spec.md`](./ux_flows_spec.md)
* 視覚・ブランディング: [`design_spec.md`](./design_spec.md)
* 層境界とデータフロー: [`architecture.md`](./architecture.md)
* KMP の HOW: [`kmp_spec.md`](./kmp_spec.md)
* キャッシュの Freshness / メモリ解放: [`cache_spec.md`](./cache_spec.md)
* スナップショット Retention / Quota: [`storage_spec.md`](./storage_spec.md)
* 統計の可視化意味: [`statistics_spec.md`](./statistics_spec.md)
* 欠測 ≠0 / 補間禁止: [`domain_rules.md`](./domain_rules.md)
* コンポーネント境界: [`component_spec.md`](./component_spec.md)
* 認証方針と UI に出してよい状態: [`authentication_spec.md`](./authentication_spec.md)
* Token 漏洩の禁止面: [`security_spec.md`](./security_spec.md)
* 状態の分類・保持・復元: [`application_state.md`](./application_state.md)
* 状態遷移: [`state_machine.md`](./state_machine.md)
* 何をテストするか: [`testing_spec.md`](./testing_spec.md)

## UI/UX 基本方針

下記を基本原則とする。

1. 「情報」First
2. 操作可能性を最優先する
3. アクセシビリティを後付けにしない
4. Loading/エラー/Empty/オフラインを正式な UI 状態として扱う
5. プラットフォーム・ネイティブ UX を尊重する

Viewport / Size Class / 向きの要件は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## プラットフォーム UI

Native UI は [`architecture.md`](./architecture.md) を正本とする。本仕様は、Business / ドメイン・ロジックを UI 層から分離することだけを定める。

## UI 層境界

層の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様は、SwiftUI / Compose が Packagist / GitHub API を直接呼び出さず、View → プレゼンテーション → ユースケース → ドメインとすることだけを定める。

## プラットフォーム Independence

Native UI API をドメイン仕様に持ち込まないことは [`architecture.md`](./architecture.md) を正本とする。本仕様は、SwiftUI / Jetpack Compose のコンポーネント API をドメインに漏らさないことだけを定める。

## 画面、ナビゲーション、Viewport

画面 / ナビゲーション / Viewport / 操作経路の正本は `## 非責務` を正本とする。

## Undo

Remove 等の Reversible Action では、必要に応じて Undo を提供する。

## Pull to Refresh

主要リスト / Dashboard では、プラットフォーム・ネイティブな Pull-to-Refresh を利用可能とする。画面ごとの更新アクションの置き場所は [`screen_spec.md`](./screen_spec.md) を正本とする。

## Refresh Feedback

Refresh 中は、`Refreshing...` またはプラットフォーム・ネイティブ Indicator を表示する。

## Refresh with Existing Data

既存 Data がある場合、既存 Data と Refreshing Indicator を同時に出す。画面全体を Blank/スケルトンに置き換えない。

## Loading 状態

Loading 状態:

* Initial Loading
* Refreshing
* Background Updating

を区別する。

## スケルトン

スケルトン UI は必要な箇所にのみ利用する。過度なスケルトン Animation を使用しない。Loading Indicator も必要な範囲にのみ表示する。

## Empty 状態

Empty 状態には、

* What happened
* What can the user do
* Action

を含める。

例:

```text
No favorite パッケージ

Add a パッケージ to start tracking it.

[Add パッケージ]
```

統計の履歴不足も同じ型とする。文言例: `Not enough 過去データ`。不足の意味は [`statistics_spec.md`](./statistics_spec.md) / [`domain_rules.md`](./domain_rules.md) を正本とする。

## エラー状態

エラー UI:

* What happened
* Retry
* Alternative Action

を提供する。

## Partial Failure

プロバイダ単位で Failure を表示する。

```text
Packagist: ✓

GitHub: ⚠ Unable to load
[Retry]
```

Dashboard 全体をエラーにしない。

## オフライン状態

オフライン時は、Local Data が存在すれば表示する。

* オフライン
* Last updated: 2hours ago

等を表示可能とする。

## Stale Data

Stale Data は、Fresh Data と視覚的に区別可能とする。

## Unauthorized 状態

権限不足時に何を要求するかは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、不足を `0` として表示せず、「アクセスが必要」等の状態として示すことだけを定める。

## Authentication UI

認証方針と UI に出してよい状態は [`authentication_spec.md`](./authentication_spec.md)、Settings の画面構成は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、Authentication UI を統計 UI と分離することだけを定める。

## クレデンシャル (資格情報) UI

生の Token を UI 状態に置かないこと、および UI に出してよい状態は [`authentication_spec.md`](./authentication_spec.md) を正本とする。マスク表示と漏洩面は [`security_spec.md`](./security_spec.md) を正本とする。

## Destructive Action

Data 削除など不可逆操作には、確認 UI を使用する。

例:

```text
Delete all local data?

This cannot be undone.

[Cancel] [Delete]
```

## アクセシビリティ

アクセシビリティは、全 UI で考慮する。

対象:

* VoiceOver
* Dynamic Type
* Reduce Motion
* Increase Contrast
* Switch Control
* TalkBack
* キーボード
* ポインタ (カーソル)

## 操作領域

到達可能な Hit Area は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、Interactive Control の最小サイズを定める。

iOS/iPadOS では Apple HIG の推奨サイズを基準とする。

Apple は iOS/iPadOS について、Default Control Size を44×44pt、Minimum Control Size を28×28pt としている。([Accessibility - Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/accessibility))

## Spacing

隣接する Interactive Element は、誤 Tap を防ぐため十分な Spacing を確保する。

## Dynamic Type

Text は、User が設定した Font Size に適応する。大きい Text での clipping 禁止は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Text Truncation

長い Package Name の Layout 手段 (改行 / Truncation / Detail / Accessibility Label) は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、`vendor/very-long-package-name` を識別不能な形に省略せず、Detail では全文を確認できることだけを定める。

## ローカライズ

対応言語と翻訳対象カテゴリー、日付/数値の視覚書式は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、UI String を UI ロジックに Hard-code しないこと、日本語 UI で英語指標 Name との混在によって操作不能にしないことだけを定める。

パッケージ Identifier (`vendor/package`) は翻訳しない。

## RTL

将来的な RTL 対応を阻害しない。Leading/Trailing を使用し、Left/Right に過度に依存しない。

## Color

色の設計 (システムカラー、意味論的な配色、ダークモードの色) は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、Color だけで Status を表現しないこと (Icon / Text を併用する) だけを定める。

## Dark Mode

ライト/ダーク双方の視覚サポートは [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、主要 UI 状態が両モードで操作可能であることだけを定める。

## Motion

モーションの視覚方針は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、Animation が状態 Change の理解を助け、Decorative Animation を使わないことだけを定める。

## Reduce Motion

Reduce Motion 設定時には、Animation を縮小/無効化可能とする。

## 画面の向きアニメーション

向き変更時の Intermediate Layout 禁止は [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、向き変更 Animation が情報伝達を阻害しないことだけを定める。

## Chart Animation

Chart 更新時の Animation は、Data Change の理解を妨げない範囲とする。視覚 Token は [`design_spec.md`](./design_spec.md) を正本とする。

## Haptics

重要な User Action では、プラットフォーム・ネイティブ Haptic Feedback を利用可能とする。

過剰な Haptic Feedback は避ける。

## ポインタ (カーソル)

iPad/Android Tablet 等でポインタ (カーソル) インプットをサポートする。

ポインタ (カーソル) Hover 時の Feedback を必要に応じて提供する。

## キーボード

External キーボード使用時にも主要ナビゲーションを実行可能とする。

## Focus

キーボード/アクセシビリティ Focus は、視覚的に識別可能とする。

## スクロール位置

向き変更時のスクロール位置は [`ui-viewport.md`](./ui-viewport.md)、ナビゲーション後の維持は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## 状態 Preservation

何を Configuration Change / 再起動後に保持するかは [`application_state.md`](./application_state.md) を正本とする。本仕様は、保持された状態がユーザーに自然に見えることだけを定める。

## ドメイン状態 vs UI 状態

状態の分類は [`application_state.md`](./application_state.md) を正本とする。本仕様は、ドメイン・モデルを View の Rendering 状態として直接使わないことだけを定める。

## UI 状態機械

画面の状態遷移は [`state_machine.md`](./state_machine.md) を正本とする。本仕様は、Loading / Loaded / エラー等をユーザーが区別できることだけを定める。

## Context Menu

Secondary Action は、Context Menu 等にまとめることができる。

ただし重要 Action を Context Menu のみに隠さない。

## Swipe Action

Swipe Action は、発見可能性が低い Action に使用しない。

## Destructive Swipe

Delete 等の Destructive Action を Swipe だけに依存しない。

## Pull ジェスチャ

Pull-to-Refresh と水平スクロール等のジェスチャ Conflict を避ける。

## スクリーンショット・テスト

何をテストするかは [`testing_spec.md`](./testing_spec.md)、Viewport 組み合わせは [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、主要画面の Visual 回帰を可能とすることだけを定める。

## アクセシビリティ・テスト

検証項目は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、VoiceOver / TalkBack / Dynamic Type / Reduce Motion / キーボード / ポインタを操作可能にすることだけを定める。

## UI パフォーマンス

大量パッケージ/スナップショットを表示しても、スクロール/ナビゲーションが不自然に遅延しないこと。検証対象は [`testing_spec.md`](./testing_spec.md) を正本とする。

## Lazy Rendering

Large Collection では、プラットフォームの Lazy リスト/ Lazy グリッド等を利用する。

全パッケージを一度に Rendering しない。

## Chart Data Loading

長期間のスナップショットを一度に UI に渡さない。期間指定のクエリーは [`storage_spec.md`](./storage_spec.md)、選択できる Period は [`screen_spec.md`](./screen_spec.md) を正本とする。

## Large Dataset

UI はパッケージ / スナップショットが増えてもスクロール可能であること。保持上限と Quota は [`storage_spec.md`](./storage_spec.md)、キャッシュ容量は [`cache_spec.md`](./cache_spec.md)、Performance 検証は [`testing_spec.md`](./testing_spec.md) を正本とする。

## ネットワーク Independence

データの流れと層境界は [`architecture.md`](./architecture.md) を正本とする。本仕様は、View がネットワーク状態を直接判定しないことだけを定める。

## エラー・メッセージ

Technical エラーをそのままユーザーに表示しない。

たとえば、`URLError(-1009)` ではなく、

```text
Unable to connect.
Check your ネットワーク connection and try again.
```

等にマッピングする。

## Retry

Retry 可能なエラーでは、ユーザーが明示的に再試行できる。Recovery 手段は Retry / Back / Refresh 等とし、エラー UI の型 (What happened / Action) は `## エラー状態` を正本とする。

## レート制限

API レート制限到達時は、

```text
Too many requests.
Please try again later.
```

等の User-oriented メッセージを使用する。

## Data Freshness

Fresh / Stale の判定は [`cache_spec.md`](./cache_spec.md)、指標ごとの鮮度の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、`Updated just now` / `Updated 5 minutes ago` 等の表示文言だけを定める。

## Source Transparency

ソースの意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、Packagist / GitHub / Collected by S2J Package Dashboard 等を確認できることだけを定める。

## No False Precision

取得できない Precision を UI 上で推測しない。欠測を `0` にしないこと、Stale を Fresh に見せないことは [`domain_rules.md`](./domain_rules.md) / [`cache_spec.md`](./cache_spec.md) を正本とする。

## アクセシビリティ Labels

Icon-only Action には、アクセシビリティ Label を設定する。

例:

* Favorite
* Refresh
* Open リポジトリ
* More

## Semantic Grouping

関連する指標を アクセシビリティ Tree 上でも意味的に Group 化する。

## VoiceOver/TalkBack Order

Reading Order は、Visual Hierarchy と可能な限り一致させる。

## Chart アクセシビリティ

Chart には、可能な限り Textual Summary を提供する。傾向を含める場合の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

例: `Downloads 120,000. Source: Packagist.`

## Contrast

コントラストの視覚基準は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、Text / Icon / Chart が Light / Dark 双方で読み取れることだけを定める。

## ローカライズ・テスト

検証する言語は [`design_spec.md`](./design_spec.md) を正本とする。本仕様のテストでは、両言語で主要操作が完了できることだけを確認する。

## Date ローカライズ

日付/数値の視覚書式は [`design_spec.md`](./design_spec.md) を正本とする。永続化の UTC は [`storage_spec.md`](./storage_spec.md) を正本とする。

## External Link

パッケージ Detail に出す Open Packagist / Open GitHub は [`screen_spec.md`](./screen_spec.md) を正本とする。Incoming ディープリンクの検証は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、外部 URL をプラットフォーム標準の Browser / Web View 方針で開くことだけを定める。

## Privacy

UI では、不要な Personal Data を表示しない。Token / クレデンシャルを通常 UI やエラー・メッセージに出さないことは [`security_spec.md`](./security_spec.md) / [`authentication_spec.md`](./authentication_spec.md) を正本とする。

## Design System

視覚 Token (Color / Typography / Spacing / Shape / Iconography / Elevation) は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、横断 UI がその Design System に従うことだけを定める。

## プラットフォーム・ネイティブ・コンポーネント

可能な限り、

* SwiftUI
* Jetpack Compose

それぞれのプラットフォーム・ネイティブ・コンポーネントを利用する。

## プラットフォーム横断型 Consistency

iOS/Android で情報アーキテクチャー / Terminology / ドメイン Meaning / Interaction インテントは可能な限り統一する。画面 Purpose は [`screen_spec.md`](./screen_spec.md)、Destination / Route は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## プラットフォーム Difference

ナビゲーション Container / Back / Sidebar 等の Chrome は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、Context Menu / Sheet / System Dialog / キーボード / アクセシビリティがプラットフォーム・ネイティブ UX でよいことだけを定める。

## No Pixel-identical Requirement

視覚の非同一化は [`design_spec.md`](./design_spec.md) を正本とする。本仕様は、Meaning / 情報 / UX Goal をそろえ、Pixel-level 一致を要求しないことだけを定める。

## SwiftUI

SwiftUI では、View を可能な限りプレゼンテーション状態にバインドする。

## Jetpack Compose

Compose では、状態 Hoisting を基本とする。

Android 公式のアダプティブ UI guidance でも、Window Size Class 等の状態を含む状態を適切に Hoist することが推奨されている。([Canonical layouts | Adaptive Apps - Android Developers](https://developer.android.com/develop/adaptive-apps/guides/canonical-layouts))

## 共有 UI ロジック

共有対象は [`architecture.md`](./architecture.md) を正本とする。本仕様は、SwiftUI View / Compose Composable を初期の共有対象にせず、プレゼンテーション状態とインテントを View から分離することだけを定める。

## UI アーキテクチャー

層の境界は [`architecture.md`](./architecture.md) を正本とする。本仕様は、View がユースケース/ドメインを直接呼び出さないことだけを定める。

## UI 状態の所有権

状態の分類と SSoT は [`application_state.md`](./application_state.md) を正本とする。イミュータブルな値として扱うことは [`architecture.md`](./architecture.md) を正本とする。

## イベント Handling

一度きりの操作は [`application_state.md`](./application_state.md) の Transient Event を正本とする。本仕様は、Tap / Refresh / 選択を View からインテントとして渡すことだけを定める。

## Side Effects

ネットワーク/ストレージ/Authentication 等の Side Effect を View に直接記述しない。

## Animation Timing

Animation Duration は [`design_spec.md`](./design_spec.md) の Design System に従う。プラットフォーム Standard Animation を可能な限り利用する。

## No Startup Flash

起動時および向き変更時の Intermediate Layout 禁止は [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Launch 状態

起動時に何を復元するかは [`application_state.md`](./application_state.md) を正本とする。Authentication 等の機密状態は [`authentication_spec.md`](./authentication_spec.md) を正本とする。

## Background Return

Foreground 復帰時の Freshness Check / Refresh 可否は [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、復帰時に既存表示を消して Blank にしないことだけを定める。

## メモリ Pressure

メモリ・キャッシュの解放は [`cache_spec.md`](./cache_spec.md)、Historical スナップショットの保持は [`storage_spec.md`](./storage_spec.md) を正本とする。本仕様は、Chart の再描画用データを捨てたとしても、履歴が見えなくならないことだけを定める。

## UX Principle

Empty / エラーで「何が起きたか / 何ができるか」を示すことは `## Empty 状態` / `## エラー状態` を正本とする。本節は、ユーザーが次の操作を選べない画面を作らないことだけを定める。

## User Control

Automatic Action よりも、ユーザーが明示的に理解できる操作を優先する。

## パフォーマンス vs Accuracy

指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。Loading を短くするために意味を変えない。キャッシュ表示時の Freshness 見え方は `## Data Freshness` を正本とする。

## UX 非ゴール

下記を初期バージョンの目標としない。

* Excessive Animation
* Gamification
* Social Features
* Arbitrary Dashboard Customization
* Complex ジェスチャ System
* Pixel-identical プラットフォーム横断型 UI (`## No Pixel-identical Requirement`)

## v1 - アクセシビリティ

v1で考慮する支援技術は `## アクセシビリティ` を正本とする。検証項目は [`testing_spec.md`](./testing_spec.md) を正本とする。

## v1 - パフォーマンス

v1で体感遅延を避ける操作は Launch / Dashboard / Search / Detail / Chart / Refresh / ナビゲーションとする。Benchmark 項目は [`testing_spec.md`](./testing_spec.md) を正本とする。
