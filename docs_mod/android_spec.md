# S2J Package Dashboard - Android ストレージ仕様

**Status:** Draft

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、Android 実装における Storage Architecture を定義します。

本仕様では Android 固有の Storage Implementation を定義する。

本仕様の対象は下記とする。

* Local Persistent Storage
* キャッシュ Storage
* Statistics スナップショット Storage
* User Preference Storage
* Credential Storage
* Storage Migration
* Data Deletion
* バックアップ/ Restore
* Android Lifecycle における Storage
* 将来の KMP Shared Storage への移行可能性

実装時に下記を確定する。

* Room スキーマ
* Entity/DAO
* Migration Strategy
* DataStore Type
* DataStore スキーマ/Keys
* Credential Encryption Strategy
* Keystore Key Alias
* バックアップ Rules
* スナップショット Retention Policy

KMP Shared Persistence、Cloud 同期、External 同期 Service は、必要性が明確になった時点で別途仕様化する。

本仕様は Android のストレージ実装差分に限定する。方針の正本は下記とする。

* 永続化 / スナップショット: [`storage_spec.md`](./storage_spec.md)
* スナップショットの不変条件: [`domain_rules.md`](./domain_rules.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* 認証 / クレデンシャル: [`authentication_spec.md`](./authentication_spec.md)

ドメイン・モデル、アプリケーション Logic、リポジトリ Interface 等の Platform-independent な仕様は、それぞれ下記を Source of Truth とする。

* [`models_spec.md`](./models_spec.md)
* [`domain_rules.md`](./domain_rules.md)
* [`architecture.md`](./architecture.md)
* [`kmp_spec.md`](./kmp_spec.md)

## 目的

本仕様は、Android におけるストレージ実装差分を定義する。Room、DataStore、Keystore など、プラットフォーム固有の保存方法を対象とする。

## 非目的

本仕様では下記を初期実装の必須要件としない。

* Cloud-based 同期
* External 同期 Server
* Cross-platform Credential Migration
* 独自暗号アルゴリズム
* External Storage
* Background Statistics Collection の保証
* KMP Shared Persistence
* Android-specific UI Storage Logic

## 責務

Android の Persistent Storage、キャッシュ Storage、スナップショット Storage、Preference、Credential の実装差分を定義する。

## 非責務

方針の正本は下記とする。

* 永続化 / スナップショット: [`storage_spec.md`](./storage_spec.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* 認証 / クレデンシャル: [`authentication_spec.md`](./authentication_spec.md)
* 復元対象: [`application_state.md`](./application_state.md)
* 検証の種類: [`testing_spec.md`](./testing_spec.md)
* ドメイン型 / ルール / アーキ: [`models_spec.md`](./models_spec.md) / [`domain_rules.md`](./domain_rules.md) / [`architecture.md`](./architecture.md)

## 基本方針

Android Storage は下記の原則に従う。層の分離、Credential 分離、キャッシュと Persistent の区別、スナップショットの不変条件は [`architecture.md`](./architecture.md) / [`authentication_spec.md`](./authentication_spec.md) / [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) / [`domain_rules.md`](./domain_rules.md) を正本とする。本節は、その原則を Room / DataStore / Keystore に載せることを定める。

1. UI が Storage API を直接利用しない
2. リポジトリを Storage Boundary とする
3. Room を構造化された Persistent Storage の第一候補とする
4. DataStore を User Preferences / 小規模設定の第一候補とする
5. Android Keystore を暗号鍵の保護に利用する
6. Credentials を平文で保存しない
7. Android 固有 API を Domain Layer に侵入させない
8. 将来の KMP Shared Logic / Shared Storage への移行を妨げない

Android の公式 Storage ガイドでも、構造化されたアプリケーションデータには Room、private な key-value 設定には DataStore 等を利用する構成が推奨されている。([データ ストレージとファイル ストレージの概要 | App data and files | Android Developers](https://developer.android.com/training/data-storage?authuser=108))

## Storage Architecture

基本的な依存関係は [`architecture.md`](./architecture.md) を正本とする。本節は、Android Storage Layer が Room / DataStore / キャッシュ / Keystore であり、UI がこれらを直接呼び出してはならないことだけを定める。

## Storage Categories

Android では Storage を下記に分類する。

| Category | Purpose | Storage |
| --- | --- | --- |
| Persistent Data | Package / Favorite 等 | Room |
| スナップショット | Statistics History | Room |
| Preferences | User Settings | DataStore |
| キャッシュ | 一時的 API Response | App キャッシュ / HTTP キャッシュ |
| Credentials | API Token 等 | Keystore + encrypted storage |
| Temporary Data | 一時ファイル | キャッシュ / Temporary Storage |

各 Category は用途を明確に分離する。

## Room

### 1. 基本方針

Package、Favorite、Statistics スナップショット等の構造化されたデータには Room を利用する。

Room は SQLite の上に abstraction layer を提供し、SQL Query の compile-time verification、boilerplate の削減、migration パスを提供する。Android 公式も SQLite API を直接利用するより Room の利用を推奨している。([Room を使用してローカル データベースにデータを保存する | App data and files | Android Developers](https://developer.android.com/training/data-storage/room?hl=ja))

## Room Architecture

Room は リポジトリ → DAO → Room Database → SQLite とする。アプリケーション Layer は Room Database や DAO に直接依存しない。経路は アプリケーション → リポジトリ Interface → Room リポジトリ → DAO とする。

## ドメイン・モデルと Room Entity

Room Entity をドメイン・モデルとして扱わない。ドメイン・モデルを Room Entity に mapping して SQLite へ書く。

たとえば:

```kotlin
data class Package(
    val id: PackageIdentifier,
    val name: String,
    val description: String?
)
```

Persistence 側:

```kotlin
@Entity
data class PackageEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String?
)
```

実際の Entity 定義は [`models_spec.md`](./models_spec.md) に従って決定する。

## リポジトリ Boundary

アプリケーション Layer から見えるのはリポジトリ Interface とする。

```kotlin
interface PackageRepository {
    suspend fun find(
        id: PackageIdentifier
    ): Package?

    suspend fun save(
        package: Package
    )

    suspend fun delete(
        id: PackageIdentifier
    )
}
```

Android ではこれを Room リポジトリが実装する。`RoomPackageRepository` implements `PackageRepository` → DAO → Room。

## DAO

DAO は Persistence Layer 内部の API とする。

```kotlin
@Dao
interface PackageDao {
    // Query definitions
}
```

DAO を ViewModel や Composable に直接公開しない。

DAO の Query は Persistence Model を返し、リポジトリがドメイン・モデルに変換する構成を基本とする。

## Package Storage

Package の Local Representation は、Packagist API Response の単純なコピーとして保存しない。フィールドは [`models_spec.md`](./models_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、API DTO をドメイン・モデル / Room Entity に変換してから保存することだけを定める。

## Favorite Storage

Favorite の不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。本節は Room 上で Package と別 Entity にすることだけを定める。

## Maintained Package Storage

Maintained と Favorite の意味の区別は [`domain_rules.md`](./domain_rules.md) を正本とする。本節は、「Room 上で両方を同時に持つことが可能」だけを定める。

## Statistics スナップショット Storage

Statistics の長期履歴は Room にスナップショットとして保存する。行の形は [`storage_spec.md`](./storage_spec.md)、指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本節は、Package に対して複数のスナップショット行を Room に置くことだけを定める。

## Room スナップショット書き込み

スナップショットの不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。本節は、新しい観測を新しい Room 行として保存することだけを定める。

## DataStore

DataStore は User Preferences および小規模なアプリケーション Configuration に利用する。

対象例:

* Selected Statistics Period
* Refresh Preference
* Appearance Preference
* First Launch Flag
* Sort Order
* Display Preference
* Last Selected Package Identifier

Android 公式では DataStore は小規模なデータの保存に適しており、より大きく複雑なデータ、部分更新、参照整合性が必要な場合は Room を利用することが推奨されている。([アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## DataStore と Room の境界

下記を原則とする。Small / Configuration は DataStore、Structured / Relational は Room。たとえば Statistics Period は DataStore、Favorite Packages / Package Metadata / Statistics スナップショットは Room。User Preferences を Room に保存することを基本としない。逆に、Package/スナップショット等を DataStore に JSON Blob として保存することも基本としない。

## DataStore Type

DataStore は用途に応じて下記を選択する。

### Preferences DataStore

単純な Key-Value が適している設定に使用する。

### Proto DataStore

型付きでスキーマ-driven な設定が必要になった場合に使用する。

初期実装では Preferences DataStore を第一候補とし、設定の複雑化に応じて Proto DataStore を検討する。

DataStore は immutable な型を扱うことが推奨され、`updateData` による atomic read-modify-write を提供する。([アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## DataStore Instance

同一 DataStore File に対して複数の DataStore Instance を生成しない。

DataStore の公式ドキュメントでも、同一プロセス内で同じファイルに複数の DataStore を作成すると `IllegalStateException` になるため、単一の DataStore Instance を共有する構成が求められている。([アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

基本構成: アプリケーション → Singleton DataStore → PreferencesRepository。

## DataStore Access

Composable が DataStore を直接利用してはならない。Composable → ViewModel → PreferencesRepository → DataStore。

DataStore の `Flow` はリポジトリから公開し、ViewModel が UI 状態に変換する。

Android 公式も Compose から DataStore を直接利用せず、リポジトリ→ ViewModel → Compose という Data Layer を推奨している。([アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## キャッシュ

キャッシュとスナップショットの区別、Lifetime / Freshness は [`cache_spec.md`](./cache_spec.md) を正本とする。本節は Android のキャッシュ実装差分のみを定義する。

## HTTP キャッシュ

HTTP Response のキャッシュには、必要に応じて HTTP Client のキャッシュ機構を利用する。

ただし、HTTP キャッシュをアプリケーション Data の永続化手段として扱わない。HTTP キャッシュは Optimization、Room はアプリケーション Data。区別は [`cache_spec.md`](./cache_spec.md) を正本とする。

## キャッシュ Entity とスナップショット Entity

区別の意味は [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とする。Android では、最新 API 応答と Historical スナップショットを同一 Entity に保存しない。

## Credential Storage

認証方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本節は Android Keystore / セキュア保存の実装差分を定義する。

何を保存するかは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本節は、平文で Persistent Storage に保存してはならないことだけを定める。

## Android Keystore

Android Keystore を暗号鍵の保護に利用する。

Android Keystore はアプリケーションが使用する暗号鍵を長期的に安全に保持するためのしくみであり、鍵素材へのアクセスを制限できる。Android の Security Guide でも、繰り返し利用する鍵は KeyStore 等のしくみで保管することが推奨されている。([セキュリティ ガイドライン | Security | Android Developers](https://developer.android.com/privacy-and-security/security-tips))

基本構成: Credential は Encrypted Storage に置き、暗号鍵は Android Keystore が保護する。

## Credential Encryption

Credential 本体は、Keystore に保存した暗号鍵を利用して暗号化し、その状態での保存を基本とする。Plain Token → Encryption → Encrypted Token → Internal Storage。暗号鍵: `Android Keystore` という分離を基本とする。

## Credential Storage Location

Credential の暗号化されたデータは App-private Internal Storage 等に保存する。

Android の Internal Storage はアプリケーションごとに sandbox 化され、他アプリケーションから直接アクセスできない。Android v10以降では内部ストレージも暗号化されている。([アプリ固有のファイルにアクセスする | App data and files | Android Developers](https://developer.android.com/training/data-storage/app-specific))

External Storage に Credential を保存してはならない。

## Credential リポジトリ

アプリケーション Layer は Keystore / encrypted storage の API を直接利用しない。Authentication Service → `CredentialStore` → `AndroidCredentialStore` → Android Keystore / Encrypted Storage。

## Credential Lifecycle

Lifecycle の意味 (未設定 / 設定済 / 認証済 / 失効) は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本節は Encrypted Storage / Keystore 上の追加・更新・削除に対応づける。ユーザーが Disconnect / Remove した場合は暗号化 Credential を削除する。

## Credential とアプリケーション Data の分離

Credential の削除はアプリケーション Data の削除を意味しない。Encrypted Credential を消しても Package / Favorites / スナップショットは残す。アプリケーション Data の削除は別操作とする。

## Security Boundary

Room に置いてはならないものは [`authentication_spec.md`](./authentication_spec.md) の禁止リストを正本とする。本節は、Room / DataStore / ログへ書かないことの実装確認である。

また、下記にも保存してはならない。

* Log
* Analytics
* URL Query
* Crash Report
* スナップショット
* Error Message

## Cryptography

独自暗号アルゴリズムを実装しない。

暗号化が必要な場合は Android Platform / Jetpack / Google が提供する既存の暗号 API を利用する。

Android の Security Guide でも、独自の暗号プロトコルや暗号アルゴリズムを実装せず、既存の暗号実装を利用することが推奨されている。([セキュリティ ガイドライン | Security | Android Developers](https://developer.android.com/privacy-and-security/security-tips))

暗号化方式の具体値は、採用ライブラリの公式の推奨設定を優先する。

## Data Protection

アプリケーション-private data は原則として Internal Storage に保存する。

Android 公式でも、他アプリケーションからアクセスさせる必要のない private data には Internal Storage が推奨されている。([アプリのセキュリティを強化する | Security | Android Developers](https://developer.android.com/privacy-and-security/security-best-practices))

External Storage を使用する場合は、共有を意図したデータに限定する。

## バックアップ/Restore

Android では Auto バックアップ/Device-to-Device Transfer の対象になるデータと、対象外にすべきデータを明確に区別する。

たとえば: バックアップ Allowed は Non-sensitive Preferences / User アプリケーション Data。バックアップ Excluded は Encryption Key / Sensitive Credential / Temporary キャッシュ。バックアップのプライバシーは [`security_spec.md`](./security_spec.md) を正本とする。本節は Android Auto バックアップの対象/除外を区別することだけを定める。

DataStore のファイルはデフォルトで Auto バックアップ/Device-to-Device Transfer の対象になり得るため、Sensitive Data を保存する DataStore と一般設定用 DataStore を分離し、必要に応じてバックアップ Rules を設定する。([アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## Credential バックアップ

Credential を Android バックアップ/Device-to-Device Transfer にそのまま含めることを前提としない。

端末移行後は必要に応じて再認証する。Old Device の Credential を New Device へ自動移送せず、New Device では Re-authentication とする。

Cross-platform Credential Migration も実装しない。

## iOS/iPadOS との バックアップ方針の違い

iOS/iPadOS と Android の Storage/バックアップ Mechanism は同一ではない。

したがって、iOS バックアップ ≠ Android バックアップとする。各 HOW は [`ios_spec.md`](./ios_spec.md) / 本仕様を正本とする。

とする。

KMP Shared Logic は両 Platform に共通化するが、バックアップ/ Restore は Platform-specific concern として扱う。

## Offline Behavior

Local Persistent Data が存在する場合、Network が利用できなくても可能な範囲で下記を提供する。

* Package List
* Favorite List
* Package Detail
* Last known statistics
* Historical スナップショット Chart
* Settings

最新情報を取得できない場合は、

```text
Offline
Last Updated: ...
```

を明示する。

## Storage Freshness

Persistent Data には可能な限り取得時刻を保存する。

例:

`lastFetchedAt`

* スナップショット: `collectedAt`
* キャッシュ: `cachedAt`、`expiresAt`

## Storage Source

Provider 由来の Data は Source を識別可能な形で保持する。

例:

* `source = Packagist`
* `source = GitHub`

同じ Metric 名でも Provider によって意味が異なる可能性があるため、Provider 情報を省略しない。

## Storage Consistency

アプリケーション状態と Persistence 状態の整合性を維持する。

たとえば Favorite 追加: User Action → Validate → Persist Favorite → Update アプリケーション状態。Persistence が失敗した場合、成功したように UI を更新してはならない。

## Transaction Boundary

複数の Persistence Operation が一つの Domain Operation を構成する場合、可能な限り Transaction / Atomic Operation として扱う。

たとえば Add Favorite は Create Favorite と Update Package Reference を一つの Atomic Operation とする。Room の Transaction API 等を利用する場合でも、Transaction の具体 API を Domain Layer に漏らさない。アトミック性の意味は [`domain_rules.md`](./domain_rules.md) を正本とする。

## Concurrency

Storage Access は Kotlin Coroutines を利用し、UI Thread を Block しない。

基本構造: Compose → ViewModel → ユースケース → リポジトリ → Room / DataStore。層の依存方向は [`architecture.md`](./architecture.md) を正本とする。本節は、Storage Operation を `Main` Dispatcher に固定しないことだけを定める。

Storage Operation を `Main` Dispatcher に固定しない。

DataStore は Coroutines / Flow を前提とした非同期 Storage である。([アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## Flow / StateFlow

Persistent Settings や Observable Data は Flow を利用して変更を伝播できる構造とする。Room / DataStore → Flow → リポジトリ → ViewModel → StateFlow → Compose。Compose は Storage Layer に直接接続しない。

## Storage Migration

Room スキーマ Version を管理する。Room スキーマ v1→ v2→ v3。行の互換は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は Room のスキーマ Version を独立管理することだけを定める。

Migration はアプリケーション Version と独立して管理可能な構造とする。

## Migration Rules

Migration では下記を保証する。

* Package Data を可能な限り保持する
* Favorite を失わない
* スナップショット History を失わない
* Credential を Migration Data に含めない
* Migration Failure を検知できる
* Migration 後のスキーマ Version を正しく更新する

## Migration Failure

Migration に失敗した場合、既存データを無条件に削除してはならない。Migration Failure → Preserve Existing Data → Error / Recovery。

Migration の destructive fallback は明示的な仕様なしに実装しない。

## DataStore Corruption

DataStore のファイル破損を想定する。

必要に応じて DataStore の Corruption Handler を利用し、recoverable な設定については初期値に復旧できる構造とする。

DataStore は Corruption Handler を提供しており、破損したファイルを定義済みの Default Value に置き換える構成が可能である。([アプリ アーキテクチャ: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

ただし、ユーザーが明示的に保存した重要なアプリケーション Data を DataStore に入れない。

## Storage Deletion

Settings から下記を個別に削除可能とする。削除対象の意味は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、キャッシュ / Statistics スナップショット / Local Package Data / Favorites / Credentials を Android Settings から個別削除でき、Credential とアプリケーション Data の削除を暗黙に結合しないことだけを定める。

## キャッシュ Deletion

キャッシュは再取得可能であるため、削除してもアプリケーション状態を失わない。Lifetime は [`cache_spec.md`](./cache_spec.md) を正本とする。本節は、Delete キャッシュ → Empty → Next Request で Provider から Fetch することだけを定める。

## スナップショット Deletion

スナップショットは Historical Data として扱う。削除方針は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、削除後の Chart が Remaining Data のみを出し、Provider から過去スナップショットを復元できるとは限らないことだけを定める。

## Storage Reset

完全な Local Data Reset を提供する場合、Room Data / キャッシュ / スナップショット / Preferences を対象とする。Reset の意味は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、Storage Reset ≠ Credential Reset であることだけを定める。

## App Lifecycle

Storage は下記の Lifecycle 変更に耐えられること。

* Launch
* Foreground
* Background
* Stop
* Process Death
* Relaunch

Android では Process Death を前提とし、一時的な UI 状態を Persistent Storage に保存することと、アプリケーション Data を保存することを区別する。

## Background Execution

Background Execution を Statistics Collection の保証手段としない。

Android でも Background Execution は実行時刻や実行時間を無条件に保証するものではない。

したがって、「App must remain open」を長期にわたる統計収集の必須条件としない。

長期的な自動スナップショット Collection が必要になった場合は、

* WorkManager
* External Scheduler
* Backend

等を別途検討する。

## Temporary Files

Temporary File はアプリケーション・キャッシュ/ Temporary Directory に保存する。

Temporary File を Persistent Data として扱わない。

必要なくなった Temporary File は削除する。

## External Storage

External / Shared Storage は初期実装では使用しない。

理由:

1. Package Dashboard の基本データはアプリケーション専用である
2. Package Data を他アプリケーションと共有する必要がない
3. Credential を共有 Storage に置く必要がない
4. Android Storage Permission の複雑化を避けられる

ユーザーが Export / Import を要求する場合のみ、Android の標準的な Document / Share UI を利用する。

## Export / Import

将来的に Statistics / Package Data の Export を実装する場合は、アプリケーション-private Storage と Export File を明確に分離する。Internal Storage → Export → User-selected File。Export File に Credentials を含めない。

## Performance

下記を避ける。

* Compose Render 毎の Database Query
* スナップショット全件の無条件読み込み
* 不要な Full Table Scan
* Main Thread 上での重い Migration
* Main Thread 上での大量 Data Transformation
* DataStore の頻繁な同期 Read

Statistics Chart では必要な期間/Metric のみ Query する。

## Query Strategy

Room Query は用途に応じて必要な Data のみ取得する。

たとえば Dashboard は Summary Query、Statistics は Period-specific スナップショット Query。全 Package/全スナップショットを一度に Memory に読み込まない。

## Retention Policy

スナップショット Retention は [`storage_spec.md`](./storage_spec.md)、長期傾向の目的は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、Android 実装が独自に削除期限を決めないことだけを定める。

## Security Logging

Storage Error の診断情報を Log に出力する場合でも、Secret を含めない。禁止対象は [`security_spec.md`](./security_spec.md) を正本とする。
* Credential
* 完全な API Request
* 個人情報

## Testing

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、Room / DataStore / Keystore の HOW を In-memory Store で検証できることだけを定める。

## In-memory Storage

Unit Test / UI Test / Preview では In-memory Database を利用できる構造とする。

* Production: Room Persistent Database
* Test: Room In-memory Database

Domain Test は Room に依存しない。

## Storage Failure Handling

Android-specific Storage Error はアプリケーション Error に変換する。層の分類は [`architecture.md`](./architecture.md)、`ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とする。本節は、Room / DataStore Error → PersistenceError → アプリケーション Error → UI Error 状態とし、具体 Exception を UI に直接公開しないことだけを定める。

## KMP Boundary

Android Storage は KMP Shared Logic の実装詳細として扱う。配置は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本節は、commonMain に Domain / アプリケーション / リポジトリ Interface / Statistics Logic を置き、androidMain に Room / DataStore / Keystore を置くことだけを定める。Android-specific API が `commonMain` に侵入してはならない。

## Cross-platform Storage

iOS/iPadOS と Android で同じ Persistence フレームワークを使用することを必須としない。共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本節は、Shared リポジトリ Interface の iOS 実装が SwiftData、Android 実装が Room であることだけを定める。この構成を初期実装の基本とする。

将来的に KMP Shared Persistence が必要になった場合は、SQLDelight 等を別途評価する。

## SQLDelight に関する方針

KMP Shared Storage を将来採用する場合、SQLDelight 等を候補とする。

ただし、Android 初期実装で Room を採用したこと自体を失敗とみなさない。

Storage フレームワークの共有よりも、

* ドメイン・モデル
* リポジトリ Interface
* ユースケース
* Mapping Rules
* Storage Semantics

の共有を優先する。

## バックアップ Boundary

バックアップ対象は下記を原則とする。Potentially Backupable: User Preferences / Favorites / Package Metadata / Historical スナップショット。Sensitive / Reconstructable Data は必要に応じて除外する。特に Credentials と Encryption Key は アプリケーション Data バックアップから独立させる。

## Privacy

Local Storage に保存する情報は必要最小限とする。

保存しないもの:

* Packagist Password
* GitHub Password
* 不要な OAuth Response
* 不要な API Response 全体
* 不要な Personal Data
* 不要な Request / Response Log

## Source of Truth

Storage に関する責務は下記のように分離する。

| Concern | Source of Truth |
| --- | --- |
| ドメイン・モデル | [`models_spec.md`](./models_spec.md) |
| Data Model | [`models_spec.md`](./models_spec.md) |
| Domain Invariant | [`domain_rules.md`](./domain_rules.md) |
| キャッシュ | [`cache_spec.md`](./cache_spec.md) |
| Statistics | [`statistics_spec.md`](./statistics_spec.md) |
| Credential | [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) |
| iOS/iPadOS Storage | [`ios_spec.md`](./ios_spec.md) |
| Android Storage | [`android_spec.md`](./android_spec.md) |
| Cross-platform Storage | [`kmp_spec.md`](./kmp_spec.md) |

## Initial Implementation Recommendation

初期 Android 実装では下記を基本構成とする。層の依存方向は [`architecture.md`](./architecture.md) を正本とする。本節は、Room に Package / Favorite / スナップショット、DataStore に Preferences、Credential Store に Keystore + Encrypted Store を置くことだけを定める。

初期版では **Local-first + Room + DataStore + Keystore** を基本とする。

## Future Evolution

将来的に下記の要件が発生した場合、Storage Architecture を拡張する。共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本節は、初期実装に先行して導入しないことだけを定める。

### Case-1: Android Device 同期

Android Device A ↔ 同期 Service ↔ Android Device B。

### Case-2: iOS/Android 同期

iOS → Sync Service → Android。

### Case-3: KMP Shared Persistence

KMP リポジトリ → iOS / Android。

これらを初期実装に先行して導入しない。

## Acceptance Criteria

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。永続化対象は [`storage_spec.md`](./storage_spec.md)、復元対象は [`application_state.md`](./application_state.md)、脅威 / ログは [`security_spec.md`](./security_spec.md)、オフライン閲覧は [`cache_spec.md`](./cache_spec.md) / [`ui.md`](./ui.md) を正本とする。本仕様は下記の Android HOW だけを判定する。

### Architecture

* [ ] UI が Room / DataStore / Keystore を直接呼び出さない
* [ ] ドメイン・モデル / リポジトリ Interface が Room に依存しない

### Persistent Data

* [ ] Package / Favorite / スナップショットを Room に保存できる

### Preferences

* [ ] User Preferences を DataStore に保存できる
* [ ] 同一 DataStore File に複数 Instance を生成しない

### Credentials

* [ ] Credential が平文で保存されず、Room に保存されない
* [ ] Encryption Key が Android Keystore で管理される
* [ ] Credential を個別に削除できる

### Migration

* [ ] Room スキーマ Version が管理される
* [ ] Migration Failure 時に既存データを無条件に削除しない
* [ ] DataStore Corruption を適切に扱える

### バックアップ

* [ ] バックアップ対象が明示されている
* [ ] Credential を通常のバックアップ Data として扱わない
