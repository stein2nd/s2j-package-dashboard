# S2J Package Dashboard - セキュリティ・権限・プライバシー仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、セキュリティ/権限/プライバシーを定義します。

外部 API、OS セキュリティ・モデル、Kotlin Multiplatform (KMP)、サードパーティ製 SDK、クラウド同期等の変更に応じて更新する。

セキュリティ上重大な変更については、ADR およびセキュリティ・レビューを実施する。

## 目的

本ドキュメントでは、セキュリティ、権限およびプライバシーに関する仕様を定義する。ユーザーデータ保護、安全な通信、最小権限、個人情報の最小化、オフライン/バックアップ時のセキュリティ、プラットフォーム間の方針一貫を目的とする。

## 非目的

本仕様は、認証そのものの詳細、特定 OS API の呼び出し手順、サードパーティ SDK の導入を目的としない。

## 責務

セキュリティ原則、権限、プライバシー、ログに Secret を出さないこと、Fail Securely を正本とする。

## 非責務

認証/クレデンシャルは [`authentication_spec.md`](./authentication_spec.md) を正本とする。API 固有のセキュリティは各 API 仕様、ストレージ実装差分は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md)、共有対象は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md)、検証の種類は [`testing_spec.md`](./testing_spec.md)、Release 可否は [`release.md`](./release.md) を参照する。

## セキュリティ原則

S2J Package Dashboard では、下記を基本原則とする。

1. Least Privilege
2. データの最小化
3. Secure by Default
4. プライバシー by Design
5. 「匿名」ファースト
6. 「ローカル」ファースト
7. クレデンシャル (資格情報) の分離
8. Secure ストレージ
9. Explicit Consent
10. Fail Securely

## セキュリティ境界

アプリケーション全体を下記の境界に分離する。層の依存方向は [`architecture.md`](./architecture.md) を正本とする。本仕様は、クレデンシャル境界 (Secure ストレージ) を通常のインフラストラクチャー (Packagist / GitHub / ストレージ) から分離することだけを定める。クレデンシャル (資格情報) は通常のアプリケーション・データと分離する。

## 脅威モデル

主要な脅威 Actor: ネットワーク Attacker / 不正アプリケーション / 不正 User / Stolen デバイス / 侵害されたデバイス / Reverse Engineer / Supply-chain Attacker / Accidental 開示。

すべての脅威を完全に防止することを目的とせず、アプリケーションの Risk を合理的に低減する。

## 保護対象アセット

保護対象: Packagist / GitHub クレデンシャル、アカウント・メタデータ、お気に入り Packages、統計スナップショット、User Preferences、キャッシュ済み API データ、アプリケーション Configuration、ソースコード/Signing アセット。

特に API Token / アクセス Token / リフレッシュ Token / 認証 Secret をハイ・センシティブとして扱う。分類は [`authentication_spec.md`](./authentication_spec.md) を正本とする。

## データの分類

アプリケーション・データを下記に分類する。

### 公開

外部サービスから公開されている情報。

* パッケージ名
* パッケージ説明
* パッケージ・バージョン
* GitHub スター数
* GitHub フォーク数
* 公開リリース
* 公開ダウンロード統計

### 内部

ユーザー固有だが、クレデンシャル (資格情報) そのものではない情報。

* 「お気に入り」
* User Preferences
* 統計スナップショット
* キャッシュ
* Display Settings

### 機密

認証/クレデンシャル (資格情報) に関連する情報。

* API Token
* アクセス Token
* リフレッシュ Token
* 認証 Secret

## データの最小化

アプリケーションは、目的達成に必要なデータだけを取得・保存する。

たとえば、

* ユーザー名称
* Email Address
* Profile 情報

等が API 応答に含まれていても、ダッシュボードに不要であればドメイン・モデルに取り込まない。

## 利用目的の限定

取得したデータは、取得時に定めた目的以外に利用しない。例: GitHub トラフィックは統計可視化にのみ使う。Advertising / User Profiling に利用しない。

## 「匿名」ファースト

公開情報の取得については認証を要求しない。不要なクレデンシャル付与の禁止は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、匿名ファーストが脅威低減 (Token 露出面の縮小) であることだけを定める。

## 外部サービスデータ

外部サービスから取得したデータについて、

* Packagist データ
* GitHub データ

を、それぞれのソース情報として保持する。

異なるプロバイダから取得したデータを、ユーザー情報として勝手に統合しない。

