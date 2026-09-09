# S2J Package Dashboard - ローカル・ストレージ/スナップショット仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、ローカル永続化および Historical スナップショットを定義します。キャッシュ方針は [`cache_spec.md`](./cache_spec.md) を正本とします。

iOS/iPadOS 実装、Android 実装、Kotlin Multiplatform (KMP) 移行、ストレージ・フレームワークの選定、クラウド同期導入等に応じて更新する。

## 目的

本ドキュメントでは、ローカル永続化、統計スナップショット、Migration、バックアップ/Restore およびデータ Lifecycle を定義する。永続化と Historical スナップショットの正本である。

## 非目的

本仕様は、クラウド Backend、クラウド同期 Protocol、SwiftUI/Compose UI、Chart Rendering を詳細に定義しない。

## 責務

端末内の永続化、スナップショットの保持/Migration/削除、オフライン時の永続データ参照、スキーマ Lifecycle を定義する。

## 非責務

キャッシュ方針は [`cache_spec.md`](./cache_spec.md)、型は [`models_spec.md`](./models_spec.md)、スナップショットの不変条件は [`domain_rules.md`](./domain_rules.md)、認証フローとクレデンシャル Format は [`authentication_spec.md`](./authentication_spec.md)、API エンドポイントは各 API 仕様を正本とする。集約の意味 (Sum / Last / Unique) は [`statistics_spec.md`](./statistics_spec.md) を正本とする。SwiftData / Room 等の実装差分は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md)、Restorable UI 状態は [`application_state.md`](./application_state.md)、共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。

## 基本方針

ローカル・ストレージについて、下記を基本原則とする。

1. 「ローカル」ファースト
2. API Response をそのまま永続化しない
3. ドメイン・モデルと Persistence モデルを分離する
4. キャッシュと Historical スナップショットを分離する。キャッシュ方針は [`cache_spec.md`](./cache_spec.md) を正本とする
5. クレデンシャル (資格情報) とアプリケーション・データを分離する
6. Historical スナップショットは原則として Immutable とする。不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする
7. ストレージ Failure でアプリケーション・データ全体を破壊しない
8. スキーマ Migration を明示的に管理する
9. オフライン Read を可能とする
10. クラウド・ストレージを必須依存にしない

## ドキュメント

ストレージ実装変更時には、下記を更新する。

* [`storage_spec.md`](./storage_spec.md)
* [`cache_spec.md`](./cache_spec.md)
* [`models_spec.md`](./models_spec.md)
* Migration 仕様
* テスト Fixture
* リリース Notes

## ストレージ・アーキテクチャー

層の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様は、ストレージ Abstraction をリポジトリの下に置き、アプリケーション・ロジックが具体的なストレージ・フレームワークに直接依存しないことだけを定める。

## ストレージ Categories

ローカル・ストレージでは下記を区別する。

* User データ (Favorite / 管理パッケージ)
* パッケージ・データ (パッケージ / リポジトリ・メタデータ)
* キャッシュ (再取得可能なカレント・データ。Lifetime は [`cache_spec.md`](./cache_spec.md))
* Historical スナップショット
* メタデータ (スキーマ・バージョン等)

クレデンシャル (資格情報) は別ストレージとする。

## クレデンシャル (資格情報) ストレージ

ローカル・データベースにクレデンシャルを保存しない。禁止対象と Secure Storage 必須は [`authentication_spec.md`](./authentication_spec.md) を正本とする。Keychain / Keystore の実装は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) とする。

## パッケージ・ストレージ

永続フィールドは `## PackageRecord` を正本とする。ドメイン型は [`models_spec.md`](./models_spec.md) を正本とする。

## 管理パッケージ

ユーザーがメンテナンス対象として扱うパッケージは、ローカル・ストレージに保持する。

* `maintained = true`

Packagist API から自動取得したパッケージ一覧と、ローカル User Preference を混同しない。

## Favorite パッケージ

Favorite パッケージは、ユーザーのローカル Preference として保持する。

* `favorite = true`

Favorite 状態そのものは Packagist/GitHub の Remote データではない。

## パッケージ ID

パッケージ ID はプロバイダ固有の URL ではなく、ドメイン上で安定した識別子を使用する。

