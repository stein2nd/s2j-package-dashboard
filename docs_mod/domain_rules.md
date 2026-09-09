# S2J Package Dashboard - ドメイン・ルール仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、ドメイン・ルールを定義します。

ドメイン・モデル、統計仕様、API 仕様、ストレージ仕様、Kotlin Multiplatform (KMP) 移行方針等の変更に応じて更新する。

## 目的

本ドキュメントでは、S2J Package Dashboard におけるドメイン・ルール、ドメイン Invariant、Business ルールおよびドメイン上の状態遷移を定義する。

本仕様は、UI/Persistence/API/プラットフォームから独立したドメイン層の仕様である。

## 非目的

本仕様は、HTTP、OAuth、Keychain、永続化スキーマ、UI Layout、Chart Rendering、色/タイポグラフィ/アニメーションを定義しない。

## 責務

ドメイン上の正しさ (何が妥当か、何を混同してはいけないか、どの遷移が許されるか) を正本として定義する。

## 非責務

型と層境界は [`models_spec.md`](./models_spec.md)、指標の意味と収集は [`statistics_spec.md`](./statistics_spec.md)、スナップショットの永続化は [`storage_spec.md`](./storage_spec.md)、キャッシュ方針は [`cache_spec.md`](./cache_spec.md)、表示文言は [`ui.md`](./ui.md)、層と共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md)、検証の種類は [`testing_spec.md`](./testing_spec.md)、API の実装は各専門仕様を正本とする。

## ドメインの目的

S2J Package Dashboard は、「Packagist および GitHub 上の Package/リポジトリに関する統計を取得・整理・蓄積し、ユーザーが管理対象および Favorite Package の状態を継続的に把握できるようにする」ことを目的とする。

## ドメイン 境界

本アプリケーションのドメインは、

* Package
* リポジトリ
* 統計
* スナップショット
* Favorite
* Maintained

を中心とする。

## ドメインに含まれないもの

下記はドメイン・ルールそのものではない。

* SwiftUI View
* Jetpack Compose UI
* SwiftData モデル
* SQLite スキーマ
* Packagist HTTP Client
* GitHub HTTP Client
* Keychain
* Android Keystore
* Network Connection
* プラットフォーム固有 UI
* Animation
* Rendering

これらはドメイン外の責務とする。

## Ubiquitous 言語

本アプリケーションでは、下記の用語を統一して使用する。

| 用語 | 定義 |
| --- | --- |
| Package | Packagist 上で識別される Composer Package |
| リポジトリ | Package の Source リポジトリ |
| Maintained Package | ユーザー自身が Maintenance 対象として扱う Package |
| Favorite Package | ユーザー が Favorite として登録した Package |
| カレント・データ | プロバイダから取得した現在値 |
| スナップショット | 特定時点で取得した統計の記録 |
| 指標 | 統計を構成する個々の指標 |
| プロバイダ | Packagist/GitHub 等の Data Source |
| Availability | 指標を取得可能かどうかを示す状態 |
| Stale | 最新の取得期限を超えた Data |
| Derived 指標 | Raw 指標から計算された指標 |

## ドメイン・ルールの原則

ドメイン・ルールは下記を満たす。

1. プラットフォームに依存しない
2. UI に依存しない
3. Persistence に依存しない
4. API エンドポイントに依存しない
5. クレデンシャル (資格情報) に依存しない
6. Deterministic である
7. テスト可能である
8. ドメイン Object 自身が守るべきルールはドメイン Object 内で保証する

## ドメイン Invariant

ドメイン Invariant とは、「ドメイン上、常に成立していなければならない条件」とする。

Invariant を破ったドメイン Object を正常なドメイン状態として扱わない。

## Invalid 状態

下記のような状態をドメイン上の Valid 状態としない。

* Package ID = empty
* 指標 Value = NaN
* 指標 Value = Infinity
* スナップショット・タイムスタンプ = invalid
* Unknown 指標 Unit
* Invalid Package Identifier

## Package Identity

Package は一意なドメイン Identity を持つ。

Canonical Identifier: `vendor/package` を基本とする。

## Package Identifier ルール

Package Identifier は、`vendor/package` 形式を基本とする。

下記を許可しない。

* `vendor/`
* `package`
* `/vendor/package`
* `https://packagist.org/packages/vendor/package`

