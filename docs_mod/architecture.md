# S2J Package Dashboard - アーキテクチャー仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、ソフトウェア・アーキテクチャーの責務分担と依存関係を定義します。

実装過程で発見された制約、API 仕様、パフォーマンス要件、セキュリティ要件等により変更する場合があります。変更する場合は、既存仕様との整合性を確認し、必要に応じて ADR を作成します。

## 目的

本仕様は、S2J Package Dashboard のソフトウェア・アーキテクチャー方針を定義します。共有ロジック / プラットフォーム UI、Swift 先行、移植容易な範囲、ビルドに Xcode、という境界の正本です。

本アプリケーションは、Packagist API および GitHub API から取得した Composer パッケージ/リポジトリ情報を統合し、iOS/iPadOS 上でパッケージの探索、管理、統計情報の可視化を行います。

最終的な方針は、「ロジックは共有、UI はプラットフォーム別」です。初期実装では Swift/SwiftUI を使用し、初期実装を不必要に KMP に依存させません。

## 非目的

本仕様は、初期実装で Kotlin コードを導入すること自体を目的としません。KMP の source set / expect/actual / 移行手順を定義しません。

## 責務

層構造、依存関係の方向、共有ロジックの対象と優先順位、ドメイン/API/ストレージ/プレゼンテーション境界、プラットフォーム境界を定義します。

## 非責務

KMP 実施時の実装境界は [`kmp_spec.md`](./kmp_spec.md)、キャッシュ方針は [`cache_spec.md`](./cache_spec.md)、指標の意味は [`statistics_spec.md`](./statistics_spec.md)、ドメイン型は [`models_spec.md`](./models_spec.md)、不変条件は [`domain_rules.md`](./domain_rules.md)、コンポーネント境界は [`component_spec.md`](./component_spec.md)、画面/ナビゲーション/Viewport は各専門仕様を正本とします。プロダクト原則 (公開データ / ローカル / オブザーバブル) は [`overview.md`](./overview.md) を正本とします。認証ライフサイクルは [`authentication_spec.md`](./authentication_spec.md)、Keychain / Keystore の HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とします。

## アーキテクチャーの原則

本プロジェクトでは、下記を基本原則とします。

1. **「ドメイン」ファースト**

   * パッケージおよびリポジトリに関するドメイン判断を、UI から分離する。

2. **純粋なドメインロジック**

   * ドメイン判断は、可能な限り純関数として実装する。

3. **イミュータブルな状態**

   * 状態は、イミュータブルな値として扱う。

4. **「I/O」境界**

   * ネットワーク、ファイル I/O、Keychain 等の副作用を、アダプタに閉じ込める。

5. **プラットフォーム・ネイティブな UI**

   * UI 実装は共有しない。
   * iOS/iPadOS は、SwiftUI を使用する。
   * Android は、Jetpack Compose UI を使用する。

6. **Kotlin Multiplatform (KMP) 移植性**

   * ロジックは共有し、UI はプラットフォーム別に実装する。
   * 将来 KMP に移植するロジックは、初期段階から移植容易な Swift として実装する。

7. **「ローカル」ファースト**

   * 外部サーバーを必須とせず、ユーザーデータおよび統計スナップショットは、端末内保存を基本とする。

8. **最小権限の原則**

   * 外部サービスの認証は、必要な機能に限定し、必要最小限の権限を使用する。

9. **認証情報とデータの分離**

   * 認証情報と通常のアプリケーション・データを分離する。

10. **Viewport の整合性**

    * UI の到達性、安定性、コンテンツ完全性、操作完全性を保証する。

## アーキテクチャー層

本アプリケーションは、プレゼンテーション (SwiftUI / ビュー / 状態 / イベント)、アプリケーション/ユースケース (SearchPackage / LoadPackage / LoadStatistics / ManageFavorite / LoadMyPackages)、ドメイン (パッケージ / バージョン / 依存関係 / リポジトリ / 統計)、アダプタ (Packagist/GitHub API、ローカル・ストレージ/Keychain) の論理層に分割します。依存は プレゼンテーション → アプリケーション → ドメイン、アダプタ → ドメイン とします。これは実装上のモジュール境界を必ずしも意味しません。特に初期段階では、過剰なモジュール分割を避け、論理的な責務分離を優先します。

## プレゼンテーション層

### 1. UI フレームワーク

iOS/iPadOS では、SwiftUI を使用します。Android 版では、Jetpack Compose UI を使用します。

SwiftUI と Jetpack Compose の UI 実装は、共有しません。

### 2. モデル・ビュー・アップデート (MVU)

画面状態は、イミュータブルな状態として定義します。

イベントは、`enum` 等による値として定義します。

状態更新は、下記の概念を基本とします。

`(State, Event) -> State`

