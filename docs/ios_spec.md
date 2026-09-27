# S2J Package Dashboard - iOS/iPadOS ストレージ仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、iOS/iPadOS 実装でのストレージ・アーキテクチャーを定義します。

本仕様では、iOS/iPadOS 固有のストレージの実装を定義します。

本仕様の対象は、下記とします。

* ローカルの永続化ストレージ
* キャッシュ・ストレージ
* 統計スナップショット・ストレージ
* ユーザー設定 (Preference) ストレージ
* クレデンシャル (資格情報) ストレージ
* ストレージ移行
* データの削除
* バックアップ/復元
* iCloud/CloudKit の扱い

実装時に、下記を確定します。

* SwiftData スキーマ
* リポジトリの実装
* Keychain アイテム識別子
* Keychain アクセシビリティ
* 移行戦略
* スナップショット保持の方針
* インメモリ・テスト・ストア

CloudKit/iCloud 同期は、複数デバイス UX の要求が明確になった時点で、別途仕様化します。

本仕様は、iOS/iPadOS のストレージ実装差分に限定します。方針の正本は、下記とします。

* 永続化/スナップショット: [`storage_spec.md`](./storage_spec.md)
* スナップショットの不変条件: [`domain_rules.md`](./domain_rules.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* 認証/クレデンシャル (資格情報): [`authentication_spec.md`](./authentication_spec.md)

ドメイン・モデル、アプリケーション・ロジック、リポジトリ・インターフェース等のプラットフォーム非依存な仕様は、それぞれ下記を信頼できる情報源 (SoT) とします。

* [`models_spec.md`](./models_spec.md)
* [`domain_rules.md`](./domain_rules.md)
* [`architecture.md`](./architecture.md)
* [`kmp_spec.md`](./kmp_spec.md)

## 目的

本仕様は、iOS/iPadOS におけるストレージ実装差分を定義します。SwiftData、Keychain、ファイル配置など、プラットフォーム固有の保存方法を対象とします。

## 非目的

本仕様では、下記を初期実装の必須要件としません。

* CloudKit 同期
* iCloud Drive ストレージ
* 外部同期サーバー
* プラットフォーム横断型クレデンシャル (資格情報) 移行
* 独自暗号化データベース
* 独自バックアップ・フォーマット
* バックグラウンド統計コレクションの保証

## 責務

iOS/iPadOS の永続化ストレージ、キャッシュ・ストレージ、スナップショット・ストレージ、ユーザー設定 (Preference)、クレデンシャル (資格情報) の実装差分を定義します。

## 非責務

方針の正本は、下記とします。

* 永続化 / スナップショット: [`storage_spec.md`](./storage_spec.md)
* スナップショットの不変条件: [`domain_rules.md`](./domain_rules.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* 認証 / クレデンシャル (資格情報): [`authentication_spec.md`](./authentication_spec.md)
* 復元対象: [`application_state.md`](./application_state.md)
* 検証の種類: [`testing_spec.md`](./testing_spec.md)
* ドメイン型 / ルール / アーキテクチャー: [`models_spec.md`](./models_spec.md) / [`domain_rules.md`](./domain_rules.md) / [`architecture.md`](./architecture.md)

## 基本方針

iOS/iPadOS のストレージは、下記の原則に従います。層の分離、クレデンシャル (資格情報) 分離、キャッシュと永続化の区別、スナップショットの不変条件は [`architecture.md`](./architecture.md) / [`authentication_spec.md`](./authentication_spec.md) / [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) / [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「その原則を SwiftData / Keychain に載せる」ことを定めます。

1. ストレージ実装を UI から直接利用しない
2. ストレージ・リポジトリを介して、アクセスする
3. SwiftData を iOS/iPadOS の主要永続化ストレージ実装候補とする
4. Keychain を クレデンシャル (資格情報) の保管先とする
5. CloudKit/iCloud 同期は、初期実装の必須要件としない
6. 将来の Kotlin Multiplatform (KMP) 移行を妨げない構造とする

## 初期実装のおすすめ

初期版では、**「ローカル」ファースト + Keychain** を基本とします。

初期 iOS/iPadOS 実装では、下記を基本構成とします。

SwiftData にパッケージ/お気に入り/スナップショット/ユーザー設定 (Preference) を置き、Keychain に クレデンシャル (資格情報) を置きます。

層の依存方向は [`architecture.md`](./architecture.md) を正本とします。
本節は、「永続化とクレデンシャル (資格情報) を別ストレージに置く」ことのみを定めます。

## 今後の展開

将来的に、下記の要件が発生した場合、ストレージ・アーキテクチャーを拡張します。共有対象は [`architecture.md`](./architecture.md)、Kotlin Multiplatform (KMP) の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本節は、「初期実装に先行して導入しない」ことのみを定めます。

これらを初期実装に先行して導入しません。

### Case-1: iPhone/iPad 同期

SwiftData ↔ CloudKit。

### Case-2: Android 同期

iOS →同期サービス/Android。

### Case-3: Kotlin Multiplatform (KMP) 共有の永続化

KMP リポジトリ→ iOS/Android。

## ストレージ・アーキテクチャー

基本的な依存関係は [`architecture.md`](./architecture.md) を正本とします。
本節は、「iOS ストレージ・アダプタが SwiftData と Keychain であり、UI が SwiftData / Keychain API を直接呼び出してはならない」ことのみを定めます。

## ストレージ・カテゴリー

下記は、iOS/iPadOS でのストレージを分類したものです。ストレージ・カテゴリーを混在させません。

| カテゴリー | 目的 | ストレージ |
| --- | --- | --- |
| 永続化データ | パッケージ / お気に入り等 | SwiftData |
| スナップショット | 統計履歴 | SwiftData |
| キャッシュ | 一時的 API レスポンス | URLCache / アプリケーション・キャッシュ |
| ユーザー設定 (Preference) | ユーザー設定 | UserDefaults / AppStorage |
| クレデンシャル (資格情報) | API Token 等 | Keychain |
| 一時データ | 一時ファイル等 | 一時ディレクトリ |

## 永続化データ

### 対象

永続化データには、アプリケーションを再起動しても保持する必要があるデータを保存します。何を永続化するかは [`storage_spec.md`](./storage_spec.md)、型は [`models_spec.md`](./models_spec.md) を正本とします。
本節は、「iOS では、それらを SwiftData に置く」ことのみを定めます。

## SwiftData

iOS/iPadOS の永続化ストレージには、SwiftData を第一候補とします。

SwiftData は、宣言的なモデル定義と永続化を提供し、ローカルデータの保存に加えて、ネットワークデータのローカルコピーや限定的なオフライン機能にも利用できます。

(参考: [SwiftData | Apple Developer Documentation](https://developer.apple.com/documentation/SwiftData?changes=_4))

ただし、SwiftData の `@Model` 型自体をドメイン・モデルとして扱いません。ドメイン・モデルを SwiftData 永続化モデルにマッピングして、永続化ストアに書きます。

## ドメイン・モデルと永続化モデル

下記を、明確に分離します。

実際の型・属性は実装時に定義します。

永続化モデルが、ドメイン・モデルの API や不変を規定してはなりません。

### ドメイン

```swift
struct Package {
    let id: PackageIdentifier
    let name: String
    let description: String?
}
```

### 永続化

```swift
@Model
final class PackageRecord {
    var id: String
    var name: String
    var packageDescription: String?
}
```

## 永続化リポジトリ

アプリケーション層は、SwiftData を直接利用しません。

たとえば、下記のようなリポジトリ・インターフェースを定義します。

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

iOS/iPadOS では、このインターフェースの実装として SwiftData アダプタを提供します。

`PackageRepository` ← implements `SwiftDataPackageRepository` → SwiftData

## ストレージ・アクター/並行処理

永続化操作は、UI スレッドに直接依存しません。

Swift 並行処理を利用し、ストレージ・アダプタは、適切なアクターの分離を持つ構造とします。

基本方針: SwiftUI MainActor →アプリケーション→リポジトリ→ 永続化アクター/コンテキスト

ストレージ操作によって、UI が不必要にブロックされないようにします。

Keychain API についても、同期 API の呼び出しによって、UI を長時間ブロックしない構造とします。

Apple の Keychain API ドキュメントでも、Keychain 操作は呼び出しスレッドをブロックし得るため、UI を停止させないようバックグラウンド・キュー / async 処理が推奨されています。

(参考: [SecItemAdd | Apple Developer Documentation](https://developer.apple.com/documentation/security/secitemadd%28_%3A_%3A%29?changes=_2_1&language=objc))

## パッケージ・ストレージ

パッケージのローカル表現は、API レスポンスの単純なコピーとしてではなく、アプリケーションが必要とするローカルデータとして保存します。フィールドは [`models_spec.md`](./models_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「API データ転送オブジェクト (DTO) の完全保存を目的とせず、永続化が必要なものだけを、永続化モデルに変換する」ことのみを定めます。

## お気に入りストレージ

お気に入りの不変条件は [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「SwiftData 上でパッケージと別レコードにし、PackageIdentifier で結ぶ」ことのみを定めます。

## 管理対象のパッケージ・ストレージ

管理対象とお気に入りの意味の区別は [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「SwiftData 上で、両方を同時に保持できる」ことのみを定めます。

## 統計スナップショット・ストレージ

統計の長期履歴は、スナップショットとして保存します。行の形は [`storage_spec.md`](./storage_spec.md)、指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とします。
本節は、「パッケージに対して、複数のスナップショット・レコードを SwiftData に置く」ことのみを定めます。

## SwiftData スナップショット書き込み

スナップショットの不変条件は [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「新しい観測を、新しい SwiftData レコードとして保存する」ことのみを定めます。

## キャッシュ

キャッシュとスナップショットの区別、有効期間/鮮度は [`cache_spec.md`](./cache_spec.md) を正本とします。
本節は、「iOS/iPadOS のキャッシュ実装差分」のみを定義します。

## `URLCache`

HTTP レスポンスのキャッシュには、必要に応じて、`URLCache` / `URLSession` の標準キャッシュ機構を利用します。

ただし、API レスポンスのすべてを `URLCache` に依存して永続化することは避けます。

アプリケーションが意味論的に保持する必要のあるデータは、リポジトリを通じて、永続化ストレージに保存します。

## キャッシュ・レコードとスナップショット・レコード

区別の意味は [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とします。
iOS/iPadOS では、最新 API レスポンスと履歴スナップショットを、同一ストレージ・レコード に保存しません。

## ユーザー設定 (Preference)

ユーザー設定 (Preference) には `UserDefaults` / `AppStorage` を利用します。ただし、大量データや複雑なリレーションシップを UserDefaults に保存しません。

対象例:

* 選択された 統計期間
* リフレッシュのユーザー設定 (Preference)
* 外観のユーザー設定 (Preference)
* 初回起動フラグ
* 表示のユーザー設定 (Preference)
* ソート順序
* 最後に選択したパッケージの識別子

## クレデンシャル (資格情報)

認証方針は [`authentication_spec.md`](./authentication_spec.md) を正本とします。
本節は、「Keychain への保存方法」を定義します。

クレデンシャル (資格情報) は、通常の永続化ストレージに保存してはなりません。何を保存するかは [`authentication_spec.md`](./authentication_spec.md) を正本とします。
本節は、「Keychain Services に保存する」ことのみを定めます。

Apple は Keychain Services を、パスワードや暗号鍵などの小さな秘密情報を、安全に保存するための API として提供しています。

(参考: [Keychain services | Apple Developer Documentation](https://developer.apple.com/documentation/security/keychain-services))

## Keychain アーキテクチャー

Keychain へのアクセスも、専用アダプタを介します。アプリケーション層が `SecItemAdd` 等を直接呼び出してはなりません。

認証サービス→ `CredentialStore` → `KeychainCredentialStore` → Keychain Services

## Keychain アイテム

プロバイダごとにクレデンシャル (資格情報) を分離します。Keychain アイテムの識別子は、アプリケーション内で一意に管理します。

実際のバンドル識別子/アクセス・グループは、Xcode プロジェクト設定に合わせて確定します。

Packagist は API Token、GitHub はアクセス Token を別 Keychain アイテム とします。

例:

* `com.s2j.package-dashboard.packagist.token`
* `com.s2j.package-dashboard.github.token`

## Keychain アクセシビリティ

クレデンシャル (資格情報) の用途に応じて、可能な限り、制限的な Keychain アクセシビリティを選択します。

バックグラウンド処理等で常時アクセス可能にする必要がないクレデンシャル (資格情報) を、`Always` 相当の設定で保存しません。

Apple も Keychain アイテムについて、用途に応じて、最も制限の強いアクセシビリティの使用を推奨しています。

(参考: [Restricting keychain item accessibility | Apple Developer Documentation](https://developer.apple.com/documentation/security/restricting-keychain-item-accessibility?changes=_7_1))

## 生体認証による保護

初期バージョンでは、全 API Token について、毎回 Face ID/Touch ID の要求を必須としません。

ただし、将来的に、ユーザーが明示的にクレデンシャル (資格情報) 保護を有効化できる場合は、Keychain のアクセス制御と LocalAuthentication を利用します。

Apple の Keychain は、Face ID/Touch ID によるユーザー認証をアクセス制御と組み合わせて要求できます。

(参考: [Accessing Keychain Items with Face ID or Touch ID | Apple Developer Documentation](https://developer.apple.com/documentation/localauthentication/accessing-keychain-items-with-face-id-or-touch-id?changes=la_3))

## クレデンシャル (資格情報) ライフサイクル

ライフサイクルの意味 (未認証→認証中→認証済み→有効期限切れ/取り消し済み) は [`authentication_spec.md`](./authentication_spec.md) を正本とします。
本節は、「Keychain アイテムの追加・更新・削除」に対応づけます。

ユーザーが切断/削除した場合は、Keychain アイテムを削除します。

## クレデンシャル (資格情報) とアプリケーション・データの分離

クレデンシャルの削除は、アプリケーション・データの削除を意味しません。Keychain アイテムを消しても、パッケージ/お気に入り/スナップショットは残します。ユーザーが明示的にローカルデータの削除を選択した場合のみ、アプリケーション・データを削除します。

## セキュリティ境界

通常の SwiftData ストアに置いてはならないものは [`authentication_spec.md`](./authentication_spec.md) の禁止リストを正本とします。
本節は、「SwiftData/UserDefaults/ログに書かないことの実装確認」です。

また、下記にも保存してはなりません。

* ログ
* アナリティクス・イベント
* URL クエリー
* エラー・メッセージ
* クラッシュ・レポート
* スナップショット

## ローカルデータの暗号化

アプリケーションが独自に暗号化データベースを実装することを、初期要件としません。

まず、下記のプラットフォーム・セキュリティを利用します。

* iOS データ保護
* SwiftData / CoreData
* Keychain Services

独自暗号化が必要となった場合は、セキュリティ/ CryptoKit 等の既存 API を利用し、独自暗号アルゴリズムを実装しません。

Apple もセキュリティ・フレームワークにおいて、可能な限り、高レベルのセキュリティ API の利用を推奨しています。

(参考: [Security | Apple Developer Documentation](https://developer.apple.com/documentation/security))

## バックアップ/復元

初期バージョンでは、ユーザーが明示的にエクスポート/インポートを実行しない限り、アプリケーション・データを独自形式で外部にバックアップしません。

対象データについては、Apple の標準的なデバイス・バックアップ/復元の挙動を基本とします。

ただし、クレデンシャル (資格情報) のバックアップ・復元については、Keychain のプラットフォーム挙動に依存するため、アプリケーション独自のエクスポートを行いません。

## iCloud Keychain

クレデンシャル (資格情報) の iCloud Keychain による同期可能性は、プラットフォームの機能として利用できるが、アプリケーションがクレデンシャルを iCloud Drive や CloudKit に独自コピーしてはなりません。

Apple の Keychain と iCloud Keychain の利用範囲は、選択する Keychain アクセシビリティおよびエンタイトルメントに従います。

プラットフォーム横断型移行を目的として、クレデンシャルを iCloud から Android に移送するフィクスチャは実装しません。

## CloudKit

CloudKit は、下記の理由により、初期バージョンでは必須としません。CloudKit は、将来の iOS/iPadOS 専用同期オプションとして検討します。

1. 初期版は、「ローカル」ファーストを優先する
2. Android 版とのストレージ戦略が異なる
3. CloudKit は、Apple プラットフォームに固有である
4. プラットフォーム横断型同期を CloudKit に依存させると、Kotlin Multiplatform (KMP) アーキテクチャーと分離しにくくなる
5. 同期コンフリクト/アカウント変更/オフライン・キュー等の追加設計が必要になる

## SwiftData + CloudKit

将来 CloudKit 同期を採用する場合でも、ドメイン・モデルと SwiftData モデルの分離を維持します。

経路は、ドメイン→リポジトリ→ SwiftData →ローカル・ストアまたは CloudKit 同期。

SwiftData は CloudKit によるモデル・データの同期をサポートしています。

(参考: [Syncing model data across a person’s devices | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices?changes=_8))

ただし、CloudKit を採用する場合は、下記を別途仕様化します。これらを本仕様に暗黙に含めません。

* CloudKit コンテナ
* スキーマ
* レコード・マッピング
* コンフリクト解決
* アカウント変更
* オフライン・キュー
* 同期失敗
* 移行
* プライバシー
* 削除
* iCloud 可用性

## 複数デバイス戦略

iPhone/iPad 間でローカルデータを同期する必要が生じた場合、下記の候補を比較します。初期バージョンでは、オプション C またはローカルのみを優先します。

### オプション A — CloudKit

iPhone ↔ CloudKit ↔ iPad。

### オプション B — 外部同期サービス

iPhone ↔ S2J 同期サービス↔ iPad。

### オプション C — エクスポート/インポート

iPhone →エクスポート→ファイル→インポート→ iPad。

## プラットフォーム横断型ストレージ

Android 版では iOS/iPadOS の SwiftData を共有ストレージとして扱いません。将来、KMP 共有ストレージを採用する場合は、SQLDelight 等を候補として別途評価します。

共有対象は [`architecture.md`](./architecture.md)、Kotlin Multiplatform (KMP) の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本節は、「共有リポジトリ・インターフェースの iOS 実装が SwiftData、Android 実装が Android ストレージである」ことのみを定めます。

## ストレージ移行

永続化モデルのスキーマ・バージョンを管理します。移行は、アプリケーション・バージョンと独立して管理できる構造を推奨します。

スキーマ v1→ v2→ v3

行の互換は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「SwiftData のスキーマ・バージョンを独立管理する」ことのみを定めます。

## 移行ルール

移行では、下記を保証します。

* 既存パッケージ・データを、可能な限り、保持する
* お気に入りを失わない
* スナップショット履歴を失わない
* クレデンシャル (資格情報) を移行データに含めない
* 移行失敗を検知できる
* 移行後のスキーマ・バージョンを正しく更新する

## 移行失敗

移行に失敗した場合、ユーザーの既存データを無条件に削除してはならない。

基本のフロー: 移行失敗→既存ストアの保持→エラー/リカバリー。

必要に応じて、下記のリカバリーを検討します。

* リトライ
* バックアップの復元
* ローカル・キャッシュのリビルド

## データの削除

設定から下記を個別に削除可能とします。削除対象の意味は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「キャッシュ/統計スナップショット/ローカルのパッケージ・データ/お気に入り/クレデンシャル (資格情報) を iOS 設定から個別削除できる」ことのみを定めます。

初期 UI では、すべてを一括削除する場合でも、削除対象を明示します。

## キャッシュの削除

キャッシュは再取得可能なため、ユーザーが削除してもアプリケーション状態を失いません。有効期間は [`cache_spec.md`](./cache_spec.md) を正本とします。
本節は、「キャッシュの削除→キャッシュ空→次リクエストで、プロバイダからフェッチする」ことのみを定めます。

## スナップショットの削除

統計スナップショットは、ユーザーの履歴データとして扱います。削除方針は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「削除後のチャートが残存データのみを出し、プロバイダから過去スナップショットを自動復元できるとは限らない」ことのみを定めます。

## ストレージのリセット

完全なローカルデータ・リセットを提供する場合、永続化データ/キャッシュ/スナップショット/ユーザー設定 (Preference) を対象とします。リセットの意味は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「ストレージのリセット≠クレデンシャル (資格情報) リセットである」「すべて削除時に対象を明示する」ことのみを定めます。

## オフラインの挙動

ローカル永続化データが存在する場合、ネットワーク接続がない状態でも、可能な限り、下記を提供します。

* パッケージリスト
* お気に入りリスト
* パッケージ詳細
* 最後に確認された統計
* スナップショット・チャート
* 設定

ただし、最新情報を必要とする操作については、下記を明示します。

* 最終更新
* オフライン

## ストレージの鮮度

永続化データには、可能な限り、取得時刻を保持します。鮮度の判定は [`cache_spec.md`](./cache_spec.md)、スナップショット時刻は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「SwiftData 上で `lastFetchedAt` / `collectedAt`、キャッシュで `cachedAt` / `expiresAt` を保持できる」ことのみを定めます。

## ストレージ・ソース

プロバイダ由来のデータには、出典を識別可能な形で保持します。同じ指標名でもプロバイダによって意味が異なる場合があるため、プロバイダ 情報を省略しません。

例:

`source = Packagist`
`source = GitHub`

## ストレージの一貫性

アプリケーション状態と永続化の状態の間に、不整合が発生しないようにします。

たとえば、お気に入り追加の場合: ユーザー・アクション→検証→お気に入りの保存→アプリケーション状態の更新

永続化が失敗した場合、成功したように UI を更新してはなりません。

## トランザクション境界

複数の永続化操作が一つのドメイン操作を構成する場合、可能な限り、トランザクション/アトミック操作として扱います。

たとえば、お気に入り追加は、「お気に入りの作成」「パッケージ参照の更新」を一つのアトミック操作とします。ただし、永続化実装のトランザクション API をドメイン層に漏らしません。アトミック性の意味は [`domain_rules.md`](./domain_rules.md) を正本とします。

## テスト

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
本仕様は、「SwiftData/Keychain の HOW をインメモリ・ストアで検証できる」ことのみを定めます。

## インメモリ・ストレージ

ユニットテスト/プレビューでは、インメモリ・ストレージを利用可能な構造とします。ドメイン・テストが SwiftData に依存しない構造を維持します。

SwiftData はテスト用途などでインメモリ・ストアを構成できるため、実ファイルに依存しないテスト環境を用意します。

(参考: [Preserving your app’s model data across launches | Apple Developer Documentation](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches))

* 本番: 永続化ストア
* テスト: インメモリ・ストア

## ストレージ失敗の処理

ストレージ・エラーは、アプリケーション・エラーに変換します。層の分類は [`architecture.md`](./architecture.md)、`ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とします。
本節は、「SwiftData エラー→ PersistenceError →アプリケーション・エラー→ UI エラー状態とし、SwiftData の具体エラータイプを UI に公開しない」ことのみを定めます。

## ログ記録

ストレージ・エラーは、必要に応じて、診断情報として記録します。ただし、Secret をログに含めません。禁止対象は [`security_spec.md`](./security_spec.md) を正本とします。

## パフォーマンス

ストレージ・アクセスは、必要最小限とします。

特に下記を避けます。統計チャートでは、必要な期間/指標のみをクエリーします。

* UI レンダリングごとのデータベース・クエリー
* 大量スナップショットの全件読込
* 不要な、フルテーブルスキャン
* MainActor 上での重い移行
* MainActor 上での大量データ変換

## 保持の方針

スナップショットの保持は [`storage_spec.md`](./storage_spec.md)、長期傾向の目的は [`statistics_spec.md`](./statistics_spec.md) を正本とします。
本仕様は、「iOS 実装が、独自に削除期限を決めない」ことのみを定めます。

## アプリケーションのライフサイクル

アプリケーションが下記の状態になっても、ストレージが破綻しないことを保証します。特にバックグラウンド移行時に、可能な限り、未保存データを安全にコミットします。

* 起動
* バックグラウンド
* フォアグラウンド
* 一時停止
* 終了
* 再起動

## バックグラウンド実行

バックグラウンド実行を、統計コレクションの保証手段として扱いません。

iOS/iPadOS のバックグラウンド実行は、実行時刻・実行時間が保証されないため、長期にわたる統計収集の必須条件を「アプリケーションを開いたままにする」とはしません。

GitHub トラフィックのスナップショットは、初期バージョンに含めます。取得は認証成功時に限ります。認証の設定の実装時期は [`use_cases.md` 優先順位-2](./use_cases.md#優先順位-2) の UC-17を正本とします。いつ取得するかは [`api-github.md` トラフィック・スナップショット・スケジュール](./api-github.md#トラフィックスナップショットスケジュール) を正本とします。

時計どおりの定期収集が必要になった場合は、外部スケジューラ/バックエンド等を別途検討します。

## アプリケーションの更新

アプリケーション・バージョンが更新されても、互換性のある永続化データは保持します。「アプリケーション v1→更新→アプリケーション v2」でも既存データを残します。必要な場合は、スキーマ移行します。

## アプリケーションのアンインストール

アプリケーションのアンインストール時に、アプリケーション・データが削除されることを前提とします。

ただし、Keychain アイテムの保持挙動等、プラットフォームの仕様に依存するものについては、アプリケーションが「アンインストール時に必ずクレデンシャル (資格情報) が消える」と仮定しません。

再インストール時には、既存クレデンシャルが存在する可能性を考慮して、認証状態を検証します。

## プライバシー

ローカル・ストレージに保存する情報は、必要最小限とします。

保存しないもの:

* Packagist パスワード
* GitHub パスワード
* 不要な、OAuth レスポンス
* 不要な、API レスポンス全体
* 不要な、個人情報
* 不要な、リクエスト/レスポンスのログ

## 信頼できる情報源 (SoT)

ストレージに関する責務は、下記のように分離します。

| 関心事 | SoT |
| --- | --- |
| ドメイン・モデル | [`models_spec.md`](./models_spec.md) |
| データモデル | [`models_spec.md`](./models_spec.md) |
| ドメイン不変性 | [`domain_rules.md`](./domain_rules.md) |
| キャッシュ | [`cache_spec.md`](./cache_spec.md) |
| 統計 | [`statistics_spec.md`](./statistics_spec.md) |
| クレデンシャル (資格情報) | [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) |
| iOS/iPadOS ストレージ | [`ios_spec.md`](./ios_spec.md) |
| プラットフォーム横断型ストレージ | [`kmp_spec.md`](./kmp_spec.md) |

## 受け入れ条件

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
永続化対象は [`storage_spec.md`](./storage_spec.md)、復元対象は [`application_state.md`](./application_state.md)、脅威/ログは [`security_spec.md`](./security_spec.md)、オフライン閲覧は [`cache_spec.md`](./cache_spec.md) / [`ui.md`](./ui.md) を正本とします。
本仕様は、下記の iOS HOW だけを判定します。

### アーキテクチャー

* [ ] UI がストレージ API を直接呼び出さない
* [ ] ドメイン・モデル/リポジトリ・インターフェースが SwiftData に依存しない

### 永続データ

* [ ] パッケージ/お気に入り/スナップショットを SwiftData に保存できる

### クレデンシャル (資格情報)

* [ ] クレデンシャルが Keychain に保存され、SwiftData に保存されない
* [ ] クレデンシャルを個別に削除できる
* [ ] Keychain アクセシビリティが適切に設定されている

### 移行

* [ ] スキーマ・バージョンが管理される
* [ ] 移行失敗時に、既存データを無条件に削除しない