ただし API アダプタが External Representation をドメイン Identifier に変換することは可能とする。

## Package Identity Immutability

Package Identity は、Package の Lifetime 中に変更しない。

Package Rename 等がプロバイダ側で発生した場合は、別ドメイン・イベント/Migration ルールとして扱う。

## リポジトリ Identity

GitHub リポジトリは、`owner/repository` を Canonical Identifier とする。

## リポジトリ・プロバイダ

リポジトリにはプロバイダを持たせる。

例: `github`

将来的なプロバイダ追加を妨げない。

## Package/リポジトリ Relationship

Package とリポジトリの関係は、必ずしも1対1とは限らない。ドメイン・モデルでは Package がリポジトリ・リファレンスを持つ。

## Package does not equal リポジトリ

Packagist Package と GitHub リポジトリを同一 Identity として扱わない。同じ名前を持つ場合でも、それぞれ独立したドメイン Object とする。

## Maintained Package

Maintained Package とは、「ユーザーが自身の Maintenance 対象として Dashboard で管理する Package」と定義する。

## Maintained Package Source

Maintained 状態は、プロバイダから取得した統計ではない。

User Preference/User 状態として扱う。

## Maintained Package ルール

Package は、`maintained = true` または `maintained = false` のいずれかである。

## Favorite Package

Favorite Package とは、「ユーザーが自分の Dashboard で継続的に観測したい Package」と定義する。

## Favorite ルール

Package は、`favorite = true` または `favorite = false` のいずれかである。

## Maintained and Favorite

Maintained と Favorite は独立した属性とする。

下記をすべて許可する。

* `Maintained = true`、`Favorite   = true`
* `Maintained = true`、`Favorite   = false`
* `Maintained = false`、`Favorite   = true`
* `Maintained = false`、`Favorite   = false`

## Automatic Maintained Package Discovery

Packagist Account からユーザーが Maintenance する Package を取得できる場合、その結果を Maintained Package 候補として扱う。

## Discovery Result

プロバイダから取得した Package が、`Maintained` であることと、`Dashboardに表示する` ことを同一視しない。

Discovery と Presentation は別責務とする。

## Favorite Registration

Favorite 追加時には、対象 Package がドメイン上有効な Package であることを確認する。

## Duplicate Package

同一 Package Identity について、複数の Package Record を作成しない。

`vendor/package` は Dashboard 内で一意とする。

## Duplicate Favorite

すでに Favorite である Package を再度 Favorite にしても、Duplicate 状態を作成しない。

Operation は Idempotent とする。

## Favorite Removal

Favorite を解除しても、Package 自体を削除する必要はない。Favorite は `false` になる。

## Maintained Removal

Maintained 状態が解除された場合も、Package 自体を自動削除しない。

## Package Removal

「Dashboard から Package を削除する」ことと、「Historical スナップショットを削除する」ことを分離する。

## Historical Data Preservation

Package を Dashboard から削除しても、Historical スナップショットを自動削除しないことを基本とする。

## Explicit Historical Deletion

Historical スナップショットを削除する場合は、ユーザーによる明示的な削除操作を必要とする。

## プロバイダ

プロバイダは外部 Data Source を表す。

初期バージョン:

* Packagist
* GitHub

## プロバイダ Independence

層境界は [`architecture.md`](./architecture.md)、API 実装は各 API 仕様を正本とする。本仕様は、ドメイン・モデルが API URL / HTTP Method / Authentication Header を知らないことだけを定める。

## プロバイダ Data

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、プロバイダ Data をドメイン・マッパー経由でドメイン Object にしてから扱うことだけを定める。

## カレント・データ

カレント・データとは、「プロバイダから比較的新しい時点で取得された統計の現在値」とする。

## カレント・データ is not スナップショット

カレント・データと Historical スナップショットを同一概念として扱わない。

* カレント・データ: 現在状態
* スナップショット: 過去時点の記録

## スナップショット

スナップショットは、「S2J Package Dashboard が特定時点に取得した統計の記録」とする。Immutability、Identity、Deduplication、欠測および Zero の扱いは本仕様を正本とする。永続化は [`storage_spec.md`](./storage_spec.md)、収集の意味は [`statistics_spec.md`](./statistics_spec.md) とする。