ビューは、状態を表示し、ユーザー操作をイベントとして発行します。ビュー自身に、ドメイン判断を実装してはなりません。

### 3. ViewModel

ViewModel を使用する場合、その責務は下記に限定します。

* I/O の起動
* 非同期処理の制御
* 状態の保持
* ユースケースとの接着

ViewModel にパッケージのビジネスルールや統計の計算ロジックを集約してはなりません。

## アプリケーション/ユースケース層

ユースケースは、ユーザーが実行する機能単位として定義します。

例:

* `SearchPackage`
* `LoadPackage`
* `LoadPackageVersions`
* `LoadPackageDependencies`
* `LoadPackageStatistics`
* `LoadRepository`
* `LoadRepositoryStatistics`
* `LoadMyPackages`
* `AddFavorite`
* `RemoveFavorite`
* `LoadFavorites`
* `RefreshPackage`

ユースケースは、UI や外部 API の具体的な実装に直接依存しません。

ユースケース内では、取得したデータをドメイン・モデルに変換し、プレゼンテーション層が利用可能な状態に整理します。

## ドメイン層

ドメイン層は、本アプリケーションの中心とします。

### 1. パッケージ

Composer/Packagist パッケージを表現します。型とフィールドは [`models_spec.md`](./models_spec.md) を正本とします。

### 2. バージョン

パッケージ・バージョンを表現します。型とフィールドは [`models_spec.md`](./models_spec.md) を正本とします。

### 3. 依存関係

Composer パッケージの依存関係を表現します。区分を含む型は [`models_spec.md`](./models_spec.md) を正本とします。

### 4. リポジトリ

GitHub 等のソース・リポジトリを表現します。型とフィールドは [`models_spec.md`](./models_spec.md) を正本とします。

### 5. 統計

統計情報を、時系列データとして表現します。統計データは、Packagist 由来、GitHub 由来、および本アプリケーションが算出した派生指標を区別します。指標の意味は [`statistics_spec.md`](./statistics_spec.md)、型は [`models_spec.md`](./models_spec.md) を正本とします。

## ドメイン・モデルの設計

ドメイン・モデルは、イミュータブルな値として実装します。

Swift では、原則として下記を使用します。

* `struct`
* `enum`
* `let`

クラス階層によるドメイン・モデルは、原則として採用しません。

たとえば、下記のような Value 志向な設計を基本とします。

```swift
struct Package {
    let name: String
    let description: String?
    let latestVersion: Version?
}
```

将来 Kotlin に移植する際には、Kotlin の `data class`、`sealed class`、`enum class` 等に、自然に変換できる構造を優先します。

## 関数型ドメイン・ロジック

ドメイン層では、外部状態に依存しない処理を、純関数として実装します。

例:

* calculateDownloadTrend
* calculateStatisticsSummary
* sortPackages
* filterPackages
* compareVersions
* validatePackageName
* calculateHealthMetric

下記のような処理を、ドメイン・ロジックに直接持ち込みません。

* HTTP リクエスト
* ファイル I/O
* Keychain
* UserDefaults
* SwiftUI 状態
* UIKit
* OS 固有 API

## アダプタ層

外部サービスおよび OS 固有機能へのアクセスは、アダプタに閉じ込めます。

### 1. Packagist アダプタ

Packagist API との通信を担当します。

責務:

* API リクエスト
* 認可ヘッダー
* レスポンスの解析
* API エラーのマッピング
* レート制限の処理

Packagist API 固有の応答モデルを、ドメイン・モデルに変換します。

ドメイン層が、Packagist API の JSON 構造に直接依存してはなりません。

## GitHub アダプタ

GitHub API との通信を担当します。

責務:

* リポジトリ API
* リポジトリ指標 API
* リリース API
* Issue/プル・リクエスト API
* 貢献者/履歴 API
* 認証
* API エラーのマッピング
* レート制限の処理

GitHub API 固有の応答モデルを、ドメイン・モデルに変換します。

ドメイン層が、GitHub API 固有の JSON 構造に直接依存してはなりません。

## ストレージ・アダプタ

ローカル・ストレージへのアクセスを、アダプタに閉じ込めます。

保存対象の例:

* お気に入り
* パッケージ設定
* 統計スナップショット
* キャッシュされたパッケージデータ
* ユーザーの設定

ドメイン層およびユースケース層は、具体的なデータベース実装に直接依存してはなりません。

## クレデンシャル (資格情報) ストレージ

