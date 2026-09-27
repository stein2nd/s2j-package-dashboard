# S2J Package Dashboard - Android ストレージ仕様

## 概要

本ドキュメントは、今後のターゲットである Android 版のストレージについて、利用の第一候補を定めます。時期は [`overview.md`](./overview.md) を正本とします。

Android UI は、Jetpack Compose とします。構造化された永続化ストレージについて、Room を利用の第一候補とします。本仕様は、その第一候補の置き方です。初期バージョンの実装ではありません。

本仕様の対象は、下記とします。

* ローカルの永続化ストレージ
* キャッシュ・ストレージ
* 統計スナップショット・ストレージ
* ユーザー設定 (Preference) ストレージ
* クレデンシャル (資格情報) ストレージ
* ストレージ移行
* データの削除
* バックアップ/復元
* Android ライフサイクルにおけるストレージ
* 将来の Kotlin Multiplatform (KMP) 共有ストレージへの移行可能性

実装時に、下記を確定します。

* Room スキーマ
* エンティティ/DAO
* 移行戦略
* DataStore タイプ
* DataStore スキーマ/Keys
* クレデンシャル (資格情報) 暗号化戦略
* Keystore のキー・エイリアス
* バックアップ・ルール
* スナップショット保持の方針

KMP 共有の永続化、クラウド同期、外部同期サービスは、必要性が明確になった時点で別途仕様化します。

本仕様は、Android のストレージ実装差分に限定します。方針の正本は、下記とします。

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

本仕様は、Android におけるストレージ実装差分を定義します。Room、DataStore、Keystore など、プラットフォーム固有の保存方法を対象とします。

## 非目的

本仕様では、下記を初期実装の必須要件としません。

* クラウド・ベースの同期
* 外部同期サーバー
* プラットフォーム横断型クレデンシャル (資格情報) 移行
* 独自暗号アルゴリズム
* 外部ストレージ
* バックグラウンド統計コレクションの保証
* Kotlin Multiplatform (KMP) 共有の永続化
* Android 固有の UI ストレージ・ロジック

## 責務

Android の永続化ストレージ、キャッシュ・ストレージ、スナップショット・ストレージ、ユーザー設定 (Preference)、クレデンシャル (資格情報) の実装差分を定義します。

## 非責務

方針の正本は、下記とします。