## クレデンシャル (資格情報) の分離

クレデンシャル (資格情報) をアプリケーション・データから分離する方針は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、分離が破れた場合の脅威 (ログ、バックアップ、権限) を扱う。

## Secure ストレージ

クレデンシャル (資格情報) はプラットフォームが提供する Secure ストレージを利用する。何を置いてよいかは [`authentication_spec.md`](./authentication_spec.md)、Keychain の HOW は [`ios_spec.md`](./ios_spec.md)、Keystore の HOW は [`android_spec.md`](./android_spec.md) を正本とする。

## Kotlin Multiplatform (KMP) セキュリティ境界

KMP 移行後も、プラットフォーム固有 Secure ストレージを Common Code に直接持ち込まない。配置は [`kmp_spec.md`](./kmp_spec.md) を正本とする。

## パスワード方針

パスワードを保存しないことは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、パスワードがデータベース / UserDefaults / SharedPreferences / ファイルに残らないことだけを定める。

## Token 方針

Token について下記を禁止する。

* ソースコードへの埋め込み
* リポジトリへの Commit
* アプリケーション・バンドルへの固定値埋め込み
* 通常 Log への出力
* アナリティクスへの送信
* クラッシュ・レポートへの送信
* スクリーンショットへの表示
* クリップボードへの自動保存

## Token の表示

生の Token を UI に出さない。必要な場合はマスクする。全文を再表示する機能は提供しない。UI に出してよい状態の一覧は [`authentication_spec.md`](./authentication_spec.md) を正本とする。

## ネットワーク・セキュリティ

外部 API との通信には HTTPS を必須とする。`http://` は Reject、`https://` は Allowed。本番環境で HTTP 通信に Fallback しない。

## TLS

TLS 証明書検証を無効化しない。

禁止:

* Trust All Certificates
* Disable Certificate 検証
* Ignore TLS エラー

Development Environment で例外を設ける場合、本番ビルドに含めない。

## API ホスト規制

クレデンシャル (資格情報) を送信するホストを限定する。例: Packagist クレデンシャルは Packagist API、GitHub クレデンシャルは GitHub API。GitHub クレデンシャル (資格情報) を Packagist ホストに送信しない。

## 認可ヘッダー

認可ヘッダーをロギングしない。

例:

`Authorization: Bearer <redacted>`

HTTP Debug Logger を使用する場合も、クレデンシャル (資格情報) を Redact する。

## URL クレデンシャル (資格情報) 方針

クレデンシャル (資格情報) を URL に含めない。

禁止:

`https://example.com/api?token=SECRET`

原則として HTTP 認可ヘッダー等を利用する。

プロバイダ固有仕様については各 API 仕様を正本とする。

## HTTP リダイレクト

クレデンシャル (資格情報) 付きリクエストが、意図しないホストにリダイレクトされた場合にクレデンシャル (資格情報) を送信しない。

リダイレクト時には、Original ホストからリダイレクト・ホストへ移る前にクレデンシャル Scope Check を行う。

## キャッシュ・セキュリティ

API 応答をキャッシュする場合、クレデンシャル (資格情報) を含む応答を通常キャッシュに保存しない。

キャッシュには必要な公開/アプリケーション・データのみを保存する。

## デリケートな対応

認可済み API 応答に個人情報やクレデンシャル (資格情報) 関連データが含まれる場合、必要な情報だけをドメイン・モデルにマッピングする。

不要な応答全体を永続保存しない。

## アプリケーション・ストレージ

アプリケーション・ストレージには下記を保存可能とする。

* 「お気に入り」
* Package メタデータ・キャッシュ
* GitHub リポジトリ・キャッシュ
* 統計スナップショット
* User Preferences
* UI Preferences

クレデンシャル (資格情報) は除外する。

## 「統計」プライバシー

統計スナップショットには、必要な統計値のみを保存する。

例:

* `repository`
* `metric`
* `value`
* `capturedAt`
* `source`

不要な User ID を一緒に保存しない。

## 「お気に入り」プライバシー

お気に入りは User Preference として扱う。お気に入り情報を外部サービスに送信しない。初期バージョンでは Server に送信しない。

## 「ローカル」ファースト・プライバシー

初期バージョンでは、ユーザー固有データを S2J Package Dashboard 独自 Server に送信しないことを基本とする。ユーザーデータはデバイス上に置く。

## アカウント登録は必須ではない