Packagist パッケージの場合: `vendor/package` を Canonical パッケージ識別子として扱う。

## リポジトリ ID

GitHub リポジトリは、`owner/repository` を Canonical リポジトリ識別子として扱う。

リポジトリ URL を主キーとして直接使用しない。

## パッケージ/リポジトリ Relationship

パッケージと GitHub リポジトリは1対1とは限らない。1パッケージが複数リポジトリ参照を持ち得る。

## 永続対象とキャッシュの境界

再取得可能なカレント・データはキャッシュとして扱う。区別の意味は [`cache_spec.md`](./cache_spec.md) を正本とする。

本仕様の対象は、ユーザー所有の永続データおよび Historical スナップショットである。キャッシュを削除してもスナップショットは削除しない。

## スナップショット

統計スナップショットは、ある時点で取得した統計を記録する。型は [`models_spec.md`](./models_spec.md)、意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。永続フィールドは `## StatisticsSnapshotRecord` を正本とする。

## スナップショット Purpose

スナップショットの主目的:

* Historical Trend
* Growth 計算
* パッケージ Comparison
* Long-term 統計
* GitHub トラフィックの Retention 補完

## スナップショット書き込み規則

スナップショットの不変条件 (Immutability、Identity、Deduplication、欠測の扱い) は [`domain_rules.md`](./domain_rules.md) を正本とする。永続化では、確定済み行を UPDATE しない。同一 `(package, provider, capturedDay)` は挿入しない。

## スナップショット・タイムスタンプ

スナップショットには、`capturedAt` を保存する。

これは S2J Package Dashboard が統計を取得した時点を表す。

## タイムスタンプ Standard

Persistence では UTC を基本とする。

* `capturedAt = Instant/UTC`

ユーザー向け表示時のみ現地時間に変換する。

## Daily スナップショット

可視化の粒度は [`statistics_spec.md`](./statistics_spec.md) の `## スナップショット Granularity` を正本とする。本仕様は、永続化の基本単位を Daily 行とすることだけを定める。

## スナップショット Deduplication

Deduplication の規則は [`domain_rules.md`](./domain_rules.md) を正本とする。永続化では、同一日の後勝ちを Unique Constraint または同等の書き込み規則で実現する。

## Failed スナップショット

失敗時に偽の0値行を書かないことは [`domain_rules.md`](./domain_rules.md) を正本とする。永続化層は失敗した取得に対してスナップショット行を生成しない。

## Partial スナップショット

プロバイダ単位で部分的にスナップショットを保存可能とする。片方のプロバイダが Unavailable でも、取得できた側の行を残す。欠測側を0で埋めないことは [`domain_rules.md`](./domain_rules.md) を正本とする。

## 指標 Availability

可用性の値と Zero の区別は [`domain_rules.md`](./domain_rules.md) を正本とする。永続化では、指標ごとに可用性を保存できること。

## GitHub トラフィック・スナップショット

14日 Window を超える組み立て HOW は [`api-github.md`](./api-github.md) の「長期統計」を正本とする。本仕様は、取得できたトラフィックを Daily スナップショット行として永続することだけを定める。

## トラフィック過去データ