資格情報は、通常のローカル・ストレージとは別に扱う。対象と禁止保存先は [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、資格情報をアダプタに閉じ込め、SQLite / JSON / UserDefaults に保存しないことだけを定める。

### iOS/iPadOS

Keychain の HOW は [`ios_spec.md`](./ios_spec.md) を正本とする。

### Android

Keystore の HOW は [`android_spec.md`](./android_spec.md) を正本とする。

## 「認証」境界

認証を必要とする処理と、公開情報を取得する処理を分離する。どの API が匿名でよいかは [`authentication_spec.md`](./authentication_spec.md) を正本とする。本仕様は、公開情報の取得だけを理由にユーザー認証を要求せず、認証が必要な機能では必要最小限の権限に閉じることだけを定める。

## リポジトリ・パターン

リポジトリという名称は、ドメイン上の概念として必要な場合に限定して、使用します。

下記のような、「リポジトリ・インターフェイスの大量生成」は、行いません。

* IPackageRepository
* IVersionRepository
* IStatisticsRepository
* IGitHubRepository
* IPackagistRepository
* ...

「I/O」境界の差し替えが実際に必要な場合のみ、Protocol を導入します。

リポジトリは、「データアクセス層を抽象化するため」という理由だけで機械的に作成しません。

## データのフロー

通常のパッケージ取得は、プレゼンテーション → ユースケース → アダプタ → 外部 API とする。ドメイン・モデルを外部 API の応答モデルとしてそのまま使用しない。層の置き場所は本仕様の層図を正本とする。

## キャッシュのフロー

キャッシュ可能なデータについては、ローカル・キャッシュを利用する。TTL / Freshness / Invalidation および取得順序は [`cache_spec.md`](./cache_spec.md) を正本とする。本仕様ではデータ種別ごとの具体 TTL を定義しない。プロバイダ固有の取得制約は [`api-packagist.md`](./api-packagist.md) / [`api-github.md`](./api-github.md) を参照する。

## 統計アーキテクチャー

統計は、単一の数値ではなく、時系列データとして扱います。指標の意味と収集は [`statistics_spec.md`](./statistics_spec.md) を正本とします。

本仕様は、取得したスナップショットをローカル・ストレージに保存し、チャート表示に利用すること、および外部 API の期間を超える長期トレンドはアプリケーション側スナップショットを基礎とすることだけを定めます。

## 派生指標

派生指標の定義は [`statistics_spec.md`](./statistics_spec.md) を正本とします。本仕様は、複数ソースを組み合わせた算出をドメイン層で行い、UI 層で直接計算しないことだけを定めます。

## 「お気に入り」アーキテクチャー

「お気に入り」は、ユーザー固有データとしてローカル・ストレージに保存します。型は [`models_spec.md`](./models_spec.md)、Maintained との独立性は [`domain_rules.md`](./domain_rules.md) を正本とします。

本仕様は、お気に入りが Packagist の所有権情報とは独立したユーザー所有データであることだけを定めます。

## 「マイ・パッケージ」アーキテクチャー

「マイ・パッケージ」は、Packagist アカウントと関連付けられた動的データです。型は [`models_spec.md`](./models_spec.md)、発見と表示の分離は [`domain_rules.md`](./domain_rules.md) を正本とします。

本仕様は、認証済み API からリストを取得し、取得できない場合は既存のローカル・データを破棄せずエラー状態を明示することだけを定めます。

## プラットフォーム境界

アーキテクチャー方針 (共有ロジック / プラットフォーム UI、Swift 先行、移植容易な範囲、ビルドに Xcode) の正本は本仕様です。KMP 実施時の source set、expect/actual、モジュール構成、移行手順の正本は [`kmp_spec.md`](./kmp_spec.md) です。

初期実装では、下記の責務を Swift 側に置きます。

将来 Android 版を実装する際は、共有可能な部分を Kotlin Multiplatform (KMP) に移植します。

この境界は、「目的」および原則5・6を、モジュール構成として具体化したものです。共有ロジックは KMP に移植し、UI は SwiftUI と Jetpack Compose に分離します。source set / モジュール構成の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。

### 共用される移植可能な候補

* ドメイン
* ドメイン・ルール
* モデル
* 統計
* ユースケース
* キャッシュの方針
* リポジトリ・インターフェイス
* プロバイダ抽象化
* 検証
* データ転送

### 共有ロジックの優先順位

何を共有してよいか、どの順で共有対象とするかの正本は本仕様です。KMP 実施時の段階 (Phase-0以降)、source set、expect/actual は [`kmp_spec.md`](./kmp_spec.md) です。

共有に移す順序は下記を基本とします。

1. ドメイン・モデル
2. ドメイン・ルール
3. 統計計算
4. アプリケーション・ユースケース
5. リポジトリ・インターフェイス
6. キャッシュの方針
7. プロバイダ Client
8. プラットフォーム Integration (アダプタ)

UI は共有対象としません。原則5に従い、プラットフォーム実装のまま共有ロジックに接続します。

### プラットフォーム固有

* SwiftUI
* Jetpack Compose
* UIKit
* Keychain
* ファイルシステム
* OSLog
* Swift Concurrency
* アプリケーションのライフサイクル

### ビルドツールチェーン

共有ロジックを KMP に移植しても、iOS/iPadOS のビルドは macOS/Xcode から独立しません。

iOS ビルドには macOS/Xcode が必要です。KMP プロジェクトでも、iOS のビルドツールチェーンは Xcode を使用します。([Create your Compose Multiplatform app | Kotlin Multiplatform Documentation](https://kotlinlang.org/docs/multiplatform/compose-multiplatform-create-first-app.html))

CI 上の実行環境は、[`kmp_spec.md`](./kmp_spec.md) の「CI プラットフォーム」で定義します。

## Kotlin Multiplatform (KMP) の移行戦略

初期実装では Kotlin コードの導入自体を目的としません。移行は Big Bang を避けます。

段階、source set、expect/actual、モジュール構成の正本は [`kmp_spec.md`](./kmp_spec.md) の Migration Strategy です。

## 依存関係の方向

依存関係の方向は、プレゼンテーション → アプリケーション/ユースケース → ドメイン、アダプタ → ドメイン を基本とします。

ドメインからプレゼンテーションおよび具体的なアダプタに依存してはなりません。

ユースケースから SwiftUI、UIKit、Android フレームワーク等に依存してはなりません。

## 「エラー」境界

エラーは、外部 API エラー → アダプタ・エラー → アプリケーション・エラー → UI 状態 → ユーザーに表示されるエラー と境界ごとに分類します。`ApplicationError` の case は [`models_spec.md`](./models_spec.md) を正本とします。

ドメイン・エラーとネットワーク・エラーを混同しません。

ユーザーに提示可能なエラーと、診断用エラーを分離します。

エラーを黙殺してはなりません。

## 「並行処理」境界

初期の移植層では、同期的な純関数を基本とします。

ネットワークおよびその他の I/O では、Swift Concurrency を使用します。ドメインは純粋/同期的、アダプタは async/await とします。

移植層に対して、`Task`、`actor` 等の Swift 固有の「並行処理」機構を持ち込みません。

将来 Kotlin Multiplatform (KMP) に移植する際には、Kotlin Coroutines 等に置換します。

## UI/ドメイン分離

UI は、ドメイン・モデルを直接変更してはなりません。

たとえば、Downloads の閾値から Health を判定する処理は、ビューに実装しません。このような判断は、ドメインまたはユースケース側で行います。ビューは状態の表示に集中します。

## Viewport アーキテクチャー

Viewport の到達可能性・安定性・サイズクラスは [`ui-viewport.md`](./ui-viewport.md) を正本とする。本仕様は、Viewport を UI アーキテクチャーの一部として扱うことだけを定める。

## iPhone/iPad アーキテクチャー

iPhone と iPad では、同一情報モデルを使用するが、必ずしも同一レイアウトを使用しません。画面サイズに応じて情報密度を調整します。

ナビゲーション構造は [`navigation_spec.md`](./navigation_spec.md)、画面構成は [`screen_spec.md`](./screen_spec.md)、サイズクラスは [`ui-viewport.md`](./ui-viewport.md) を正本とする。

## Android アーキテクチャー

Android 版では、Jetpack Compose UI を使用します。

Kotlin Multiplatform (KMP) に移植されたドメイン/ユースケースを Compose UI から利用します。

Android 固有の UI およびライフサイクル処理は Android 側に閉じ込めます。

iOS UI と Android UI を、1対1で再現することを目的としません。

共有するのは、主として下記です。

* ドメイン・モデル
* ドメイン・ロジック
* ユースケース
* 統計
* 検証
* データ転送

## 「テスト仕様」アーキテクチャー

各層を、可能な限り独立してテストします。

### ドメイン

* 純関数テスト
* Value オブジェクト・テスト
* 統計計算テスト
* 検証テスト

### アプリケーション

* ユースケース・テスト
* 状態遷移テスト

### アダプタ

* API レスポンスの解析
* エラーのマッピング
* キャッシュ
* クレデンシャル (資格情報) ストレージ

### プレゼンテーション

Viewport 変更時の確認項目は [`ui-viewport.md`](./ui-viewport.md)、テスト種別は [`testing_spec.md`](./testing_spec.md) を正本とする。

* スナップショット・テスト
* UI 操作テスト

## ADR (アーキテクチャー決定記録)

アーキテクチャー上の重要な判断については、必要に応じて ADR を作成します。

対象例:

* Kotlin Multiplatform (KMP) 導入時期
* ストレージの方式
* クラウド同期の方式
* 認証の方式
* 統計スナップショットの方式
* GitHub OAuth の方式
* データベースの方式
* チャート・フレームワークの選定

ADR では、少なくとも下記を記録します。

* 背景
* 決定
* 選択肢
* 結果
* 状況