S2J 独自アカウントを必須としないことは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、Install → Launch だけで公開データを使えることがプライバシー方針であることだけを定める。

## 権限の最小化

OS 権限は必要になった場合のみ要求する。権限が不要な機能ではリクエストしない。

## 権限一覧

初期バージョンでは、可能な限り追加 OS 権限を必要としない設計を目指す。

想定:

* ネットワーク: Required
* 通知: Optional/Future
* Photos / Contacts / Location / Bluetooth / Microphone / Camera: Not Required

不要な権限を要求しない。

## ネットワーク権限

ネットワーク通信は本アプリケーションの主要機能である。

Packagist/GitHub API に HTTPS 通信する。

ネットワーク障害時にも、ローカル・キャッシュが存在する場合は可能な範囲でオフライン表示する。

## 通知

通知機能を実装する場合、ユーザーによる明示的な Opt-in を基本とする。

たとえば:

* パッケージ更新の通知
* セキュリティ告知の通知

等を将来実装する場合も、通知権限をアプリケーション起動時に無条件要求しない。

## バックグラウンド処理

バックグラウンド処理を利用する場合、下記の目的に限定する。

* 統計スナップショット
* パッケージ更新 Check
* セキュリティ告知 Check

バックグラウンド処理で取得するデータは、Foreground 処理と同じプライバシー方針に従う。

## バックグラウンド・クレデンシャル (資格情報)

バックグラウンド処理でクレデンシャル (資格情報) を使用する場合でも、クレデンシャル をバックグラウンド Task の引数、Persistent Job データ、Log 等に保存しない。

クレデンシャルは実行時に Secure ストレージから取得する。

## アプリケーションのライフサイクル

アプリケーションがバックグラウンドに移行した場合、機密 UI データを可能な限り保護する。

特に App Switcher スナップショット等に、

* Token
* 非公開リポジトリ
* アカウント情報

が表示されないようにする。

プラットフォーム固有の対策はプラットフォーム仕様で定義する。

## クリップボード

アプリケーションからクレデンシャル (資格情報) をクリップボードに自動コピーしない。

お気に入り/パッケージ名等のユーザーが明示的に Copy した 公開/Internal データについては、通常のクリップボード方針に従う。

## 共有シート

Share 機能を提供する場合、クレデンシャル (資格情報) や機密データを Share 対象に含めない。

たとえばパッケージ共有では、

* パッケージ名
* Package URL
* リポジトリ URL

等を共有可能とする。

Token を含む URL を生成しない。

## スクリーンショット

通常の UI にクレデンシャル (資格情報) を表示しない。

また、認可済みユーザーデータを表示するスクリーンについて、必要に応じてスクリーンショット/画面キャプチャーへの対策を検討する。

プラットフォーム固有の仕様は、

* [`ios_spec.md`](./ios_spec.md)
* [`android_spec.md`](./android_spec.md)

で定義する。

## ロギング

Log には下記を出力しない。

*  パスワード
* API Token
* アクセス Token
* リフレッシュ Token
* 認可ヘッダー
* 非公開キー
* クライアント Secret

## 本番ロギング

本番ビルドでは、Debug 目的の詳細 HTTP ロギングを無効化する。

必要な Diagnostic 情報のみをロギングする。

## エラーメッセージ

ユーザー向けエラーメッセージに、

* アクセス Token
* 認可ヘッダー
* Internal URL
* 非公開リポジトリ・データ

等を含めない。

## クラッシュ報告

クラッシュ報告を導入する場合、機密データを送信しない。

最低限、

* クレデンシャル (資格情報)
* Token
* 非公開リポジトリ・コンテンツ
* User 個人情報

を除外する。

## アナリティクス

アナリティクスを導入する場合、プライバシー-by-Default とする。

送信してよい情報:

* スクリーン View
* Feature Usage
* パフォーマンス指標
* Crash-free 状態

送信しない情報:

* Token
* パスワード
* Email Address
* 非公開リポジトリ名
* お気に入り Package List
* Raw API 応答

アナリティクス導入時には、収集項目を別途明示する。

## ユーザー識別

初期バージョンでは、S2J Package Dashboard 独自の User ID を発行しない。

外部サービスのアカウント ID を利用する場合も、必要な目的に限定する。

## サードパーティ製 SDK

サードパーティ製 SDK を追加する場合、セキュリティ/プライバシー・レビューを実施する。

確認項目:

* データ・コレクション
* データ Transmission
* 権限
* Tracking
* クラッシュ報告
* アナリティクス
* ネットワーク Access
* Third-party Servers

目的が不明確な SDK を導入しない。

## 依存関係セキュリティ

外部の依存関係について、下記を確認する。

* ソース
* バージョン
* License
* セキュリティ告知
* メンテナンス Status

依存関係の更新時には、既知のセキュリティ Vulnerability を確認する。

## サプライチェーン・セキュリティ

依存関係/ビルドツールについて、可能な限りバージョンを Pin または再現可能な状態にする。

CI で依存関係を取得する場合、信頼できるレジストリ/ソースのみを利用する。

## ビルドのセキュリティ

リリース・ビルドでは、

* Debug ロギング
* テスト クレデンシャル (資格情報)
* Development エンドポイント
* Debug Flag

を含めない。

Development Configuration と Production Configuration を分離する。

## ソースコード中の Secret

下記をソースコードに Commit しない。

* API Token
* 非公開キー
* パスワード
* クライアント Secret
* Signing クレデンシャル (資格情報)

## CI Secret

CI で Secret が必要な場合は、CI プロバイダの Secret Store を利用する。

Secret を、

* リポジトリ
* Workflow ファイル
* .plist
* .json
* .env

等に Commit しない。

## Secret スキャン

リポジトリで Secret スキャンを有効化することを推奨する。

誤 Commit が発生した場合、Detection → 無効化 → Rotation → Cleanup を実施する。

Git 履歴から文字列を削除するだけでは、クレデンシャル (資格情報) が有効なまま残る可能性があるため、無効化/Rotation を優先する。

## コード署名

リリース・ビルドはプラットフォームのコード署名を利用する。

* iOS/iPadOS: Apple コード署名
* Android: Android App 署名

署名クレデンシャル (資格情報) をソース・リポジトリに保存しない。

## リバース・エンジニアリング

Mobile アプリケーションは、完全に Secret を隠蔽できる環境ではないことを前提とする。

そのため、

* API Secret
* クライアント Secret
* 非公開キー

等をネイティブ・アプリケーションに埋め込まない。

## 公開クライアント原則

iOS/iPadOS/Android アプリケーションを完全に Trust されたクライアントとはみなさない。

アプリケーション・バンドルに含まれる情報は、最終的に解析可能であることを前提とする。

## クライアント Secret

OAuth 等でクライアント Secret が必要な場合、ネイティブ・アプリケーションに埋め込まない。

必要な場合は、バックエンドを介したフロー、またはプロバイダがネイティブ・アプリケーション向けに提供する適切な認証フローを利用する。

認証方式については、[`authentication_spec.md`](./authentication_spec.md) を参照する。

## データのエクスポート

将来、データのエクスポート機能を提供する場合、エクスポート対象を明示する。例: お気に入り / 統計 / Preferences。クレデンシャル (資格情報) はエクスポートしない。

## バックアップ

通常のアプリケーション・バックアップにはクレデンシャル (資格情報) を含めない。お気に入り / 統計 / Preferences / キャッシュはバックアップしてよい。クレデンシャルは Secure ストレージ方針に従う。デバイス移行時にクレデンシャルが復元されない場合は、Reauthentication を Recovery 手段とする。

## 復元

復元されたアプリケーション・データを、信頼できるクレデンシャル (資格情報) として扱わない。復元されたデータベースにクレデンシャル参照があっても、Secure ストレージに実体があることを確認する。

## デバイス紛失

デバイスを紛失した場合、アプリケーション・データが漏洩する Risk を低減する。

クレデンシャル (資格情報) はプラットフォーム Secure ストレージを利用する。

ユーザーは必要に応じて、Packagist/GitHub 側から Token を Revoke できる。

## クレデンシャル (資格情報) 無効化

クレデンシャル (資格情報) 無効化については、[`authentication_spec.md`](./authentication_spec.md) の仕様に従う。

セキュリティ仕様では、侵害 suspected → Revoke → Rotate → Reauthenticate という Recovery 方針を定義する。

## 不正アクセス

不正アクセスを検出した場合、下記を区別する。

* 認証障害
* 認可障害
* ネットワーク障害
* プロバイダ障害

アプリケーション全体を停止せず、影響範囲を限定する。

## 部分的な障害

外部サービスのセキュリティ障害によって、別サービスの公開データを利用不能にしない。

例: GitHub 認証が Failed でも Packagist 公開データは Still Available とする。

