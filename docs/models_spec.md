# S2J Package Dashboard - モデル定義仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、モデルの構造、層境界および責務を定義します。ドメイン型の正本であり、外部データ転送オブジェクト (DTO)、永続化モデル、UI モデルとの境界も本仕様で定義します。

実装、Packagist API/GitHub API の検証、Kotlin Multiplatform (KMP) への移植検証等により変更される可能性があります。

モデル構造に重大な変更を加える場合は、アーキテクチャーおよび永続性への影響を確認し、必要に応じて、ADR (アーキテクチャー決定記録) を作成します。

統計指標の意味、収集方針および可視化は、[`statistics_spec.md`](./statistics_spec.md) を正本とします。
本仕様では、統計の型とスキーマのみを定義します。

外部 API のレスポンス・スキーマは、下記を正本とします。

* [`api-packagist.md`](./api-packagist.md)
* [`api-github.md`](./api-github.md)

## 目的

本ドキュメントでは、S2J Package Dashboard で使用するドメイン・モデル、値オブジェクト、Enum、モデル間の関係、および外部/永続化/UI モデルとの層境界を定義します。ドメイン型の正本です。

モデルは、下記のデータソースから取得した情報を統合して、表現します。

* Packagist API
* GitHub API
* ローカル・ストレージ
* ユーザーデータ

## 非目的

本仕様は、画面設計、API エンドポイント、認証フロー、データベース・エンジン選択、チャートのレンダリング、ネットワーク・クライアント実装を目的としません。

## 責務

ドメイン型、値オブジェクト、層境界 (外部データ転送オブジェクト (DTO) ≠ドメイン≠永続化≠ UI)、統計の型とスキーマを定義します。

## 非責務

* 統計指標の意味、収集方針、可視化: [`statistics_spec.md`](./statistics_spec.md)
* 正しさのルール: [`domain_rules.md`](./domain_rules.md)
* 永続スキーマ / 移行: [`storage_spec.md`](./storage_spec.md)
* 外部 API レスポンス・スキーマ: [`api-packagist.md`](./api-packagist.md) / [`api-github.md`](./api-github.md)
* キャッシュ方針: [`cache_spec.md`](./cache_spec.md)
* クレデンシャル (資格情報) ストレージ: [`authentication_spec.md`](./authentication_spec.md)
* 共有対象 / プラットフォーム固有: [`architecture.md`](./architecture.md)
* Kotlin Multiplatform (KMP) の HOW: [`kmp_spec.md`](./kmp_spec.md)

## モデル設計原則

モデル設計では、下記を基本原則とします。

1. 「ドメイン」ファースト

   * 外部 API のデータ構造ではなく、本アプリケーションのドメインを基準として、モデルを定義する。

2. 値指向

   * ドメイン・モデルは、値として扱う。

3. 不変

   * 原則として、ドメイン・モデルの値は、不変とする。

4. ソースの独立性

   * Packagist API/GitHub API 固有の JSON 構造を、ドメイン・モデルに持ち込まない。

5. プラットフォームの独立性

   * SwiftUI、UIKit、Jetpack Compose、Android フレームワーク等に依存しない。

6. Kotlin Multiplatform (KMP) 移植性

   * 将来 KMP に移植可能な構造とする。

7. 明示的なセマンティクス

   * `String` や `Int` だけで表現せず、意味の異なる値は、可能な限り、専用の値オブジェクトで表現する。

8. UI の状態なし

   * ロード中/エラー/選択等の UI の状態をドメイン・モデルに含めない。

## モデル・カテゴリー

本アプリケーションのモデルは、下記のカテゴリーに分類します。API データ転送オブジェクト (DTO)、永続性モデル、UI モデルは、別カテゴリーとして扱います。

* ドメイン・モデル
   * `Package`
   * `PackageVersion`
   * `Dependency`
   * `Repository`
   * `Release`
   * `Statistics`
* 値オブジェクト
   * `PackageName`
   * `Version`
   * `RepositoryIdentifier`
   * `RepositoryURL`
   * `PackageURL`
   * `StatisticsPeriod`
* ユーザー・モデル
   * お気に入り
   * アカウント
