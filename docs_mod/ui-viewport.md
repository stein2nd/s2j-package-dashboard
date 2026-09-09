# S2J Package Dashboard - Viewport 整合性仕様

**Status:** Draft

本仕様は、実機 UI 検証を通じて継続的に更新する。

特に下記について、実装後に再評価する。

* iPhone Portrait / Landscape
* iPad Portrait / Landscape
* iPad Split View / Window Resize
* Android Window Size Class
* Dynamic Type / Font Scale
* Chart Layout
* Long Package Name
* Large Numeric Value
* Loading/Error/Empty 状態
* Navigation UI の表示状態の変化

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、**UI Viewport Integrity (表示領域の整合性)** を定義します。

本仕様における Viewport とは、アプリケーションがその時点で UI を表示可能な実効表示の領域を指す。

Viewport は、単純な物理画面サイズではなく、下記を考慮した表示領域として扱う。

* デバイスの画面サイズ
* 画面の向き
* Safe Area
* Window Size
* iPadOS の Split View / Stage Manager 等によるウィンドウサイズ
* Android の Window Size Class
* Dynamic Type / Font Scale
* システム UI
* Navigation UI / Toolbar / Tab Bar 等による占有領域
* キーボード等の一時的な表示領域の変化

本仕様の目的は、下記を保証することである。

1. 表示されている UI 要素が実際に到達可能であること
2. UI 要素が画面外に意図せず配置されないこと
3. 画面サイズや向きの変更に対して UI が安定して再配置されること
4. コンテンツが切り取られたり隠れたりしないこと
5. タッチ・クリック等の操作領域が適切に確保されること
6. iPhone / iPad / Android の異なる Viewport に対して適応的に表示できること

Viewport 整合性の正本は本仕様とする。横断的な UI 振る舞いは [`ui.md`](./ui.md)、画面構成は [`screen_spec.md`](./screen_spec.md)、ナビゲーションは [`navigation_spec.md`](./navigation_spec.md) を参照する。

## 目的

本仕様は UI Viewport Integrity (表示領域の整合性) を保証する。表示中の UI が到達可能であり、向きや Window Size の変更に対して安定して再配置され、コンテンツが意図せず隠れないことを正本として定義する。

## 非目的

本仕様は、Navigation Graph、Screen の責務、ドメイン・モデル、API Contract、色/タイポグラフィの Design Token、Animation の詳細を直接定義しない。

## 責務

到達可能性、レイアウト安定性、コンテンツ整合、操作整合、v1の Release Blocker、Viewport テスト行列を定義する。

## 非責務

横断 UI は [`ui.md`](./ui.md)、画面構成は [`screen_spec.md`](./screen_spec.md)、ナビゲーションは [`navigation_spec.md`](./navigation_spec.md)、視覚 Token は [`design_spec.md`](./design_spec.md)、向き変更後に何を保持するかは [`application_state.md`](./application_state.md) を正本とする。

## 基本原則

### 1. Viewport を固定サイズとして扱わない

UI は特定のデバイスの物理画面サイズを前提として設計してはならない。

下記のような固定値への依存を避ける。

* 特定デバイスの横幅
* 特定デバイスの縦幅
* 特定の Aspect Ratio
* 「この端末なら必ず表示できる」という前提
* 固定された画面座標

UI は、その時点で利用可能な Window / Viewport に応じてレイアウトを決定する。

## Viewport Integrity

本アプリケーションでは、下記を **Viewport Integrity** の基本要件とする。

### 1. Reachability

画面上に表示されている操作可能な UI 要素は、ユーザーが実際に操作可能でなければならない。

特に下記を禁止する。

* 画面端に隠れてタップできないボタン
* Safe Area の外側に配置された操作要素
* 親 View の clipping により操作できない要素
* 水平方向に意図せずはみ出した UI
* 見えているが実際の Hit Area が画面外にある UI
* ScrollView の外側に存在するがスクロールによって到達できない UI