## プライバシー境界

プライバシー上の境界: お気に入り / 統計 / Preferences / クレデンシャルは User デバイス上に置き、外部へは Packagist/GitHub へ HTTPS のみとする。初期バージョンでは、S2J Package Dashboard 独自バックエンドを介在させない。

## クレデンシャル (資格情報) バックエンドなし

初期バージョンでは、S2J Package Dashboard 独自バックエンドにクレデンシャル (資格情報) を送信・保存しない。

* Packagist Token X S2J Server
* GitHub Token X S2J Server

## ユーザー・トラッキングなし

初期バージョンでは、ユーザーのアプリケーション利用行動を個人単位で追跡しない。

特に、

* Viewed パッケージ
* お気に入りパッケージ
* GitHub アカウント
* Packagist アカウント

等をユーザー識別情報と結び付けて外部に送信しない。

## プライバシー開示

App Store/Google Play 等で公開する場合、実際のデータ・コレクションについて、各プラットフォームのプライバシー開示に正確に反映する。

仕様と実際のデータ・コレクションが一致することを必須とする。

## プライバシー方針

外部プライバシー方針を提供する場合、最低限、下記を明示する。

* Collect するデータ
* Collect しないデータ
* データの用途
* データの保存場所
* Third-party サービス
* データ Sharing
* データの保持
* データの削除
* クレデンシャル (資格情報) Handling
* Contact 情報

## データの保持