## スナップショット Immutability

確定済みスナップショットは、原則 Immutable とする。

過去スナップショットを、現在のプロバイダ Data によって上書きしない。

## スナップショット Identity

スナップショットは少なくとも Package + プロバイダ + `Captured At` によって識別可能とする。永続キーの構成は [`storage_spec.md`](./storage_spec.md) の `## スナップショット ID` を正本とする。

## Daily スナップショット

初期バージョンでは、同一 Package/プロバイダについて1日1スナップショットを基本とする。

## スナップショット Deduplication

同一日について複数回取得した場合、Duplicate Historical スナップショットを無制限に生成しない。

## スナップショット・タイムスタンプ

スナップショットには、`capturedAt` を必ず持つ。

## タイムスタンプのセマンティクス

`capturedAt` は、「S2J Package Dashboard がその統計を取得した時点」を表す。

プロバイダ側の Data Generation Time と同一とは限らない。

## UTC

ドメイン上のタイムスタンプは UTC/Instant として扱う。

表示時の Timezone 変換は UI/Presentation 層の責務とする。

## Future タイムスタンプ

明らかに不正な Future タイムスタンプを正常な Historical スナップショットとして扱わない。

## 指標

指標は統計を構成する最小の意味単位とする。

例:

* `downloads`
* `favers`
* `stars`
* `forks`
* `views`
* `clones`

## 指標 Identity

指標には、`metricName` またはドメイン上で同等の Identity を持たせる。

## 指標 Value

指標 Value は、指標の定義に応じた型を使用する。

Count 指標では、原則として非負の整数とする。

## Negative Count

下記をドメイン上の Valid 状態としない。

* Downloads = -1
* Stars = -10
* Forks = -1

## Zero Value

`0` は有効な指標 Value になり得る。

`Downloads = 0` と、`Downloads = unavailable` を区別する。

## Availability

指標には Data Availability を表現可能とする。

基本状態:

* `Available`
* `Unavailable`
* `NotFetched`
* `NotAuthorized`
* `NotSupported`
* `Stale`

## Unavailable と0は等しくない

`Unavailable` と値 `0` を明確に区別する。

## NotAuthorized

Authentication/Permission 不足の場合、`NotAuthorized` とする。

`0` に変換しない。

## NotSupported

プロバイダが指標自体を提供していない場合、`NotSupported` とする。

## Stale

取得時点が一定の Freshness 方針を超えた場合、指標/Data を Stale として扱える。

## Stale is not Invalid

Stale Data は、`Invalid` ではない。

ただし、`Fresh` とも扱わない。

## Source

指標には Source を明示可能とする。

例:

* Packagist
* GitHub
* Derived

## Raw 指標

プロバイダから直接取得した指標を Raw 指標とする。

`source = Packagist` または `source = GitHub` 等。

## Derived 指標

Raw 指標から計算した指標を Derived 指標とする。

例:

* Growth Rate
* Change
* Moving Average

## Derived 指標ルール

Derived 指標は、Raw 指標から再計算可能な場合、Raw 指標を「信頼できる情報源 (SoT)」とする。

## Derived 指標バージョン

Derived 指標の計算方法がバージョンによって変わる場合、`calculationVersion` を区別する。

## 統計 Comparison

統計の比較は、同じ指標 Definition 同士で行う。

`Downloads ↔ Downloads` は比較可能。

`Downloads ↔ Stars` は直接比較しない。

## Unit

指標には Unit を定義する。

例:

* `count`
* `percentage`
* `ratio`
* `bytes`
* `duration`

## Unit Compatibility

異なる Unit の指標を、同一指標として扱わない。

## Period

指標が期間に依存する場合、Period を明示する。

例:

* `daily`
* `monthly`
* `total`

## Period Compatibility

異なる Period を、無条件に比較しない。例: Daily Downloads と Monthly Downloads は同一指標ではない。

## Total vs Periodic

Total 指標と Periodic 指標を別指標のセマンティクスとして扱う。

## Downloads

Packagist Downloads については、プロバイダが定義する Period のセマンティクスを尊重する。

S2J 側で Total/Monthly/Daily 等を勝手に同一指標として扱わない。

## Favers

Favers は Packagist 由来の指標として扱う。