「見えていること」と「操作できること」は同一の品質条件として扱う。

### 2. Layout Stability

Viewport の変化によってレイアウトを再計算する場合でも、不必要な視覚的ジャンプを発生させてはならない。

特に下記を禁止する。

* 起動直後に左寄せされた後、遅れて中央寄せになる
* 画面回転時にコンテンツが一時的に画面外に移動する
* データ取得完了とは無関係に UI の位置が大きく移動する
* Navigation UI の表示・非表示によってコンテンツが不必要に跳ねる
* Window Size Class の変更時に一時的な不正レイアウトを表示する

Layout の変更が必要な場合は、可能な限り一貫したレイアウト計算結果を直接表示する。

### 3. Content Integrity

ユーザーに提示する情報は、Viewport の制約によって意図せず欠落してはならない。

下記を禁止する。

* テキストの意図しない clipping
* Package 名の途中切断
* 数値の途中切断
* Chart の軸・凡例の clipping
* ボタンのラベルが表示されない状態
* Error Message の一部だけが表示される状態
* Accessibility に必要な情報が画面外に消える状態

表示領域が不足する場合は、下記のいずれかを使用する。

* 改行
* Truncation + 詳細表示
* Vertical Scroll
* Horizontal Scroll
* Adaptive Layout
* Multi-pane Layout
* 別画面への遷移

ただし、Horizontal Scroll は、情報構造上、必要な場合に限定して使用する。

### 4. Interaction Integrity

UI の操作領域は、表示領域および UI 階層との整合性を保たなければならない。

下記を禁止する。

* 親 View の Gesture が子 View の操作を妨げる
* Scroll Gesture と Button Gesture の競合によって操作不能になる
* 見た目と Hit Area が大きく異なる
* UI 要素同士の重なりによって操作対象を誤認する
* Overlay が意図せず下層 UI の操作を遮断する

## Safe Area

### 1. 基本方針

Platform が提供する Safe Area を尊重する。

Apple の UI ガイドラインでも Safe Area は、システム UI やデバイス固有の表示・操作領域によって覆われない領域として扱われている。([Layout | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/layout?changes=la__1_8_1))

したがって、アプリケーション独自に「画面端から何 pt 空ければ安全」といった固定ルールを設定してはならない。

### 2. 操作 UI

下記の UI は Safe Area 内に配置する。

* Button
* Navigation Item
* Toolbar Item
* Tab Item
* Toggle
* Menu
* TextField
* SearchField
* Slider
* Chart 操作 UI

特に画面端に配置される操作 UI は、Safe Area と実際の Hit Area の両方を確認する。

## Adaptive Layout

UI は「端末種類」ではなく、利用可能な Viewport / Window Size を基準として適応する。compact / medium / expanded を優先し、`if iPhone` / `if iPad` を基本設計にしない。

画面上の置き場所は [`screen_spec.md`](./screen_spec.md)、Split View / Stack の Collapse は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、狭い Viewport では縦スクロールで到達可能にし、画面座標に依存した Layout を最小にすることだけを定める。

## iOS/iPadOS

SwiftUI の adaptive 機構を使う。`NavigationStack` / `NavigationSplitView` は [`navigation_spec.md`](./navigation_spec.md) を正本とする。本仕様は、`GeometryReader` による画面座標の依存を最小にすることだけを定める。

## Android

物理デバイスではなく Window Size Class を基準とする。`ListDetailPaneScaffold` 等の Pane 構成は [`navigation_spec.md`](./navigation_spec.md) を正本とする。

## Orientation Change

Portrait / Landscape の切り替えによって UI が破綻してはならない。対象デバイスは `## Reference Devices` を正本とする。

Orientation Change 時には、新しい Viewport に対してレイアウトを再計算する。中間 Layout を見せない。保持する Application 状態は [`application_state.md`](./application_state.md) を正本とする。

