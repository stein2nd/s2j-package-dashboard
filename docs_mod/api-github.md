# S2J Package Dashboard - GitHub API 仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、GitHub API との連携を定義します。

GitHub API バージョン、API 仕様変更、実 API 検証、パフォーマンス検証、セキュリティ・レビュー等により変更される可能性があります。

API 仕様に重大な変更が発生した場合は、ドメイン・モデル、ストレージ、統計、認証および UI への影響を確認します。

## 目的

本ドキュメントでは、S2J Package Dashboard が GitHub API を利用する際の仕様を定義します。GitHub API は、Packagist パッケージに関連付けられたソース・リポジトリの情報および統計を取得するために利用します。

GitHub API 自体の仕様変更については、[GitHub 公式 REST API ドキュメント](https://docs.github.com/ja/rest?apiVersion=2026-03-10)/[GraphQL API ドキュメント](https://docs.github.com/ja/graphql) を正本とします。

## 非目的

本仕様は、GitHub 公式 API を再定義すること、Issue/PR の作成・編集、リポジトリ管理操作を目的としません。

## 責務

本アプリケーションが使う GitHub エンドポイント、REST/GraphQL の使い分け、DTO/マッピング、レート制限、トラフィック取得、エラー扱いを定義します。

## 非責務

ドメイン型 / `ApplicationError` は [`models_spec.md`](./models_spec.md)、エラー境界は [`architecture.md`](./architecture.md)、キャッシュ TTL は [`cache_spec.md`](./cache_spec.md)、スナップショット永続は [`storage_spec.md`](./storage_spec.md)、認証は [`authentication_spec.md`](./authentication_spec.md)、Keychain / Keystore の HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md)、`0` と欠測は [`domain_rules.md`](./domain_rules.md) を正本とします。

## データソース

GitHub API には、REST API および GraphQL API が存在します。初期実装では、原則として REST API を利用します。ただし、複数リソースを一括取得する必要がある場合、または REST API では取得効率が著しく悪い場合には、GraphQL API の利用を検討します。

REST API と GraphQL API を排他的に扱う必要はありません。GitHub 自身も、用途に応じて REST API と GraphQL API を選択できるとしています。

## API ベース URL

* GitHub REST API のベース URL: `https://api.github.com/`
* GraphQL API: `https://api.github.com/graphql`

## API バージョン

GitHub REST API への各リクエスト・ヘッダーでは、下記のように明示します。

`X-GitHub-Api-Version: 2026-03-10`

GitHub 公式ドキュメント URL の `apiVersion` クエリーは、ドキュメントの表示版であり、本アプリケーションの採用バージョンではありません。

実装時には、この値を GitHub アダプタ内の定数 `GitHubAPIVersion` に集約し、各リクエストはそこからヘッダーを設定します。エンドポイント実装にバージョン文字列を散在させません。

採用バージョンを更新する場合は、本節を更新した後、データ転送オブジェクト (DTO) およびマッパーの差分を確認します。ヘッダー値の変更だけで、アダプタ全体を書き換える必要はない構造とします。

## 認証の方針

どの操作が匿名でよいかは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、公開リポジトリ情報を匿名リクエストで取得し、トラフィック / 非公開 / ユーザー固有は認証済み API に限ることだけを定める。必要最小限の権限は `## Token スコープ` を正本とする。

## 認証レベル

GitHub API 利用を、認証主体により「匿名/ユーザー/インストール」の3段階に分類します。どのエンドポイントが匿名/認証済みかは `## エンドポイントの概要` を正本とする。

### 匿名

公開リポジトリのメタデータおよび公開統計を取得します。対象は `## エンドポイントの概要` の `公開*` を正本とする。

### 認証済みユーザー

ユーザー自身の権限にもとづく情報を取得します。対象は `## エンドポイントの概要` の Push access 行、および非公開リポジトリ / ユーザー固有情報です。

### インストール

GitHub アプリケーション等による、組織または選択リポジトリへのインストール認証です。初期実装では、必須としません。

## リポジトリ識別子

GitHub リポジトリは、`owner/repository` 形式で識別します。

下記は、本リポジトリの「GitHub リポジトリ」でのリポジトリ識別子例です。