プロバイダから取得できない場合は、Unavailable/NotSupported 等の適切な状態を使用する。

## GitHub Stars

GitHub Stars は、GitHub リポジトリの状態を表す指標とする。

## GitHub Forks

GitHub Forks は、GitHub リポジトリの状態を表す指標とする。

## GitHub Traffic

GitHub Traffic は、GitHub 側の Retention 制限を持つ Data として扱う。

S2J スナップショットによって長期 History を形成できる。

## Traffic スナップショット・ルール

GitHub Traffic を取得した場合、スナップショット方針に従って Historical Data を保存可能とする。

## Historical Truth

Historical スナップショットは、「S2J Package Dashboard がその時点で取得した Data」を記録する。

プロバイダの完全な Historical Database を表すものではない。

## No Historical Guessing

取得できなかった過去 Data を、現在 Data から推測して生成しない。

## Missing スナップショット

ある日スナップショットを取得できなかった場合、

* `2026-08-20`
* `2026-08-21`
* `2026-08-23`

のような Gap を許容する。

## Missing Data `!=` Zero

スナップショットが存在しないことを、`Metric = 0` として扱わない。

## スナップショット Gap

欠測を実値として補間しない。Chart 上の Gap 表現は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## Interpolation

ドメイン上で Historical Data を自動 Interpolation しない。

## API Failure

API Failure は、ドメイン Data そのものの Value ではない。`0` との区別は `## Unavailable と0は等しくない` を正本とする。

## Partial プロバイダ Failure

Packagist 取得成功、GitHub 取得失敗のような状態を許容する。

* Packagist: Available
* GitHub: Unavailable

## Partial Data

Partial Data を理由に、成功したプロバイダの Data まで破棄しない。

## Refresh

Refresh は、「カレント・データを再取得する操作」とする。

Refresh そのものは、Historical スナップショット生成を必ず意味しない。

## スナップショット Collection

スナップショット Collection は、Refresh とは独立した方針として扱う。

## Idempotency

下記の Operation は、可能な限り Idempotent とする。

* Add Favorite
* Remove Favorite
* Set Maintained
* Unset Maintained
* Refresh

## Favorite Command

`favorite(package)` は、すでに Favorite の場合でもドメイン状態を壊さない。

## Unfavorite Command

`unfavorite(package)` は、Favorite でない場合でも正常に完了可能とする。

## Maintained Command

`markMaintained(package)` は、すでに Maintained の場合でも Duplicate 状態を作成しない。

## Unmaintain Command

`unmarkMaintained(package)` は、すでに Maintained でない場合でも正常に完了可能とする。

## Package Registration

Package を Dashboard に登録する場合、Package Identity の Uniqueness を保証する。

## Package Discovery

プロバイダ Discovery 結果は、ドメイン Package を自動的に Duplicate 作成しない。

## Package Merge

同一 Package Identity が複数 Source から取得された場合、ドメイン上では同一 Package として扱う。

## プロバイダ Metadata

プロバイダ固有 Metadata は、Core Package Identity とは分離する。

## リポジトリ Association

Package と リポジトリの Association は、プロバイダ Data によって更新可能とする。

ただし、Package Identity そのものを変更してはならない。

## リポジトリ状態

リポジトリには、必要に応じて下記の状態を持たせる。

* Active
* Archived
* Unavailable
* Unknown

## Archived リポジトリ

Archived リポジトリは、統計 Data を必ずしも削除しない。

## リポジトリ Unavailable

リポジトリが取得不能になっても、過去スナップショットを削除しない。

## Package Availability

Package についても、

* Available
* Unavailable
* Unknown

等の状態を必要に応じて表現可能とする。

## プロバイダ Failure and Package 状態

一時的な API Failure だけで、`Package = Deleted` 等の不可逆状態を変更しない。

## Deletion Confirmation

プロバイダから Package が取得できなくなった場合、それだけを理由に Local Package を削除しない。

## External 状態 vs Local 状態

プロバイダ状態と User Preference を明確に分離する。たとえば、`GitHub リポジトリ Archived` と `User Favorite` は独立した状態である。

## Account

Packagist Account/GitHub Account は、ドメイン Package そのものとは異なる概念とする。

## クレデンシャル (資格情報)