同一コンテンツを表示可能な場合、Scroll Position を可能な限り維持する。Layout Mode が変わる場合は、offset ではなく現在表示していたコンテンツを基準に復元する。

## Dynamic Type / Font Scale

UI は Dynamic Type / Font Scale に対応する。

Apple では Dynamic Type を含む文字サイズ変更への適応が UI の adaptability の一部として扱われている。([Layout | Apple Developer Documentation](https://developer.apple.com/design/human-interface-guidelines/layout?changes=la__1_8_1))

Android でも font scale を含む configuration change に対して UI の continuity を維持することが求められる。([Get started with adaptive apps | Adaptive Apps | Android Developers](https://developer.android.com/develop/adaptive-apps/guides/get-started-with-adaptive-apps?hl=en))

### 要件

下記を禁止する。

* 固定高さの Text Container
* 固定行数を前提とした重要情報
* 大きな文字サイズでの clipping
* Button Label の clipping
* 数値・単位の重なり
* Chart Label の clipping

## Long Content

Package Dashboard では外部 API から取得する文字列長を保証できない。

対象:

* Package Name
* Description
* リポジトリ Name
* Maintainer Name
* Version
* Release Notes
* Error Message

したがって、長い文字列を通常ケースとして扱う。

### Package Name

Package Name は原則として省略せず表示可能な構成を優先する。

表示領域が不足する場合は、下記のいずれかを使用する。

1. 改行
2. Truncation
3. Detail View
4. Tooltip / Accessibility Label

## Large Numeric Values

Package Dashboard では下記のような大きな数値を扱う。

* Downloads
* GitHub Stars
* Forks
* Issues
* Pull Requests
* Contributors

下記を保証する。

* 数値が画面外にはみ出さない
* 桁数増加によって Card の Layout が破綻しない
* 単位表示と数値が重ならない
* Locale に応じた Number Formatting を使用する

例:

* 1,234
* 12.4K
* 1.2M
* 1.2B

ただし、略記によって意味が曖あいまいになる場合は完全な値を確認できる UI を提供する。

## Charts

Statistics Chart は Viewport に応じて適応する。Compact / Expanded とも Chart は横幅に応じて表示密度を調整する。

下記を禁止する。

* X 軸 Label の clipping
* Y 軸 Label の clipping
* Legend の画面外配置
* Chart 操作領域の画面外配置
* 数値 Tooltip が画面外に完全に消える状態

## Horizontal Overflow

原則として、アプリケーション全体に意図しない Horizontal Overflow を発生させない。

特に下記を禁止する。

```text
┌─────────────────────┐
│ Content ────────────┼──→
└─────────────────────┘
```

画面全体が横方向にスクロール可能になってしまう場合は、Layout defect とみなす。

ただし、下記のように情報構造上 Horizontal Scroll が必要な場合は例外とする。

* 横方向 Chart
* 横方向 Table
* 明示的な Horizontal Collection
* 横方向 Carousel

この場合でも、Horizontal Scroll の存在をユーザーが認識できることを確認する。

## Viewport Overflow Detection

開発時および UI Test において、下記を検査対象とする。

### 1. Clipping

* Text clipping
* Button clipping
* Card clipping
* Chart clipping
* Navigation item clipping

### 2. Overflow

* Horizontal overflow
* Vertical overflow
* Safe Area overflow
* Hit Area overflow

### 3. Overlap

* Button / Button
* Text / Icon
* Card / Card
* Chart / Legend
* Navigation / Content
* Overlay / Interactive Element

## 状態 Change による Viewport Stability

Loading / Refresh / Error / Empty の状態分類は [`application_state.md`](./application_state.md)、見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、状態切替で主要コンテンツが不必要に移動しないことだけを定める。

## Navigation UI と Viewport

Navigation UI は Content Area と競合してはならない。

Navigation UI の表示状態が変化した場合でも、

* Content が clipping されない
* 操作対象が隠れない
* Scroll Position が不必要に失われない
* Layout が不必要にジャンプしない

ことを保証する。

Navigation の意味論については [`navigation_spec.md`](./navigation_spec.md) を Source of Truth とする。

## Accessibility

Viewport Integrity は Accessibility を含む。

対象:

* Dynamic Type
* Font Scale
* VoiceOver
* TalkBack
* Larger Text
* Bold Text
* Reduce Motion
* Increased Contrast
* Touch Target

UI は、文字サイズやアクセシビリティ設定を変更しても、主要な情報および操作を利用可能な状態に維持する。

## Reference Devices

初期検証の対象は下記とする。

### iPhone

* `iPhone 16 Pro Max`
* `iOS 26.6`

### iPad

* `iPad Air 5th generation`
* `iPadOS 26.6`

### Android

* 会社支給 Android device

Android device の具体的な機種/OS Version が確定した時点で、本仕様に追記する。

## Viewport Test Matrix

最低限、下記の組み合わせを検証する。

| Platform | Orientation | Size | Text |
| --- | --- | --- | --- |
| iPhone | Portrait | Compact | Default |
| iPhone | Landscape | Compact/Medium  | Default |
| iPad | Portrait | Medium/Expanded | Default |
| iPad | Landscape | Expanded | Default |
| Android | Portrait | Compact | Default |
| Android | Landscape | Medium/Expanded | Default |
| iPhone | Portrait | Compact | Large |
| iPad | Landscape | Expanded | Large |
| Android | Portrait | Compact | Large |

## Viewport Acceptance Criteria

下記をすべて満たした場合、Viewport Integrity を満たすものとする。

### A. Reachability

* [ ] すべての表示中の操作 UI を操作できる
* [ ] Safe Area 外に重要な操作 UI が存在しない
* [ ] Hit Area が画面外に存在しない

### B. Layout Stability

* [ ] 起動時に不自然な Layout Jump が発生しない
* [ ] Orientation Change 時に不自然な Layout Jump が発生しない
* [ ] Window Size Change 時に不自然な Layout Jump が発生しない
* [ ] Loading/Loaded 状態 Change による不必要な Layout Shift が発生しない

### C. Content Integrity

* [ ] 重要な Text が clipping されない
* [ ] 数値が clipping されない
* [ ] Chart が clipping されない
* [ ] Error/Empty 状態が clipping されない

### D. Interaction Integrity

* [ ] Gesture Conflict がない
* [ ] Overlay による意図しない操作不能がない
* [ ] Scroll と Interactive Element の競合がない

### E. Adaptability

* [ ] Portrait / Landscape の双方で利用可能
* [ ] iPad の異なる Window Size に適応する
* [ ] Android の Window Size Class に適応する
* [ ] Dynamic Type / Font Scale に適応する

### F. Accessibility

* [ ] Large Text で UI が破綻しない
* [ ] VoiceOver / TalkBack で主要操作が可能
* [ ] Touch Target が適切に確保されている

## v1の Release Blocker

v1では下記を Release Blocker とする。

* 重要 UI が Viewport 外にある
* 重要 UI が Tap できない
* Text が Clip される
* Chart が操作不能
* 向き変更で Layout が破綻する
* iPad Resize で Layout が破綻する

向き変更 (Portrait ↔ Landscape) で下記が発生することも Blocker とする。

* Unexpected Left Alignment
* Unexpected Centering
* Clipped コンテンツ
* Lost 状態
* Unreachable コンテンツ

## Implementation Principles

実装時には、下記を原則とする。

### iOS/iPadOS

SwiftUI で Adaptive Layout を組み、Safe Area / Size / Accessibility に合わせる。

### Android

Jetpack Compose で Window Size Class に合わせ、Adaptive Layout と Accessibility / Font Scale を扱う。

UI の共通化を目的として、iOS / Android の UI 実装そのものを無理に共通化しない。

共通化対象は、

* Screen Semantics
* Navigation Semantics
* 状態
* Domain Logic
* アプリケーション Logic

を優先する。