`stein2nd/s2j-package-dashboard`

`.git` 拡張子は、ドメイン・モデルでは、保持しません。

リポジトリ識別子は、`RepositoryIdentifier` Value オブジェクトにマッピングします。

## リポジトリ API

### 1. エンドポイント

`GET /repos/{owner}/{repo}`

下記は、リポジトリ API のエンドポイント例です。

`GET /repos/stein2nd/s2j-package-dashboard`

### 2. 目的

リポジトリの基本情報を取得します。

### 3. メインデータ

実際にドメイン・モデルに取り込むフィールドは、S2J Package Dashboard で利用する情報に限定します。

下記は、フィールドの例です。

* `id`
* `node_id`
* `name`
* `full_name`
* `owner`
* `private`
* `description`
* `fork`
* `html_url`
* `homepage`
* `language`
* `forks_count`
* `stargazers_count`
* `watchers_count`
* `open_issues_count`
* `default_branch`
* `created_at`
* `updated_at`
* `pushed_at`
* `size`
* `archived`
* `disabled`
* `visibility`
* `license`
* `topics`

## リポジトリ・ドメイン・マッピング

GitHub リポジトリ応答は、`GitHubRepositoryDTO` → Mapper → リポジトリ とします。

GitHub API の JSON フィールドをドメイン・モデルに直接公開しません。

## リポジトリの状態

リポジトリの状態を表現します。

下記は、リポジトリの状態例です。

* アクティブ
* アーカイブ済み
* 無効
* フォーク
* 非公開
* 公開

状態は、必要に応じて、複数のプロパティとして表現します。たとえば、下記を単一 Enum に無理に統合しません。

* `private`
* `archived`
* `fork`
* `disabled`

## リポジトリのライセンス

GitHub から取得したライセンス情報を、ドメイン・モデルにマッピングします。

例:

* MIT
* Apache-2.0
* GPL-3.0
* BSD-3-Clause
* Unknown

Packagist パッケージのライセンスと GitHub リポジトリのライセンスは、別ソースとして扱います。一致しているように見える場合でも、自動的に同一データとはみなしません。

## リポジトリのトピック

GitHub リポジトリのトピックを取得します。GitHub のトピックは、パッケージのキーワードとは別の情報として扱います。

用途:

* パッケージ分類
* 検索
* 関連パッケージ
* UI 表示

## リリース API

### エンドポイント

`GET /repos/{owner}/{repo}/releases`

### 目的

GitHub リポジトリのリリースを取得します。

### ドメイン・マッピング

リリースは `Release` ドメイン・モデルにマッピングします。GitHub リリース・データ転送オブジェクト (DTO) → リリース。

## リリース・モデル

Draft (開発) および Prerelease (プリリリース) を、Stable (安定版) リリースと同一視しません。

主な情報:

* `tagName`
* `name`
* `publishedAt`
* `createdAt`
* `draft`
* `prerelease`
* `htmlURL`
* `author`

## パッケージ・バージョン vs GitHub リリース

Packagist パッケージ・バージョンと GitHub リリースを同一モデルとして扱いません。

同一バージョン番号を持つ場合でも、`PackageVersion` ≠ `Release` とします。Packagist の `PackageVersion` と GitHub のリリースは別ソースです。

必要に応じて将来、`VersionReleaseReference` 等によって関連付けます。

## 貢献者 API

### エンドポイント

`GET /repos/{owner}/{repo}/contributors`

### 目的

リポジトリの貢献者数を取得します。

### ドメイン・マッピング

貢献者は、リポジトリ統計として利用します。GitHub 貢献者 → 貢献者。

## 貢献者アイデンティティ (ID)

GitHub 貢献者と Packagist メンテナー/作者を、自動的に同一人物として扱いません。GitHub 貢献者 ≠ Packagist メンテナー。

将来、アイデンティティ (ID) マッチングを実装する場合は、別仕様として定義します。

## Issue API

下記の「状態」を必要に応じて利用します。

* `open`
* `closed`
* `all`

### エンドポイント

`GET /repos/{owner}/{repo}/issues`

## プル・リクエスト API

下記は、別モデルとして扱います。

* `Issue`
* `PullRequest`