インストール前の履歴を推測しないことは [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、最初のスナップショット行より前の日付を Persistence に補完しないことだけを定める。

## スナップショット Retention

初期バージョンでは、スナップショットに固定的な短期 Retention を設定しない。

ユーザーが削除するまで、可能な範囲で過去データを保持する。

将来的にストレージ最適化が必要となった場合、Retention 方針を追加可能とする。

## ストレージ Quota

スナップショット増加によるストレージ消費を考慮する。

アプリケーションは必要に応じて、

* ストレージ Used
* スナップショット Count
* Oldest スナップショット

を確認可能とする。

## ストレージ最適化

長期運用でスナップショット数が増えた場合、Daily 行の Monthly 集約を検討する。ただし、Raw Daily データを削除する場合は、Loss of Precision を明示する。

## 集計スナップショット

集計データには、

* `aggregationType`
* `aggregationPeriod`

を保持可能とする。

例:

* `aggregationType` = monthly
* `aggregationPeriod` = 2026-08

## 集約ルール

指標ごとの集約意味 (Sum / Last / Unique を加算しない等) は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、集約結果を `aggregationType` / `aggregationPeriod` として永続することだけを定める。

## Raw vs Derived

Persistence では、`Raw 指標` と `Derived 指標` を区別する。

* Raw: source = Packagist/GitHub
* Derived: source = S2J Package Dashboard

## Derived 指標 Persistence

Derived 指標は、必要性がない限り永続化せず、Raw スナップショットから再計算可能とする。

ただし、

* 計算コストが高い
* 長期保存する必要がある
* 計算バージョンを固定する必要がある

場合は Persistence を許容する。

## 計算バージョン

Derived データを保存する場合、`calculationVersion` を保持する。

計算ルール変更時に、旧データとの互換性を維持する。

## スナップショット・スキーマ・バージョン

スナップショットには、`schemaVersion` を持たせる。

アプリケーション・バージョンとは分離する。

## Persistence モデル

ドメイン ≠ 永続は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、Persistence マッパー経由でローカル・データベースへ書き、スキーマ変更がドメイン型に直接影響しないことだけを定める。

## ストレージ リポジトリ

アプリケーションからはリポジトリ・インターフェースを利用する。

例:

* `PackageRepository`
* `StatisticsRepository`
* `SnapshotRepository`
* `CacheRepository`

## リポジトリ境界

* ドメイン層: `interface SnapshotRepository`
* Infrastructure 層: `SwiftDataSnapshotRepository`

または将来的に、`SQLDelightSnapshotRepository` を実装する。

## プラットフォーム Independence

ドメイン層は下記に直接依存しない。

* SwiftData
* Core Data
* SQLite API
* SQLDelight API
* Android Room
* Jetpack Compose
* SwiftUI

## Kotlin Multiplatform (KMP) Migration

共有対象と優先順位は [`architecture.md`](./architecture.md)、HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、ストレージ・インターフェースを移行時に再利用することだけを定める。

## Kotlin Multiplatform (KMP) -Compatible Persistence

KMP 移行後の候補として、SQLite/SQLDelight 等を利用可能とする。

SQLDelight は SQL スキーマから型安全な Kotlin API を生成でき、SQLite を Android/iOS/Multiplatform で利用できる。([Getting Started - SQLDelight](https://sqldelight.github.io/sqldelight/2.0.0/multiplatform_sqlite/))

ただし、初期 iOS 実装において特定の KMP Persistence フレームワークを必須としない。

## SwiftData

iOS/iPadOS の SwiftData 実装は [`ios_spec.md`](./ios_spec.md) を正本とする。本仕様は、初期 iOS で SwiftData を Persistence 実装として採用し得ること、ドメインが SwiftData に依存しないことだけを定める。

## SwiftData 境界

ドメイン・モデルに SwiftData の Persistence Annotation を直接持ち込まない。実装差分は [`ios_spec.md`](./ios_spec.md) を正本とする。

## データベース・スキーマ

Persistence スキーマは、下記の概念を持つ。

* `PackageRecord`
* `RepositoryRecord`
* `FavoriteRecord`
* `StatisticsSnapshotRecord`
* `MetricRecord`
* `CacheRecord`
* `StorageMetadata`

## PackageRecord

概念: `id` / `name` / `description` / `repositoryID` / `maintained` / `favorite` / `source` / `createdAt` / `updatedAt`。ドメイン型の正本は [`models_spec.md`](./models_spec.md) とする。本仕様は永続化行の列だけを定める。

## RepositoryRecord

概念: `id` / `provider` / `owner` / `name` / `url` / `archived` / `defaultBranch` / `updatedAt`。ドメイン型の正本は [`models_spec.md`](./models_spec.md) とする。

## StatisticsSnapshotRecord

概念: `id` / `packageID` / `source` / `capturedAt` / `schemaVersion` / `availability`。スナップショット不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。

## MetricRecord

概念: `id` / `snapshotID` / `name` / `value` / `unit` / `period` / `availability` / `derived`。指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。

## スナップショット ID

スナップショット ID は `packageID` + `source` + `calendarDay` を基本構成とする。同一指標を複数保存する必要がある場合は、指標 ID を追加する。

## 主キー

Persistence 内部の主キーには、ストレージ固有識別子を使用可能とする。

ドメイン ID とデータベース主キーを必ずしも一致させない。

## 外部キー

概念的には、PackageRecord 一つに対して StatisticsSnapshotRecord が複数、各スナップショット一つに対して MetricRecord が複数、とする。

パッケージ削除時のスナップショット処理については明示的な Delete 方針を使用する。

## パッケージ Deletion

ユーザーがパッケージをローカル・ダッシュボードから削除した場合、

* Favorite
* 管理
* Current キャッシュ

を削除する。Current キャッシュの削除方針は [`cache_spec.md`](./cache_spec.md) に従う。

Historical スナップショットについては、ユーザーの意図を確認せず自動削除しない。

## Remove from ダッシュボード

「ダッシュボードから削除」と「過去データを完全削除」を分離する。非表示にしても Historical スナップショットは保持し得る。

## Delete 過去データ

ユーザーが明示的に過去データの削除を要求した場合のみ、対象スナップショットを削除する。

## Delete All ローカル・データ

「すべてのローカル・データを削除」機能を提供する場合、

* パッケージ
* Favorite
* 管理
* キャッシュ
* スナップショット
* メタデータ

を削除する。

クレデンシャル (資格情報) については、クレデンシャル (資格情報) ストレージの方針に従う。

## クレデンシャル (資格情報) Separation

ローカル・データベースの全削除処理とクレデンシャル削除処理を分離する。クレデンシャル削除は別途明示する。方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。

## Migration

Persistence スキーマ変更時には、Migration を実施する。既存データを可能な限り保持する。

## Migration Principle

Migration は、

* Repeatable
* Testable
* Atomic
* Recoverable

であることを目指す。

## Migration Failure

Migration に失敗した場合、既存データを破壊した状態でアプリケーションを起動しない。Recovery / Rollback を検討する。

## Migration テスト

Migration テストでは、

* `v1 → v2`
* `v2 → v3`
* ...

を検証する。

代表的な Production データを Fixture として保持する。

## Backward Compatibility

新バージョンでは、旧バージョンの Persistence データを可能な限り読み込めるようにする。

## Forward Compatibility

旧アプリケーションが、新アプリケーションによって作成された Persistence スキーマを読み込めることは保証しない。

旧バージョンでのデータ使用が必要な場合は、Export/バックアップを利用する。

## Transaction

複数レコードを同時更新する場合、Transaction 境界を明示する。例: PackageRecord Update とスナップショット Insert を同一 Commit にする。途中状態をユーザーに成功データとして表示しない。

## Atomic スナップショット

スナップショット保存は、可能な限り SnapshotRecord と MetricRecords を同一 Commit にする。途中で失敗した場合、Incomplete スナップショットを残さない。

## Corrupted スナップショット

スナップショットが破損している場合、そのスナップショットだけを Unavailable として扱えるようにする。

データベース全体をエラーにしない。

## Integrity Check

必要に応じて `schemaVersion` / `metricCount` / `checksum` 等で Integrity を検証可能とする。初期バージョンでは Checksum を必須としない。

## バックアップ

ローカル・ストレージは、OS/デバイス・バックアップによってバックアップ可能な Persistence 方式を優先する。

iOS/iPadOS では、採用する Persistence フレームワークのバックアップ/Restore 挙動を実機で検証する。

## デバイス Migration

機種変更時は OS バックアップ / Migration によるローカル・データ Restore を基本とする。アプリケーション独自の Server Migration を必須にしない。

## バックアップ Integrity

バックアップ後に、

* パッケージ数
* Favorite 数
* 管理パッケージ数
* スナップショット数
* 最古スナップショット
* 最新スナップショット

等を検証可能とする。

## バックアップ vs クレデンシャル (資格情報)

バックアップ対象データとクレデンシャル (資格情報) を分離する。

クレデンシャル (資格情報) は、プラットフォーム Secure ストレージのバックアップ/Restore 方針に従う。

アプリケーション データベースにクレデンシャル (資格情報) をコピーしない。

## クラウド同期

クラウド同期は初期バージョンでは必須としない。

将来的に iCloud/CloudKit 等を利用する場合も、ローカル Persistence をソースとして設計可能とする。

SwiftData の ModelContainer は、CloudKit entitlement を設定した場合、永続化データの複数デバイス間同期を扱える。([ModelContainer | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/modelcontainer))

ただし、クラウド同期を採用するかどうかは別仕様として決定する。

## External Server

初期バージョンでは、統計スナップショット保存のためだけに外部 Server を導入しない。

理由:

* 運営費用
* Privacy
* セキュリティ
* Availability
* Server メンテナンス
* Authentication Infrastructure

## Cross-デバイス同期

複数端末間でのデータ共有は、初期バージョンでは必須機能としない。iPhone / iPad / Android はそれぞれローカル・ストレージを正とする。

## Future Cross-デバイス同期

将来導入する場合の同期対象は Favorite / 管理 / パッケージ・メタデータ / スナップショットから選択する。クレデンシャルは原則として同期対象外とする。

## Conflict Resolution

Cross-デバイス同期を将来導入する場合、Conflict Resolution を定義する。

例:

* Favorite
* デバイス A = true
* デバイス B = false

等について、

* Last Writer Wins
* タイムスタンプ
* User Resolution

等の方針を採用する。

初期バージョンでは不要。

## ストレージ Encryption

機密データを含む Persistence については、プラットフォームが提供するデータ Protection/Encryption を優先利用する。

クレデンシャル (資格情報) はデータベースに保存せず、Secure ストレージを利用する。

## スナップショット Sensitivity

統計スナップショットには、原則としてクレデンシャル (資格情報) を含めない。

また、不要な個人情報を保存しない。

## API Response ストレージ

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、API Response 全文をデータベースに保存せず、必要なフィールドだけを Persistence することだけを定める。

## Unknown API フィールド

プロバイダ API に未知フィールドが追加されても、アプリケーション Persistence スキーマを自動的に拡張しない。

必要なフィールドのみ明示的にマッピングする。

## API バージョン

Persistence スキーマ・バージョンとプロバイダ API バージョンを混同しない。

`storageSchemaVersion` と、`providerAPIVersion` は別管理する。

## スナップショット Invalidation

キャッシュ Invalidation ではスナップショットを削除しない。キャッシュの Invalidation は [`cache_spec.md`](./cache_spec.md) を正本とする。

* キャッシュ → Invalidate possible
* スナップショット → Historical レコード

## Refresh Failure

Refresh に失敗しても、既存のスナップショットを削除しない。キャッシュを残すかどうかは [`cache_spec.md`](./cache_spec.md) に従う。

## オフライン Startup

オフライン状態でアプリケーションを起動した場合、永続化した User データおよび Historical スナップショットを優先して利用する。カレント・データの Stale 表示は [`cache_spec.md`](./cache_spec.md) に従う。

API unavailable を理由にダッシュボード全体を表示不能にしない。

## Empty 状態

Empty の見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、初回起動等でローカル・データがないことを正常状態 (`No ローカル・データ`) として扱うことだけを定める。

## First Launch

First Launch ではローカル・ストレージが Empty であることを前提とする。パッケージ・データを Hard-code して Persistence に初期投入しない。

## ストレージ Reset

Debug/Development 環境では、ローカル・ストレージ Reset を可能とする。

Production では、ユーザーが誤操作しにくい UI とする。

## Debug データ

Debug 用データは、Production Persistence に混入させない。

## テスト・ストレージ

Unit テストでは、可能な限りインメモリ・ストレージを利用する。

Production データベースをテストから直接操作しない。

SwiftData はインメモリ等のストレージ Configuration を設定可能であるため、テスト用 Persistence を分離できる。([ModelContainer | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/modelcontainer))

## リポジトリ・テスト

リポジトリ・テストでは、

* Create
* Read
* Update
* Delete

に加えて、

* スナップショット Insert
* スナップショット・クエリー
* スナップショット Deduplication
* Migration

を検証する。

## スナップショット・テスト

最低限、下記をテストする。

* Create スナップショット
* Read スナップショット
* Duplicate スナップショット
* Missing スナップショット
* Partial スナップショット
* Invalid スナップショット
* Historical クエリー

## ストレージ Failure テスト

下記を Simulation する。

* ディスク Full
* データベース・エラー
* Migration Failure
* Corrupted レコード
* Transaction Failure
* Permission Failure

## ディスク Full

ストレージ容量不足時にも、既存過去データを可能な限り保持する。新規スナップショット保存に失敗しても、既存 History を破棄しない。

## Concurrent Access

複数 Task から同時に Persistence にアクセスする場合、ストレージ・フレームワークが提供する Concurrency モデルに従う。

ドメイン層からデータベース・スレッド Safety を直接制御しない。

## Background Access

Background Refresh からローカル・ストレージにアクセスする場合も、Foreground UI との競合を避ける。

## Write 方針

統計取得時の順序は Fetch → Validate → Map → Persist → Update UI を基本とする。Invalid データを先に Persistence に保存しない。

## Validation

Persistence 前に最低限、

* パッケージ識別子
* 指標 Name
* Numeric Value
* タイムスタンプ
* ソース
* Unit
* Availability

を検証する。

## Numeric Validation

統計 Value について、

* NaN
* Infinity
* negative count

等を保存しない。

## タイムスタンプ Validation

スナップショット・タイムスタンプについて、明らかに未来のタイムスタンプ等を無条件に過去データとして保存しない。

プロバイダ固有のタイムスタンプ Definition を考慮する。

## ストレージ・メタデータ

ストレージ全体について、`schemaVersion` / `createdAt` / `lastMigrationAt` / `lastIntegrityCheckAt` 等を保持可能とする。

## アプリケーション・バージョン

アプリケーション・バージョンはストレージ・メタデータに必要に応じて記録する。

ただし、`applicationVersion` と `schemaVersion` を同一視しない。

## ストレージ Diagnostics

Debug 画面等では、データベース・サイズ、パッケージ数、スナップショット数、キャッシュ数、Oldest/Newest スナップショットを確認可能とする。Production UI への公開は別途検討する。

## Export

将来的にローカル・データ Export を提供する場合、対象 (パッケージ / Favorites / スナップショット / メタデータ) を明示する。クレデンシャルは Export しない。

## Import

Import 時の順序は Validate → スキーマ Migration → Conflict Resolution → Transaction → Commit とする。

## Import Failure

Import 途中で失敗した場合、部分的なデータを Production ストレージに残さない。

## JSON Export

JSON Export を提供する場合、ドメイン Export スキーマを定義する。

Internal Persistence スキーマをそのまま Export Format として公開しない。

## CSV Export

統計について CSV Export を提供する場合、

* `package`
* `source`
* `metric`
* `date`
* `value`
* `unit`

等を基本 Column とする。

## データ Portability

ユーザーが蓄積した Historical 統計を、アプリケーション・バージョンやプラットフォーム変更によって失わないことを目指す。

## プラットフォーム Migration

「iOS → iPadOS」等の同一プラットフォーム間 Migration では、OS/デバイス Migration による Persistence 移行を基本とする。

## プラットフォーム横断型 Migration

「iOS → Android」では、OS バックアップだけに依存しない。将来的に Export → Portable Format → Import による Migration を可能とする。

## Portable スナップショット Format

永続フィールドは `## StatisticsSnapshotRecord` を正本とする。本仕様は、Logical スキーマをプラットフォーム固有データベース・スキーマから独立させることだけを定める。

## Kotlin Multiplatform (KMP) Migration Strategy

共有に移す順序は [`architecture.md`](./architecture.md) を正本とする。本仕様は、ドメイン・モデル / リポジトリ / Persistence を段階的に移行可能な構造とすることだけを定める。

## ストレージ・アダプタ

KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、`SnapshotRepository` を iOS / Android アダプタ経由で実装し、将来共有 SQL へ移行可能とすることだけを定める。

## No UI Dependency

ストレージ層は、

* SwiftUI
* Jetpack Compose

に依存しない。

## No ネットワーク Dependency

層境界は [`architecture.md`](./architecture.md) を正本とする。本仕様は、ストレージ層が Packagist / GitHub API Client に直接依存しないことだけを定める。

## ソース・メタデータ

Persistence された統計には、必ずソースを保持する。

例:

* source = Packagist
* source = GitHub
* source = derived

## プロバイダ・データ Retention

プロバイダ側の Retention と S2J 側の Retention を混同しない。プロバイダ Window の意味は [`api-github.md`](./api-github.md) / [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、S2J の保持期限をプロバイダ Retention と同一視しないことだけを定める。

## Historical Truth

S2J スナップショットは、「S2J Package Dashboard がその時点で取得したプロバイダ・データ」を記録する。

プロバイダ側の Historical データベースそのものではない。

## スナップショット Provenance

永続フィールドは `## StatisticsSnapshotRecord` を正本とする。本仕様は、必要に応じて `source` / `capturedAt` / `providerAPI` / `schemaVersion` で Provenance を追跡可能とすることだけを定める。

## Current データ Refresh

Current データの Refresh では、スナップショットを必ず作成する必要はない。カレント・データの更新は [`cache_spec.md`](./cache_spec.md) に従う。

Historical スナップショットを作成するのは、スナップショット方針に該当する場合とする。

## スナップショット Schedule

初期バージョンでは、スナップショット取得を Daily 単位とする。

将来的に Background Task 等を利用して、自動取得を可能とする。

## Background スナップショット方針

Background スナップショットを導入する場合、`Maximum: 1スナップショット/パッケージ/Day` を基本とする。

過剰な API Request を避ける。

## Manual スナップショット

Debug/Advanced User 向けに Manual スナップショットを許可する場合も、Daily Deduplication 方針を維持する。

## ストレージ Lifecycle

キャッシュ Lifetime は [`cache_spec.md`](./cache_spec.md)、Daily 行は `## Daily スナップショット`、削除は `## Remove from ダッシュボード` / `## Delete All ローカル・データ` を正本とする。本仕様は、API 取得成功後にカレント → (必要なら) Daily スナップショット → 任意の集約へ進み、User Deletion で終わることだけを定める。

## データ Deletion Lifecycle

ダッシュボードからの非表示は `## Remove from ダッシュボード`、明示的な完全削除は `## Delete All ローカル・データ` を正本とする。本仕様は、Removal でキャッシュを消しスナップショットは保持し得ること、完全削除ではパッケージ / キャッシュ / スナップショット / メタデータを対象とすることだけを再掲する。

## Privacy Deletion

ユーザーがローカル・データ削除を要求した場合、対象データを復元不能な形で削除する。

OS バックアップ等に存在するデータについては、プラットフォームのバックアップ方針に従う。

## セキュリティ境界

クレデンシャルの分離は [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、公開統計をローカル・データベースに置き、クレデンシャルをスナップショットに混在させないことだけを定める。

## Logging

Token / クレデンシャルをログに出さないことは [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、統計値の Diagnostic を必要最小限にすることだけを定める。

## Crash Recovery

アプリケーション Crash 中にストレージ Write が発生した場合も、可能な限り Atomic Commit を利用する。

再起動後に Incomplete Transaction をアプリケーションが通常データとして扱わない。

## Corruption Recovery

データベース Corruption が検出された場合、Detect → recoverable データの保全 → Restore/Rebuild を検討する。キャッシュは再構築可能とし、Historical スナップショットの保全を優先する。キャッシュの Rebuild は [`cache_spec.md`](./cache_spec.md) を正本とする。

## Rebuild Strategy

ローカル・データベース全体を再構築する場合、Portable / Exported データを Validation した後で Rebuild を利用可能とする。

## パフォーマンス

ストレージ・クエリーは、UI スレッド/Main スレッドを不必要に Block しない。

大量スナップショットを取得する場合は、Pagination/Date Range Filtering 等を利用する。

## スナップショット・クエリー

Historical Chart では、必要な期間だけスナップショットを取得する。選択できる Period は [`screen_spec.md`](./screen_spec.md)、期間の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。全 History を毎回メモリにロードしない。

## Index

下記の検索条件について、必要に応じて Index を設ける。

* `packageID`
* `capturedAt`
* `source`
* `metricName`

特に、`packageID + capturedAt` を Historical クエリーの主要 Index 候補とする。

## ストレージ Size Monitoring

スナップショット数が増加した場合、ストレージ使用量を監視可能とする。

必要に応じてユーザーに、「ストレージ usage is growing」等を通知可能とする。

## Initial バージョン・ストレージ方針

基本方針は `## 基本方針` を正本とする。v1固有の制約は、Persistence / キャッシュ / スナップショットを Local に限り、External Server とクラウド同期を必須としないこととする。

## Initial iOS 実装

iOS/iPadOS の Persistence 実装は [`ios_spec.md`](./ios_spec.md) を正本とする。本仕様は、ドメイン / リポジトリ・インターフェース / ユースケースを SwiftData に依存させないことだけを定める。

## Android 実装

Android の Persistence 実装は [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、iOS と独立して実装を選べること、共有ドメインからプラットフォーム・ストレージへ依存することだけを定める。

## Kotlin Multiplatform (KMP) -Compatible アーキテクチャー

境界は [`architecture.md`](./architecture.md) を正本とする。共有 Persistence 候補は `## Kotlin Multiplatform (KMP) -Compatible Persistence` を正本とする。本仕様は、ドメイン / リポジトリ・インターフェースをプラットフォーム・ストレージから独立させることだけを定める。

## ストレージ Abstraction Example

概念:

```text
interface SnapshotRepository {
    suspend fun save( snapshot: StatisticsSnapshot )
    suspend fun find( packageID: PackageID, from: Instant, to: Instant ): List<StatisticsSnapshot>
    suspend fun delete( packageID: PackageID )
}
```

具体的な API 定義は実装時に決定する。

## ドメイン/ Persistence マッピング

ドメイン ≠ 永続は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、`SnapshotPersistenceMapper` 等で `StatisticsSnapshot` と `StatisticsSnapshotRecord` を双方向に写すことだけを定める。

## ストレージ・エラー

ドメイン・エラー / `ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、SQLite / CoreData / SwiftData 等の例外を `StorageError` に写像し、ドメインへそのまま漏出させないことだけを定める。アプリケーション層へ出す場合は `PersistenceFailed` とする。

## エラー Categories

`StorageError` は少なくとも下記を区別する。

* `ReadFailure`
* `WriteFailure`
* `MigrationFailure`
* `Corruption`
* `QuotaExceeded`
* `Unknown`

## Retry

ストレージ Write Failure について、Blind Retry を行わない。

Transaction Failure 等、Retry 可能性が明確な場合のみ再試行する。

## Consistency

アプリケーション起動後は、

* パッケージ
* Favorite
* 管理
* スナップショット
* キャッシュ

の Referential Integrity を可能な限り維持する。

## Orphan レコード

Orphan スナップショット等を定期的に検出可能とする。

例: `Snapshot.packageID` に対応するパッケージがない場合、Recover / Keep / Delete を方針に従って処理する。

## Historical Orphan

パッケージ・レコードが削除されても、Historical スナップショットを保持する場合がある。

そのため、「PackageRecord」と「Historical スナップショット」を必ず Cascade Delete しない。

## Orphan Display

パッケージ・レコードが存在しないスナップショットは、通常のダッシュボードには表示しない。

Debug/Recovery 用途では存在を確認可能とする。

## ストレージ Consistency Check

必要に応じて、

* パッケージ Count
* スナップショット Count
* Orphan Count
* Invalid 指標 Count

を検査する。

## Repair

Consistency Check で問題を検出した場合、自動修復は慎重に行う。

過去データを推測によって修正しない。

## データ Loss Principle

ストレージ Repair では、「不明なデータを推測して修復するより、壊れているデータとして保持する」ことを優先する。

## User-visible ストレージ Status

通常ユーザーには、ストレージ内部実装を意識させない。

ただし下記の場合は通知可能とする。

* Migration Required
* ストレージ・エラー
* ストレージ Almost Full
* データ Recovery Required

## テスト Fixtures

Migration テスト 用に、各スキーマ・バージョンの Fixture を保持する。

```text
fixtures/
├── storage-v1/
├── storage-v2/
└── storage-v3/
```

## バージョニング

ストレージ・スキーマ・バージョンは、アプリケーション・リリース・バージョンとは独立して Semantic に管理する。

例:

* アプリケーション: 1.4.0
* ストレージ・スキーマ: 3

## Migration ドキュメント

Migration が必要になった場合、「ストレージ・スキーマ: `3 → 4`」について、

* Changed
* Added
* Removed
* Migration ルール
* Compatibility
* テスト Result

を記録する。

## Initial ストレージ・スキーマ

Logical スキーマは `## データベース・スキーマ` を正本とする。