クレデンシャルをドメインに載せないことは [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、Password / Token / Secret をドメイン・エンティティの属性としないことだけを定める。

## Account Identity

Account Identity は、Authentication 層からドメインに必要最小限の情報だけを渡す。

## Authorization

Authorization 状態は、ドメイン Data の指標 Value に変換しない。

## Permission

Permission 不足によって取得できない指標は、`NotAuthorized` として表現可能とする。

## ドメイン・エラー

ドメイン・エラーは、プラットフォーム・エラー/HTTP エラーと分離する。

例:

* `InvalidPackageIdentifier`
* `DuplicatePackage`
* `InvalidMetric`
* `InvalidSnapshot`
* `InvalidStateTransition`

## API エラー Mapping

境界の分類は [`architecture.md`](./architecture.md)、`ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、HTTP Status Code そのものをドメイン・ルールにしないことだけを定める。

## ドメイン Service

複数 ドメイン Object を横断し、単一エンティティに自然に所属させられないドメイン Operation にはドメイン Service を利用可能とする。

## ドメイン Service Example

例:

* StatisticsComparisonService
* TrendCalculationService
* PackageIdentityResolver

## ドメイン Service Restrictions

ドメイン Service は、UI/Database/HTTP Client を直接操作しない。

## リポジトリ

リポジトリは、ドメイン Object の Collection として扱う。

ドメイン層からは Interface のみを参照する。

## リポジトリ Independence

リポジトリ Interface は、下記を知らない。

* SwiftData
* SQLite
* SQLDelight
* Room
* Core Data

## Aggregate

Aggregate は、ドメイン Invariant を守る必要がある範囲で定義する。

Relationship があるという理由だけで同一 Aggregate にまとめない。

## Package Aggregate

初期バージョンでは、Package を主要 Aggregate Root 候補とする。

Package が、

* Package Identity
* Maintained 状態
* Favorite 状態

等の整合性を保持する。

## スナップショット Aggregate

統計スナップショットは、Package とは別の Aggregate として扱うことを許容する。

理由:

* Historical Data が大量になる
* Append-oriented である
* Package 状態と独立して保存できる
* スナップショットの Immutable 性を保ちやすい

## スナップショット境界

スナップショット内部では、指標の集合として整合性を保証する。

## スナップショット Atomicity

永続の Atomic Commit は [`storage_spec.md`](./storage_spec.md) を正本とする。本仕様は、スナップショット Metadata と指標が一貫した状態で確定することだけを定める。

## Cross-Aggregate Consistency

Package とスナップショットの間に存在するすべての関係を単一 Transaction で常に同期させることをドメイン・ルールとはしない。

## Eventual Consistency

プロバイダ Metadata 等の外部情報については、Eventual Consistency を許容する。

## No Global Transaction

Packagist 取得、GitHub 取得、Package 更新、スナップショット確定を単一ドメイン Transaction として必須化しない。

## 信頼できる情報源 (SoT)

Package Identity はドメイン Package、User Preference は Local User 状態、Current 統計はプロバイダ、Historical 統計は S2J スナップショットを「信頼できる情報源 (SoT)」とする。詳細は直後の各節を正本とする。

## プロバイダ as 信頼できる情報源 (SoT)

Current Packagist/GitHub 統計については、各プロバイダを「信頼できる情報源 (SoT)」とする。

## スナップショット as Historical Record

Historical スナップショットは、プロバイダの Current 状態を上書きするものではない。

## User Preference as Local Truth

Favorite/Maintained は、プロバイダの Data ではなく User Preference として扱う。

## 統計 Freshness

Freshness は指標の Validity とは別概念とする。

* Fresh
* Stale

は、

* Valid
* Invalid

とは異なる。

## 計算ルール

Growth Rate 等の Derived 指標は、定義された Formula に従う。

## Growth

基本: `Growth Rate = (Current - Previous) / Previous × 100`

ただし Previous = 0の場合は通常の Percentage 計算を適用しない。

## Division by Zero

`Previous = 0` の場合、`Growth Rate` を単純に Infinity として扱わない。

`Undefined`/`NotAvailable` 等のドメイン状態を利用する。

## 指標 Comparison Period

比較対象 Period が存在しない場合、Growth 指標を生成しない。

## Trend

Trend は、

* Increasing
* Decreasing
* Stable
* InsufficientData

等のドメイン状態として表現可能とする。

## Trend Minimum Data

Trend 判定には、最低限必要なスナップショット数を定義する。

初期バージョンでは、少なくとも2つの比較可能な Data Point を必要とする。

## No Data Guessing

スナップショットが1つしか存在しない場合、Trend を推測しない。

## Stable

Stable 判定には、明示的な Threshold を使用する。

Threshold 未定義の場合、Stable と断定しない。

## Health

Package Health 等の Composite Indicator を導入する場合、判定ルールを明示する。指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、Downloads Trend / Release 履歴 / Issue 状態等を合成する場合にルールを持つことだけを定める。

## Health is Derived

Health はプロバイダから直接取得した指標ではなく、S2J が計算する Derived ドメイン Concept とする。

## Health Threshold

Threshold は UI に Hard-code しない。

ドメイン Configuration として管理する。

## Configuration

ドメイン・ルールに必要な Configuration:

* スナップショット Interval
* Trend Threshold
* Health Threshold
* Freshness 方針

等は、ドメイン Configuration として扱う。

## Configuration Immutability

Runtime Configuration を変更した場合でも、過去スナップショットそのものを変更しない。

## Historical 計算

過去統計の再計算が必要な場合、計算バージョンを明示する。

## Data Provenance

Derived Data は、可能な限り Source 指標とプロバイダを追跡可能とする。

## ドメイン Clock

現在時刻を直接 Global API から取得しない。

必要に応じてドメイン Clock を抽象化する。

`Clock.now()` 等の形を想定する。

## Deterministic テスト

ドメイン・ルールは、固定 Clock/Fixed タイムスタンプを利用して Deterministic テスト可能とする。

## Locale Independence

ドメイン・ルールは、User Locale に依存しない。

たとえば、`1,234` という表示形式は UI の責務であり、ドメイン Value は数値として保持する。

## Timezone Independence

ドメイン・ルールは、Display Timezone に依存しない。

## Currency

統計に Currency が必要になった場合も、Display Formatting とドメイン Value を分離する。

## String Formatting

Package Name/指標 Value 等の表示用 Formatting は Presentation 層の責務とする。

## ドメイン・モデル Immutability

Value Object/スナップショット等、変更する必要のないドメイン Object は可能な限り Immutable とする。

## Value Object

下記は Value Object 候補とする。

* `PackageID`
* `RepositoryID`
* `MetricName`
* `MetricUnit`
* `MetricPeriod`
* `ProviderID`

## エンティティ

Identity と Lifecycle を持つものはエンティティ候補とする。

* Package
* リポジトリ

## Aggregate Root

Aggregate Root は、外部から直接、内部状態を変更できないようにする。

## Illegal 状態 Prevention

可能な限り、「Illegal 状態を生成できないモデル」を目指す。

たとえば、`Downloads = -1` のような状態をドメイン Constructor/Factory で拒否する。

## Factory

Complex ドメイン Object 生成には、Factory を利用可能とする。

## Validation Timing

ドメイン Validation は、ドメイン Object 生成時および状態 Change 時に行う。

## DTO Validation

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、API スキーマ Validation とドメイン Validation を分離することだけを定める。

## External Data Trust

プロバイダから取得した Data であっても、ドメイン Validation を省略しない。

## Unknown 指標

未知指標を受信した場合、Core ドメインを破壊しない。

下記のいずれかを採用可能とする。

* Ignore
* Store as Extension Data
* Mark Unsupported

## Forward Compatibility

プロバイダ API に新指標が追加されても、既存ドメイン・モデルが Invalid にならない。

## Backward Compatibility

ドメイン ・スキーマ変更時には、既存スナップショットを可能な限り解釈可能とする。

## ドメイン バージョン

ドメイン・モデル変更時には、必要に応じてドメイン・スキーマ・バージョンを更新する。

## ドメイン・イベント

将来的に必要となった場合、ドメイン・イベントを利用可能とする。

候補:

* PackageAdded
* PackageFavorited
* PackageUnfavorited
* PackageMaintained
* PackageUnmaintained
* SnapshotCaptured
* SnapshotDeleted

## イベントのセマンティクス

ドメイン・イベントは、「ドメイン上で意味のある状態変化が発生した」ことを表す。

UI イベントと同一視しない。

## イベント Immutability

発生済みドメイン・イベントは Immutable とする。

## イベント Payload

イベント Payload には、必要最小限のドメイン情報のみを含める。

クレデンシャル (資格情報) を含めない。

## External Integration

ドメイン・イベントを将来的に外部同期/Analytics 等に利用可能とする。

ただし初期バージョンでは External イベント Bus を必須としない。

## API Independence

ドメイン・ルールをプロバイダ API の現在仕様に過度に固定しない。

## Packagist Independence

Packagist 固有の仕様は、Packagist アダプタ/プロバイダ・モデルに閉じ込める。

## GitHub Independence

GitHub 固有の仕様は、GitHub アダプタ/プロバイダ・モデルに閉じ込める。

## Multi-プロバイダ

将来的にプロバイダを追加しても、Core ドメイン・ルールを大きく変更しない。

## プロバイダ Capability

プロバイダごとの指標対応差は、`Capability` として表現可能とする。

## Capability Example

扱う指標は [`statistics_spec.md`](./statistics_spec.md) の `## Packagist 指標` / `## GitHub 指標` を正本とする。本仕様は、プロバイダ差を `Capability` として表現することだけを定める。

## Capability ルール

指標がプロバイダ Capability に存在しない場合、`NotSupported` として扱う。

## プロバイダ Authentication

Authentication の有無は、指標の Meaning を変更しない。

## Authorization-dependent 指標

Authorization が必要な指標について、未認証状態を Zero に変換しない。

## Public vs Authorized Data

Public Data と Authorized Data をドメイン上で必要に応じて区別する。

## セキュリティ境界

Token をドメインに載せないことは [`security_spec.md`](./security_spec.md) / [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、ドメイン・モデルに Password / API Token / Secret を渡さないことだけを定める。

## No クレデンシャル (資格情報) Persistence

ドメイン Object はクレデンシャル (資格情報) を永続化しない。

## オフライン・ルール

オフラインであること自体は、ドメイン Object の Invalid 状態ではない。

## オフライン・カレント・データ

オフライン時には、Last Known Data を利用可能とする。

その Data が Stale である場合は Stale 状態を保持する。

## オフライン・スナップショット

オフライン時に新しいスナップショットを作成してはならない。

プロバイダ Data を取得していないためである。

## スナップショット Authenticity

スナップショットは、実際に取得したプロバイダ Data にもとづく場合のみ生成する。

## No Synthetic スナップショット

オフライン時に Previous Value から New スナップショットを合成して、通常の Historical スナップショットとして保存しない。

## Refresh タイムスタンプ

Refresh 開始時刻とスナップショット Capture 時刻を混同しない。

## Successful Fetch

スナップショットを作成するには、対象指標の取得が成功している必要がある。

Partial プロバイダ Data については、Partial スナップショットルールを適用する。

## Partial スナップショット

一部指標のみ取得成功した場合、指標単位の Availability を保持可能とする。

## スナップショット Completeness

スナップショットには必要に応じて、

* Complete
* Partial

を表現可能とする。

## Complete スナップショット

プロバイダから必要な対象指標がすべて取得できた場合を Complete とする。

## Partial スナップショット

Complete / Partial の表現は `## スナップショット Completeness` を正本とする。本節は、一部指標が取得できなかった場合を Partial とすることだけを定める。Missing 指標を Zero に変換しないことは `## Unavailable と0は等しくない` を正本とする。

## スナップショット Comparison

スナップショット同士を比較する場合、比較可能な指標だけを比較する。

## Missing 指標 Comparison

片方にしか存在しない指標について、Growth を計算しない。

## Historical Delete

Historical スナップショット削除は、ドメイン上の不可逆操作として扱う。

## スナップショット Restore

バックアップ/Import からスナップショットを復元する場合もドメイン Validation を行う。

## Imported Data

External Import Data を無条件に Trusted ドメイン状態として扱わない。

## Import Validation

Import の処理順は [`storage_spec.md`](./storage_spec.md) の `## Import` を正本とする。本仕様は、スキーマ Validation のあとにドメイン Validation と Duplicate Resolution を行い、無条件に Trusted としないことだけを定める。

## Duplicate スナップショット Import

既存スナップショットと Identity が一致する場合、Duplicate スナップショットを作成しない。

## Conflict Resolution

Import/Sync で Conflict が発生した場合、ドメイン・ルールとして勝手に Last Writer Wins を適用しない。

Conflict 方針を別途定義する。

## Cross-デバイス同期

Cross-デバイス同期は初期バージョンではドメイン Requirement としない。

将来的に導入する場合、Favorite/Maintained/スナップショット等の Conflict ルールを別途定義する。

## プラットフォーム Independence

ドメイン・ルールは、

* iOS
* iPadOS
* Android

のいずれでも同一のセマンティクスを持つ。

## Kotlin Multiplatform (KMP) Compatibility

KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、ドメイン層が共有 Code に移行可能な構造であることだけを定める。

## Kotlin Multiplatform (KMP) Migration 境界

共有対象と優先順位は [`architecture.md`](./architecture.md) を正本とする。本仕様は、ドメイン・ルールを共有ロジック側に置くことだけを定める。

## Swift Implementation

初期実装の言語は [`architecture.md`](./architecture.md) を正本とする。本仕様は、ドメイン・ルールが SwiftUI / SwiftData / iOS 固有 API に依存しないことだけを定める。

## Kotlin Migration

共有に移す順序は [`architecture.md`](./architecture.md) を正本とする。本仕様は、Invariant を移植対象の中心とすることだけを定める。

## UI Independence

ドメイン・ルールは、SwiftUI/Compose の Rendering ロジックに直接埋め込まない。

## Persistence Independence

ドメイン・ルールは、SwiftData/SQLite/SQLDelight/Room 等の Persistence Technology に依存しない。

## API Independence

ドメイン・ルールは、HTTP Client や API Response DTO に依存しない。

## ドメイン・テスト

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、ドメイン・ルールを UI テストではなく Unit テストで検証することだけを定める。

## Invariant テスト

検証項目は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、Package ID / 指標 / スナップショット / Favorite / Maintained の不変条件をテスト可能であることだけを定める。

## 統計テスト

指標の意味は [`statistics_spec.md`](./statistics_spec.md)、検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、Growth / Trend / Zero / Missing / Partial / Stale のドメイン判定をテスト可能であることだけを定める。

## Property-based テスト

可能なドメイン・ルールについて、将来的に Property-based Testing を導入可能とする。

## Determinism

同一インプットに対して、同一ドメイン・ルールは同一 Result を返す。

現在時刻等の External 状態は抽象化する。

## ドメイン・ルール Priority

ルールが競合した場合、下記を優先する。

1. ドメイン Invariant
2. Data Integrity
3. User インテント
4. プロバイダ Data
5. Presentation Convenience

## プロバイダ Data Does Not Override User 状態

プロバイダから取得した Data によって、Favorite/Maintained を勝手に変更しない。

## UI Does Not Override ドメイン・ルール

UI からの操作であっても、ドメイン・ルールを無視した状態 Change を許可しない。

## ストレージ Does Not Define ドメイン・ルール

Database スキーマによって、ドメインのセマンティクスを決定しない。

## API Does Not Define ドメイン・モデル

プロバイダ API Response をそのままドメイン・モデルとして扱わない。

## ドメイン as Source of Semantic Truth

アプリケーション内部の意味については、`ドメイン・モデル + ドメイン・ルール` を意味的な「信頼できる情報源 (SoT)」とする。

## ドメイン・ルール Change

ドメイン・ルールを変更する場合、

* 変更理由
* 旧ルール
* 新ルール
* 影響するモデル
* 影響する統計
* Migration Requirement
* テスト

を記録する。

## Backward Compatibility of ルール

過去スナップショットの意味を変えてしまうドメイン・ルール変更には注意する。

## Historical のセマンティクス

過去スナップショットを再解釈する場合、旧計算バージョン/スキーマ・バージョンを参照可能とする。

## ルール Versioning

将来的にルール・バージョンが必要となった場合、`domainRuleVersion` を利用可能とする。

## No Silent Semantic Change

ドメイン・ルール変更によって Historical Data の意味が変わる場合、Silent Migration を行わない。

## ドメイン Documentation

ドメイン・ルール変更時には、関連する専門仕様を確認する。ファイル名簿は [`specs.md`](./specs.md) を正本とする。
