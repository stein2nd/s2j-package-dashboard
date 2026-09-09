# S2J Package Dashboard - キャッシュ仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、キャッシュを定義します。

プロバイダ API、統計仕様、ストレージ実装、iOS/iPadOS/Android 実装、Kotlin Multiplatform (KMP) 移行等に応じて更新する。

## 目的

本ドキュメントでは、キャッシュの対象 Data、Lifetime、Freshness、Invalidation、Refresh、オフライン利用およびプロバイダ別キャッシュ方針を定義する。キャッシュ方針の正本は本仕様とする。

キャッシュは、「再取得可能な Data を一時的に保持し、Network Request の削減および UI Response の改善を目的とする Data」と定義する。

## 非目的

本仕様は、Cloud 同期、External Backend、Chart Rendering、SwiftUI/Compose Layout を詳細に定義しない。

## 責務

TTL / Freshness / Stale / Invalidation / Rebuild、オフライン時のカレント・データ利用を定義する。

## 非責務

永続化および Historical スナップショットは [`storage_spec.md`](./storage_spec.md)、統計指標の意味は [`statistics_spec.md`](./statistics_spec.md)、API エンドポイントは各 API 仕様、認証フローとクレデンシャル保存は [`authentication_spec.md`](./authentication_spec.md)、Foreground 復帰時の既存表示の維持と Freshness の表示文言は [`ui.md`](./ui.md)、共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。

## キャッシュの基本原則

キャッシュは下記を原則とする。

1. キャッシュは「信頼できる情報源 (SoT)」ではない
2. キャッシュは再構築可能である
3. キャッシュ消失によってアプリケーション・データ全体を失わない
4. キャッシュと Historical スナップショットを混同しない
5. キャッシュの Freshness を明示的に管理する
6. Stale キャッシュを可能な限り有効利用する
7. キャッシュ Failure でアプリケーション全体を停止しない
8. クレデンシャル (資格情報) をキャッシュしない
9. プロバイダごとに適切なキャッシュ方針を設定する
10. プラットフォーム固有キャッシュ API にドメイン・ロジックを依存させない

## キャッシュとスナップショット

キャッシュとスナップショットは明確に分離する。

* キャッシュ: カレント・データを再利用するための一時 Data
* スナップショット: Historical 統計として保存する Data

キャッシュを削除しても、Historical スナップショットは削除しない。スナップショットの不変条件は [`domain_rules.md`](./domain_rules.md)、スキーマ / Retention / Migration は [`storage_spec.md`](./storage_spec.md) を正本とする。

## キャッシュと「信頼できる情報源 (SoT)」

Current 統計の「信頼できる情報源 (SoT)」はプロバイダ側の Data とする。キャッシュはそのコピーであり、プロバイダの代替ではない。

## キャッシュ・アーキテクチャー

層の置き場所は [`architecture.md`](./architecture.md) を正本とする。本仕様は、キャッシュをリポジトリとプロバイダ API の間に置き、アプリケーション・ロジックからキャッシュの存在を必須としないことだけを定める。

## キャッシュ境界

ドメイン層は URLCache / NSCache 等のキャッシュ・フレームワークに依存しない。アクセスは `CacheRepository` 経由とし、プラットフォーム実装はアダプタに置く。

## キャッシュ・リポジトリ

概念:

`CacheRepository` を利用可能とする。

例:

* `get(key)`
* `put(key, value)`
* `remove(key)`
* `clear()`

具体的な API は実装時に定義する。

## キャッシュ可能データ

初期バージョンでは、下記をキャッシュ対象とする。

* Package Metadata
* リポジトリ Metadata
* Current 統計
* プロバイダ Capability

## 非キャッシュ可能データ

