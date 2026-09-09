# S2J Package Dashboard - iOS/iPadOS ストレージ仕様

**Status:** Draft

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、iOS/iPadOS 実装における Storage Architecture を定義します。

本仕様では、iOS/iPadOS 固有の Storage Implementation を定義する。

本仕様の対象は下記とする。

* Local Persistent Storage
* キャッシュ Storage
* Statistics スナップショット Storage
* User Preference Storage
* Credential Storage
* Storage Migration
* Data Deletion
* バックアップ / Restore
* iCloud / CloudKit の扱い

実装時に下記を確定する。

* SwiftData スキーマ
* リポジトリ Implementation
* Keychain Item Identifier
* Keychain Accessibility
* Migration Strategy
* スナップショット Retention Policy
* In-memory Test Store

CloudKit/iCloud 同期は、Multi-device UX の要求が明確になった時点で別途仕様化する。

本仕様は iOS/iPadOS のストレージ実装差分に限定する。方針の正本は下記とする。

* 永続化 / スナップショット: [`storage_spec.md`](./storage_spec.md)
* スナップショットの不変条件: [`domain_rules.md`](./domain_rules.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* 認証 / クレデンシャル: [`authentication_spec.md`](./authentication_spec.md)

ドメイン・モデル、アプリケーション Logic、リポジトリ Interface 等の platform-independent な仕様は、それぞれ下記を Source of Truth とする。

* [`models_spec.md`](./models_spec.md)
* [`domain_rules.md`](./domain_rules.md)
* [`architecture.md`](./architecture.md)
* [`kmp_spec.md`](./kmp_spec.md)

## 目的

本仕様は、iOS/iPadOS におけるストレージ実装差分を定義する。SwiftData、Keychain、ファイル配置など、プラットフォーム固有の保存方法を対象とする。

## 非目的

本仕様では下記を初期実装の必須要件としない。

* CloudKit 同期
* iCloud Drive Storage
* External 同期 Server
* Cross-platform Credential Migration
* 独自暗号化 Database
* 独自バックアップ Format
* Background Statistics Collection の保証

## 責務

iOS/iPadOS の Persistent Storage、キャッシュ Storage、スナップショット Storage、Preference、Credential の実装差分を定義する。

## 非責務

方針の正本は下記とする。

* 永続化 / スナップショット: [`storage_spec.md`](./storage_spec.md)
* スナップショットの不変条件: [`domain_rules.md`](./domain_rules.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* 認証 / クレデンシャル: [`authentication_spec.md`](./authentication_spec.md)
* 復元対象: [`application_state.md`](./application_state.md)
* 検証の種類: [`testing_spec.md`](./testing_spec.md)
* ドメイン型 / ルール / アーキ: [`models_spec.md`](./models_spec.md) / [`domain_rules.md`](./domain_rules.md) / [`architecture.md`](./architecture.md)

## 基本方針

iOS/iPadOS の Storage は下記の原則に従う。層の分離、Credential 分離、キャッシュと Persistent の区別、スナップショットの不変条件は [`architecture.md`](./architecture.md) / [`authentication_spec.md`](./authentication_spec.md) / [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) / [`domain_rules.md`](./domain_rules.md) を正本とする。本節は、その原則を SwiftData / Keychain に載せることを定める。

1. Storage 実装を UI から直接利用しない
2. Storage リポジトリを介してアクセスする
3. SwiftData を iOS/iPadOS の主要 Persistent Storage 実装候補とする
4. Keychain を Credentials の保管先とする
5. CloudKit/iCloud 同期は初期実装の必須要件としない
6. 将来の KMP 移行を妨げない構造とする

## Initial Implementation Recommendation

初期 iOS/iPadOS 実装では、SwiftData に Package / Favorite / スナップショット / Preferences を置き、Credentials は Keychain とする。層の依存方向は [`architecture.md`](./architecture.md) を正本とする。本節は、Persistent と Credentials を別ストレージに置くことだけを定める。初期版では **Local-first + Keychain** を基本とする。

## Storage Architecture

基本的な依存関係は [`architecture.md`](./architecture.md) を正本とする。本節は、iOS Storage Adapter が SwiftData と Keychain であり、UI が SwiftData / Keychain API を直接呼び出してはならないことだけを定める。

## Storage Categories

iOS/iPadOS では Storage を下記に分類する。

| Category | Purpose | Storage |
| --- | --- | --- |
| Persistent Data | Package / Favorite 等 | SwiftData |
| スナップショット | Statistics History | SwiftData |
| キャッシュ | 一時的 API Response | URLCache / App キャッシュ |
| Preferences | User Settings | UserDefaults / AppStorage |
| Credentials | API Token 等 | Keychain |
| Temporary Data | 一時ファイル等 | Temporary Directory |

Storage Category を混在させない。

## Persistent Data

### 対象

Persistent Data には、アプリケーションを再起動しても保持する必要があるデータを保存する。何を永続化するかは [`storage_spec.md`](./storage_spec.md)、型は [`models_spec.md`](./models_spec.md) を正本とする。本節は、iOS ではそれらを SwiftData に置くことだけを定める。

## SwiftData

iOS/iPadOS の Persistent Storage には SwiftData を第一候補とする。

SwiftData は宣言的な Model 定義と永続化を提供し、ローカルデータの保存に加えて、ネットワークデータのローカルコピーや限定的な Offline 機能にも利用できる。([SwiftData | Apple Developer Documentation](https://developer.apple.com/documentation/SwiftData?changes=_4))

ただし、SwiftData の `@Model` 型そのものをドメイン・モデルとして扱わない。ドメイン・モデルを SwiftData Persistence Model に mapping して Persistent Store へ書く。

## ドメイン・モデルと Persistence Model

下記を明確に分離する。

### Domain

```swift
struct Package {
    let id: PackageIdentifier
    let name: String
    let description: String?
}
```

### Persistence

```swift
@Model
final class PackageRecord {
    var id: String
    var name: String
    var packageDescription: String?
}
```

実際の型・属性は実装時に定義する。

Persistence Model がドメイン・モデルの API や Invariant を規定してはならない。

## Persistence リポジトリ

アプリケーション Layer は SwiftData を直接利用しない。

たとえば下記のようなリポジトリ Interface を定義する。

```swift
protocol PackageRepository {
    func find(
        id: PackageIdentifier
    ) async throws -> Package?

    func save(
        _ package: Package
    ) async throws

    func delete(
        id: PackageIdentifier
    ) async throws
}
```

iOS/iPadOS では、この Interface の実装として SwiftData Adapter を提供する。`PackageRepository` ← implements `SwiftDataPackageRepository` → SwiftData。

## Storage Actor / Concurrency

Persistence 操作は UI Thread に直接依存しない。

Swift Concurrency を利用し、Storage Adapter は適切な Actor isolation を持つ構造とする。

基本方針: SwiftUI MainActor → アプリケーション → リポジトリ → Persistence Actor / Context。Storage 操作によって UI が不必要に Block されないようにする。

Keychain API についても、同期 API の呼び出しによって UI を長時間 Block しない構造とする。

Apple の Keychain API ドキュメントでも、Keychain 操作は呼び出しスレッドを Block し得るため、UI を停止させないよう Background Queue / async 処理が推奨されている。([SecItemAdd | Apple Developer Documentation](https://developer.apple.com/documentation/security/secitemadd%28_%3A_%3A%29?changes=_2_1&language=objc))

## Package Storage

Package の Local Representation は、API Response の単純なコピーとしてではなく、アプリケーションが必要とする Local Data として保存する。フィールドは [`models_spec.md`](./models_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、API DTO の完全保存を目的とせず、永続化が必要なものだけを Persistence Model に変換することだけを定める。

## Favorite Storage

Favorite の不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。本節は SwiftData 上で Package と別 Record にし、PackageIdentifier で結ぶことだけを定める。

## Maintained Package Storage

Maintained と Favorite の意味の区別は [`domain_rules.md`](./domain_rules.md) を正本とする。本節は、SwiftData 上で両方を同時に保持できることだけを定める。

## Statistics スナップショット Storage

Statistics の長期履歴はスナップショットとして保存する。行の形は [`storage_spec.md`](./storage_spec.md)、指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本節は、Package に対して複数のスナップショット Record を SwiftData に置くことだけを定める。

## SwiftData スナップショット書き込み

スナップショットの不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。本節は、新しい観測を新しい SwiftData Record として保存することだけを定める。

## キャッシュ

キャッシュとスナップショットの区別、Lifetime / Freshness は [`cache_spec.md`](./cache_spec.md) を正本とする。本節は iOS/iPadOS のキャッシュ実装差分のみを定義する。

## `URLCache`

HTTP Response のキャッシュには、必要に応じて `URLCache` / `URLSession` の標準キャッシュ機構を利用する。

ただし、API Response のすべてを `URLCache` に依存して永続化することは避ける。

アプリケーションが意味論的に保持する必要のあるデータは、リポジトリを通じて Persistent Storage に保存する。

## キャッシュ Record とスナップショット Record

区別の意味は [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とする。iOS/iPadOS では、最新 API 応答と Historical スナップショットを同一 Storage Record に保存しない。

## User Preferences

ユーザー設定には `UserDefaults` / `AppStorage` を利用する。

対象例:

* Selected Statistics Period
* Refresh Preference
* Appearance Preference
* First Launch Flag
* Display Preference
* Sort Order
* Last Selected Package Identifier

ただし、大量データや複雑な Relationship を UserDefaults に保存しない。

## Credentials

認証方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本節は Keychain への保存方法を定義する。

Credentials は通常の Persistent Storage に保存してはならない。何を保存するかは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本節は Keychain Services へ保存することだけを定める。

Apple は Keychain Services を Password や Cryptographic Key などの小さな秘密情報を安全に保存するための API として提供している。([Keychain services | Apple Developer Documentation](https://developer.apple.com/documentation/security/keychain-services))

## Keychain Architecture

Keychain へのアクセスも専用 Adapter を介する。Authentication Service → `CredentialStore` → `KeychainCredentialStore` → Keychain Services。アプリケーション Layer が `SecItemAdd` 等を直接呼び出してはならない。

## Keychain Item

Provider ごとに Credential を分離する。Packagist は API Token、GitHub は Access Token を別 Keychain Item とする。Keychain Item の識別子はアプリケーション内で一意に管理する。

例:

* `com.s2j.package-dashboard.packagist.token`
* `com.s2j.package-dashboard.github.token`

実際の Bundle Identifier / Access Group は Xcode Project 設定に合わせて確定する。

## Keychain Accessibility

Credential の用途に応じて、可能な限り restrictive な Keychain accessibility を選択する。

バックグラウンド処理等で常時アクセス可能にする必要がない Credential を `Always` 相当の設定で保存しない。

Apple も Keychain Item について、用途に応じて最も制限の強い Accessibility を使用することを推奨している。([Restricting keychain item accessibility | Apple Developer Documentation](https://developer.apple.com/documentation/security/restricting-keychain-item-accessibility?changes=_7_1))

## Biometric Protection

初期バージョンでは、全 API Token について毎回 Face ID / Touch ID を要求することを必須としない。

ただし、将来的にユーザーが明示的に Credential Protection を有効化できる場合は、Keychain の Access Control と LocalAuthentication を利用する。

Apple の Keychain は Face ID / Touch ID によるユーザー認証を Access Control と組み合わせて要求できる。([Accessing Keychain Items with Face ID or Touch ID | Apple Developer Documentation](https://developer.apple.com/documentation/localauthentication/accessing-keychain-items-with-face-id-or-touch-id?changes=la_3))

## Credential Lifecycle

Lifecycle の意味 (未設定 / 設定済 / 認証済 / 失効) は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本節は Keychain Item の追加・更新・削除に対応づける。ユーザーが Disconnect / Remove した場合は Keychain Item を削除する。

## Credential とアプリケーション Data の分離

Credential の削除はアプリケーション Data の削除を意味しない。Keychain Item を消しても Package / Favorites / スナップショットは残す。ユーザーが明示的に Local Data の削除を選択した場合のみ、アプリケーション Data を削除する。

## Security Boundary

通常の SwiftData Store に置いてはならないものは [`authentication_spec.md`](./authentication_spec.md) の禁止リストを正本とする。本節は、SwiftData / UserDefaults / ログへ書かないことの実装確認である。

また、下記にも保存してはならない。

* Log
* Analytics Event
* URL Query
* Error Message
* Crash Report
* スナップショット

## Local Data Encryption

アプリケーションが独自に暗号化 Database を実装することを初期要件としない。

まず、

* iOS Data Protection
* SwiftData / Core Data
* Keychain Services

等の Platform Security を利用する。

独自暗号化が必要となった場合は、Security / CryptoKit 等の既存 API を利用し、独自暗号アルゴリズムを実装しない。

Apple も Security フレームワークにおいて、可能な限り高レベルの Security API を利用することを推奨している。([Security | Apple Developer Documentation](https://developer.apple.com/documentation/security))

## バックアップ / Restore

初期バージョンでは、ユーザーが明示的に Export / Import を実行しない限り、アプリケーション Data を独自形式で外部にバックアップしない。

対象データについては、Apple の標準的な Device バックアップ / Restore の挙動を基本とする。

ただし、Credential のバックアップ・復元については、Keychain の Platform Behavior に依存するため、アプリケーション独自の Export を行わない。

## iCloud Keychain

Credential の iCloud Keychain による同期可能性は Platform の機能として利用できるが、アプリケーションが Credential を iCloud Drive や CloudKit に独自コピーしてはならない。

Apple の Keychain と iCloud Keychain の利用範囲は、選択する Keychain Accessibility および entitlement に従う。

Cross-platform migration を目的として Credential を iCloud から Android に移送するしくみは実装しない。

## CloudKit

CloudKit は初期バージョンでは必須としない。

理由:

1. 初期版は Local-first を優先する
2. Android 版との Storage Strategy が異なる
3. CloudKit は Apple Platform に固有である
4. Cross-platform 同期を CloudKit に依存させると KMP Architecture と分離しにくくなる
5. 同期 Conflict / Account Change / Offline Queue 等の追加設計が必要になる

CloudKit は将来の iOS/iPadOS 専用同期 Option として検討する。

## SwiftData + CloudKit

将来 CloudKit 同期を採用する場合でも、ドメイン・モデルと SwiftData Model の分離を維持する。経路は Domain → リポジトリ → SwiftData → Local Store または CloudKit 同期。

SwiftData は CloudKit による Model Data の同期をサポートしている。([Syncing model data across a person’s devices | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices?changes=_8))

ただし、CloudKit を採用する場合は、下記を別途仕様化する。

* CloudKit Container
* スキーマ
* Record Mapping
* Conflict Resolution
* Account Change
* Offline Queue
* 同期 Failure
* Migration
* Privacy
* Deletion
* iCloud Availability

これらを本仕様に暗黙に含めない。

## Multi-device Strategy

iPhone / iPad 間で Local Data を同期する必要が生じた場合、下記の候補を比較する。

### Option A — CloudKit

iPhone ↔ CloudKit ↔ iPad。

### Option B — External 同期 Service

iPhone ↔ S2J 同期 Service ↔ iPad。

### Option C — Export / Import

iPhone → Export → File → Import → iPad。

初期バージョンでは Option C または Local-only を優先する。

## Cross-platform Storage

Android 版では iOS/iPadOS の SwiftData を共有 Storage として扱わない。共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本節は、Shared リポジトリ Interface の iOS 実装が SwiftData、Android 実装が Android Storage であることだけを定める。

将来 KMP Shared Storage を採用する場合は、SQLDelight 等を候補として別途評価する。

## Storage Migration

Persistent Model のスキーマ Version を管理する。スキーマ v1→ v2→ v3。Migration はアプリケーション Version と独立して管理できる構造を推奨する。行の互換は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は SwiftData のスキーマ Version を独立管理することだけを定める。

## Migration Rules

Migration では下記を保証する。

* 既存 Package Data を可能な限り保持する
* Favorite を失わない
* スナップショット History を失わない
* Credential を Migration Data に含めない
* Migration Failure を検知できる
* Migration 後にスキーマ Version を更新する

## Migration Failure

Migration に失敗した場合、ユーザーの既存データを無条件に削除してはならない。

基本 Flow: Migration Failure → Preserve Existing Store → Error / Recovery。

必要に応じて、

* Retry
* バックアップ Restore
* Rebuild Local キャッシュ

等の Recovery を検討する。

## Data Deletion

Settings から下記を個別に削除可能とする。削除対象の意味は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、キャッシュ / Statistics スナップショット / Local Package Data / Favorites / Credentials を iOS Settings から個別削除できることだけを定める。

初期 UI では、すべてを一括削除する場合でも、削除対象を明示する。

## キャッシュ Deletion

キャッシュは再取得可能なため、ユーザーが削除してもアプリケーション状態を失わない。Lifetime は [`cache_spec.md`](./cache_spec.md) を正本とする。本節は、Delete キャッシュ → Empty → Next Request で Provider から Fetch することだけを定める。

## スナップショット Deletion

Statistics スナップショットはユーザーの履歴データとして扱う。削除方針は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、削除後の Chart が残存 Data のみを出し、Provider から過去スナップショットを自動復元できるとは限らないことだけを定める。

## Storage Reset

完全な Local Data Reset を提供する場合、Persistent Data / キャッシュ / スナップショット / Preferences を対象とする。Reset の意味は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、Storage Reset ≠ Credential Reset であること、および「すべて削除」時に対象を明示することだけを定める。

## Offline Behavior

Local Persistent Data が存在する場合、ネットワーク接続がない状態でも下記を可能な限り提供する。

* Package List
* Favorite List
* Package Detail
* Last known statistics
* スナップショット Chart
* Settings

ただし、最新情報を必要とする操作については、

* Last Updated
* Offline

を明示する。

## Storage Freshness

Persistent Data には可能な限り取得時刻を保持する。鮮度の判定は [`cache_spec.md`](./cache_spec.md)、スナップショット時刻は [`storage_spec.md`](./storage_spec.md) を正本とする。本節は、SwiftData 上で `lastFetchedAt` / `collectedAt`、キャッシュで `cachedAt` / `expiresAt` を保持できることだけを定める。

## Storage Source

Provider 由来のデータには Source を識別可能な形で保持する。

例:

`source = Packagist`
`source = GitHub`

同一 Metric 名でも Provider によって意味が異なる場合があるため、Provider 情報を省略しない。

## Storage Consistency

アプリケーション状態と Persistence 状態の間に不整合が発生しないようにする。

たとえば Favorite 追加の場合: User Action → Validate → Persist Favorite → Update アプリケーション状態。Persistence Failure が発生した場合は、成功したように UI を更新してはならない。

## Transaction Boundary

複数の Persistence Operation が一つの Domain Operation を構成する場合、可能な限り Transaction / Atomic Operation として扱う。

例: Add Favorite は Create Favorite と Update Package Reference を一つの Atomic Operation とする。ただし、Persistence Implementation の Transaction API を Domain Layer に漏らさない。アトミック性の意味は [`domain_rules.md`](./domain_rules.md) を正本とする。

## Testing

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、SwiftData / Keychain の HOW を In-memory Store で検証できることだけを定める。

## In-memory Storage

Unit Test/Preview では In-memory Storage を利用可能な構造とする。

SwiftData はテスト用途などで In-memory Store を構成できるため、実ファイルに依存しないテスト環境を用意する。([Preserving your app’s model data across launches | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches))

* Production: Persistent Store
* Test: In-memory Store

Domain Test が SwiftData に依存しない構造を維持する。

## Storage Failure Handling

Storage Error はアプリケーション Error に変換する。層の分類は [`architecture.md`](./architecture.md)、`ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とする。本節は、SwiftData Error → PersistenceError → アプリケーション Error → UI Error 状態とし、SwiftData の具体 Error Type を UI に公開しないことだけを定める。

## Logging

Storage Error は必要に応じて診断情報として記録する。

ただし Secret を Log に含めない。禁止対象は [`security_spec.md`](./security_spec.md) を正本とする。

## Performance

Storage Access は必要最小限とする。

特に下記を避ける。

* UI Render 毎の Database Query
* 大量スナップショットの全件読み込み
* 不要な Full Table Scan
* MainActor 上での重い Migration
* MainActor 上での大量 Data Transformation

Statistics Chart では、必要な期間/Metric のみを Query する。

## Retention Policy

スナップショット Retention は [`storage_spec.md`](./storage_spec.md)、長期傾向の目的は [`statistics_spec.md`](./statistics_spec.md) を正本とする。本仕様は、iOS 実装が独自に削除期限を決めないことだけを定める。

## App Lifecycle

App が下記の状態になっても Storage が破綻しないことを保証する。

* Launch
* Background
* Foreground
* Suspend
* Terminate
* Relaunch

特に Background 移行時に未保存データを可能な限り安全に Commit する。

## Background Processing

Background Execution を Statistics Collection の保証手段として扱わない。

iOS/iPadOS の Background Execution は実行時刻・実行時間が保証されないため、長期にわたる統計収集の必須条件を「App must remain open」とはしない。

長期的な自動スナップショット Collection が必要になった場合は、外部 Scheduler / Backend 等を別途検討する。

## App Update

アプリケーション Version が更新されても、互換性のある Persistent Data は保持する。App v1→ Update → App v2でも Existing Data を残す。スキーマ Migration が必要な場合は Migration を実行する。

## App Uninstall

App のアンインストール時にアプリケーション Data が削除されることを前提とする。

ただし、Keychain Item の保持挙動等、Platform の仕様に依存するものについては、アプリケーションが「アンインストール時に必ず Credential が消える」と仮定しない。

再インストール時には、既存 Credential が存在する可能性を考慮して認証状態を検証する。

## Privacy

Local Storage に保存する情報は必要最小限とする。

保存しないもの:

* Packagist Password
* GitHub Password
* 不要な OAuth Response
* 不要な API Response 全体
* 不要な個人情報
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
| Cross-platform Storage | [`kmp_spec.md`](./kmp_spec.md) |

## Future Evolution

将来的に下記の要件が発生した場合、Storage Architecture を拡張する。共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本節は、初期実装に先行して導入しないことだけを定める。

### Case-1: iPhone/iPad 同期

SwiftData ↔ CloudKit。

### Case-2: Android 同期

iOS → Sync Service → Android。

### Case-3: KMP Shared Persistence

KMP リポジトリ → iOS / Android。

これらを初期実装に先行して導入しない。

## Acceptance Criteria

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。永続化対象は [`storage_spec.md`](./storage_spec.md)、復元対象は [`application_state.md`](./application_state.md)、脅威 / ログは [`security_spec.md`](./security_spec.md)、オフライン閲覧は [`cache_spec.md`](./cache_spec.md) / [`ui.md`](./ui.md) を正本とする。本仕様は下記の iOS HOW だけを判定する。

### Architecture

* [ ] UI が Storage API を直接呼び出さない
* [ ] ドメイン・モデル / リポジトリ Interface が SwiftData に依存しない

### Persistent Data

* [ ] Package / Favorite / スナップショットを SwiftData に保存できる

### Credentials

* [ ] Credential が Keychain に保存され、SwiftData に保存されない
* [ ] Credential を個別に削除できる
* [ ] Keychain Accessibility が適切に設定されている

### Migration

* [ ] スキーマ Version が管理される
* [ ] Migration Failure 時に既存データを無条件に削除しない
