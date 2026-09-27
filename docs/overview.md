# S2J Package Dashboard - プロジェクト概要

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、プロジェクト概要を定義します。

**S2J Package Dashboard** は、Composer ライブラリ・ディレクトリ『[Packagist](https://packagist.org)』に公開されている Composer パッケージを、開発者の視点から探索・管理・分析するためのダッシュボード・アプリケーションです。

Packagist API および GitHub API を利用し、パッケージの基本情報、依存関係、バージョン、ダウンロード統計、GitHub リポジトリの活動状況などを一つのアプリケーションから確認できるようにします。

個別機能の詳細は、[`specs.md`](./specs.md) から各仕様書を参照してください。

本アプリケーションは、単なるパッケージ・ビュワーではなく、下記の2種類のパッケージを統合して扱います。

1. **マイ・パッケージ**

   * ユーザー自身が Packagist 上でメンテナンスしているパッケージ
   * Packagist アカウントを接続した場合、自動的にリストアップする
   * 実装時期は [`use_cases.md` 優先順位-1](./use_cases.md#優先順位-1) の UC-02。認証の設定は UC-16

2. **お気に入り**

   * ユーザー自身がメンテナンスしていないパッケージ
   * ユーザーが任意に登録し、継続的に参照できるパッケージ

## 目的

本アプリケーションの主な目的は、Composer パッケージの利用状況と開発状況を、モバイル・デバイスから容易に把握できるようにすることです。

特に、下記の情報を一つの画面体系に統合します。

* Packagist パッケージ情報
* パッケージのバージョン
* パッケージの依存関係
* Packagist ダウンロードの統計
* パッケージの依存先
* GitHub リポジトリ情報
* GitHub スター/フォーク
* GitHub Issue 数/プル・リクエスト数
* GitHub 貢献者
* GitHub コミット履歴
* GitHub リリース
* その他、取得可能なパッケージ/リポジトリ指標

## 非目的

初期バージョンでは、下記を必須機能としません。これらは、将来の拡張候補として扱います。

* Packagist パッケージの新規登録
* Packagist パッケージの編集
* Composer パッケージのリリース操作
* GitHub リポジトリの管理操作
* GitHub Issue/プル・リクエストの作成・編集
* 外部サーバーへのユーザーデータ保存
* 複数デバイス間のクラウド同期
* 非公開 Packagist への対応

## 責務

本ドキュメントは、プロジェクトの存在理由、対象ユーザー、基本コンセプトおよび非目標を定義します。入口の目次は [`specs.md`](./specs.md) です。

## 非責務

実装方針と層分離は [`architecture.md`](./architecture.md)、Kotlin Multiplatform (KMP) の HOW は [`kmp_spec.md`](./kmp_spec.md)、Viewport は [`ui-viewport.md`](./ui-viewport.md)、認証ライフサイクルは [`authentication_spec.md`](./authentication_spec.md)、脅威・ログは [`security_spec.md`](./security_spec.md)、Keychain / Keystore の HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とします。
個別機能、API、モデル、ストレージ、画面、ナビゲーション等の詳細は、各専門仕様を正本とします。

## 設計原則

本プロジェクトのプロダクト原則は、下記とします。実装方針・層分離は、[`architecture.md`](./architecture.md) を正本とします。

1. **「公開データ」ファースト**

   * 公開情報の閲覧に、認証を要求しない。

2. **「ローカル」ファースト**

   * 初期実装では、ユーザーデータおよび統計スナップショットは、端末内保存を基本とする。

3. **オブザーバブル・データ**

   * パッケージ/リポジトリの状態を、数値だけでなく、時系列/比較/可視化によって理解できるようにする。

ネイティブ UI と Kotlin Multiplatform (KMP) 移植性は [`architecture.md`](./architecture.md)、Viewport 整合性は [`ui-viewport.md`](./ui-viewport.md)、最小権限と認証情報の分離は [`authentication_spec.md`](./authentication_spec.md) / [`architecture.md`](./architecture.md) を正本とします。

## 参考アプリケーション

UI/UX および情報設計の先行研究として、下記を参照します。

### npm Registry

『[npm Registry](https://apps.apple.com/jp/app/npm-registry/id1360641778)』アプリケーションを、パッケージ・エクスプローラーとしての情報構造の参考にします。

特に下記を参考とします。

* パッケージ検索
* README
* パッケージ情報
* 依存関係
* バージョン
* 統計
* GitHub 情報

### GitHub

『[GitHub](https://apps.apple.com/jp/app/github/id1477376905)』アプリケーションを、開発者ダッシュボードとしての情報構造の参考にします。

特に下記を参考とします。

* お気に入り
* リポジトリ
* Issue/プル・リクエスト
* 履歴
* フィルター
* 開発者志向のナビゲーション

これらのアプリケーションの UI をそのまま複製することを目的とせず、本アプリケーションの対象ユーザーおよび Composer/Packagist の情報モデルに適した UI に再構成します。

## 基本コンセプト

### パッケージ・エクスプローラー

Packagist 上のパッケージを検索・探索し、パッケージ単位で情報を確認できます。

パッケージ詳細では、少なくとも下記の情報カテゴリーを提供します。呼び方と並びは [`screen_spec.md` 「パッケージ詳細」コンテンツ](./screen_spec.md#パッケージ詳細コンテンツ) を正本とします。

* README
* パッケージ・メタデータ
* 依存関係
* リポジトリ
* 現在のバージョン
* 統計

画面構成および情報カテゴリーは、既存の『[npm Registry](https://apps.apple.com/jp/app/npm-registry/id1360641778)』アプリケーションを先行研究の一つとして参考にします。

ただし、本アプリケーションは、『npm Registry』の単純な Packagist 版ではなく、Composer/Packagist 固有の情報モデルと GitHub 情報を活用したパッケージ・ダッシュボードを目指します。

### マイ・パッケージ

Packagist アカウントを接続したユーザーについて、自身がメンテナンスするパッケージを自動的にリストアップします。個別にパッケージ名の登録を、ユーザーに要求しないことを基本とします。実装時期は [`use_cases.md` 優先順位-1](./use_cases.md#優先順位-1) の UC-02を正本とします。認証の設定は UC-16を正本とします。

なお、公開パッケージの検索・閲覧・統計取得については、可能な限り、認証を要求しません。

Packagist アカウントに関する機能については、必要最小限の権限のみを利用します。

### お気に入り

ユーザー自身がメンテナンスしていないパッケージについても、任意に「お気に入り」に登録できます。

「お気に入り」は、下記の用途を想定します。

* 利用中の依存パッケージ
* 関心のあるオープンソース・ソフトウェア・パッケージ
* 開発上参照するパッケージ
* 競合・代替パッケージ
* 統計を継続的に確認したいパッケージ

## データソース

本アプリケーションでは、主に下記の外部 API を利用します。

### Packagist API

Packagist API を、パッケージに関する主要なデータソースとします。主な用途は、下記のとおりです。公開パッケージについては、可能な限り、匿名 API アクセスを利用します。

* パッケージ検索 (実装時期は [`use_cases.md` 優先順位-1](./use_cases.md#優先順位-1) の UC-04)
* パッケージのメタデータ
* パッケージのバージョン
* 依存関係
* ダウンロードの統計
* 依存先
* リポジトリ情報
* Packagist 上のパッケージ情報

### GitHub API

GitHub API をパッケージに関連付けられたリポジトリの情報源とします。主な用途は、下記のとおりです。GitHub の認証が必要な情報については、公開情報と認証情報を明確に区別します。特にリポジトリのトラフィック等、権限を必要とする情報は、ユーザーが適切な GitHub 権限を持つ場合のみ取得対象とします。

* リポジトリのメタデータ
* スター
* フォーク
* Issue 数
* プル・リクエスト数
* リリース
* 貢献者
* コミット履歴
* リポジトリの統計
* その他、取得可能なリポジトリ指標

## 統計情報

本アプリケーションでは、統計情報を単なる数値の一覧ではなく、時系列および比較可能なデータとして可視化します。扱う指標と意味は [`statistics_spec.md`](./statistics_spec.md) を正本とします。

### パッケージの統計情報

Packagist をデータソースとします。

### リポジトリの統計情報

GitHub をデータソースとします。

### 派生の統計情報

Packagist および GitHub から取得したデータを組み合わせ、本アプリケーション独自の派生指標の提供を将来検討します。派生指標は、外部サービスが提供する公式指標ではなく、本アプリケーションが独自に算出した指標であることを明示します。

## 過去の統計情報

外部 API から取得できる統計情報には、取得可能な期間や保持期間に制約が存在する場合があります。収集の意味は [`statistics_spec.md`](./statistics_spec.md)、永続化は [`storage_spec.md`](./storage_spec.md) を正本とします。
本仕様は、「長期統計のためにスナップショットをローカル保存する」「初期実装で外部サーバーを必須としない」ことだけを述べます。

複数デバイス間の統計データ同期については、別途仕様を定義します。

## 認証とセキュリティ

公開情報に認証を要求しないことは、[設計原則](#設計原則) を正本とします。
認証ライフサイクルと許可状態は [`authentication_spec.md`](./authentication_spec.md)、脅威・ログは [`security_spec.md`](./security_spec.md) を正本とします。

### Packagist

公開パッケージの検索・閲覧・統計取得に、認証を必須としません。アカウント紐付けと Token の方針は [`authentication_spec.md`](./authentication_spec.md) を正本とします。

### GitHub

公開リポジトリは、可能な限り、匿名アクセスまたは公開 API とします。スコープは [`authentication_spec.md`](./authentication_spec.md) を正本とします。

### 認証情報のストレージ

認証情報は、通常のアプリケーション・データと分離します。何を置いてよいかは [`authentication_spec.md`](./authentication_spec.md)、保存 HOW は [`ios_spec.md`](./ios_spec.md) / [`android_spec.md`](./android_spec.md) を正本とします。

## データの所有権

本アプリケーションが扱うデータは、下記のように、分類します。ユーザーの認証情報を、本アプリケーションの運営者が管理する外部サーバーに送信することを、初期仕様として要求しません。

| データ | 性質 | 基本の保存方針 |
| --- | --- | --- |
| Packagist 公開情報 | 公開 | API から取得 |
| GitHub 公開情報 | 公開 | API から取得 |
| パッケージお気に入り数 | ユーザーデータ | 「ローカル」ファースト |
| パッケージ設定 | ユーザーデータ | 「ローカル」ファースト |
| 統計スナップショット | ユーザーデータ/派生データ | 「ローカル」ファースト |
| Packagist クレデンシャル (資格情報) | Secret | セキュア・ストレージ |
| GitHub クレデンシャル (資格情報) | Secret | セキュア・ストレージ |

## マルチ・プラットフォーム

初期ターゲットは iOS/iPadOS です。Android は、今後のターゲットです。時期は、本節を正本とします。ネイティブ UI の置き方は [`architecture.md`](./architecture.md) を正本とします。

初期バージョンの UI は、SwiftUI のみです。Android 版の開発に着手したタイミングで、UI は「iOS/iPadOS: SwiftUI」と「Android: Jetpack Compose」に分けます。

Android 版に向けて、下記とします。

* 共有ロジックは、Kotlin Multiplatform (KMP) に移設します。実施手順は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
* Android UI は、Jetpack Compose とします。Android の永続化ライブラリとして、Room を利用の第一候補とします。置き方は [`android_spec.md`](./android_spec.md) を正本とします。
* テストは、Android 版の開発に着手したタイミングで、iOS/iPad トラックと Android トラックに分けます。分け方は [`release.md`](./release.md) と [`testing_spec.md`](./testing_spec.md) を正本とします。

## Kotlin Multiplatform (KMP) の移植性

共有対象と優先順位は [`architecture.md`](./architecture.md)、KMP の HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本仕様は、「初期実装が Swift である」ことだけを述べます。

## UI/UX

Viewport 整合性は [`ui-viewport.md`](./ui-viewport.md) を正本とします。
本仕様は、「大量の情報を扱うダッシュボードとして Viewport を品質基準とする」ことだけを述べます。
