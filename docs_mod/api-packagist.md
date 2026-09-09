# S2J Package Dashboard - Packagist API 仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、Packagist API との連携を定義します。

Packagist API の仕様変更、実 API 検証、パフォーマンス検証、セキュリティ・レビュー等により変更される可能性があります。

API 仕様に重大な変更が発生した場合は、ドメイン・モデル、ストレージ、統計および UI への影響を確認します。

## 目的

本ドキュメントでは、S2J Package Dashboard が Composer パッケージ・リポジトリ「Packagist.org」の API を利用する際の仕様を定義します。

Packagist API 自体の仕様変更については、[Packagist.org > API ドキュメント](https://packagist.org/apidoc) を正本とします。

## 非目的

本仕様は、Packagist 公式 API を再定義すること、パスワード認証を導入すること、非公開 Packagist を初期対象とすることを目的としません。

## 責務

本アプリケーションが使う Packagist エンドポイント、リクエスト/応答の扱い、DTO/マッピング、エラー、レート制限、認証ヘッダー方針を定義します。

## 非責務

ドメイン型 / `ApplicationError` は [`models_spec.md`](./models_spec.md)、エラー境界は [`architecture.md`](./architecture.md)、キャッシュ TTL は [`cache_spec.md`](./cache_spec.md)、クレデンシャル保存は [`authentication_spec.md`](./authentication_spec.md) を正本とします。

## データソース

下記は、主要なデータソースです。Packagist.org の API は、下記のとおりです。

* 検索
* パッケージ
* Composer メタデータ
* ダウンロード統計
* パッケージ更新
* 統計
* セキュリティ告知

Packagist は、Composer の主要な公開パッケージ・リポジトリであり、公開 PHP パッケージを集約しています。

## API ベース URL

用途に応じて、両者を使い分けます。

### 1. Packagist API

`https://packagist.org/`

### 2. Composer メタデータのリポジトリ

`https://repo.packagist.org/`

## 認証の方針

どの操作が匿名でよいかは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、公開パッケージ情報を匿名 API で取得し、認証は必要機能に限ることだけを定める。

## 認証レベル

Packagist API の操作は、匿名 / `SAFE` Token / `MAIN` Token の3種類に分類します。どのエンドポイントが匿名/SAFE/MAIN かは `## エンドポイントの概要` を正本とする。初期バージョンでは `MAIN` Token を必要とする機能を実装しません。

### 匿名

公開情報を取得します。対象は `## エンドポイントの概要` の匿名行を正本とする。

### SAFE Token

SAFE 操作に使用します。対象は `## エンドポイントの概要` の SAFE 行です。

### MAIN Token

UNSAFE 操作に使用します。対象は `## エンドポイントの概要` の MAIN 行です。

## パスワードの方針

Packagist パスワードを、S2J Package Dashboard に保存しません。

Packagist アカウントとの接続が必要な場合は、Packagist API Token を利用します。

クレデンシャル (資格情報) の保存については、下記を正本とします。

* [authentication_spec.md](./authentication_spec.md)
* [architecture.md](./architecture.md)

## パッケージ検索 API

### 1. 目的

パッケージ検索 API は、ユーザーがパッケージを検索するために使用します。

### 2. エンドポイント

`GET https://packagist.org/search.json`

### 3. クエリー・パラメータ

下記は、主なクエリー・パラメータです。

* `q`
* `tags`
* `type`
* `per_page`
* `page`

#### `q`

下記は、パッケージ名等による検索文字列です。

`?q=monolog`

#### `tags`

下記は、タグによる検索です。

`?tags=psr-3`

#### `type`

下記は、パッケージタイプによる検索です。

`?type=symfony-bundle`

#### `per_page`

1ページあたりの結果数です。

#### `page`

ページ番号です。

### 4. 複合検索

下記のように、複数の条件を組み合わせて検索できます。

`/search.json?q=monolog&type=library`

### 5. 応答

概念上、下記の構造を持ちます。

```json
{
  "results": [
    {
      "name": "vendor/package",
      "description": "...",
      "url": "https://packagist.org/packages/vendor/package",
      "repository": "https://github.com/vendor/package",
      "downloads": 123456,
      "favers": 123
    }
  ],
  "total": 123,
  "next": "..."
}
```

### 6. ドメイン・マッピング

検索応答を、直接 `Package` にマッピングしません。検索結果は、パッケージ詳細より情報量が少ないため、`Package` ドメイン・モデルとは別モデルとして扱います。変換は `SearchResponse` → `PackageSearchResultDTO` → `PackageSearchResult` → UI モデルです。

## 人気のパッケージ API

### 1. 目的

人気のパッケージを取得します。

### 2. エンドポイント

`GET https://packagist.org/explore/popular.json`

### 3. パラメータ

Packagist では、人気のパッケージは、直近1週間のダウンロードを基準として並べる仕様であり、累積ダウンロードだけを基準としません。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

* `per_page`
* `page`

### 4. ユースケース

初期バージョンでは、必須機能としません。

将来的に、下記に利用します。

* 探索
* 人気のパッケージ
* トレンド・パッケージ

## パッケージ・リスト API

### 1. 目的

パッケージ名リストを取得します。

### 2. エンドポイント

`GET https://packagist.org/packages/list.json`

### 3. パラメータ

* `vendor`
* `type`
* `fields[]`

### 4. ユースケース

パッケージ・エクスプローラーや Vendor エクスプローラー等で利用します。

ただし、全パッケージ・リストを取得して、ローカル・データベースに保持することを、初期仕様とはしません。

## パッケージ情報 API

### 1. 目的

パッケージの詳細情報を取得します。

### 2. エンドポイント

`GET https://packagist.org/packages/{vendor}/{package}.json`

例:

`https://packagist.org/packages/monolog/monolog.json`

### 3. 応答

Packagist の JSON API では、パッケージ・メタデータに加え、メンテナー、ダウンロード数、依存関係、等を含む情報を取得できます。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

下記は、概念構造です。

```json
{
  "package": {
    "name": "vendor/package",
    "description": "...",
    "time": "...",
    "maintainers": [],
    "versions": [],
    "type": "library",
    "repository": "...",
    "downloads": {
      "total": 0,
      "monthly": 0,
      "daily": 0
    },
    "favers": 0
  }
}
```

## Composer メタデータ API

Packagist は、Composer メタデータを「推奨される方法」としており、静的ファイルとして提供されるため、効率がよいです。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

### 1. 目的

パッケージ・メタデータを効率的に取得する場合は、Composer v2メタデータを利用します。

### 2. エンドポイント

* タグ付きリリース: `GET https://repo.packagist.org/p2/{vendor}/{package}.json`
* 開発ブランチ: `GET https://repo.packagist.org/p2/{vendor}/{package}~dev.json`

### 3. セレクション方針

パッケージ・メタデータだけが必要な場合は、Composer メタデータ API を優先します。下記のような情報が必要な場合は、パッケージ API を利用します。

* メンテナー
* ダウンロード統計
* GitHub 情報
* 依存関係等、メタデータ以外の情報

## メタデータのキャッシュ

Composer メタデータ API では、`Last-Modified`/`If-Modified-Since` を利用できます。

S2J Package Dashboard では、可能な場合、これを利用します。ローカルが `If-Modified-Since` を送り、Packagist は「304: 変更なし」、または「200: 更新済み」を返します。

## パッケージ API キャッシュ 

パッケージ API は、Packagist 側で動的生成され、応答が12時間キャッシュされます。したがって、S2J Package Dashboard 側でも過剰なリクエストを避けます。パッケージ詳細を表示するたびに、必ず API にリクエストする設計としません。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

## ダウンロード統計 API

### 1. エンドポイント

`GET https://packagist.org/packages/{vendor}/{package}/stats.json`

### 2. 応答

下記は、概念構造です。

```json
{
  "downloads": {
    "total": 100,
    "monthly": 10,
    "daily": 1
  },
  "versions": [
    "1.0.0",
    "1.1.0"
  ],
  "date": "2026-08-01"
}
```

### 3. ユースケース

下記の表示に利用します。

* 合計
* 月別
* 日別

パッケージ API をすでに取得している場合は、その応答内の `downloads` を再利用します。

ダウンロード統計だけを必要とする場合は、統計エンドポイントを利用します。

Packagist 自身も、この使い分けを推奨しています。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

## ダウンロード統計の推移

Packagist API が提供するダウンロード統計の履歴だけでは、本アプリケーションが必要とする長期トレンドを保証できません。

そのため、S2J Package Dashboard では、取得した値をスナップショットとして保存します。流れは Packagist → ダウンロード統計 → `StatisticsSnapshot` → ローカル・ストレージ → 長期チャートです。スナップショット方針は [`storage_spec.md`](./storage_spec.md) / [`statistics_spec.md`](./statistics_spec.md) を正本とします。

## スナップショットの方針

行の形は [`storage_spec.md`](./storage_spec.md)、型は [`models_spec.md`](./models_spec.md)、不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。本節は、Packagist 取得値をスナップショット対象にすることだけを定める。

## 統計コレクション

統計情報を定期取得する場合、Packagist API へのリクエストを特定時刻に集中させません。

Packagist は、毎日0時や毎時 XX 分などの、特定の時間帯に集中するスケジュールジョブを避け、ランダムな時間帯の設定を推奨しています。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

本アプリケーションの定期スナップショット取得を実装する場合も、この方針を尊重します。

## パッケージ更新 API

Packagist API では、更新パッケージは、SAFE 操作として定義されています。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

### 1. エンドポイント

`POST https://packagist.org/api/update-package`

### 2. 認証

SAFE Token または MAIN Token を利用できます。

### 3. 初期スコープ

S2J Package Dashboard では、初期バージョンに実装しません。

本アプリケーションの主要目的は、下記のとおりであり、パッケージの管理ではないためです。

* 監視
* 分析
* 可視化

## パッケージ作成 API

Packagist パッケージの新規登録は、本アプリケーションのダッシュボード機能ではありません。

### 1. エンドポイント

`POST https://packagist.org/api/create-package`

### 2. 認証

MAIN Token が必要です。

### 3. 初期スコープ

実装しません。

## パッケージ編集 API

### 1. エンドポイント

`PUT https://packagist.org/api/packages/{vendor}/{package}

### 2. 認証

MAIN Token が必要です。

### 3. 初期スコープ

実装しません。

## マイ・パッケージ

Packagist アカウントから取得した結果を正本とします。

### 1. 目的

Packagist アカウントに関連するパッケージを、ユーザー自身のパッケージとして表示します。

### 2. 認証

アカウント関連情報を取得する場合は、Packagist アカウント・クレデンシャル (資格情報) を使用します。

クレデンシャル (資格情報) は、Secure ストレージに保存します。

### 3. データモデル

取得結果は、Packagist アカウント → マネージド・パッケージ名 → `MyPackage` → `Package` にマッピングします。

### 4. 手動オーバーライド

ユーザーが「マイ・パッケージ」の手動追加を基本としません。

## お気に入り

「お気に入り」は、Packagist アカウントとは独立したユーザーデータです。

Packagist API から取得したパッケージそのものを「お気に入り」に複製保存しません。お気に入りは `PackageName` を指します。

## セキュリティ告知 API

Packagist のセキュリティ告知 API は、匿名で利用可能です。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

### 1. エンドポイント

`GET https://packagist.org/api/security-advisories/`

### 2. クエリー

パッケージ名による検索を基本とします。

例:

`?packages[]=vendor/package`

PURL 形式も利用可能です。

`pkg:composer/vendor/package`

## セキュリティ告知のユースケース

バージョン固有な影響を確認できる場合は、対象バージョンとの関係を表示します。

パッケージ詳細に、

```text
セキュリティ
────────────
注意喚起: 既知の告知がない
```

または、

```text
セキュリティ
────────────
注意喚起: 3
```

を表示します。

## セキュリティ・データの意味論

API が対象パッケージを認識していない場合と、既知の告知が存在しない場合とを、同一視しません。告知なしは、データなしと同一ではありません。

## API データ転送オブジェクト (DTO)

Packagist API 応答は、専用 DTO として定義します。DTO をドメイン・モデルとして公開しません。

例:

* `PackagistPackageResponse`
* `PackagistSearchResponse`
* `PackagistDownloadStatsResponse`
* `PackagistSecurityAdvisoryResponse`
* `PackagistMetadataResponse`

## マッピング

下記は、基本的な変換フローです。HTTP レスポンス→ JSON デコーダ→ Packagist DTO → マッパー→ドメイン。

例: `PackagistPackageDTO` → `PackageMapper` → パッケージ

## Unknown フィールド

Packagist API 応答に未知のフィールドが追加されても、既存アプリケーションが破綻しないこと。

未使用フィールドは、原則として無視します。ドメイン・モデルに必要になった場合のみ、明示的に追加します。

## 欠落フィールド

API 応答にフィールドが存在しない場合、適切な Optional 値にマッピングします。下記を区別します。

* フィールドが存在しない
* フィールドが null
* フィールドが空
* フィールドが0

これらを無条件に同一視しません。

## HTTP ステータス

少なくとも、下記を区別します。

* 200: OK
* 304: 変更なし
* 400: 不正なリクエスト
* 401: 未認証
* 403: アクセス拒否
* 404: 見つかりません
* 429: リクエスト超過
* 5xx: サーバー・エラー
* ネットワーク・エラー
* タイムアウト

## エラーのマッピング

境界の分類は [`architecture.md`](./architecture.md)、`ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、HTTP を `PackagistAPIError` に写像し、ドメイン・エラーへ直接変換しないことだけを定める。

| HTTP | PackagistAPIError |
| --- | --- |
| 404 | `PackageNotFound` |
| 429 | `RateLimited` |
| 401 | `AuthenticationRequired` |
| 5xx | `ServiceUnavailable` |

## レート制限/トラフィック制御

Packagist API に不要なリクエストを送信しません。下記を基本とします。

* ローカル・キャッシュ
* リクエスト重複排除
* 条件付きリクエスト
* ページネーション
* バッチ取得可能な場合の利用
* 更新操作のスロットリング

## UA (ユーザー・エージェント)

Packagist API へのリクエストには、アプリケーションを識別できる UA (ユーザー・エージェント) を付与します。実際の UA のフォーマットは、リリース時に確定します。

可能であれば、下記のような連絡先情報を含めます。

`S2J-Package-Dashboard/1.0 (+mailto:...)`

Packagist は、API 利用時に UA を送信し、`mailto` による連絡先を含めることを推奨しています。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

## リクエスト・タイムアウト

ネットワーク・リクエストには、タイムアウトを設定します。

タイムアウト値は、プラットフォームおよびネットワーク状態を考慮して決定します。

タイムアウト発生時には、可能であればローカル・キャッシュをフォールバックとして利用します。

## オフライン時の挙動

キャッシュ利用は [`cache_spec.md`](./cache_spec.md)、見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、ネットワークがないとき Packagist 取得を必須にしないことだけを定める。

## キャッシュの方針

TTL / Freshness / どの応答をキャッシュするかは [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、Packagist 側のキャッシュ挙動だけを定める。パッケージ API は Packagist 側で約12時間キャッシュされる。Composer メタデータは `If-Modified-Since` を利用可能とする。

## 更新の方針

Pull-to-Refresh の横断 HOW は [`ui.md`](./ui.md)、画面ごとの更新アクションの置き場所は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、更新時に必要な Packagist API のみをリクエストし、パッケージ詳細全体を無条件で再取得しないことだけを定める。

## API リクエスト重複排除

同一パッケージについて、同時に複数のリクエストが発生した場合、可能な限り重複リクエストを抑制します。

同一データに対する重複リクエストを避けます。

例: `PackageDetailView` がメタデータ / 統計 / セキュリティを同時に要しても、重複リクエストを抑制します。

## API ページネーション

ページネーションをサポートするエンドポイントでは、API のページネーションを利用します。UI 側で全結果を一度に取得しません。

必要になった時点で追加取得します。

例: ページ1→2→3と、必要時に追加取得します。

## API バージョンの互換性

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、Packagist スキーマ変更の影響をアダプタ / DTO / マッパーに閉じることだけを定める。

## API テスト

Packagist API アダプタでは、実 API への依存を減らすため、「しかけ」を利用します。

最低限、下記の「しかけ」を用意します。

* `package.json`
* `package-not-found.json`
* `search.json`
* `stats.json`
* `security-advisories.json`
* `metadata.json`

## 連携テスト

実 API へのリクエスト数は必要最小限とする。確認対象は `## エンドポイントの概要` の初期対象と、エラー応答 / ページネーション / 条件付きリクエストとする。

## スナップショット・テスト

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、Packagist JSON フィクスチャでマッパーの回帰を取ることだけを定める。

## API セキュリティ

Token のマスクと漏洩面は [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、Packagist 認可ヘッダーを HTTP ログの対象から除外することだけを定める。

## API クレデンシャル (資格情報) の分離

認証方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、公開情報の取得に AuthenticatedClient を使わないことだけを定める。

## 初期 API スコープ

必須/任意は `## エンドポイントの概要` の初期状態列を正本とする。

### アカウント関連

`My Packages`

### 将来

* パッケージ更新数の追跡
* パッケージ更新

### スコープ外

* パッケージ作成
* パッケージ編集

## エンドポイントの概要

Packagist 公式 API ドキュメントを基準として、実装時にエンドポイントの最新仕様を再確認します。([Packagist.org > API ドキュメント](https://packagist.org/apidoc))

| エンドポイント | 認証 | 初期状態 |
| --- | --- | --- |
| `/search.json` | 匿名 | Yes |
| `/packages/{vendor}/{package}.json` | 匿名 | Yes |
| `/packages/{vendor}/{package}/stats.json` | 匿名 | Yes |
| `/packages/list.json` | 匿名 | Optional |
| `/explore/popular.json` | 匿名 | Optional |
| `/p2/{vendor}/{package}.json` | 匿名 | Yes |
| `/statistics.json` | 匿名 | 将来 |
| `/api/security-advisories/` | 匿名 | Yes |
| `/api/update-package` | SAFE/MAIN | 将来 |
| `/api/create-package` | MAIN | No |
| `/api/packages/{package}` | MAIN | No |

## ドメイン・マッピングの概要

Packagist 固有のデータ転送オブジェクト (DTO) は、ドメイン層に露出させません。Packagist からの対応は、下記のとおりです。

* 検索 → `PackageSearchResult`
* パッケージ API → パッケージ
* Composer メタデータ → `PackageVersion` / 依存関係
* ダウンロード統計 → `DownloadStatistics`
* セキュリティ告知 → `SecurityAdvisory`