プル・リクエストは、GitHub API 上では Issue API と関連します。

一方、ドメイン・モデルでは、Issue とプル・リクエストを区別します。

## Issue 統計

リポジトリ・ダッシュボードでは、少なくとも下記を表示可能とします。

* 未処理の Issue 数
* 解決済みの Issue 数

「未処理の Issue 数」については、リポジトリ・メタデータに含まれる値を利用できる場合、不要な追加リクエストを行いません。

## プル・リクエスト統計

初期実装では、ダッシュボードに必要な指標から、段階的に実装します。

必要に応じて、下記を取得します。

* 未処理のプル・リクエスト数
* クローズされたプル・リクエスト数
* マージされたプル・リクエスト数

## コミット履歴

リポジトリのコミット活動は、GitHub リポジトリ統計 API を利用します。応答形式の正本は、[リポジトリの統計情報に関する REST API エンドポイント - GitHub Docs](https://docs.github.com/en/rest/metrics/statistics?apiVersion=2026-03-10&partner=null) とします。

### エンドポイント

`GET /repos/{owner}/{repo}/stats/commit_activity`

このエンドポイントは、直近約52週分のコミット活動を返します。各週は、週の開始、その週の合計、曜日別件数を持ちます。「週次コミット履歴」と「年次コミット履歴」は、同一応答の異なる切り口です。用途ごとにエンドポイントを二重コールしません。

`202 Accepted` の扱いは、「統計計算」および「リポジトリ統計 `202`」を正本とします。

### 週次コミット履歴

1週の中の、曜日別コミット数です。週をまたぐ系列ではありません。GitHub の曜日の並びは、日から土です。週は 日〜土。

1週を `WeeklyCommitActivity` として保持します。`days` が曜日別件数です。`WeeklyCommitActivity` は `week` / `total` / `days`。

### 年次コミット履歴

直近約52週を、週単位の時系列として利用します。暦年の集計 API ではありません。各要素の `week` と `total` を、年次の推移に用います。

この API が返す期間より古いコミット活動は、再取得できるとは仮定しません。

## 統計計算

GitHub リポジトリ統計 API では、計算処理が高コストであるため、同一リポジトリに短時間に繰り返しリクエストしません。

リトライ間隔および最大リトライ回数を、アダプタ側で制御します。リクエスト → `202 Accepted` → 待機 → リトライ → `200 OK`。

## リポジトリ・トラフィック

リポジトリ・トラフィックは、本アプリケーションの重要な統計情報の一つとして扱います。

対象:

* クローン数
* ビュー数
* リファラー数
* 人気コンテンツ

ただし、これらは通常の公開リポジトリ・メタデータとは異なり、リポジトリへの適切な権限が必要となります。

GitHub のトラフィック情報は、リポジトリへのプッシュ権限を持つユーザーが利用できます。

## リポジトリ・クローン数

`clones` は、日単位または週単位の時系列データとして扱います。

### エンドポイント

`GET /repos/{owner}/{repo}/traffic/clones`

### データ

下記を取得します。

* `count`
* `uniques`
* `clones[]`

## リポジトリ・ビュー数

日単位または週単位の時系列データとして扱います。

### エンドポイント

`GET /repos/{owner}/{repo}/traffic/views`

### データ

* `count`
* `uniques`
* `views[]`

## トラフィックの維持

GitHub リポジトリ・トラフィック API が提供するクローン数/ビュー数データは、直近14日間を対象とします。

したがって、長期的なトラフィック傾向を表示するためには、本アプリケーション側でスナップショットを保存します。

GitHub 自身もトラフィック・グラフについて、過去14日間のビジター/クローン等を提供しています。

参考: [リポジトリへのアクセス状況の確認 - GitHub Docs](https://docs.github.com/en/repositories/viewing-activity-and-data-for-your-repository/viewing-traffic-to-a-repository?apiVersion=2022-11-28)

GitHub トラフィック → スナップショット → ローカル → 長期チャート。

## トラフィック・スナップショット

行の形は [`storage_spec.md`](./storage_spec.md)、型は [`models_spec.md`](./models_spec.md) を正本とする。本節は、GitHub トラフィック API が直近14日しか返さないため、応答の `count` / `uniques` をスナップショットとして残すことだけを定める。

## トラフィック・リファラー数

GitHub 自身および検索エンジン等の扱いについては、GitHub API の仕様を正本とします。

例:

* Google
* Stack Overflow
* Packagist
* GitHub

### エンドポイント

`GET /repos/{owner}/{repo}/traffic/popular/referrers`

### 目的

リポジトリへのトラフィックを誘導した、主要なリファラー数を取得します。

## トラフィックの人気コンテンツ

下記の「人気コンテンツ」の分析に利用します。

* 人気の README
* 人気のドキュメント
* 人気のページ

### エンドポイント

`GET /repos/{owner}/{repo}/traffic/popular/paths`

### 目的

リポジトリ内で閲覧された、人気コンテンツを取得します。

## トラフィック・データの利用状況

トラフィック情報が取得できない場合、下記を区別します。「0」と「取得不能」を同一視しません。

* アクセス権限なし
* データなし
* API エラー
* リポジトリが見つからない
* 非公開リポジトリ
* トラフィック利用不可

## コミュニティ・プロフィール

リポジトリ・コミュニティ指標を取得します。

必要に応じて、下記の情報を利用します。

* README
* 行動規範
* 貢献
* ライセンス
* Issue テンプレート
* プル・リクエストのテンプレート
* セキュリティの方針

初期実装では、パッケージの健全性等の補助情報として利用します。

### エンドポイント

`GET /repos/{owner}/{repo}/community/profile`

## パッケージの健全性

下記のように、GitHub コミュニティ・プロフィールとリポジトリ履歴を、パッケージの健全性の派生指標に利用できます。ただし、GitHub コミュニティ・プロフィールを、そのまま「パッケージの健全性」とみなしません。

* README
* ライセンス
* 貢献
* 行動規範
* セキュリティの方針

## リポジトリ統計

リポジトリ統計は、下記を基本とします。

* `stars`
* `forks`
* `watchers`
* `openIssues`
* `contributors`
* `commits`
* `releases`
* `traffic`

各指標について、下記を可能な限り保持します。

* `value`
* `source`
* `capturedAt`

## 派生リポジトリ指標

下記のような、S2J Package Dashboard 独自の指標を、必要に応じて提供します。これらは、GitHub 公式指標とは明確に区別します。

* リポジトリ履歴
* メンテナンス履歴
* コミュニティ履歴
* リリース履歴
* トラフィック傾向

## リポジトリ検索 API

リポジトリ検索 API は、クエリー文字列によって GitHub 上のリポジトリを探す API です。Packagist のパッケージ検索 API とは対象が異なります。

パッケージ検索の結果から GitHub 情報を付ける処理では、本 API を使いません。Packagist が返すリポジトリ URL から `owner/repository` を特定し、リポジトリ API を利用します。詳細は、「リポジトリ解決」を正本とします。

本 API を利用するのは、リポジトリ識別子が未知で、リポジトリ名等のクエリーから GitHub リポジトリを探す場合に限ります。

リポジトリ検索 API は、通常の REST API とは別のレート制限を持つため、不要な利用を避けます。

### エンドポイント

`GET /search/repositories`

## リポジトリ解決

Packagist パッケージからリポジトリ URL を取得できる場合、下記の流れを基本とします。リポジトリ URL が GitHub でない場合、GitHub API を利用しません。Packagist パッケージ → リポジトリ URL → GitHub 識別子 → GitHub API。

## リポジトリ URL 解析

下記の URL 形式を考慮します。ドメイン・モデルでは、`owner/repository` に正規化します。

* `https://github.com/owner/repository`
* `https://github.com/owner/repository.git`
* `git@github.com:owner/repository.git`

## リポジトリ解決失敗

リポジトリ URL から GitHub リポジトリを特定できない場合、パッケージ情報を失敗扱いにしません。GitHub 情報のみ、利用不可とします。Packagist パッケージは残し、GitHub リポジトリだけ未特定とします。

上記の場合でも、パッケージ詳細は Packagist 情報 / バージョン数 / 依存関係 / 統計を表示可能とします。

## GitHub API データ転送オブジェクト (DTO)

GitHub API 応答は、下記のように、専用 DTO として定義します。DTO をドメイン・モデルとして公開しません。

* `GitHubRepositoryDTO`
* `GitHubReleaseDTO`
* `GitHubContributorDTO`
* `GitHubIssueDTO`
* `GitHubPullRequestDTO`
* `GitHubCommitActivityDTO`
* `GitHubTrafficDTO`
* `GitHubCommunityProfileDTO`

## マッピング

下記は、基本的な変換です。GitHub JSON → DTO → マッパー → ドメイン。

例: `GitHubRepositoryDTO` → `RepositoryMapper` → リポジトリ

## REST vs GraphQL

初期実装では、REST API を基本とします。

GraphQL は、下記の場合に採用を検討します。GraphQL を採用する場合も、ドメイン・モデルを GraphQL スキーマに依存させません。

* 複数のリソースを一度に取得したい
* REST API では、リクエスト数が過剰になる
* UI に必要な情報が、複数エンドポイントに分散している
* REST API では取得しにくい関連データを、効率的に取得したい

## GraphQL 境界

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、GraphQL を採用する場合も REST との切り替えがドメイン層に波及しないことだけを定める。

## レート制限

GitHub API のレート制限の正本は、[REST API のレート制限 - GitHub Docs](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2026-03-10) とします。本節の数値は採用時点の目安であり、GitHub 側の変更に追随します。

GitHub REST API には、プライマリ・レート制限とセカンダリ・レート制限があります。プライマリ・レート制限は、認証主体によって異なります。

* 匿名: 1時間あたり60リクエスト
* ユーザー: 1時間あたり5,000リクエスト
* インストール: GitHub App インストール単位の上限。初期実装では必須としません

リポジトリ検索 API など、一部のエンドポイントは、上記とは別のプライマリ・レート制限を持ちます。詳細は、「リポジトリ検索 API」を正本とします。

本アプリケーションでは、公開情報は匿名リクエストを基本としつつ、リクエスト数を最小化します。ヘッダーの参照、制限到達時の扱い、並行数の上限は、「レート制限ヘッダー」「レート制限の処理」「並行処理のリクエスト」を正本とします。

## レート制限ヘッダー

下記のレスポンス・ヘッダーを利用します。別途 `GET /rate_limit` を頻繁に呼び出すのではなく、可能な限り、通常の API レスポンス・ヘッダーから状態を取得します。

* `x-ratelimit-limit`
* `x-ratelimit-remaining`
* `x-ratelimit-used`
* `x-ratelimit-reset`
* `x-ratelimit-resource`

## レート制限の処理

制限到達時の待ち方と、リトライの可否は、本節を正本とします。`403`/`429` をドメイン・エラーに対応付ける扱いは、「エラー・マッピング」を正本とします。

プライマリ・レート制限に達した場合は、`Retry-After` があればその秒数、なければ `x-ratelimit-reset` まで待機してからリトライします。

セカンダリ・レート制限に達した場合は、`Retry-After` があればその秒数、なければ指数バックオフで待機してからリトライします。`403`/`429` → 待機 → リトライ。

待機せずにただちにリトライすること、および制限中にリクエストを継続することは禁止します。GitHub は、制限を超えた状態でリクエストを続けると連携が停止される可能性があるとしています。([REST API のレート制限 - GitHub Docs](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2026-03-10))

無制限にはリトライしません。

## 並行処理のリクエスト

大量のリポジトリを同時取得する場合でも、リクエストを無制限に並列化することはありません。

GitHub のセカンダリ・レート制限では、REST/GraphQL を合わせて同時リクエスト100個以下、という制限があります。([REST API のレート制限 - GitHub Docs](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2026-03-10))

S2J Package Dashboard では、これより十分低い並行処理リミットを設定します。

## キャッシュの方針

Lifetime / Freshness / Invalidation は [`cache_spec.md`](./cache_spec.md)、取得順は [`architecture.md`](./architecture.md) の「キャッシュのフロー」を正本とする。本仕様は、GitHub 応答をローカル・キャッシュ優先とし、期限切れまたは欠落のときだけ API することだけを定める。TTL の具体値は [`cache_spec.md`](./cache_spec.md) を正本とする。

キャッシュ対象の優先度は「キャッシュの優先順位」、HTTP 再検証は「条件付きリクエスト」、ネットワーク切断時は「オフライン時の挙動」、明示更新は「リフレッシュの方針」を正本とします。

## キャッシュの優先順位

TTL / 優先度は [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、公開メタデータ等をキャッシュ対象とし、トラフィックはキャッシュではなく長期スナップショットとすることだけを定める。

## 条件付きリクエスト

GitHub API が提供する「HTTP キャッシュ検証」機構を利用可能な場合は、利用します。`304 Not Modified` の場合、ローカル・キャッシュを再利用します。

たとえば、下記を利用します。

* `ETag`
* `If-None-Match`

## オフライン時の挙動

キャッシュ利用は [`cache_spec.md`](./cache_spec.md)、見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、ネットワークがないとき GitHub 取得を必須にしないことだけを定める。

## リフレッシュの方針

Pull-to-Refresh の横断 HOW は [`ui.md`](./ui.md)、画面ごとの更新アクションの置き場所は [`screen_spec.md`](./screen_spec.md) を正本とする。本仕様は、リフレッシュで全 GitHub エンドポイントを無条件リクエストせず、トラフィックは `## トラフィック・スナップショット・スケジュール` に従うことだけを定める。

## トラフィック・スナップショット・スケジュール

スナップショットをいつ取得するかは、本節を正本とします。直近14日しか取得できない理由と保存の必要性は、「トラフィックの維持」を正本とします。保存項目は「トラフィック・スナップショット」、14日を超えた利用は「長期統計」を正本とします。

モバイル・アプリケーションは、常時バックグラウンド実行されることを保証できません。時計どおりの定期ジョブではなく、利用可能なタイミングで取得を試みます。

* アプリケーション起動
* アプリケーションのフォアグラウンド復帰
* 明示的手動リフレッシュ
* バックグラウンド更新が許可されている場合

起動やフォアグラウンドのたびに、全リポジトリに無条件にリクエストしません。権限があり、直近のスナップショットが不足している場合に限ります。トラフィック取得は、認証が必要です。詳細は、「リポジトリ・トラフィック」および「公開/認証済みデータ境界」を正本とします。

## 長期統計

14日を超えた GitHub トラフィックの利用は、本節を正本とします。直近14日しか取得できない理由は、「トラフィックの維持」、保存項目は「トラフィック・スナップショット」、取得タイミングは「トラフィック・スナップショット・スケジュール」を正本とします。スナップショットの意味は、[`models_spec.md`](./models_spec.md) の「統計のスナップショット」、永続化は [`storage_spec.md`](./storage_spec.md) を正本とします。

14日を超えた傾向は、GitHub API の現在の応答ではなく、本アプリケーションが保存したスナップショットから組み立てます。過去14日より古いデータは、GitHub API から再取得できるとは仮定しません。

取得できなかった日を、後から API で埋め直すことはできません。欠落と値 `0` は同一視しません。詳細は、「トラフィック・データの利用状況」を正本とします。

直近14日は GitHub API またはスナップショット。14日より前はローカルのスナップショットのみ。

## 認証ストレージ

クレデンシャルの分離と保存 HOW は [`authentication_spec.md`](./authentication_spec.md) / [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、GitHub Token を通常のアプリケーション・データに保存しないことだけを定める。

## Token スコープ

必要最小限の権限は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、トラフィック取得のためにリポジトリ管理権限を要求しないことだけを定める。

## 公開/認証済みデータ境界

認証方針は `## 認証の方針`、エンドポイントの可否は `## エンドポイントの概要` を正本とする。本仕様は、未認証でも公開リポジトリのメタデータを表示し、トラフィック系を認証なしでは要求しないことだけを定める。

## エラー・マッピング

境界の分類は [`architecture.md`](./architecture.md)、`ApplicationError` は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、HTTP を `GitHubAPIError` に写像し、ドメイン・エラーへ直接変換しないことだけを定める。

| HTTP | GitHubAPIError |
| --- | --- |
| 404 | `RepositoryNotFound` |
| 401 | `AuthenticationRequired` |
| 403 | `Forbidden` または `RateLimited` |
| 429 | `RateLimited` |
| 202 | `StatisticsPending` (`## リポジトリ統計 202`) |
| 5xx | `ServiceUnavailable` |

## リポジトリ統計 `202`

リポジトリ統計 API が `202 Accepted` を返した場合は、リポジトリ統計がまだ生成中である可能性があります。

この場合、下記とします。

1. 現在のリクエストを「成功済み」データとして扱わない
2. リトライ可能な状態として、保持する
3. 適切な遅延を設ける
4. 最大リトライ回数を超えた場合は、「利用不可」とする

## 欠落データ

`0` と欠測の区別は [`domain_rules.md`](./domain_rules.md) を正本とする。トラフィック固有の区別は `## トラフィック・データの利用状況` を正本とする。本仕様は、値 `0` / データなし / 許可されていない / 利用できない / API エラーを同一表示にしないことだけを定める。

## API セキュリティ

Token のマスクと漏洩面は [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、GitHub 認可ヘッダーを HTTP ログの対象から除外することだけを定める。

## UA (ユーザー・エージェント)

GitHub API へのリクエストでは、アプリケーションを識別できる、`S2J-Package-Dashboard/1.0` のような、UA (ユーザー・エージェント) を、可能な限り、設定します。実際のフォーマットは、リリース時に確定します。

## API テスト

GitHub API アダプタでは、「フィクスチャ」を利用します。最低限、下記を用意します。

* `repository.json`
* `releases.json`
* `contributors.json`
* `issues.json`
* `pull-requests.json`
* `commit-activity.json`
* `traffic-clones.json`
* `traffic-views.json`
* `traffic-referrers.json`
* `traffic-paths.json`
* `community-profile.json`

## 結合テスト

実 API へのリクエスト数は必要最小限とする。確認対象は `## エンドポイントの概要` の初期対象と、レート制限/404/403/429/202とする。

## スナップショット・テスト

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、GitHub JSON フィクスチャでマッパーの回帰を取ることだけを定める。

## エンドポイントの概要

`公開*` は、公開リポジトリについて匿名取得が可能な場合を示します。実際のアクセス可否は、GitHub API の最新仕様およびリポジトリ可視性/権限設定によります。

| エンドポイント | 認証 | 初期状態 |
| --- | --- | --- |
| `GET /repos/{owner}/{repo}` | 公開* | Yes |
| `GET /repos/{owner}/{repo}/releases` | 公開* | Yes |
| `GET /repos/{owner}/{repo}/contributors` | 公開* | Yes |
| `GET /repos/{owner}/{repo}/issues` | 公開* | Yes |
| `GET /repos/{owner}/{repo}/pulls` | 公開* | Yes |
| `GET /repos/{owner}/{repo}/stats/commit_activity` | 公開* | Yes |
| `GET /repos/{owner}/{repo}/community/profile` | 公開* | Optional |
| `GET /repos/{owner}/{repo}/traffic/clones` | Push access | 将来/Auth |
| `GET /repos/{owner}/{repo}/traffic/views` | Push access | 将来/Auth |
| `GET /repos/{owner}/{repo}/traffic/popular/referrers` | Push access | 将来/Auth |
| `GET /repos/{owner}/{repo}/traffic/popular/paths` | Push access | 将来/Auth |
| `GET /rate_limit` | Optional | Support |

## API の初期スコープ

必須エンドポイントは `## エンドポイントの概要` の初期状態列を正本とする。

### 推奨

* コミュニティ・プロフィール
* トピック
* ライセンス

### 認証済み/将来

リポジトリ・トラフィック (クローン / ビュー / リファラー / 人気コンテンツ) は認証済み。エンドポイントは `## エンドポイントの概要` を正本とする。

### 将来

* GraphQL
* 非公開リポジトリ
* Organization 統計
* GitHub App

## パッケージ → GitHub データフロー

Packagist API と GitHub API の責務を混在させません。Packagist パッケージのリポジトリ URL から GitHub リポジトリ識別子を解決し、その後 GitHub API を呼び出す。

## 統計の統合

Packagist と GitHub の統計は、別ソースとして保持します。同一の「人気スコア」に自動的に統合しません。派生指標は [`statistics_spec.md`](./statistics_spec.md) を正本とする。