クレデンシャルをキャッシュしないことは [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、Password / Token / Authorization Header をアプリケーション・キャッシュに入れないことだけを定める。

## API Response

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、API Response 全文を無条件にアプリケーション・キャッシュへ保存せず、検証・ドメイン写像後のキャッシュ可能モデルだけをキャッシュすることだけを定める。

## HTTP キャッシュ vs アプリケーション・キャッシュ

下記を区別する。

* HTTP キャッシュ: HTTP レスポンスのキャッシュ
* アプリケーション・キャッシュ: アプリケーションが意味を理解したカレント・データのキャッシュ

iOS の `URLCache` は HTTP/HTTPS Response をメモリ/ディスクにキャッシュできるが、アプリケーションのドメイン・キャッシュとは別物として扱う。([developer.apple.com](https://developer.apple.com/documentation/foundation/accessing-cached-data?changes=_3))

## `URLCache`

iOS 実装では、`URLCache` を HTTP 層のキャッシュとして利用可能とする。`URLCache` は S2J のカレント・データ・キャッシュと同一視しない。

## `URLCache` Purge

iOS ではディスク・キャッシュがシステムによって Purge される可能性がある。

したがって、URLCache の存在をアプリケーション・データの永続性保証として利用しない。([developer.apple.com](https://developer.apple.com/documentation/foundation/urlcache?changes=_6))

## アプリケーション キャッシュ

カレント・データについて、必要に応じてアプリケーション-managed キャッシュを利用する。

例:

* `PackageCurrentCache`
* `StatisticsCurrentCache`
* `RepositoryCurrentCache`

## キャッシュ・キー

キャッシュには一意なキャッシュ・キーを持たせる。

概念: キャッシュ・キーは provider + resource + identifier + parameters を組み合わせて一意にする。

## Package キャッシュ・キー

例: `packagist:package:vendor/package`

## リポジトリ・キャッシュ・キー

例: `github:repository:owner/repository`

## 統計キャッシュ・キー

統計については、指標および Period 等を考慮する。

例: `packagist:statistics:vendor/package:downloads`

## Parameterized キャッシュ

API クエリー・パラメータによって結果が変化する場合、キャッシュ・キーにパラメータを含める。

## キャッシュ・キー Stability

キャッシュ・キーは、プロバイダ API URL そのものと同一である必要はない。

ドメイン上で安定した Identity を優先する。

## キャッシュ Entry

キャッシュ Entry は最低限、`key` / `value` / `fetchedAt` / `expiresAt` / `schemaVersion` を持つ。

## `fetchedAt`

`fetchedAt` は、「S2J Package Dashboard がプロバイダから Data を正常取得した時点」を表す。

## `expiresAt`

`expiresAt` は、キャッシュが Fresh として扱える期限を表す。

## Fresh

`now < expiresAt` の場合、「Fresh」とする。

## Stale

`now >= expiresAt` の場合、「Stale」とする。

## Stale キャッシュ

Stale キャッシュは即時削除しない。

Network Request が失敗した場合などに、Last Known Data として利用可能とする。

## キャッシュ状態

キャッシュ状態:

* Missing
* Fresh
* Stale
* Invalid

を基本とする。

### Missing

キャッシュ Entry が存在しない場合、「Missing」とする。

### Invalid

キャッシュ Entry がスキーマ Validation 等に失敗した場合、「Invalid」とする。

### Invalid キャッシュ

Invalid キャッシュは、正常なカレント・データとして UI に渡さない。

必要に応じて削除して再取得する。

### Freshness

Freshness は Data Validity とは異なる。

* Fresh
* Stale

は、

* Valid
* Invalid

とは別概念とする。

## キャッシュ Validity

キャッシュされた Data がドメイン Rule 上 Valid であることを確認してから利用する。

## キャッシュ Validation

キャッシュ Read 時には必要に応じて、

* スキーマ・バージョン
* Package Identity
* 指標 Type
* Unit
* タイムスタンプ
* Availability

等を検証する。

## キャッシュ・スキーマ・バージョン

キャッシュ Entry には、必要に応じてスキーマ・バージョン `schemaVersion` を保持する。

アプリケーション・バージョンとは分離する。

## スキーマ Mismatch

キャッシュ ・スキーマが Current アプリケーションで解釈できない場合、`Invalid` として扱い、必要に応じて再取得する。

## キャッシュ Migration

キャッシュについては、Historical スナップショットほど厳密な Migration を要求しない。

再取得可能なキャッシュについては、旧エントリを破棄して再取得することを許可する。

## キャッシュ TTL

キャッシュ TTL は、プロバイダおよび指標の性質に応じて設定する。

固定 TTL を全 Data に適用しない。

## プロバイダ固有 TTL

初期バージョンでは、プロバイダ/Resource 単位で TTL を定義可能とする。

例:

* Packagist Package Metadata: `TTL = 24h`
* Packagist Search: 短めの TTL
* Packagist API エラー: キャッシュしない、または短めの TTL
* GitHub リポジトリ Metadata: `TTL = 1h`
* GitHub Traffic: キャッシュではなくスナップショット。Current 応答の TTL は短め / 方針 dependent

具体値は実測結果に応じて調整する。

## 統計 TTL

統計は、指標の更新頻度に応じて TTL を決定する。

## Slow-changing Data

Package Description 等の比較的変化が少ない Data については、長めの TTL を許容する。

## Fast-changing Data

Traffic/Views 等の変化頻度が高い Data については、短めの TTL を設定可能とする。

## User Refresh

ユーザーが明示的に Refresh した場合、通常の TTL を無視して再取得可能とする。

## Manual Refresh

明示更新は `## User Refresh` を正本とする。

## Refresh Failure

Refresh に失敗した場合、既存キャッシュを削除しない。

## Refresh Failure UI

見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、Refresh 失敗時に既存キャッシュの Freshness を Presentation 層へ渡すことだけを定める。

## No キャッシュ + Failure

Empty / Error の見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、キャッシュなしかつ取得失敗を「データなし + エラー」として扱うことだけを定める。

## No Fake Zero

`0` と欠測の区別は [`domain_rules.md`](./domain_rules.md) を正本とする。本仕様は、キャッシュ Missing / API Failure を `指標 = 0` に変換しないことだけを定める。

## オフライン Mode

オフライン時には、Fresh キャッシュを優先して利用する。

## オフライン Stale

見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、オフライン時に Fresh がなければ Stale キャッシュを利用可能とすることだけを定める。

## オフライン No キャッシュ

見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、キャッシュがないオフラインではプロバイダ Data を表示できないことだけを定める。

## オフライン・スナップショット

オフライン状態で、プロバイダ Data を取得していない場合、新しい Historical スナップショットを生成しない。

## キャッシュ vs スナップショット

区別の意味は `## キャッシュとスナップショット` を正本とする。キャッシュの TTL Expiration は、スナップショットの Retention とは無関係である。

## スナップショット Creation

スナップショットの生成規則は [`domain_rules.md`](./domain_rules.md) を正本とする。キャッシュ Hit だけを理由に新規スナップショットを生成しない。

## キャッシュ Hit

Fresh キャッシュがある場合、それをカレント・データとして返す。

## キャッシュ Miss

キャッシュが欠ける場合、プロバイダから Fetch し、成功後にキャッシュを更新する。

## Stale-While-Revalidate

可能な場合、Stale キャッシュを表示しつつ Background Refresh する。見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、UI が Stale を Fresh Data と誤認しないことだけを定める。

## Background Revalidation

既存 Data がある Refresh の見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、Background Revalidation で既存キャッシュを消去してから Fetch しないことだけを定める。

## キャッシュ Stampede

同一 Resource に対して複数の Request が同時発生した場合、同一キャッシュ Entry への重複 Request を可能な限り抑制する。

## Request Coalescing

同一 Resource への同時リクエストを、可能な範囲で単一のプロバイダ・リクエストへまとめる。

## Concurrent Refresh

同一 Package の Refresh 要求が同時に複数発生した場合、無制限に API Request を発行しない。

## キャッシュ Lock

必要に応じて、キャッシュ・キー単位で Refresh 処理を Serialize する。

## キャッシュ Write

DTO ≠ ドメインは [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、ドメイン Validation 成功後にだけキャッシュ Write することだけを定める。

## Failed Fetch

HTTP エラー/デコード・エラー/ドメイン Validation エラーの場合、キャッシュを更新しない。

## Partial Fetch

一部指標のみ取得できた場合、Partial キャッシュ Entry として保存可能とする。

ただし Missing 指標を Zero に変換しない。

## Partial キャッシュ

Partial キャッシュには、指標単位の Availability を保持する。

* Downloads: Available
* Traffic: Unavailable

## プロバイダ固有キャッシュ

プロバイダごとにキャッシュ名前空間を分離する。

* `packagist:`
* `github:`

等を使用可能とする。

## Cross-プロバイダ Collision

下記を同一キャッシュ Entry として扱わない。

* `packagist:package:foo/bar`
* `github:repository:foo/bar`

## カレント・データ・モデル

Current キャッシュは、ドメイン・モデルまたは専用キャッシュ・モデルとして保持する。

## キャッシュ・モデル

永続化モデルとドメイン・モデルの分離は [`models_spec.md`](./models_spec.md) を正本とする。本仕様は、キャッシュ Record をマッパー経由でドメイン・モデルへ写すことだけを定める。

## キャッシュ・ストレージ

保存 HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、メモリ / HTTP / Local Persistence を利用してよいが、ドメイン層から具体的なフレームワークに依存しないことだけを定める。

## メモリ・キャッシュ

メモリ・キャッシュは、高速な Current セッション・キャッシュとして利用する。

アプリケーション Termination で消失してもよい。

## ディスク・キャッシュ

ディスク・キャッシュは、アプリケーション Restart 後にも再利用する必要がある場合に使用する。

## System-managed キャッシュ

プラットフォームが管理するキャッシュは、アプリケーションが完全な Persistence を保証できない。

## iOS `URLCache` 方針

iOS の HTTP 層では、`URLSessionConfiguration.requestCachePolicy` を利用してキャッシュ方針を制御可能とする。

Apple ではデフォルトの `useProtocolCachePolicy` が HTTP キャッシュ-Control 等に従う方針として定義されている。([developer.apple.com](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/requestcachepolicy?changes=l_9))

## iOS Ephemeral セッション

クレデンシャル (資格情報) や機密データを含む Request では、必要に応じて Ephemeral セッション等を利用する。

Ephemeral セッションは、キャッシュ/Cookie/クレデンシャル (資格情報) をディスクに保存しない。([developer.apple.com](https://developer.apple.com/documentation/foundation/urlsessionconfiguration))

## 機密 HTTP レスポンス

機密データを含む HTTP レスポンスについては、ディスク・キャッシュに保存しないことを基本とする。

## クレデンシャル (資格情報) -bearing Request

Authorization Header を含む Request については、HTTP キャッシュによる Data Leakage を避ける。

必要に応じて、

* No キャッシュ
* メモリ Only

等の方針を使用する。

## Public 統計

Packagist/GitHub の公開統計については、キャッシュを利用可能とする。

## Authorized 統計

Authentication/Authorization が必要な統計は、Public キャッシュと同一方針にしない。

## User 固有キャッシュ

User Account に依存する Data については、キャッシュ・キーに Account Identity を含める。

## Account Switch

Account が変更された場合、旧 Account のキャッシュを新 Account に誤って利用しない。

## Logout

Logout 時には、User 固有キャッシュを必要に応じて削除する。

クレデンシャル (資格情報) 削除方針は [`authentication_spec.md`](./authentication_spec.md) に従う。

## Public キャッシュ after Logout

Public Package Metadata 等については、Logout 後も保持可能とする。

ただし User 固有 Data と混同しないこと。

## キャッシュ Isolation

下記を別の名前空間として扱う。

* Public
* Account 固有
* クレデンシャル (資格情報) -related

## キャッシュ Encryption

キャッシュに機密データを保存する必要が生じた場合、プラットフォーム Data Protection 等を利用する。

ただし初期バージョンでは、機密データをキャッシュしないことを優先する。

## キャッシュ Logging

キャッシュ Value そのものを Production Log に出力しない。

## キャッシュ指標

Debug/Diagnostics では、

* キャッシュ Hit
* キャッシュ Miss
* Stale Hit
* Refresh
* Eviction
* Failure

等を計測可能とする。

## キャッシュ Hit Ratio

パフォーマンス Analysis のため、キャッシュ Hit Ratio を計測可能とする。

ただし Production UI で常時表示する必要はない。

## キャッシュ Telemetry

Telemetry を導入する場合も、Package 名や User Account 等の不要な Personal/機密 Data を送信しない。

## キャッシュ Eviction

キャッシュ容量を超えた場合、再取得コストが低い Data から Eviction 可能とする。

## Eviction Priority

メモリ・キャッシュでは Old / Least Recently Used 等の方針を利用可能とする。

## Historical Data Priority

Eviction 時にも、Historical スナップショットをキャッシュ Eviction の対象として扱わない。

## キャッシュ Capacity

キャッシュ容量には上限を設定可能とする。

## ディスク Pressure

デバイス・ストレージが不足した場合、キャッシュを優先的に削除可能とする。

## Data Priority

ストレージ Pressure 時の優先順位:

1. クレデンシャル (資格情報)
2. Historical スナップショット
3. User Preference
4. カレント・データ・キャッシュ
5. Temporary Data

ただしクレデンシャル (資格情報) はキャッシュ対象外である。

## キャッシュ Clear

ユーザーがキャッシュ Clear を実行した場合、

* Current キャッシュ
* HTTP キャッシュ
* Temporary キャッシュ

等を削除可能とする。

## キャッシュ Clear does not delete History

キャッシュ Clear では、「Historical スナップショット」を削除しない。

## キャッシュ Clear does not delete Favorites

キャッシュ Clear では、「Favorite」「Maintained」を削除しない。

## キャッシュ Clear Feedback

キャッシュ Clear 後には、次回アクセス時にプロバイダから再取得されることを明示可能とする。

## Automatic Invalidation

下記の場合、キャッシュを Invalidation 可能とする。

* TTL Expiration
* Manual Refresh
* Account Change
* スキーマ Change
* プロバイダ Change
* Data Corruption

## Package Removal

Package を Dashboard から削除した場合、その Package の Current キャッシュを削除可能とする。

Historical スナップショットは別方針とする。

## リポジトリ Change

Package のリポジトリ Association が変更された場合、旧リポジトリ・キャッシュを必要に応じて Invalidation する。

## プロバイダ API バージョン Change

プロバイダ API スキーマ変更によりキャッシュ Data が解釈できなくなった場合、キャッシュを破棄して再取得可能とする。

## キャッシュ Expiration

Expiration は キャッシュ Entry 単位で判定可能とする。

## Absolute Expiration

`expiresAt` による Absolute Expiration を基本とする。

## Sliding Expiration

初期バージョンでは、単純な Sliding Expiration を基本方針としない。

Data の Freshness が利用頻度によって無制限に延長されることを避けるためである。

## Revalidation

キャッシュが Stale になった場合、プロバイダへ Revalidate できる。

## HTTP Conditional Request

プロバイダ/HTTP Server が対応する場合、ETag/Last-Modified 等の Conditional Request を利用可能とする。

## `304` Not Modified

HTTP `304` 等で Data 変更がないことが確認できた場合、既存キャッシュの `fetchedAt` / expiration 方針を更新できる。

## HTTP Header 方針

HTTP キャッシュ-Control 等の Server 方針を可能な限り尊重する。

ただしアプリケーション・キャッシュ方針がより厳しい場合はアプリケーション方針を優先する。

## Server キャッシュ方針

Server のキャッシュ-Control を無条件に無視しない。

## アプリケーション TTL

アプリケーションが独自 TTL を設定する場合、Server 方針との整合性を考慮する。

## Freshness Display

Freshness 文言は [`ui.md`](./ui.md) を正本とする。本仕様は、キャッシュ層が `fetchedAt` を Presentation に渡せることだけを定める。

## キャッシュ Status Exposure

Fresh / Stale / Refreshing / Unavailable の伝達は `## キャッシュ状態 and UI` を正本とする。

## キャッシュ状態機械

状態の分類は `## キャッシュ状態` を正本とする。本仕様は、Missing → Fetching → Fresh、および Fresh → Expired → Stale の遷移だけを定める。Failure 時は Missing または Stale を維持する。

## キャッシュ Refresh 状態

既存 Data がある Refresh の見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、Refresh 中に Existing Data を Blank に戻さないことだけを定める。

## Refresh Cancellation

User が画面を離れた場合、不要な Refresh を Cancel 可能とする。

ただし Background スナップショット Collection 等とは独立した Lifecycle とする。

## Request Timeout

キャッシュ利用時にも、プロバイダ Request には適切な Timeout を設定する。

## 「キャッシュ」First

通常の UI 表示では、「キャッシュ」First を利用可能とする。

## 「Network」First

Explicit Refresh 等では、「Network」First を利用可能とする。

## 「キャッシュ」First 方針

Fresh キャッシュがあれば表示する。Missing / Stale のときは Fetch する。

## 「Network」First 方針

先に Fetch する。成功時はキャッシュを更新して表示し、失敗時は既存キャッシュがあればそれを使う。

## 方針の選択

ユースケースに応じて、キャッシュ First/Network First 等を選択する。

## Dashboard 方針

Dashboard 初期表示では、キャッシュ First を基本とする。

## Detail 方針

Package Detail では、Fresh キャッシュがあれば即時表示し、必要に応じて Background Refresh を行う。

## Manual Refresh 方針

Manual Refresh では、Network First を基本とする。

## Background 方針

Background Update では、API Request 数と Battery Consumption を考慮する。

## スナップショット Collection 方針

生成の不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。キャッシュ層では、キャッシュ Hit だけでスナップショットを作成せず、プロバイダ取得の成功を必要とする。

## Rate Limit

キャッシュはプロバイダ Rate Limit を考慮して設計する。

## Rate Limit Response

Rate Limit に到達した場合、無駄な Retry を繰り返さない。

既存キャッシュがあれば、Stale Data として利用する。

## Backoff

Retry 可能なプロバイダ・エラーについては、Exponential Backoff 等を利用可能とする。

## Retry Limit

無制限 Retry を行わない。

## キャッシュ Stampede Prevention

同一 Package について、複数 UI コンポーネントが同時に Refresh しても、プロバイダ Request を可能な限り統合する。

## Package List + Detail

List と Detail が同じ Package Data を要求する場合、同一キャッシュ Entry を共有可能とする。

## キャッシュ Consistency

キャッシュ更新後、同じキャッシュ・キーを参照する Consumer は可能な限り同一 Data を取得する。

## Atomic キャッシュ Update

複数指標を一括更新する場合、Partial Write による不整合を避ける。

## Current 統計キャッシュ

Current 統計を保存する場合、

* Package
* プロバイダ
* 指標
* Period
* FetchedAt

を考慮する。

## カレント・データ vs Historical Data

Current 統計キャッシュが更新されても、Historical スナップショットを上書きしない。

## スナップショット Generation Example

生成の不変条件は [`domain_rules.md`](./domain_rules.md) を正本とする。本仕様は、プロバイダ取得成功後に Current キャッシュを更新し、その後スナップショット方針に従って Historical 行を書くことだけを定める。

## キャッシュ Failure

キャッシュ Write に失敗しても、プロバイダから取得したカレント・データを UI に表示可能とする。

## キャッシュ Read Failure

キャッシュ Read に失敗しても、プロバイダ Fetch に Fallback 可能とする。

## キャッシュ・ストレージ Failure

キャッシュ・ストレージそのものが利用不能でも、Network Fetch が可能ならアプリケーションを継続可能とする。

## キャッシュ as Optional Optimization

キャッシュは、「アプリケーションの Correctness に必須ではないが、パフォーマンス/オフライン Capability を改善するもの」として扱う。

## オフライン Dependency

完全オフラインでカレント・データを表示する場合は、キャッシュが必要となる。

ただしオフライン表示自体をドメイン Rule として必須化しない。

## キャッシュ Purge

OS/プラットフォームによるキャッシュ Purge を正常な状態として扱う。

## キャッシュ Rebuild

キャッシュ Purge 後は、プロバイダ Fetch により Rebuild できることを基本とする。キャッシュ破損時はキャッシュを破棄し、Historical スナップショットは保持する。

## キャッシュ・バックアップ

キャッシュをバックアップ対象の重要 User Data として扱わない。

## キャッシュ Migration

デバイス Migration 時にキャッシュが失われても、Historical スナップショット/User Preference が保持されていれば正常とする。

## キャッシュ Export

通常、キャッシュを User Export 対象としない。

Export 対象は Historical Data/User Data を優先する。

## キャッシュ・セキュリティ

キャッシュには、

* Password
* Token
* Secret

を含めない。

## キャッシュ Privacy

キャッシュに不要な Personal Data を保存しない。

## Public Data

Packagist/GitHub の公開 Package Metadata や Public 統計はキャッシュ可能とする。

## User 固有 Data

User 固有 Data は、Account Identity を考慮してキャッシュする。

## Account Isolation

Account A のキャッシュを Account B のセッションから利用しない。

## Logout キャッシュ方針

Logout 時、Account 固有キャッシュは削除する。

Public キャッシュは保持可能とする。

## Authentication 状態

Authentication 状態の変更によって、キャッシュ Data の Availability が変化する場合がある。

## Authorization キャッシュ

Authorization Result 自体を長期間キャッシュしない。

必要な場合は短い TTL を利用する。

## Permission Revocation

Permission が Revoked された場合、該当する Authorized キャッシュを Invalidation する。

## セキュリティ境界

クレデンシャルの分離は [`authentication_spec.md`](./authentication_spec.md) / [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、キャッシュ層をクレデンシャル・ストレージから分離することだけを定める。

## キャッシュ Diagnostics

Debug 画面では必要に応じて、

* キャッシュ Size
* Entry Count
* Hit Count
* Miss Count
* Stale Count
* Last Cleanup

を表示可能とする。

## Production Diagnostics

Production UI では、Technical キャッシュ情報を通常ユーザーに公開しない。

## キャッシュ・テスト

最低限、下記を Unit テストする。

* キャッシュ Hit
* キャッシュ Miss
* Fresh
* Stale
* Invalid
* Expiration
* Refresh
* Refresh Failure
* Clear
* Eviction

## キャッシュ Consistency テスト

Package List と Package Detail が同一キャッシュ Entry を利用しても不整合が起きないことを確認する。

## Concurrent Access テスト

同一キャッシュ・キーへの Concurrent Read/Write をテストする。

## Request Coalescing テスト

同一 Resource への Concurrent Fetch が不必要に複数 Request を発生させないことを確認する。

## オフライン・テスト

下記を検証する。

* Fresh キャッシュ + オフライン
* Stale キャッシュ + オフライン
* No キャッシュ + オフライン

## Rate Limit テスト

プロバイダ Rate Limit 時に、既存キャッシュと Rate Limit エラーを同時に扱えることを確認する。

## Account Isolation テスト

* Account A キャッシュ
* Account B セッション

が混同されないことを確認する。

## キャッシュ Clear テスト

キャッシュ Clear 後に、

* Favorite
* Maintained
* Historical スナップショット

が削除されないことを確認する。

## スナップショット Isolation テスト

キャッシュ Invalidation/Clear によって Historical スナップショットが変更されないことを確認する。

## Migration テスト

キャッシュ・スキーマ・バージョンが変更された場合、`Compatible` なら Migration、`Incompatible` なら Discard + Re-fetch できることを確認する。

## パフォーマンス・テスト

下記を測定可能とする。

* Cold Start
* キャッシュ Hit
* キャッシュ Miss
* Stale-While-Revalidate
* Large キャッシュ Read
* Large キャッシュ Clear

## メモリ Pressure

メモリ・キャッシュは、メモリ Pressure 時に解放可能とする。

ディスク/Persistent キャッシュに必要に応じて Fallback する。

## Battery

Background Refresh では、過剰な Polling を行わない。

## Network Efficiency

キャッシュは、プロバイダ API Request 削減を目的とする。

同一 Data を短時間に繰り返し取得しない。

## Data Freshness vs Network Cost

Freshness を高めるために無制限に API Request を行わない。

## User インテント Priority

Explicit Refresh は、通常の Automatic キャッシュ方針より優先される。

## System Constraints

Background Execution、Network Availability、Battery 等のプラットフォーム Constraint を考慮する。

## プラットフォーム Independence

ドメイン・キャッシュ方針は、iOS/iPadOS/Android で同じセマンティクスを持つ。

## プラットフォーム固有 Implementation

保存 HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、HTTP キャッシュ / メモリ / SQLite 系をプラットフォーム実装としてよいことだけを定める。

## Kotlin Multiplatform (KMP) 境界

共有対象は [`architecture.md`](./architecture.md) を正本とする。本仕様は、TTL / Freshness / Invalidation / キャッシュ・キーを共有方針とし、ストレージ実装をアダプタに置くことだけを定める。

## プラットフォーム・キャッシュ・アダプタ

KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、共有キャッシュ方針を `CacheRepository` 経由でプラットフォーム・アダプタに実装することだけを定める。

## Swift Implementation

保存 HOW は [`ios_spec.md`](./ios_spec.md) を正本とする。本仕様は、iOS でキャッシュ方針を Swift 実装してよいが、ドメイン・ロジックを SwiftUI / SwiftData / URLCache に依存させないことだけを定める。

## KMP Migration

共有に移す順序は [`architecture.md`](./architecture.md)、HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、キャッシュ方針を共有ロジックへ移行可能な構造とすることだけを定める。

## キャッシュ Rule バージョン

キャッシュ方針を変更する場合、必要に応じて、`cachePolicyVersion` を更新する。

## TTL 変更

TTL 変更によって Historical スナップショットを変更しない。

## キャッシュ方針 Changes

キャッシュ方針変更時は、

* TTL
* Invalidation
* ストレージ
* セキュリティ
* API Request Frequency
* Battery Impact

を確認する。

## No Silent Historical Change

キャッシュ方針変更によって Historical スナップショットの意味を変更してはならない。

## キャッシュ Lifecycle

基本 Lifecycle: プロバイダ → Fetch → Validate → キャッシュ → Fresh → Stale → Revalidate。Revalidate 成功なら Fresh、失敗なら Stale のまま、必要時に Eviction/Clear する。

## キャッシュ状態 and UI

Fresh / Stale / Refreshing / Unavailable の見え方は [`ui.md`](./ui.md)、状態分類は [`application_state.md`](./application_state.md) を正本とする。本仕様は、キャッシュ層がそれらの状態を Presentation に伝達できることだけを定める。

## カレント・データ Presentation

Value / Source の意味は [`statistics_spec.md`](./statistics_spec.md)、Updated At / Freshness の見え方は [`ui.md`](./ui.md) を正本とする。本仕様は、キャッシュ層がそれらを Presentation に渡せるように保持することだけを定める。

## No False Freshness

Stale を Fresh に見せないことは [`ui.md`](./ui.md) を正本とする。本仕様は、Stale キャッシュを Current/Fresh Data として扱わないことだけを定める。

## No False Availability

`0` と欠測の区別は [`domain_rules.md`](./domain_rules.md) を正本とする。本仕様は、Authorization Failure をキャッシュ Missing = 0にしないことだけを定める。

## No キャッシュ-derived スナップショット

キャッシュから読み出しただけの Data を新しいスナップショットとして記録しない。

## キャッシュ and Historical Accuracy

Historical スナップショットは、キャッシュ TTL に左右されない。

スナップショット Collection 方針に従って独立して管理する。

## ストレージ境界

キャッシュは、[storage_spec.md](./storage_spec.md) で定義された Persistent ストレージの補助層として扱う。

## キャッシュ Persistence

キャッシュ Persistence は、プラットフォーム/Implementation に応じて変更可能とする。

## Persistent キャッシュ vs スナップショット

キャッシュとスナップショットの分離は `## キャッシュとスナップショット` を正本とする。本仕様は、Persistent キャッシュがあっても Historical スナップショットと同一視しないことだけを定める。

## キャッシュ Deletion

キャッシュ Deletion は、通常の User Data Deletion とは異なる。

## User-visible Meaning

ユーザー向けには、`Clear キャッシュ` を、「次回表示時に最新 Data を再取得します。」という意味として扱う。

## キャッシュ仕様 Summary

基本方針は `## キャッシュの基本原則` を正本とする。v1固有の制約は、キャッシュを Local に限り、Cross-デバイス同期と External キャッシュ Server を必須としないこととする。