* 認証モデル
   * `PackagistCredential`
   * `GitHubCredential`
* 統計モデル
   * `Statistic`
   * `StatisticPoint`
   * `DownloadStatistics`
   * `RepositoryStatistics`

## モデル層

モデルを下記の層に分類します。各層は同一の型として扱いません。

* 外部データモデル
   * Packagist DTO、GitHub DTO
* ドメイン・モデル
   * パッケージ、バージョン、リポジトリ、統計
* 永続化モデル
   * `PackageRecord`、`StatisticsSnapshotRecord`、`FavoriteRecord`
* UI モデル
   * `PackageListItem`、`PackageDetail`、`StatisticsChartData`

型の例は、[モデル・カテゴリー](#モデルカテゴリー) を正本とします。
外部 API のレスポンスを、そのままアプリケーション全体のモデルとして使用しません。

## パッケージ

### 概要

`Package` は、Composer/Packagist 上のパッケージを表現する主要ドメイン・モデルです。

パッケージは、本アプリケーションにおける中心的な「集約ルート」とします。アイデンティティ、メタデータ、バージョン、依存関係、リポジトリ、統計を持ちます。

### アイデンティティ (ID)

パッケージを一意に識別します。

* `PackageName`

Composer パッケージ名は、下記のような `vendor/package` 形式を基本とします。

* `stein2nd/docs-linter`
* `symfony/console`
* `composer/composer`

### パッケージ・プロパティ

実際の Swift 型定義では、任意性およびコレクション型を API 仕様に合わせて確定します。

初期実装では、`PackageID` は正規化した Packagist パッケージ名とします。将来、複数レジストリを扱う場合は、`registry` と `name` からなる複合 ID に拡張可能とします。

下記は、概念モデルです。

```swift
struct Package {
    let id: PackageID
    let name: PackageName
    let description: String?
    let type: PackageType?
    let homepage: URL?
    let repository: RepositoryReference?
    let license: [License]
    let authors: [Author]
    let maintainers: [Maintainer]
    let keywords: [String]
    let versions: [PackageVersion]
    let abandoned: AbandonedStatus?
    let statistics: PackageStatistics?
}
```

### パッケージ・タイプ `PackageType`

下記のように、Composer パッケージのタイプを、表現します。未知のタイプを受信した場合には、データを破棄しません。将来追加されるタイプを考慮し、不明値を表現可能とします。

* `library`
* `project`
* `metapackage`
* `composer-plugin`
* `composer-installer`

## パッケージ名 `PackageName`

### 概要

`PackageName` は、Composer パッケージの完全修飾名を表現する、値オブジェクトです。

* 形式: `vendor/package`

### プロパティ

* `vendor`
* `package`
* `fullName`

たとえば、下記のように、表現します。

* vendor: `stein2nd`
* package: `docs-linter`
* fullName: `stein2nd/docs-linter`

### 検証

Composer のパッケージ名仕様を、正本とします。下記を満たさない値は、ドメイン上の有効な `PackageName` として扱いません。

* `/` を区切り文字として使用する
* `vendor` 部分が存在する
* `package` 部分が存在する
* 空文字列ではない

## リポジトリ `RepositoryReference`

### 概要

`Repository` は、パッケージに関連付けられたソース・リポジトリを表現します。

初期実装では、GitHub を主要なリポジトリ・プロバイダとします。ただし、ドメイン・モデルは、GitHub 固有の構造に依存しません。

* プロバイダ `RepositoryProvider`
* 所有者
* 名称
* URL
* デフォルト・ブランチ
* 統計 `RepositoryStatistics`

### RepositoryProvider

下記のようなリポジトリの「提供元」を表現します。GitHub 以外のプロバイダを将来追加できるようにします。

* GitHub
* GitLab
* Bitbucket
* その他
* 不明

### RepositoryIdentifier

リポジトリを一意に識別する値オブジェクトです。内部識別子として利用する形式は、別途確定します。

形式: `owner/repository`

* GitHub の場合:
   * 例: `stein2nd/s2j-package-dashboard`
   * プロバイダを含める場合: `github:stein2nd/s2j-package-dashboard`

### RepositoryStatistics

リポジトリに関連する統計情報を、表現します。GitHub API から取得した値であることを明示可能とします。

* `stars`
* `forks`
* `watchers`
* `openIssues`
* `openPullRequests`
* `contributors`
* `commits`

## ライセンス `License`

下記のように、パッケージの「ライセンス」を、表現します。未知のライセンス識別子を保持可能とします。

* `MIT`
* `GPL-2.0-or-later`
* `Apache-2.0`
* `BSD-3-Clause`

* `identifier`
* `displayName`

## 作者 `Author`

パッケージの「作者」を表現します。メールアドレス等の個人情報を、不要な範囲で UI に表示しません。

* `name`
* `email?`
* `homepage?`

## メンテナー `Maintainer`

パッケージの「メンテナー」を表現します。Packagist 上のメンテナー情報と GitHub 貢献者情報を、同一人物として自動的に統合しません。ID 照合は、別途定義します。

* `name`
* `username?`
* `avatarURL?`

## パッケージバージョン `PackageVersion`

### 概要

`PackageVersion` は、パッケージの特定バージョンを表現します。パッケージは `PackageVersion` を持ちます。

### プロパティ

* `version`
* `normalizedVersion`
* `stability`
* `releaseDate`
* `source`
* `dist`
* `requires`
* `requiresDev`
* `suggests`
* `conflicts`
* `replaces`
* `provides`

### バージョン `version`

`version` は、文字列として保持するだけではなく、比較可能な値として扱います。ただし、外部サービスから取得した原表記を失いません。

必要に応じて、下記を分離します。

* `rawVersion`
* `normalizedVersion`

### バージョン安定性 `stability`

下記のように、バージョンの安定性を表現します。バージョン文字列から機械的に判定できない場合は、外部データの値を優先します。

* `Stable`
* `RC`
* `Beta`
* `Alpha`
* `Dev`
* `Unknown`

## 放棄状態 `AbandonedStatus`

放棄状態は Boolean ではなく、Replacement パッケージを表現できる構造とします。Packagist API では `abandoned` が `false`、`true`、または推奨 Replacement を示す値になり得るため、単純な Boolean に縮退しません。

(参考: [Packagist.org](https://packagist.org/apidoc))

* `active`
* `abandoned`
* `replacement` (`PackageReference`)

## 依存関係 `Dependency`

### 概要

`Dependency` は、パッケージが他のパッケージ等に持つ「依存関係」を表現します。

### 依存関係タイプ

Composer パッケージの「依存関係タイプ」を区別します。

* `Require`
* `RequireDev`
* `Suggest`
* `Conflict`
* `Replace`
* `Provide`

### プロパティ

* `packageName`
* `constraint`
* `type`
* `description?`

例:

* `packageName`: `symfony/console`
* `constraint`: `^7.0`
* `type`: `require`

### バージョン制約 `constraint`

下記のように、「バージョン制約」は、文字列として保持しつつ、将来の比較・解析を可能とします。API の原表記を保持します。バージョン制約の解釈ロジックは、ドメイン・ロジックとして実装します。

* `^7.0`
* `>=8.1`
* `~2.4`
* `*`
* `dev-main`

## リリース `Release`

GitHub リポジトリ等における「リリース」を表現します。

Packagist バージョンと GitHub リリースは、別モデルとして扱います。両者が同じバージョンを表す場合でも、同一オブジェクトとして扱うことを前提としません。

* `tagName`
* `name`
* `publishedAt`
* `prerelease`
* `draft`
* `url`

## パッケージ/リポジトリ間の関係

パッケージはリポジトリをソースとして参照します (パッケージ≠リポジトリ)。1つのリポジトリから、複数のパッケージが公開される可能性を考慮します。

## 統計 `Statistics`

統計の型とスキーマは本仕様で定義します。指標の意味、収集方針、プロバイダ差および可視化は、[`statistics_spec.md`](./statistics_spec.md) を正本とします。正しさのルールは、[`domain_rules.md`](./domain_rules.md) を正本とします。

### 概要

`Statistics` は、パッケージまたはリポジトリについて取得した「統計情報」を表現します。統計情報は、単一値ではなく、可能な場合は時系列データとして扱います。

### 統計

* `metric`
* `value`
* `unit`
* `source`
* `timestamp`

### 統計の「指標」

指標識別子は Enum 等の型ケースとして表現します。将来追加される指標を保持可能な設計とします。ケース集合の意味は [`statistics_spec.md` Packagist 指標](./statistics_spec.md#packagist-指標) / [`statistics_spec.md` GitHub 指標](./statistics_spec.md#github-指標) を正本とします。
本仕様は、「識別子を型ケースとして保持可能」だけを定めます。

加えて `Watchers` / `OpenPullRequests` を型として保持可能とします。

### 統計の「出典」

下記のように、統計データの「取得元」を表現します。`Calculated` は、本アプリケーションが算出した「派生」指標を表します。

* Packagist
* GitHub
* Calculated
* 不明

### 統計の「期間」

統計データの「期間」を表現します。

* 日
* 週
* 月
* 年
* 合計
* カスタム

たとえば、下記のように使用します。

```text
ダウンロード数
期間: Month
```

### 統計の点 `StatisticPoint`

* `timestamp`
* `value`

下記のように、「時系列チャートを構成する1点」を表現します。

* `2026-08-01 → 124`
* `2026-08-02 → 137`
* `2026-08-03 → 142`

### ダウンロード統計 `DownloadStatistics`

Packagist ダウンロードの期間 (累積/日次/月次) の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とします。
本仕様は、「それらを `DownloadStatistics` 型として保持できる」「履歴はスナップショットから生成する」ことのみを定めます。

* `total`
* `daily`
* `monthly`
* `history`

### リポジトリ活動 `RepositoryActivity`

GitHub 活動指標の意味は [`statistics_spec.md`](./statistics_spec.md) を正本とします。
本仕様は、「`RepositoryActivity` が下記フィールドを保持できる」「現在値と時系列を、型として区別する」ことのみを定めます。

* `commits`
* `contributors`
* `issues`
* `pullRequests`
* `releases`

### パッケージ・ヘルス `PackageHealth`

派生であることは [`statistics_spec.md`](./statistics_spec.md) を正本とします。
本仕様は、「`PackageHealth` 型のフィールド」だけを定めます。

* `score`
* `usage`
* `maintenance`
* `community`
* `releaseActivity`

## マイ・パッケージ `MyPackage`

`MyPackage` は、ユーザーが Packagist 上でメンテナンスするパッケージへの「参照」を表現します。

`MyPackage` は、ユーザーが手動登録するデータではなく、Packagist アカウントから取得した結果として生成されます。実装時期は [`use_cases.md` 優先順位-1](./use_cases.md#優先順位-1) の UC-02を正本とします。認証の設定は UC-16を正本とします。

* `packageName`
* `accountReference`

## お気に入り `Favorite`

`Favorite` は、ユーザーが任意に登録したパッケージを表現するユーザー・モデル「お気に入り」です。

原則として、「お気に入り」は、パッケージ自体を複製して保持するのではなく、`PackageName` 等のアイデンティティ (ID) 参照を保持します。

* `packageName`
* `addedAt`
* `updatedAt`

## アカウント `Account`

`Account` は、外部サービス上の「ユーザー・アカウント」を表現します。クレデンシャル (資格情報) 自体を「アカウント」モデルに含めません。

* `provider`
* `identifier`
* `displayName?`

## `AccountProvider`

将来のプロバイダ追加を妨げません。

* Packagist
* GitHub

## クレデンシャル (資格情報) `Credential`

`Credential` は、Secret データとして扱います。ドメイン・モデルとして、通常のアプリケーション・データと同じ永続化対象にしてはなりません。実際の Secret 値は、「セキュア・ストレージ・アダプタ」で管理します。

* `provider`
* `reference`

### Packagist クレデンシャル (資格情報) `PackagistCredential`

Packagist API Token を表現します。

Token の実体を、ドメイン・モデルに直接保持するか否かは、セキュリティ仕様で決定します。パスワードをクレデンシャル (資格情報) として保存する設計は、採用しません。

* `username`
* `tokenReference`
* `tokenType`

### GitHub クレデンシャル (資格情報) `GitHubCredential`

GitHub OAuth/Token 等の認証状態を表現します。

Secret 自体を通常のドメイン・モデルとして扱いません。

* `account`
* `tokenReference`
* `scopes?`

## キャッシュ済みパッケージ

キャッシュ方針は [`cache_spec.md`](./cache_spec.md) を正本とします。
本仕様は、「ドメイン・モデルとキャッシュ・モデルを分離し、`PackageCache` が `cachedAt` / `expiresAt` / `source` / `schemaVersion` を持つ」「キャッシュと統計スナップショットを同一エンティティにしない」「クレデンシャル (資格情報) をキャッシュ・キーに含めない」ことのみを定めます。

## 統計のスナップショット `StatisticsSnapshot`

長期統計を保存するため、「取得時点の統計情報」をスナップショットとして保持します。

スナップショットは、「外部 API が現在提供する履歴」ではなく、**本アプリケーションが取得・保存した時点の観測値** です。

* `packageName`
* `repositoryIdentifier?`
* `capturedAt`
* `packagist`
* `github`
* `schemaVersion`

スナップショットは パッケージ集約に内包せず、独立した統計集約とします。件数が増え、保存期間とライフサイクルが パッケージ の現在値と異なるためです。

目的および保持期間の意味は、[`statistics_spec.md`](./statistics_spec.md) および [`storage_spec.md`](./storage_spec.md) を参照します。

### スナップショットのアイデンティティ (ID)

スナップショットは、`Package + Captured At` を基本的な「識別要素」とします。同一時刻に複数のソースから取得する場合、ソースも「識別情報」に含めます。

## モデル間の「関係」

下記は、主要な「関係」を示したものです。

* アカウントがパッケージを管理する
* お気に入り → パッケージ
* パッケージ → バージョン / 依存関係 / リポジトリ
* リポジトリ → GitHub リポジトリ → リリース / 統計 / 履歴

## 集合境界

パッケージを、主要「集合ルート」とします。

一方、リポジトリは、独立した「集合」として扱います。

パッケージ集約は `PackageVersion` / 依存関係 / メタデータ。リポジトリ集約は `Release` / `RepositoryStatistics` / `RepositoryActivity`。パッケージとリポジトリは、「参照」によって関連付けます。

## アイデンティティ (ID) 戦略

各モデルについて、アイデンティティ (ID) と値を明確に区別します。

### エンティティ

アイデンティティ (ID) を持ちます。

* パッケージ
* リポジトリ
* アカウント
* お気に入り

### 値オブジェクト

値自体がアイデンティティ (ID) となります。

* `PackageName`
* `Version`
* `VersionConstraint`
* `RepositoryIdentifier`
* `License`
* `StatisticPoint`

## エンティティ vs リファレンス

エンティティは、自身が管理する ID とライフサイクルを持ちます。リファレンスは、他エンティティを指すだけです。集約間ではエンティティ自体ではなくリファレンスを使用します。

* `PackageReference` — `packageID`、必要なら表示用の `name`
* `RepositoryReference` — `provider`、`owner`、`name`
* `CredentialReference` — 非 Secret の `provider` と `identifier`。実クレデンシャル (資格情報) は [`authentication_spec.md`](./authentication_spec.md) の Secure ストレージ境界に置きます

お気に入りや依存関係では、完全な `Package` を埋め込みません。

## 任意性

外部 API から取得できない情報を、無理に空文字列や0に変換しません。たとえば、`null` と0は、意味が異なります。下記を基本とします。

* `null`: 値が存在しない/取得できない
* 0: 値が存在し、値が0

## 不明値

外部 API の Enum 等に未知の値が追加された場合、既存アプリケーションがクラッシュしてはなりません。たとえば、下記のように、「フォールバック」を、必要に応じて、提供します。

* VersionStability.Unknown
* RepositoryProvider.Unknown
* StatisticsSource.Unknown

## API データ転送オブジェクト (DTO) との分離

Packagist API/GitHub API のレスポンスを、直接ドメイン・モデルとして使用しません。API のスキーマ変更によるドメイン・モデルへの影響を最小化します。

例:

* `PackagistPackageDTO`
* `GitHubRepositoryDTO`
* `GitHubTrafficDTO`

* Packagist JSON → DTO →マッパー→パッケージ。
* GitHub JSON → DTO →マッパー→リポジトリ。

ドメインから外部 DTO に依存しません。永続化用のシリアライズ形式も、外部 API スキーマとは独立させます。Packagist レスポンスをそのままローカル・データベースに保存しません。

## 永続性モデルとの分離

ローカル・ストレージ用モデルをドメイン・モデルと同一にしません。

* ドメイン・モデル⟷マッパー⟷永続性モデル → データベース

例:

* `Package` → `PackageRecord`
* `StatisticsSnapshot` → `StatisticsSnapshotRecord`
* `Favorite` → `FavoriteRecord`

永続性モデルには、下記のような、「ドメイン・モデルには不要な情報」を持たせてかまいません。

* 主キー
* 外部キー
* キャッシュ・メタデータ
* 移行メタデータ
* `schemaVersion`

ドメイン・モデルに永続化フレームワークのアノテーション (`@Model`、`@Entity`、`@Table`、`@Column` 等) を付与しません。プライマリ ID (`PackageID`、`StatisticsSnapshotID`、`FavoriteID` 等) は永続化後に意図せず変更しません。

リファレンス先が存在しない場合を許容します。お気に入り先のパッケージが リモート から消えても、お気に入りレコードをただちに破棄しません。統計スナップショットは、パッケージが リモート から消えても履歴として保持可能とします。

## UI モデルとの分離

UI 表示用モデルをドメイン・モデルと同一にしません。たとえば、`Package` と下記は、別概念として扱います。

* `PackageListItem`
* `PackageDetailState`
* `StatisticsChartData`

UI モデルは、プレゼンテーション層に配置します。

## 日付/時刻

ドメインでは、日時を「絶対時刻」として扱います。

API から取得した日時は、可能な限り、UTC 基準で保持します。表示時に、ユーザーのロケール/タイムゾーンに変換します。

## URL

URL は、単なる文字列として扱わず、可能な範囲で、URL 型または移植可能な値オブジェクトとして扱います。

例:

* `PackageURL`
* `RepositoryURL`
* `HomepageURL`
* `ReleaseURL`
* `AvatarURL`

ただし、Kotlin Multiplatform (KMP) 移植時の標準ライブラリ差異を考慮し、特定プラットフォームの URL API にドメイン・モデルを強く依存させません。

## 文字列の正規化

外部 API から取得した文字列は、ドメイン・モデルに取り込む際に、必要な「正規化」を行います。

ただし、外部サービスが提供する「原文」を破壊しません。特に下記は、原値を保持します。

* パッケージ名
* バージョン
* リポジトリ名
* ライセンス識別子

## モデルの直列化
ドメイン・モデル自体を、外部 API の JSON 形式に依存させません。

必要な場合は、専用の「シリアライゼーション・モデル」を定義します。

将来 Kotlin Multiplatform (KMP) に移植する場合、`kotlinx.serialization` 等を利用する構成に移行可能とします。

* ドメイン・モデル⟷シリアライゼーション・モデル

## Kotlin Multiplatform (KMP) の移植性ルール

共有対象は [`architecture.md`](./architecture.md)、HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本仕様は、「移植候補モデルを 値 / enum / sealed / 不変 / 純粋関数として定義する」ことのみを定めます。
プラットフォーム固有の API への依存禁止は [`architecture.md`](./architecture.md) の「プラットフォーム固有」を正本とします。

## モデルの「等価性」

値オブジェクトは、値によって、「同一性」を判定します。エンティティは、アイデンティティ (ID) によって、「同一性」を判定します。

たとえば、同じ `PackageName` は equals。

一方、`Package` の「同一性」は、`PackageName` 等のアイデンティティ (ID) を基準とします。

## モデルの「可変性」

原則として、ドメイン・モデルは、不変とします。パッケージ情報を更新する場合、oldPackage から newPackage を生成します。部分的な「可変」状態を、ドメイン・モデルに持たせません。

## モデルの「検証」

モデル生成時に、ドメイン上「不正な値」を検出します。

例:

* `PackageName`
* `Version`
* `VersionConstraint`
* `RepositoryIdentifier`

検証エラーは、「ドメイン・エラー」として表現します。

外部 API の不正レスポンスは、「アダプタ・エラー」として扱い、ドメイン・エラーと区別します。

## モデルの「バージョン管理」

ローカル・ストレージに保存するモデルについては、バージョンを管理します。

* モデル・バージョン v1→ v2→ v3

スキーマ変更時には、「移行」を提供します。ドメイン・モデルの変更と永続性モデルの「移行」を、同一視しません。

## モデルと「プライバシー」

モデルには、必要以上の個人情報を保持しません。特に下記は、必要最小限とします。公開情報であっても、アプリケーションの目的に不要な情報は、ドメイン・モデルに追加しません。

* メールアドレス
* ユーザー・プロフィール
* アバター
* OAuth アカウント情報
* メンテナー情報

メンテナーの Email 等は、Dashboard に不要であれば保持しません。

## セキュリティ告知

パッケージにセキュリティ告知が存在する場合、パッケージとは独立したエンティティとして扱います。

* `id`
* `package` (`PackageReference`)
* `affectedVersions`
* `patchedVersions`
* `severity?`
* `publishedAt?`

プロバイダが提供する ID をプライマリ ID とします。存在しない場合は安定した 複合キーを使用します。

## データ所有権

エンティティごとに信頼できる情報源 (SoT) を明確にします。アプリケーションは外部データの SoT ではありません。初期範囲 では、アプリケーション側で変更したデータを外部プロバイダに逆同期しません。

| エンティティ | 信頼できる情報源 (SoT) |
| --- | --- |
| パッケージ / PackageVersion | Packagist |
| Packagist ダウンロード数 | Packagist |
| リポジトリ・メタデータ | GitHub / Packagist |
| GitHub スター数 / トラフィック | GitHub |
| お気に入り / StatisticsSnapshot / ユーザー設定 (Preference) | ローカル・アプリケーション |
| クレデンシャル (資格情報) | 外部プロバイダ + Secure ストレージ |

Packagist アカウントから検出した管理パッケージ (`MyPackage`) はお気に入りと混同しません。検出結果の状態 (`Discovered` / `Loaded` / `Unavailable` / `Removed`) はアプリケーション状態として扱い、一時的な取得失敗をただちに `Removed` としません。パッケージ・エンティティ自体に UI ロード の状態を混在させません。

## エラーのモデル

ドメイン層のエラーは、HTTP ステータスや UI 文言と同一にしません。少なくとも、`NotFound`、`Unavailable`、`NotFetched`、`NotAuthorized` を区別し、0と「取得できなかった」を混同しません。

アプリケーション層の `ApplicationError` は、少なくとも、下記を区別します。

* `NetworkUnavailable`
* `AuthenticationRequired`
* `AuthenticationFailed`
* `RateLimited`
* `ResourceNotFound`
* `InvalidData`
* `PersistenceFailed`
* `Unknown`

アダプタは、プロバイダ / OS 例外をこれらに写像します。境界の分類 (API →アダプタ→アプリケーション→ UI) は [`architecture.md`](./architecture.md) を正本とします。

## 現行モデルの概要

型の分類は [モデル・カテゴリー](#モデルカテゴリー)、層の分離は [モデル層](#モデル層) を正本とします。

## モデルの「テスト要件」

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とします。
本仕様は、「下記モデルのユニットテストを必須とする」ことのみを定めます。

* `PackageName`
* `Version`
* `VersionConstraint`
* `Dependency`
* `Package`
* `RepositoryIdentifier`
* `Statistic`
* `StatisticsSnapshot`
* `PackageHealth`
* `PackageReference`
* `AbandonedStatus`
* `SecurityAdvisory`

## モデルの「ドキュメント」

各公開モデルには、少なくとも、下記を明記します。ドメイン・モデルの説明には、API レスポンスのフィールド名だけを記載しません。

* モデルの目的
* アイデンティティ (ID)
* プロパティ
* 任意性
* 検証
* ソース
* ミューテーション方針
