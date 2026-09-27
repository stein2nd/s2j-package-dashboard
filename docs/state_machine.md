# S2J Package Dashboard - 状態機械の仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、アプリケーション状態機械の形式、状態、イベント、遷移、エフェクトおよびレデューサーの責務を定義します。

何を保持・復元するかは [`application_state.md`](./application_state.md)、どう遷移するかは本仕様を正本とします。

一方向データフローと、レデューサー/エフェクトの分離は [デザイン原則](#デザイン原則) を正本とします。
本仕様は、「同一の遷移セマンティクスを、SwiftUI / Compose / Kotlin Multiplatform (KMP) 共有ロジックで共有できる」ことだけを再掲します。

## 目的

本仕様は、アプリケーション状態機械の形式、状態、イベント、遷移、エフェクトおよびレデューサーの責務を定義します。目的は、状態の変更経路を明示的かつ予測可能にすることです。

何を状態として保持・復元するかは [`application_state.md`](./application_state.md) を正本とします。
本仕様は、どう遷移するかを正本とします。

## 非目的

本仕様では、下記を要求しません。

* TCA/Redux 等の、特定フレームワークの採用
* 単一ストアの強制
* 全スクリーンの状態を、一つの巨大な状態に統合すること
* 全 UI ローカル状態の、状態機械化
* ネットワーク・リクエスト自体を、状態として永続化すること
* 非同期タスクの復元
* プラットフォーム固有のナビゲーション API の共通化

## 責務

状態/イベント/遷移/レデューサー/エフェクト、復元遷移、起動 および各部分の状態機械を定義します。

## 非責務

状態の詳細構造は [`application_state.md`](./application_state.md) を正本とします。
派生/単発を保存しないことも、同仕様を正本とします。
検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
`ApplicationError` の型は [`models_spec.md`](./models_spec.md) を正本とします。
ドメイン・モデル、リポジトリ/API 実装、SwiftUI/Compose、SwiftData/Room、Keychain/Keystore は各専門仕様を正本とします。

## デザイン原則

状態機械は、下記の原則に従います。

### 単一方向

状態の変更方向は、一方向とします。ビューが直接、ドメイン・データやリポジトリを変更してはなりません。

ユーザー/システム→イベント→レデューサー→状態→ビュー

### 単一の、信頼できる情報源 (SoT)

アプリケーション状態に含まれる値の重複禁止は [`application_state.md`](./application_state.md) を正本とします。
本仕様は、「レデューサーが導出値を、Stored 状態として持たない」ことのみを定めます。

### 純粋な状態遷移

レデューサーは、状態とイベントから次の状態を決定します。同一の状態とイベントに対して、同一の NewState の生成を原則とします。

`(State, Event) → NewState`

レデューサーは、ネットワーク、ファイルシステム、データベース、クロック、乱数生成器 (RNG) 等の外部依存を、直接操作してはなりません。

### 副作用の分離

ネットワーク・リクエストや永続化等の I/O は、エフェクト/コマンドとして、状態遷移から分離します。

イベント→レデューサー→新しい状態/エフェクトを出し、エフェクトの結果は、イベントとしてレデューサーに戻します。

この構造により、非同期処理の結果も、通常のイベントとして状態機械に戻します。

## 用語集

| 用語 | 定義 |
| --- | --- |
| 状態 | 現在のアプリケーション状態 |
| イベント | 状態機械に入力される、事象 |
| 遷移 | 状態から別の状態への遷移 |
| レデューサー | イベントに応じて、状態を更新する処理 |
| エフェクト | 状態遷移の結果として、外部 I/O 等を実行する処理 |
| コマンド | エフェクトに実行を依頼する、宣言的な命令 |
| ストア | 現在の状態を保持し、イベントを処理する実行主体 |
| セレクタ | 状態から、必要な派生値を取得する処理 |
| 不変 | 状態が常に満たすべき、条件 |
| 復元 | 保存された状態から、アプリケーション状態を再構築する処理 |

## 状態

アプリケーション状態の詳細な構造は、`application_state.md` で定義します。

本状態機械が扱うフィールド群の意味と復元対象は [`application_state.md`](./application_state.md) を正本とします。

可能な限り、状態は、値セマンティクスを持つ、不変値として扱います。

実装言語やフレームワークの都合により、内部的に可変なフィクスチャを利用してもよいが、外部から観測される状態遷移は、不変値の置換として扱います。

## イベント

イベントは、状態機械に入力される事象を表します。下記は、イベントをカテゴリーに分類したものです。

* ユーザー・イベント
* ライフサイクル・イベント
* ナビゲーション・イベント
* データ・イベント
* ネットワーク・イベント
* 認証・イベント
* 復元・イベント
* システム・イベント

下記は、各カテゴリーの例です。

### ユーザー・イベント

ユーザー操作によって、発生します。

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

### ライフサイクル・イベント

アプリケーション/Scene の状態変化を表します。

* `AppLaunching`
* `AppActive`
* `AppInactive`
* `AppBackground`

### ナビゲーション・イベント

ナビゲーションの変更を表します。

* `Navigate(destination)`
* `NavigateBack`
* `PopToRoot`
* `Present(destination)`
* `Dismiss`
* `OpenDeepLink(destination)`

### データ・イベント

リポジトリ/API から返された結果を表します。

* `DataLoaded(data)`
* `DataLoadFailed(error)`

* `PackageLoaded(package)`
* `PackageLoadFailed(error)`

* `StatisticsLoaded(statistics)`
* `StatisticsLoadFailed(error)`

### ネットワーク・イベント

ネットワークの状態の変化を表します。ネットワークの状態を、直接 UI 状態に書き込むのではなく、レデューサーを通して、必要なアプリケーション状態に、反映します。

* `NetworkAvailable`
* `NetworkUnavailable`

### 認証イベント

認証状態の変化を表します。クレデンシャル (資格情報) Secret 自体を、イベント・ペイロードに含めません。

* `AuthenticationRequested(provider)`
* `AuthenticationSucceeded(provider, account)`
* `AuthenticationFailed(provider, error)`
* `AuthenticationExpired(provider)`
* `AuthenticationRemoved(provider)`

### 復元イベント

状態復元に関連するイベントです。

* `RestoreRequested`
* `RestoreSucceeded(state)`
* `RestoreFailed(error)`
* `RestoreDiscarded(reason)`

## イベントの命名

イベントは、「発生した事象」を表す名前とします。イベントは、UI 実装ではなく、アプリケーション挙動を表現します。

推奨:

* `RefreshRequested`
* `PackageSelected`
* `StatisticsLoaded`
* `AuthenticationSucceeded`

避ける:

* `SetLoadingTrue`
* `ChangeInternalFlag`
* `UpdateBoolean`

## イベント・ペイロード

イベント・ペイロードは、状態遷移に必要な、最小限の情報のみを持ちます。パッケージ・オブジェクト全体を、イベント・ペイロードに含める必要がない場合、`PackageSelected( package: Package )` とはしません。原則として、識別子を優先します。

例:

`PackageSelected( packageID: PackageIdentifier )`

## 遷移

遷移は、`現在の状態 + イベント → 次の状態` として定義します。詳細は [遷移テーブル](#遷移テーブル) を正本とします。

例:
* アイドル + DataLoadRequested → 読込中
* 読込中 + DataLoaded → 読込完了
* 読込中 + DataLoadFailed → エラー

## 遷移テーブル

主要な状態遷移を、下記のように定義します。この表は、基本的な状態遷移を示すものであり、個々の機能の状態機械が、必要に応じて、詳細化します。

| 現在の状態 | イベント | 次の状態 |
| --- | --- | --- |
| 起動中 | AppActive | アクティブ |
| アクティブ | AppInactive | 非アクティブ |
| 非アクティブ | AppActive | アクティブ |
| アクティブ | AppBackground | バックグラウンド |
| バックグラウンド | AppActive | アクティブ |
| アイドル | DataLoadRequested | 読込中 |
| 読込中 | DataLoaded | 読込完了 |
| 読込中 | DataLoadFailed | エラー |
| 読込完了 | RefreshRequested | 更新中 |
| 更新中 | DataLoaded | 読込完了 |
| 更新中 | DataLoadFailed | Stale + エラー |
| エラー | RetryRequested | 読込中 |
| Stale | RefreshRequested | 更新中 |
| 空 | RefreshRequested | 更新中 |
| 未認証 | AuthenticationRequested | 認証中 |
| 認証中 | AuthenticationSucceeded | 認証済み |
| 認証中 | AuthenticationFailed | 未認証 + エラー |
| 認証済み | AuthenticationExpired | 有効期限切れ |
| 有効期限切れ | AuthenticationRequested | 認証中 |

## 状態機械のヒエラルキー

アプリケーション全体を、単一の巨大な状態機械として、実装する必要はありません。

下記の階層を許可します。

`ApplicationStateMachine` の下に、ナビゲーション/パッケージ/統計/認証/データ/復元、のサブ状態機械を置いてかまいません。

各サブ状態機械は、アプリケーション状態の一部を担当します。ただし、サブ状態機械間で、同一の状態を二重管理してはなりません。

## レデューサー

レデューサーは、イベントを、状態遷移に変換します。

概念的な形式:

`reduce( state: ApplicationState, event: Event ) -> TransitionResult`

`TransitionResult` は、概念的に `state` と `effects` を持ちます。

例:

`reduce( state: .loaded, event: .refreshRequested )`

結果:

* `state`: `.refreshing`
* `effects`: `.refreshPackageData`

## レデューサーの責務

レデューサーは、下記を担当します。

* イベントの解釈
* 状態遷移
* 状態不変の維持
* エフェクトの生成
* 無効イベントの無視またはエラー化

レデューサーは、下記を担当しません。

* HTTP リクエスト
* データベース・クエリー
* ファイル I/O
* Keychain/Keystore アクセス
* SwiftUI ビュー操作
* Compose UI 操作
* ナビゲーション・コントローラの直接操作
* アラートの直接表示

## エフェクト

エフェクトは、状態機械の外部で実行される処理を表します。

代表例: FetchPackage / FetchStatistics / SaveFavorite / RemoveFavorite / SaveSnapshot / LoadPersistedState / SaveRestorableState / Authenticate / OpenExternalURL。

エフェクトの完了結果は、イベントとしてストアに戻します。

エフェクト→外部システム→結果→イベント→レデューサー

## エフェクトは、状態を直接変更してはならない

エフェクトは、アプリケーション状態を直接変更してはなりません。

Bad: エフェクトが `state.isLoading = false` を書く。
Good: エフェクトが `DataLoaded` イベントを出し、レデューサーが状態を更新する。

これにより、すべての状態変更を、イベントと遷移として追跡可能にします。

## コマンド

エフェクトの実行内容を、宣言的に表現する場合、コマンドを使用します。

例:

* `Command.fetchPackage(packageID)`
* `Command.fetchStatistics(packageID, period)`
* `Command.saveFavorite(packageID)`
* `Command.deleteFavorite(packageID)`

コマンド自体は、I/O 実装を持ちません。

プラットフォーム固有のエグゼキューターがコマンドを実行し、その結果をイベントに変換します。

## 非同期処理

非同期処理は、下記の形式を基本とします。

イベント→レデューサー→状態 = 読込中 かつ エフェクト = フェッチ→リポジトリ→成功 / 失敗→イベント→レデューサー→状態 = 読込完了 / エラー

詳細は [副作用の分離](#副作用の分離) を正本とします。
非同期の処理中に、ビューが直接状態を変更してはなりません。

## リクエスト・アイデンティティ

同時に複数のリクエストが存在する可能性がある場合、リクエスト・アイデンティティを使用します。

例:

* `RequestID`
* `PackageID`
* `StatisticsPeriod`

レスポンス・イベントにリクエスト・アイデンティティを含めます。

`StatisticsLoaded( requestID, packageID, period, statistics )`

レデューサーは、現在の状態とリクエスト・アイデンティティを比較します。

## Stale レスポンス保護

古いリクエストのレスポンスによって、新しい状態が上書きされないようにします。

例:

`リクエスト A`、`リクエスト B` の順で開始された場合、B 完了なら `状態 = B`、後から完了した A は 無視 とします。

必要に応じて、下記のいずれかを採用します。機能ごとの選択は、個別仕様で定義します。

* 最新優先
* リクエスト ID マッチング
* キャンセル
* リクエスト結合

## 並行処理のリフレッシュ

同一対象へのリフレッシュが複数回要求された場合、重複リクエストを抑制します。

基本方針: 更新中の追加 RefreshRequested は No-op とする。

ただし、明示的な再実行を許可する機能では、別途定義してかまいません。

基本的には、同一のパッケージ/同一の統計期間に対して、リクエストを一つにします。

## キャンセル

不要になった非同期処理は、キャンセルを許可します。

例: パッケージ A のフェッチ中に、ユーザーがパッケージ B に移ったら、フェッチ A をキャンセルし、フェッチ B を開始する。

キャンセルは、通常のエラーと区別します。ユーザーが別の画面に移動しただけで、画面上にエラーを表示してはなりません。

Cancelled ≠ 失敗

## エラー・イベント

`ApplicationError` の型は [`models_spec.md`](./models_spec.md) を正本とします。
本仕様は、「エラーを ApplicationError に正規化し、プロバイダ固有エラー を UI 層に、直接、伝播させない」ことのみを定めます。

## エラー遷移

下記は、代表的なエラー遷移です。

* 読込中 + NetworkUnavailable → エラー / オフライン
* 更新中 + NetworkUnavailable → 読込完了 / Stale
* 読込中 + AuthenticationRequired → 未認証

詳細は [遷移テーブル](#遷移テーブル) を正本とします。
既存データが存在する場合は、可能な限り、データを保持します。

## エラー・リカバリー

エラー・リカバリーは、イベントとして表現します。

* エラー + RetryRequested → 読込中

既存データがある場合は、下記とします。

* Stale + RetryRequested → 更新中

## ナビゲーション遷移

ナビゲーションもイベントと状態の関係として扱います。行き先と戻り方は [`navigation_spec.md`](./navigation_spec.md)、経路は [`ux_flows_spec.md`](./ux_flows_spec.md) を正本とします。
本仕様は、例として「`Dashboard` + `PackageSelected(id)` → `PackageDetail(id)`、`PackageDetail(id)` + `NavigateBack` → `PackageList` とする」ことのみを定めます。

ナビゲーション UI の具体的な実装は、プラットフォーム層に委ねます。

## ディープリンク遷移

ディープリンクは、イベントとして状態機械に入力します。経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、URI は [`navigation_spec.md`](./navigation_spec.md) を正本とします。
本仕様は、「`DeepLinkReceived(url)` →解析→ `OpenPackage(packageID)` →ナビゲーション状態、とする」ことのみを定めます。

不正なディープリンクは、無視またはエラー・イベントに変換します。

## 状態の不変

状態機械は、下記の不変を維持します。

### 選択の不変

`selectedPackage != null` の場合、パッケージの識別子は、正規化済みでなければなりません。

### ロードの不変

`loadState == 読込中` の場合、初期ロード・リクエストが存在します。

ただし、リクエスト・オブジェクト自体を永続化の状態に保存してはなりません。

### リフレッシュの不変

`refreshState == 更新中` の場合、対象となるリフレッシュ操作が存在します。

### クレデンシャル (資格情報) の不変

クレデンシャル Secret を状態に入れないことは [`application_state.md`](./application_state.md) / [`security_spec.md`](./security_spec.md) を正本とします。
本仕様は、「遷移後に、その不変条件を `assertValidState` できる」ことのみを定めます。

### ナビゲーションの不変

ナビゲーション・パスに存在する遷移先は、現在のアプリケーション・バージョンで解釈可能でなければなりません。

## 派生の状態

導出して保存しないことは [`application_state.md`](./application_state.md) を正本とします。
本仕様は、「レデューサーが `isLoading` / `isRefreshing` / `hasError` 等を Stored 状態として持たない」ことのみを定めます。

## イベントの順序付け

イベントは、ストアによって順序付けられます。

基本的には、下記とし、同一ストアに対する状態の変更が、並行して実行されないようにします。

イベント A →レデューサー→状態 A →イベント B →レデューサー→状態 B

## スレッド・セーフティ

状態変更は、単一の直列化コンテキストで実行します。

プラットフォーム実装では、下記を利用してかまいません。ただし、スレッド/コルーチン・コンテキストの選択によって、状態遷移の意味が変化してはなりません。

* iOS: 主アクター/アクターの分離等
* Android: コルーチン/StateFlow 等

## ストア

ストアは、アプリケーション状態機械の実行主体です。

概念的には、状態/レデューサー/エフェクト・エグゼキューター/イベント・ディスパッチャを持ちます。

処理順序: `dispatch(Event)` →レデューサー→新しい状態→状態のパブリッシュ→エフェクトの実行→エフェクトの結果→ `dispatch(Event)`

## ストアの責務

ストアは、下記を担当します。

* 現在の状態の保持
* イベントのディスパッチ
* レデューサーの実行
* 状態のパブリッシュ
* エフェクトの起動
* エフェクト結果のイベント化
* イベントの順序付け

ストアは、下記を担当しません。

* UI レイアウト
* API クライアントの詳細
* データベースの詳細
* クレデンシャル (資格情報) の直接管理
* プラットフォーム固有のナビゲーション UI

## 状態の観測

UI は状態を観測します。ビューは、必要な状態のみを購読してかまいません。たとえば「パッケージ詳細」スクリーン は、`PackageDetailState` だけを購読してかまいません。

* ストア→状態→セレクタ→ビュー

## セレクタ

セレクタは、アプリケーション状態から、プレゼンテーションに必要な値を導出します。セレクタは、純粋関数とします。また、セレクタは、状態を変更してはなりません。

例: ApplicationState →セレクタ→ PackageDetailViewState

## プレゼンテーション状態

アプリケーション状態とビューの状態は、区別します。

見え方は [`ui.md`](./ui.md) を正本とします。
本仕様は、「アプリケーション状態→プレゼンテーション→ビューの状態→ SwiftUI / Compose とし、ビュー専用の表示情報を、アプリケーション状態に逆流させない」ことのみを定めます。

たとえば、ビュー専用の表示情報を、アプリケーション状態に逆流させません。

```text
Application State:
    statisticsPeriod = monthly
    statistics = ...

View State:
    chartData = ...
    periodLabel = "Monthly"
    showEmptyState = false
```

## プラットフォーム境界

共有対象は [`architecture.md`](./architecture.md)、Kotlin Multiplatform (KMP) の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本仕様は、「状態/イベント/レデューサー/遷移/エフェクト定義をコアに置き、SwiftUI/Compose/SceneStorage/SavedStateHandle/エフェクト・エグゼキューターをプラットフォームに置く」ことのみを定めます。

## Kotlin Multiplatform (KMP) の互換性

HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本仕様は、「状態機械コアが SwiftUI/Compose API に依存しない」ことのみを定めます。

## 直列化

復元対象は [`application_state.md`](./application_state.md) を正本とします。
本仕様は、「復元可能な状態の直列化モデルと Runtime の状態を分離し、Runtime の状態を永続化フォーマットとして固定しない」ことのみを定めます。

## 状態復元の遷移

復元対象と復元順位は [`application_state.md`](./application_state.md) を正本とします。
本節は、「復元の遷移」のみを定義します。

状態復元は、下記の状態機械とします。復元失敗後も、アプリケーション自体は、デフォルトの状態で起動可能とします。

* restoration.idle + RestoreRequested → restoration.loading
* 読込中 から RestoreSucceeded →復元済み、RestoreDiscarded → discarded、RestoreFailed →失敗

## アプリケーション起動

起動の経路は [`ux_flows_spec.md`](./ux_flows_spec.md)、ルートは [`navigation_spec.md`](./navigation_spec.md)、復元対象は [`application_state.md`](./application_state.md) を正本とします。
本仕様は、「Launching から RestoreRequested / LoadLocalData / CheckAuthentication が並行し得る」ことのみを定めます。

アプリケーション起動の基本遷移: Launching から RestoreRequested / LoadLocalData / CheckAuthentication が分岐し、アクティブに進む。

これらは独立したエフェクトとして、並行実行してかまいません。

ただし、ナビゲーション状態の復元など、依存関係がある処理は、順序を明示します。

## パッケージ・ロードの状態機械

パッケージ・データは、下記の状態機械を基本とします。

* idle + LoadRequested → 読込中。読込中 + LoadSucceeded → 読込完了、NoData → 空、LoadFailed → エラー

既存のローカルデータが存在する場合:

* idle + LocalDataAvailable → 読込完了 / Stale。Stale + RefreshRequested → 更新中。更新中 + 成功 → 読込完了、失敗 → Stale。

## 統計の状態機械

統計は、パッケージ・データとは独立した、状態機械とします。

* idle + StatisticsRequested → 読込中。読込中 + StatisticsLoaded → 読込完了、StatisticsFailed → エラー

期間変更:

* 読込完了 + StatisticsPeriodChanged → 読込中

既存スナップショットが利用可能な場合:

* PeriodChanged →ローカル・スナップショット→ 読込完了 / Stale → リモート・リフレッシュ

## お気に入りの状態機械

お気に入りの追加・削除は、冪等 (べきとう) とします。

同じイベントが複数回発生しても、最終状態が無効にならないこと。

### 追加

* `notFavorite` + `AddFavorite` → `favorite`

すでにお気に入りでも、`AddFavorite` は `favorite` のままとします。

### 削除

* `favorite` + `RemoveFavorite` → `notFavorite`

すでに notFavorite でも `RemoveFavorite` は、`notFavorite` のままとします。

## 認証の状態機械

認証状態は、下記を基本とします。

許可される状態の一覧は [`authentication_spec.md`](./authentication_spec.md) を正本とします。
本仕様は、「未認証 + AuthenticationRequested → 認証中、Succeeded → 認証済み、失敗 → 未認証 とする」ことのみを定めます。

クレデンシャル (資格情報) 有効期限: 認証済み + AuthenticationExpired → 有効期限切れ。有効期限切れ + AuthenticationRequested → 認証中。

クレデンシャル Secret をイベント・ペイロードに含めないことは [`application_state.md`](./application_state.md) / [`security_spec.md`](./security_spec.md) を正本とします。

## 無効イベント

現在の状態では意味を持たないイベントを受信した場合の、処理を定義します。

基本方針: 無効イベントは、状態を変更しません。

例: 読込中の AddFavorite が、パッケージ ID を持たず処理不能な場合。

ただし、ユーザー操作のフィードバックが必要な場合は、状態を変えずに、エラー・エフェクトを出してかまいません。

## イベントの冪等 (べきとう) 性

下記のイベントは、可能な限り、冪等 (べきとう) にします。同じイベントを複数回処理しても、状態が不正な状態に進まないこと。

* AddFavorite
* RemoveFavorite
* MarkRead 相当の操作
* リフレッシュのリクエスト結合
* 認証の削除
* 状態復元の破棄

## 遷移のログ記録

デバッグ・ビルドでは、状態遷移を追跡可能にしてかまいません。ただし、Secret をログに出力してはなりません。禁止対象は [`security_spec.md`](./security_spec.md) を正本とします。

例:

```text
[StateMachine]
状態: loaded
イベント: RefreshRequested
状態: refreshing
エフェクト: FetchPackage
```

## テスト

検証項目は [`testing_spec.md`](./testing_spec.md) を正本とします。
本仕様は、「状態機械が外部 I/O なしで、Given 状態 / When イベント / Then 状態の形式で検証できる」ことのみを定めます。

## レデューサー・テスト

遷移表は [遷移テーブル](#遷移テーブル) を正本とします。
検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
本仕様は、「レデューサー、をテーブル駆動に検証できる、純関数として設計する」ことのみを定めます。

## 不変性テスト

ドメイン不変条件は [`domain_rules.md`](./domain_rules.md)、クレデンシャル (資格情報) を状態に入れないことは [`application_state.md`](./application_state.md) / [`security_spec.md`](./security_spec.md) を正本とします。
本仕様は、「各遷移後に `assertValidState` できる」ことのみを定めます。

## エフェクト・テスト

検証項目は [`testing_spec.md`](./testing_spec.md) を正本とします。
本仕様は、「エフェクトをレデューサーから分離し、結果をイベントで戻す」ことのみを定めます。

## プロパティ・ベースのテスト/不変のテスト

可能な範囲で、状態機械のプロパティ・テストを導入します。

例:

`AddFavorite(AddFavorite(state))` を何回実行しても、`isFavorite == true` であること。

また、`RemoveFavorite(RemoveFavorite(state))` を何回実行しても、`isFavorite == false` であること。

## 受け入れ条件

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
状態の分類・復元は [`application_state.md`](./application_state.md) を正本とします。
本仕様の合格条件は、レデューサーが I/O を持たず、エフェクトが結果をイベントで戻し、コアがプラットフォーム API に依存しないこととします。