* 永続化 / スナップショット: [`storage_spec.md`](./storage_spec.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* 認証 / クレデンシャル (資格情報): [`authentication_spec.md`](./authentication_spec.md)
* 復元対象: [`application_state.md`](./application_state.md)
* 検証の種類: [`testing_spec.md`](./testing_spec.md)
* ドメイン型 / ルール / アーキテクチャー: [`models_spec.md`](./models_spec.md) / [`domain_rules.md`](./domain_rules.md) / [`architecture.md`](./architecture.md)

## 基本方針

Android ストレージは、下記の原則に従います。層の分離、クレデンシャル (資格情報) 分離、キャッシュと永続化の区別、スナップショットの不変条件は [`architecture.md`](./architecture.md) / [`authentication_spec.md`](./authentication_spec.md) / [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) / [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「その原則を、Room/DataStore/Keystore に載せる」ことを定めます。

1. UI が、ストレージ API を直接利用しない
2. リポジトリをストレージ境界とする
3. Room を、構造化された永続化ストレージの利用の第一候補とする
4. DataStore をユーザー設定 (Preference) / 小規模設定の第一候補とする
5. Android Keystore を暗号鍵の保護に利用する
6. クレデンシャル (資格情報) を平文で保存しない
7. Android 固有 API を、ドメイン層に侵入させない
8. 将来の Kotlin Multiplatform (KMP) 共有ロジック/共有ストレージへの移行を妨げない

Android の公式ストレージ・ガイドでも、構造化されたアプリケーション・データには Room、非公開な Key-Value 設定には DataStore 等を利用する構成が推奨されています。

(参考: [データ ストレージとファイル ストレージの概要 | App data and files | Android Developers](https://developer.android.com/training/data-storage?authuser=108))

## 永続化の第一候補

Android 版の開発に着手するとき、構造化データの利用の第一候補は Room です。ユーザー設定 (Preference) は DataStore、クレデンシャル (資格情報) は Keystore を第一候補とします。

層の依存方向は [`architecture.md`](./architecture.md) を正本とします。
本節は、「第一候補の構成が、Room にパッケージ/お気に入り/スナップショット、DataStore にユーザー設定 (Preference)、クレデンシャル (資格情報) ストアに Keystore + 暗号化されたストアを置く」ことのみを定めます。

## 今後の展開

将来的に、下記の要件が発生した場合、ストレージ・アーキテクチャーを拡張します。

共有対象は [`architecture.md`](./architecture.md)、Kotlin Multiplatform (KMP) の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本節は、「初期実装に先行して導入しない」ことのみを定めます。

これらを初期実装に先行して導入しません。

### Case-1: Android デバイス同期

Android デバイス A ↔同期サービス↔ Android デバイス B。

### Case-2: iOS/Android 同期

iOS →同期サービス/Android。

### Case-3: Kotlin Multiplatform (KMP) 共有の永続化

KMP リポジトリ→ iOS/Android。

## ストレージ・アーキテクチャー

基本的な依存関係は [`architecture.md`](./architecture.md) を正本とします。
本節は、「Android ストレージ層が Room / DataStore / キャッシュ / Keystore であり、UI がこれらを直接呼び出してはならない」ことのみを定めます。

## ストレージ・カテゴリー

下記は、Android でのストレージを分類したものです。各カテゴリーは、用途を明確に分離します。

| カテゴリー | 目的 | ストレージ |
| --- | --- | --- |
| 永続化データ | パッケージ/お気に入り、等 | Room |
| スナップショット | 統計履歴 | Room |
| キャッシュ | 一時的 API レスポンス | アプリケーション・キャッシュ/HTTP キャッシュ |
| ユーザー設定 (Preference) | ユーザー設定 | DataStore |
| クレデンシャル (資格情報) | API Token 等 | Keystore + 暗号化されたストレージ |
| 一時データ | 一時ファイル | キャッシュ/一時ストレージ |

## Room

### 基本方針

パッケージ、お気に入り、統計スナップショット等の構造化されたデータについて、Room を利用の第一候補とします。

Room は、SQLite の上に抽象化層を提供し、SQL クエリーのコンパイル時検証、ボイラープレートの削減、移行パスを提供します。Android 公式も、SQLite API を直接利用するより Room の利用を推奨しています。

(参考: [Room を使用してローカル データベースにデータを保存する | App data and files | Android Developers](https://developer.android.com/training/data-storage/room?hl=ja))

## Room アーキテクチャー

Room は、下記の構造とします。

リポジトリ→ DAO → Room データベース→ SQLite

アプリケーション層は、Room データベースや DAO に直接依存しません。経路は、下記とします。

アプリケーション→リポジトリ・インターフェース→ Room リポジトリ→ DAO

## ドメイン・モデルと Room エンティティ

Room エンティティをドメイン・モデルとして扱いません。ドメイン・モデルを Room エンティティにマッピングして SQLite に書きます。実際のエンティティ定義は [`models_spec.md`](./models_spec.md) に従って決定します。

たとえば:

```kotlin
data class Package(
    val id: PackageIdentifier,
    val name: String,
    val description: String?
)
```

永続化側:

```kotlin
@Entity
data class PackageEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String?
)
```

## リポジトリ境界

アプリケーション層から見えるのは、リポジトリ・インターフェースとします。

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

Android では、これを Room リポジトリが実装します。

`RoomPackageRepository` implements `PackageRepository` → DAO → Room。

## DAO

DAO は、永続化層の内部の API とします。

```kotlin
@Dao
interface PackageDao {
    // クエリー定義
}
```

DAO を ViewModel や Composable に直接公開しません。

DAO のクエリーは、永続化モデルを返し、リポジトリがドメイン・モデルに変換する構成を基本とします。

## パッケージ・ストレージ

パッケージのローカル表現は、Packagist API レスポンスの単純なコピーとして保存しません。フィールドは [`models_spec.md`](./models_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「API データ転送オブジェクト (DTO) をドメイン・モデル/Room エンティティに変換してから保存する」ことのみを定めます。

## お気に入りストレージ

お気に入りの不変条件は [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「Room 上で、パッケージと別エンティティにする」ことのみを定めます。

## 管理対象のパッケージ・ストレージ

管理対象とお気に入りの意味の区別は [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「Room 上で、両方を同時に持つことが可能」だけを定めます。

## 統計スナップショット・ストレージ

統計の長期履歴は、Room にスナップショットとして保存します。

行の形は [`storage_spec.md`](./storage_spec.md)、指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とします。
本節は、「パッケージに対して、複数のスナップショット行を Room に置く」ことのみを定めます。

## Room スナップショット書き込み

スナップショットの不変条件は [`domain_rules.md`](./domain_rules.md) を正本とします。
本節は、「新しい観測を、新しい Room 行として保存する」ことのみを定めます。

## DataStore

DataStore は、ユーザー設定 (Preference) および小規模なアプリケーション・システム設定 (Configuration) に利用します。

対象例:

* 選択された統計期間
* リフレッシュのユーザー設定 (Preference) 
* 外観のユーザー設定 (Preference)
* 初回起動フラグ
* ソート順序
* 表示のユーザー設定 (Preference)
* 最後に選択したパッケージの識別子

Android 公式では DataStore は、小規模なデータの保存に適しており、より大きく複雑なデータ、部分更新、参照整合性が必要な場合は Room を利用することが推奨されています。

(参考: [アプリ アーキテクチャー: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## DataStore と Room の境界

下記を原則とします。

* 小規模/システム設定 (Configuration) は、DataStore
* 構造化データ/リレーショナル・データは、Room

たとえば、下記のようになります。

* 統計期間は、DataStore
* お気に入りのパッケージ/パッケージのメタデータ/統計スナップショットは、Room。

ユーザー設定 (Preference) を Room に保存することを基本としません。逆に、パッケージ/スナップショット等を DataStore に JSON Blob として保存することも、基本としません。

## DataStore タイプ

DataStore は、用途に応じて、下記を選択します。

### ユーザー設定 (Preference) DataStore

単純な Key-Value が適している設定に使用します。

### Proto DataStore

型付きでスキーマ駆動な設定が必要になった場合に、使用します。

初期実装では、ユーザー設定 (Preference) DataStore を第一候補とし、設定の複雑化に応じて、Proto DataStore を検討します。

DataStore は 不変な型を扱うことが推奨され、`updateData` によるアトミック・読み込み-変更-書き込み (RMW) を提供します。

(参考: [アプリ アーキテクチャー: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## DataStore インスタンス

同一 DataStore ファイルに対して、複数の DataStore インスタンスを生成しません。

DataStore の公式ドキュメントでも、同一プロセス内で同じファイルに複数の DataStore を作成すると、`IllegalStateException` になるため、単一の DataStore インスタンスを共有する構成が求められています。

(参考: [アプリ アーキテクチャー: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

基本構成: アプリケーション→ Singleton DataStore → PreferencesRepository。

## DataStore アクセス

Composable が DataStore を直接利用してはなりません。

Composable → ViewModel → PreferencesRepository → DataStore。

DataStore の `Flow` はリポジトリから公開し、ViewModel が UI の状態に変換します。

Android 公式も、Compose から DataStore を直接利用せず、リポジトリ→ ViewModel → Compose というデータ層を推奨しています。

(参考: [アプリ アーキテクチャー: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## キャッシュ

キャッシュとスナップショットの区別、有効期間/鮮度は [`cache_spec.md`](./cache_spec.md) を正本とします。
本節は「Android のキャッシュ実装差分」のみを定義します。

## HTTP キャッシュ

HTTP レスポンスのキャッシュには、必要に応じて、HTTP クライアントのキャッシュ機構を利用します。

ただし、HTTP キャッシュをアプリケーション・データの永続化手段として扱いません。

* HTTP キャッシュは最適化
* Room はアプリケーション・データ。

区別は [`cache_spec.md`](./cache_spec.md) を正本とします。

## キャッシュ・エンティティとスナップショット・エンティティ

区別の意味は [`cache_spec.md`](./cache_spec.md) / [`storage_spec.md`](./storage_spec.md) を正本とします。
Android では、最新 API レスポンスと履歴スナップショットを同一エンティティに保存しません。

## クレデンシャル (資格情報) ストレージ

認証方針は [`authentication_spec.md`](./authentication_spec.md) を正本とします。
本節は「Android Keystore/セキュア保存の実装差分」を定義します。

何を保存するかは [`authentication_spec.md`](./authentication_spec.md) を正本とします。
本節は、「平文で永続化ストレージに保存してはならない」ことのみを定めます。

## Android Keystore

Android Keystore を暗号鍵の保護に利用します。

Android Keystore は、アプリケーションが使用する暗号鍵を長期的に安全に保持するためのフィクスチャであり、鍵素材へのアクセスを制限できます。Android のセキュリティ・ガイドでも、繰り返し利用する鍵は KeyStore 等のフィクスチャで保管することが推奨されています。

(参考: [セキュリティ ガイドライン | Security | Android Developers](https://developer.android.com/privacy-and-security/security-tips))

基本構成: クレデンシャル (資格情報) は、暗号化されたストレージに置き、暗号鍵は Android Keystore が保護

## クレデンシャル (資格情報) 暗号化

クレデンシャル本体は、Keystore に保存した暗号鍵を利用して暗号化し、その状態での保存を基本とします。

平文 Token →暗号化→暗号化された Token →内部ストレージ

暗号鍵: `Android Keystore` という分離を基本とします。

## クレデンシャル (資格情報) ストレージの保存場所

クレデンシャルの暗号化されたデータは、アプリケーション固有の内部ストレージ等に保存します。外部ストレージに、クレデンシャルを保存してはなりません。

Android の内部ストレージは、アプリケーションごとにサンドボックス化され、他アプリケーションから直接アクセスできません。Android v10以降では、内部ストレージも暗号化されています。

(参考: [アプリ固有のファイルにアクセスする | App data and files | Android Developers](https://developer.android.com/training/data-storage/app-specific))

## クレデンシャル (資格情報) リポジトリ

アプリケーション層は、Keystore/暗号化されたストレージの API を直接利用しません。

認証サービス→ `CredentialStore` → `AndroidCredentialStore` → Android Keystore/暗号化されたストレージ。

## クレデンシャル (資格情報) ライフサイクル

ライフサイクルの意味 (未認証→認証中→認証済み→有効期限切れ/取り消し済み) は [`authentication_spec.md`](./authentication_spec.md) を正本とします。
本節は「暗号化されたストレージ/Keystore 上の追加・更新・削除」に対応づけます。

ユーザーが切断/削除した場合は、暗号化クレデンシャルを削除します。

## クレデンシャル (資格情報) とアプリケーション・データの分離

クレデンシャルの削除は、アプリケーション・データの削除を意味しません。暗号化されたクレデンシャルを消しても、パッケージ/お気に入り/スナップショットは残します。アプリケーション・データの削除は、別操作とします。

## セキュリティ境界

Room に置いてはならないものは [`authentication_spec.md`](./authentication_spec.md) の禁止リストを正本とします。
本節は、「Room/DataStore/ログに書かないことの実装確認」です。

また、下記にも保存してはなりません。

* ログ
* アナリティクス
* URL クエリー
* クラッシュ・レポート
* スナップショット
* エラー・メッセージ

## 暗号化

独自暗号アルゴリズムを実装しません。

暗号化が必要な場合は、Android プラットフォーム/Jetpack/Google が提供する、既存の暗号 API を利用します。暗号化方式の具体値は、採用ライブラリの公式の推奨設定を優先します。

Android のセキュリティ・ガイドでも、独自の暗号プロトコルや暗号アルゴリズムを実装せず、既存の暗号実装を利用することが推奨されています。

(参考: [セキュリティ ガイドライン | Security | Android Developers](https://developer.android.com/privacy-and-security/security-tips))

## データ保護

原則として、アプリケーション固有のデータは、内部ストレージに保存します。外部ストレージを使用する場合は、共有を意図したデータに限定します。

Android 公式でも、他アプリケーションからアクセスさせる必要のない非公開データには、内部ストレージが推奨されています。

(参考: [アプリのセキュリティを強化する | Security | Android Developers](https://developer.android.com/privacy-and-security/security-best-practices))

## バックアップ/復元

Android では、下記のように、自動バックアップ/デバイス間データ転送の対象になるデータと、対象外にすべきデータを明確に区別します。

* バックアップ許可: 非機密の、ユーザー設定 (Preference) / ユーザーのアプリケーション・データ
* バックアップ除外: 暗号鍵 / 機密クレデンシャル (資格情報) / 一時キャッシュ

バックアップのプライバシーは [`security_spec.md`](./security_spec.md) を正本とします。
本節は「Android 自動バックアップの対象/除外を区別する」ことのみを定めます。

DataStore のファイルは、デフォルトで自動バックアップ/デバイス間データ転送の対象になり得るため、機密データを保存する DataStore と、一般設定用 DataStore を分離し、必要に応じて、バックアップ・ルールを設定します。

(参考: [アプリ アーキテクチャー: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## クレデンシャル (資格情報) バックアップ

クレデンシャルを、Android バックアップ/デバイス間データ転送にそのまま含めることを前提としません。

端末移行後は、必要に応じて、再認証します。旧デバイスのクレデンシャルを新デバイスに自動移送せず、新デバイスでは 再認証し とします。

プラットフォーム横断型クレデンシャル移行も、実装しません。

## iOS/iPadOS とのバックアップ方針の違い

iOS/iPadOS と Android のストレージ/バックアップ・メカニズムは、同一ではありません。

したがって、「iOS バックアップ≠ Android バックアップ」とします。各 HOW は [`ios_spec.md`](./ios_spec.md) / 本仕様を正本とします。

Kotlin Multiplatform (KMP) 共有ロジックは、両プラットフォームに共通化するが、バックアップ/復元はプラットフォーム固有の関心事として扱います。

## 並行処理

ストレージ・アクセスは、Kotlin コルーチンを利用し、UI スレッドをブロックしません。

基本構造: Compose → ViewModel → ユースケース → リポジトリ → Room / DataStore

層の依存方向は [`architecture.md`](./architecture.md) を正本とします。
本節は、「ストレージ操作を `Main` ディスパッチャに固定しない」ことのみを定めます。

DataStore は、コルーチン/フローを前提とした、非同期ストレージです。

(参考: [アプリ アーキテクチャー: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## フロー/StateFlow

永続化設定や観測可能なデータは、フローを利用して変更を伝播できる構造とします。

Room/DataStore →フロー→リポジトリ→ ViewModel → StateFlow → Compose

Compose は、ストレージ層に直接接続しません。

## プラットフォーム横断型ストレージ

iOS/iPadOS と Android で同じ永続化フレームワークを使用することを必須としません。将来、KMP 共有ストレージを採用する場合は、SQLDelight 等を候補として別途評価します。

共有対象は [`architecture.md`](./architecture.md)、Kotlin Multiplatform (KMP) の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本節は、「共有リポジトリ・インターフェースの iOS 実装が SwiftData、Android 実装の利用の第一候補が Room である」ことのみを定めます。この構成を、初期バージョンの実装にはしません。

## SQLDelight に関する方針

将来的に、Kotlin Multiplatform (KMP) 共有ストレージを採用する場合、SQLDelight 等を候補とします。

ただし、Room を利用の第一候補としたこと自体を、失敗とみなしません。

ストレージ・フレームワークの共有よりも、下記の共有を優先します。

* ドメイン・モデル
* リポジトリ・インターフェース
* ユースケース
* マッピング・ルール
* ストレージ・セマンティクス

## ストレージ移行

Room スキーマ・バージョンを管理します。移行は、アプリケーション・バージョンと独立して管理可能な構造とします。

Room スキーマ v1→ v2→ v3。

行の互換は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は「Room のスキーマ・バージョンを独立管理する」ことのみを定めます。

## 移行ルール

移行では、下記を保証します。

* パッケージ・データを、可能な限り、保持する
* お気に入りを失わない
* スナップショット履歴を失わない
* クレデンシャル (資格情報) を 移行データに含めない
* 移行失敗を検知できる
* 移行後のスキーマ・バージョンを正しく更新する

## 移行失敗

移行に失敗した場合、既存データを無条件に削除してはなりません。移行の破壊的なフォールバックは、明示的な仕様なしに実装しません。

移行失敗→既存データの保持→エラー/リカバリー

## DataStore 破損

DataStore のファイル破損を想定します。

必要に応じて、DataStore の破損ハンドラを利用し、復元可能な設定については、初期値に復旧できる構造とします。

ただし、ユーザーが明示的に保存した重要なアプリケーション・データを DataStore に入れません。

DataStore は、破損ハンドラを提供しており、破損したファイルを定義済みのデフォルト値に置き換える構成が可能です。

(参考: [アプリ アーキテクチャー: データレイヤー - DataStore - デベロッパー向け Android | App architecture | Android Developers](https://developer.android.com/topic/libraries/architecture/datastore))

## ストレージの削除

削除対象の意味は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「キャッシュ / 統計スナップショット / ローカルのパッケージ・データ / お気に入り / クレデンシャル (資格情報) を Android 設定から個別削除でき、クレデンシャルとアプリケーション・データの削除を暗黙に結合しない」ことのみを定めます。

## キャッシュの削除

キャッシュは再取得可能であるため、削除してもアプリケーション状態を失いません。

有効期間は [`cache_spec.md`](./cache_spec.md) を正本とします。
本節は、「キャッシュの削除→キャッシュ空→次リクエストで、プロバイダからフェッチする」ことのみを定めます。

## スナップショットの削除

スナップショットは、履歴データとして扱います。

削除方針は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「削除後のチャートが残存データのみを出し、プロバイダから過去スナップショットを復元できるとは限らない」ことのみを定めます。

## 外部ストレージ

ユーザーがエクスポート/インポートを要求する場合のみ、Android の標準的なドキュメント/共有 UI を利用します。

初期実装では、外部/共有ストレージは、下記の理由から、使用しません。

1. S2J Package Dashboard の基本データは、アプリケーション専用である
2. パッケージ・データを、他アプリケーションと共有する必要がない
3. クレデンシャル (資格情報) を、共有ストレージに置く必要がない
4. Android ストレージ権限の複雑化を避けられる

## エクスポート/インポート

将来的に、統計/パッケージ・データのエクスポートを実装する場合は、アプリケーション固有のストレージとエクスポート・ファイルを明確に分離します。エクスポート・ファイルにクレデンシャル (資格情報) を含めません。

内部ストレージ→エクスポート→ユーザー選択ファイル

## クエリー戦略

Room クエリーは、用途に応じて、下記のように必要なデータのみ取得します。全パッケージ/全スナップショットを、一度にメモリに読み込みません。

* ダッシュボード: 概要クエリー
* 統計: 期間固有のスナップショット・クエリー。

## ストレージのリセット

完全なローカルデータ・リセットを提供する場合、Room データ/キャッシュ/スナップショット/ユーザー設定 (Preference) を対象とします。

リセットの意味は [`storage_spec.md`](./storage_spec.md) を正本とします。
本節は、「ストレージのリセット≠クレデンシャル (資格情報) リセットである」ことのみを定めます。

## オフラインの挙動

ローカル永続化データが存在する場合、ネットワークが利用できなくても、可能な範囲で、下記を提供します。

* パッケージリスト
* お気に入りリスト
* パッケージ詳細
* 最後に確認された統計
* 履歴スナップショット・チャート
* 設定

最新情報を取得できない場合は、下記を明示します。

```text
オフライン
最終更新: ...
```

## ストレージの鮮度

永続化データには、可能な限り、取得時刻を保存します。

例:

`lastFetchedAt`

* スナップショット: `collectedAt`
* キャッシュ: `cachedAt`、`expiresAt`

## ストレージ・ソース

プロバイダ由来のデータには、出典を識別可能な形で保持します。同じ指標名でもプロバイダによって意味が異なる可能性があるため、プロバイダ情報を省略しません。

例:

* `source = Packagist`
* `source = GitHub`

## ストレージの一貫性

アプリケーション状態と永続化の状態の整合性を維持します。

たとえば、お気に入り追加の場合: ユーザー・アクション→検証→お気に入りの保存→アプリケーション状態の更新

永続化が失敗した場合、成功したように UI を更新してはなりません。

## トランザクション境界

複数の永続化操作が一つのドメイン操作を構成する場合、可能な限り、トランザクション/アトミック操作として扱います。

たとえば、お気に入り追加は、「お気に入りの作成」「パッケージ参照の更新」を一つのアトミック操作とします。Room のトランザクション API 等を利用する場合でも、トランザクションの具体 API をドメイン層に漏らしません。アトミック性の意味は [`domain_rules.md`](./domain_rules.md) を正本とします。

## テスト

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
本仕様は、「Room/DataStore/Keystore の HOW をインメモリ・ストアで検証できる」ことのみを定めます。

## インメモリ・ストレージ

ユニットテスト/UI テスト/プレビューでは、インメモリ・データベースを利用できる構造とします。ドメイン・テストは、Room に依存しません。

* 本番: Room 永続化データベース
* テスト: Room インメモリ・データベース

## ストレージ失敗の処理

Android 固有のストレージ・エラーは、アプリケーション・エラーに変換します。

層の分類は [`architecture.md`](./architecture.md)、`ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とします。
本節は、「Room/DataStore エラー→ PersistenceError →アプリケーション・エラー→ UI エラー状態とし、具体例外を UI に直接公開しない」ことのみを定めます。

## セキュリティ・ログ記録

必要に応じて、ストレージ・エラーは、診断情報として記録します。ただし、Secret をログに含めません。

禁止対象は [`security_spec.md`](./security_spec.md) を正本とします。

* クレデンシャル (資格情報)
* 完全な API リクエスト
* 個人情報

## パフォーマンス

下記を避けます。統計チャートでは、必要な期間/指標のみクエリーします。

* Compose レンダリングごとの、データベース・クエリー
* スナップショット全件の、無条件読込
* 不要な、フルテーブルスキャン
* メイン・スレッド 上での重い移行
* メイン・スレッド 上での大量データ変換
* DataStore の、頻繁な同期読み取り

## 保持の方針

スナップショットの保持は [`storage_spec.md`](./storage_spec.md)、長期傾向の目的は [`statistics_spec.md`](./statistics_spec.md) を正本とします。
本仕様は、「Android 実装が、独自に削除期限を決めない」ことのみを定めます。

## アプリケーションのライフサイクル

ストレージは、下記のライフサイクル変更に耐えられること。

* 起動
* フォアグラウンド
* バックグラウンド
* 停止
* プロセスの終了
* 再起動

Android では、プロセスの終了を前提とし、一時的な UI の状態を永続化ストレージに保存することと、アプリケーション・データの保存を区別します。

## バックグラウンド実行

バックグラウンド実行を、統計コレクションの保証手段としません。

Android でもバックグラウンド実行は、実行時刻や実行時間を無条件に保証するものではありません。したがって、「アプリケーションを開いたままにする」を長期にわたる統計収集の必須条件としません。

GitHub トラフィックのスナップショットは、初期バージョンに含めます。取得は認証成功時に限ります。認証の設定の実装時期は [`use_cases.md` 優先順位-2](./use_cases.md#優先順位-2) の UC-17を正本とします。いつ取得するかは [`api-github.md` トラフィック・スナップショット・スケジュール](./api-github.md#トラフィックスナップショットスケジュール) を正本とします。

時計どおりの定期収集が必要になった場合は、下記を別途検討します。

* WorkManager
* 外部スケジューラ
* バックエンド

## 一時ファイル

一時ファイルは、アプリケーション・キャッシュ/一時ディレクトリに保存します。

一時ファイルを、永続化データ として扱いません。

必要なくなった一時ファイルは、削除します。

## Kotlin Multiplatform (KMP) 境界

Android ストレージは、KMP 共有ロジックの実装詳細として扱います。Android 固有の API が共有ロジックに侵入してはなりません。

配置は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本節は、「共有ロジックに、ドメイン / アプリケーション / リポジトリ・インターフェース / 統計ロジックを置き、androidMain に Room / DataStore / Keystore を置く」ことのみを定めます。

## バックアップ 境界

バックアップ対象は、下記を原則とします。

潜在的にバックアップ可能: ユーザー設定 (Preference) / お気に入り / パッケージ・メタデータ / 履歴スナップショット

必要に応じて、機密データ/再構築可能データは、除外します。特に、クレデンシャル (資格情報) と暗号鍵は、アプリケーション・データ・バックアップから独立させます。

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
| Android ストレージ | [`android_spec.md`](./android_spec.md) |
| プラットフォーム横断型ストレージ | [`kmp_spec.md`](./kmp_spec.md) |

## 受け入れ条件

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
永続化対象は [`storage_spec.md`](./storage_spec.md)、復元対象は [`application_state.md`](./application_state.md)、脅威/ログは [`security_spec.md`](./security_spec.md)、オフライン閲覧は [`cache_spec.md`](./cache_spec.md) / [`ui.md`](./ui.md) を正本とします。
本仕様は、下記の Android HOW だけを判定します。

### アーキテクチャー

* [ ] UI が Room/DataStore/Keystore を直接呼び出さない
* [ ] ドメイン・モデル/リポジトリ・インターフェースが Room に依存しない

### 永続データ

* [ ] パッケージ/お気に入り/スナップショットを Room に保存できる

### ユーザー設定 (Preference)

* [ ] ユーザー設定 (Preference) を DataStore に保存できる
* [ ] 同一 DataStore ファイルに複数インスタンスを生成しない

### クレデンシャル (資格情報)

* [ ] クレデンシャルが平文で保存されず、Room に保存されない
* [ ] 暗号鍵が Android Keystore で管理される
* [ ] クレデンシャルを個別に削除できる

### 移行

* [ ] Room スキーマ・バージョンが管理される
* [ ] 移行失敗時に、既存データを無条件に削除しない
* [ ] DataStore 破損を適切に扱える

### バックアップ

* [ ] バックアップ対象が明示されている
* [ ] クレデンシャル (資格情報) を、通常のバックアップ・データとして扱わない