アプリケーション・データについて、不要になったキャッシュを無期限に保持しない。TTL / Expiration は [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様は、期限切れキャッシュを Delete することだけを定める。統計スナップショットについては、長期傾向の表示という目的に必要な期間を定義する。

## データの削除

ユーザーがサービスとの Connection を解除した場合、クレデンシャル (資格情報) を削除する。削除手順は [`authentication_spec.md`](./authentication_spec.md) の接続解除を正本とする。本仕様は、アプリケーション・データをクレデンシャルと独立した保持方針とすることだけを定める。

## データの完全リセット

将来的に、設定に「すべてのアプリケーション・データをリセット」を提供する場合、下記を明示的に分類して削除する。

* お気に入り
* 統計
* キャッシュ
* Preferences
* クレデンシャル (資格情報)

クレデンシャル (資格情報) は Secure ストレージから削除する。

## 認証境界

認証の HOW は [`authentication_spec.md`](./authentication_spec.md)、本仕様はアプリケーションとデータの保護を正本とする。認証仕様をセキュリティ仕様に重複記載しない。

## 権限境界

OS 権限と外部 API 権限を区別する。OS 権限は iOS/Android capability、API 権限は Packagist/GitHub capability とする。たとえば GitHub トラフィック権限は、iOS の OS 権限ではない。

## プラットフォーム・セキュリティ

Keychain / Keystore の HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とする。本仕様は、OS の Sandbox / コード署名 / 権限モデルを利用し、独自の同等機構を実装しないことだけを定める。

## Kotlin Multiplatform (KMP) セキュリティ

KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、セキュリティ方針を Common 仕様として維持し、Secure ストレージ実装をプラットフォームに置くことだけを定める。

## セキュリティ・テスト

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、OWASP MASVS を参考基準とすることだけを定める。

OWASP MASVS は Mobile アプリケーション のストレージ、Cryptography、認証、ネットワーク、プラットフォーム、Code、Resilience、プライバシー等を対象とする。([OWASP MASVS - OWASP Mobile Application Security](https://mas.owasp.org/MASVS/))

## セキュリティ・テスト・カテゴリー

検証対象の種類は [`testing_spec.md`](./testing_spec.md) の Security Tests を正本とする。本仕様は、ログ / バックアップ / 漏洩面を脅威面として扱うことだけを定める。

## Secure ストレージ・テスト

保存 HOW の検証は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md)、検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、通常ストレージにクレデンシャルが残らないことだけを定める。

## ネットワーク・テスト

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、本番で HTTPS 以外に Fallback しないことだけを定める。

## クレデンシャル (資格情報) 漏洩テスト

脅威面 (ログ / クラッシュ / アナリティクス / スクリーンショット) は本仕様、検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。

## プライバシー・テスト

プライバシー方針は本仕様、検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。

## 依存関係セキュリティ・テスト

検証の種類は [`testing_spec.md`](./testing_spec.md) を正本とする。本仕様は、既知脆弱性をリリース前に確認することだけを定める。

## リリース・セキュリティ・チェックリスト

Release 可否は [`release.md`](./release.md) を正本とする。本仕様は、Debug ログ / テスト用 Secret / 不要権限が本番に残らないことだけを定める。

## インシデント対応

クレデンシャル (資格情報) 漏洩等のセキュリティ・インシデントが発生した場合: Detection → Containment → クレデンシャル無効化 → Rotation → Impact Assessment → Remediation → Verification。

## 侵害されたクレデンシャル (資格情報)

クレデンシャル (資格情報) が漏洩した可能性がある場合、アプリケーション内での削除だけではセキュリティ・インシデントが解決したとはみなさない。

下記を基本とする。ローカル・デリート、プロバイダ Revoke、クレデンシャル Rotation をそろえて実施する。

## セキュリティ・ドキュメント

セキュリティ上重要な設計判断は ADR に記録する。

例:

* ADR-SEC-001: Packagist パスワードを保存しない
* ADR-SEC-002: GitHub トラフィック取得時のみ 認証
* ADR-SEC-003: クレデンシャル (資格情報) を独自バックエンドに保存しない
* ADR-SEC-004: 統計スナップショットとクレデンシャル (資格情報) を分離する

## セキュリティ・レビュー

下記の変更にはセキュリティ・レビューを実施する。

* New クレデンシャル (資格情報)
* New 権限
* New 外部サービス
* New サードパーティ製 SDK
* New バックエンド
* New アナリティクス
* New 個人情報
* New 認証フロー
* New バックグラウンド処理
* New データのエクスポート
* New クラウド同期

## セキュリティ・レビュー質問

変更時には最低限、下記を確認する。

1. 新しい機密データを扱うか
2. 新しい権限が必要か
3. クレデンシャル (資格情報) を扱うか
4. 新しい外部サービスに送信するか
5. ローカル・ストレージに何を保存するか
6. バックアップ対象になるか
7. Log に出る可能性があるか
8. アナリティクスに送信されるか
9. Kotlin Multiplatform (KMP) 共有ロジックに持ち込むべきか
10. プラットフォーム固有セキュリティ機構が必要か

## セキュリティ要件

本アプリケーションは、最低限、下記を満たす。

* SEC-001: クレデンシャル (資格情報) を Plain Text ストレージに保存しない。
* SEC-002: パスワードを保存しない。
* SEC-003: HTTPS 以外でクレデンシャル (資格情報) を送信しない。
* SEC-004: 認可ヘッダーを Log に出力しない。
* SEC-005: 不要な OS 権限を要求しない。
* SEC-006: 不要な個人情報を収集しない。
* SEC-007: クレデンシャル (資格情報) とアプリケーション・データを分離する。
* SEC-008: 公開 API 利用時に不要な Authentication を要求しない。
* SEC-009: サードパーティ製 SDK 追加時にセキュリティ・レビューを実施する。
* SEC-010: リリース・ビルドにテストクレデンシャル (資格情報) を含めない。
* SEC-011: クレデンシャル (資格情報) を独自バックエンドに保存しない。
* SEC-012: セキュリティ・インシデント発生時にクレデンシャル (資格情報) 無効化を可能とする。

## セキュリティ要件のトレーサビリティ

セキュリティ要件は実装およびテストと対応付ける。例: SEC-001→ `SecureCredentialStore` → `SecureStorageTests`。SEC-003→ HTTPS API クライアント → `NetworkSecurityTests`。SEC-005→ 権限 Configuration → `PermissionReview`。

## セキュリティ標準

本アプリケーション では、OWASP Mobile アプリケーション セキュリティ Verification 標準 (MASVS) を Mobile セキュリティのリファレンス標準 とする。

MASVS は iOS/Android を含む Mobile アプリケーションを対象としており、Consumer/Enterprise 双方の Deployment Scenario を想定している。([About the Standard - OWASP Mobile Application Security](https://mas.owasp.org/MASVS/02-Frontispiece/))

ただし、MASVS のすべての Control を無条件に実装することを意味しない。

S2J Package Dashboard の脅威モデルおよび Risk に応じて適用範囲を決定する。

## セキュリティ/プライバシー優先度

セキュリティと UX が競合する場合、クレデンシャル (資格情報)、個人情報および外部アカウントを保護することを優先する。

ただし、ユーザー操作を過度に複雑化しない。

基本方針は Secure / Usable / Minimal を同時に満たすこととする。
