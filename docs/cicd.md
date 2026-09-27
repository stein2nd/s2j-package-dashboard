# S2J Package Dashboard - CI/CD 仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、CI/CD の方針を定義します。GitHub アクション を使用します。

## 目的

本仕様は、CI/CD の方針、ワークフロー、品質ゲート、ビルド、テスト、成果物およびセキュリティを定義します。

## 非目的

本仕様は、アプリケーションのドメイン挙動、ストア提出の可否判断、バージョン番号の意味を再定義しません。

## 責務

いつどのジョブが走るか、成果物、パイプライン上のゲート評価、署名/環境、成果物の扱いを定義します。

## 非責務

リリース条件、バージョニング、Apple TestFlight/Google Play、ロールバックは [`release.md`](./release.md) を正本とします。
アプリケーション本体の仕様は、各専門仕様を正本とします。

## CI/CD の原則

下記を、基本原則とします。

### すべての変更は、検証可能であるべき

PR に含まれる変更は、マージ前に自動検証が可能であること。流れは下記とします。

* PR → CI →品質ゲート→マージ

### Main は、常にビルド可能

`main` ブランチは、常にリリース候補 (RC) を生成可能な状態を維持します。流れは下記とします。

* main →ビルド→テスト→リリース候補

### ビルド再現性

同一コミットから生成される成果物は、可能な限り、同一のソース/依存関係/ビルドシステム設定 (Configuration) にもとづくものとします。

### 早く失敗する

安価で高速な検証を、先に実行します。順序は、下記とします。

* Lint →静的解析→ユニットテスト→結合テスト→ビルド→ UI テスト→配布

### ソースに Secret なし

クレデンシャル (資格情報) /証明書/Token/API キー等を、リポジトリにコミットしません。

GitHub アクションでは、Secret を必要なジョブに限定して、利用します。

## CI/CD プラットフォーム

下記に配置します。

* CI/CD プラットフォーム: `GitHub Actions`
* ワークフロー: `.github/workflows/`

推奨ワークフロー・ファイル:

* `ci.yml`
* `docs.yml`
* `security.yml`
* `dependency.yml`
* `ios.yml`
* `android.yml`
* `release.yml`

実際のワークフローは、実装上の保守性を考慮して統合してかまいません。

## ワークフローの命名

ワークフロー名は、目的を明確にします。

ジョブ名も GitHub アクション UI 上で、意味が明確になるようにします。

例:

```yaml
name: CI
name: Documentation
name: Security
name: Dependency
name: iOS
name: Android
name: Release
```

## トリガーの方針

### PR

基本的に、下記を対象とします。

`pull_request`

対象ブランチ: `main`

必要に応じて、パス・フィルターを利用します。

### プッシュ

`main` ブランチへのプッシュを対象とします。PR マージ後の状態を検証します。

```yml
push:
  branches:
    - main
```

### 手動

必要に応じて、`workflow_dispatch` を利用します。

用途:

* 再ビルド
* リリース候補 (RC)
* 緊急リリース
* 配布リトライ
* メンテナンス

### リリース

Git タグまたは GitHub Release をリリース・トリガーとします。

推奨:

`vMAJOR.MINOR.PATCH`

例:

* `v1.0.0`
* `v1.1.0`
* `v1.1.1`

## ブランチ戦略

下記を利用可能とします。ただし、不要な長期間ブランチを作成しません。

* 基本ブランチ: `main`
* 機能ブランチ: `feature/*`
* 修正ブランチ: `fix/*`
* リリース・ブランチが必要となった場合: `release/*`

## PR 品質ゲート

PR は、下記を満たさなければ、マージできません。各チェックで何をテストするかは [`testing_spec.md`](./testing_spec.md) を正本とします。

* Lint
* テスト
* ビルド
* ドキュメント
* セキュリティ

最低限、下記を満たします。順序は [早く失敗する](#早く失敗する) を正本とします。

* ソースコード: コンパイル/ユニットテスト/静的解析/フォーマット・チェック
* ドキュメント: Lint
* セキュリティ: 依存関係チェック/Secret チェック

## CI パイプライン

標準 CI パイプラインの順序は [早く失敗する](#早く失敗する) を正本とします。
本節は、「PR で Lint/テスト/セキュリティを並列し、ビルド後に、品質ゲートを経てマージする」ことのみを定めます。

## ソース・チェックアウト

ワークフローでは、リポジトリをチェックアウトします。

アクション・バージョンは、明示的に固定します。実際のバージョン/SHA は、ワークフロー実装時点で決定します。

例:

```yaml
- uses: actions/checkout@<pinned-version>
```

GitHub は、アクションをブランチ名だけで参照するより、バージョン・タグまたはコミット SHA を指定することを推奨しています。特に、セキュリティ/再現性を重視するワークフローでは、SHA 固定を優先します。

(参考: [Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

## GitHub Token 権限

ワークフローの `GITHUB_TOKEN` は、最小権限とします。

基本:

```yaml
permissions: {}
```

読み取り専用が必要な CI:

```yaml
permissions:
  contents: read
```

リリース等で書き込みが必要なジョブは、そのジョブにのみ必要な権限を付与します。

GitHub アクションでは `permissions` により `GITHUB_TOKEN` の権限を `read` / `write` / `none` で明示できます。明示した場合、未指定の権限は `none` になるため、最小権限の原則を実現しやすいです。

(参考: [Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

## Secret 管理

Secret は、GitHub アクション Secret / 環境 Secret を使用します。

例:

* APP_STORE_CONNECT_API_KEY
* APP_STORE_CONNECT_KEY_ID
* APP_STORE_CONNECT_ISSUER_ID

* MATCH_PASSWORD
* SIGNING_PASSWORD

* GOOGLE_PLAY_SERVICE_ACCOUNT

実際の Secret 名は、実装時に決定します。

下記に、Secret を記述してはなりません。

* ソースコード
* `project.yml`
* `Package.swift`
* Git にコミットされた `.env`
* ドキュメント
* ワークフロー・ログ
* テスト・フィクスチャ
* スクリーンショット
* 成果物

環境 Secret を使用する場合、(リリース・ジョブのような) 必要なジョブにのみ、環境を関連付けます。

GitHub の環境 Secret は、その環境を参照するジョブにのみ提供でき、承認が設定されている場合は、承認後に利用可能となります。

(参考: [Deployments and environments · github/docs · GitHub](https://github.com/github/docs/blob/main/content/actions/reference/workflows-and-actions/deployments-and-environments.md))

## フォーク PR セキュリティ

フォークからの PR では、Secret を利用するワークフローを実行しません。特に、フォーク PR から Secret アクセスや、リリース/配布しません。フォーク PR では、通常の読み取り専用 CI のみを実行します。

GitHub アクションでは、フォーク/Dependabot 起点のワークフローは、Secret を利用できない制約があるため、この前提を CI 設計に組み込みます。

(参考: [Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

## 依存関係のインストール

依存関係のインストールは、Lock ファイルを正とします。依存関係のバージョンを、CI 実行ごとに意図せず変化させません。

対象:

* Swift パッケージ・マネージャー
* npm
* Composer
* 将来の Gradle/Kotlin

## Swift パッケージ・マネージャー

Swift パッケージ・マネージャーを利用する場合、下記を基本とします。

* Package.swift
* Package.resolved

CI では、Lock/解決情報を尊重します。

依存関係の更新は、通常の CI と分離し、専用の依存関係の更新ワークフローで検証します。

## Xcode プロジェクト自動生成

本プロジェクトでは `project.yml` を XcodeGen の入力として扱う場合、CI でも同じ生成手順を使用します。

`project.yml` → XcodeGen → Xcode プロジェクト→ビルド/テスト

生成された Xcode プロジェクトを「信頼できる情報源 (SoT)」としない場合は、リポジトリにコミットしません。

* SoT: `project.yml`

## Xcode バージョン

CI では、Xcode バージョンを明示します。実際のバージョンは、対象 SDK/配布ターゲット/CI ランナーの対応状況に応じて、固定します。

例:

`Xcode v26.x`

GitHub ホステッド macOS ランナー では、複数の Xcode バージョンが提供されるため、`xcode-select` 等を用いて、CI が意図した Xcode を使用していることを検証します。GitHub のランナー・イメージには、Xcode バージョン/macOS バージョンが明示されています。

(参考: [runner-images/images/macos/xcode-27-Readme.md at main · actions/runner-images · GitHub](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-Readme.md))

## Swift ビルド

基本ビルド:

* デバッグ
* リリース

CI では、少なくとも、デバッグ・ビルドを検証します。

リリース・ビルドは、リリース・ワークフロー、または main CI で検証します。

## Swift ユニットテスト

ユニットテストは、PR CI で必須とします。状態機械は、外部 I/O なしでテスト可能でなければなりません。

対象:

* ドメイン
* アプリケーション
* 状態機械
* レデューサー
* ユースケース
* リポジトリ・モック
* 検証
* 統計

## SwiftUI テスト

UI テストは、下記を対象とします。UI テストは、PR CI とナイトリー/Main CI で、実行頻度を分けてもかまいません。

* 起動
* ダッシュボード
* パッケージリスト
* パッケージ詳細
* 検索
* お気に入り
* 統計
* リフレッシュ
* エラー
* オフライン
* ナビゲーション
* 状態復元

## 実機テストのマトリックス

対象デバイスは [`ui-viewport.md`](./ui-viewport.md) の基準端末を正本とします。
本仕様は、「CI 上でシミュレーターの安定 OS を使い、実機固有の課題は、手動実機テストで確認する」ことのみを定めます。

## プラットフォームの互換性

Kotlin Multiplatform (KMP) 共有ロジックは、プラットフォームごとに同じテスト・スイートを共有できる構造を目指します。

最低限、CI で確認する対象は、下記の通りです。

* iOS
* iPadOS

Android 対応後、下記を追加します。

* Android

## Android CI

Android UI テストは、エミュレータを利用します。

Android 実装開始後は、下記を追加します。

* `./gradlew lint`
* `./gradlew test`
* `./gradlew assemble`

必要に応じて、`./gradlew connectedCheck` を使用します。

## Kotlin Multiplatform (KMP) CI

KMP 共有ロジック導入後は、共有ロジックを独立してテスト可能とします。

HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とします。
本仕様は、「共有ロジックを独立してユニットテストし、その後 iOS/Android で検証する」ことのみを定めます。

状態機械/ドメイン/ユースケースのテストは、可能な限り、共通テストに集約します。

## ドキュメント CI

ドキュメントも、CI の対象とします。既存の `docs-linter` の方針と整合させます。

対象:

* `docs_mod/**/*.md`
* `docs/*.md`
* `README.md`
* `CHANGELOG.md`

検証:

* マークダウン構文
* textlint
* リンク・チェック
* 内部参照チェック
* 必須見出しチェック

## ドキュメント品質ゲート

ドキュメント CI が失敗した場合、PR をマージ不可とします。

ただし、下記のような、明らかな外部サービス障害については、CI リトライを可能とします。

* 外部リンク・タイムアウト
* 一時 HTTP エラー

## 静的解析

静的解析を、CI に含めます。

Swift:

必要に応じて、「Xcode コンパイラ警告」をエラー/警告として扱います。

* [SwiftLint](https://formulae.brew.sh/formula/swiftlint)
* [SwiftFormat](https://formulae.brew.sh/formula/swiftformat) --lint

Android:

下記を導入可能とします。

* [ktlint](https://formulae.brew.sh/formula/ktlint)
* [detekt](https://formulae.brew.sh/formula/detekt)
* `Android Lint`

## フォーマット

フォーマットは、CI で検証します。CI では、ソースを自動修正せず、差分を検出して、失敗とします。

基本原則は、「ソースをフォーマッターに通し、期待されるフォーマットと差分がないこと」とします。

開発者は、ローカルでフォーマッターを実行して修正します。

## 依存関係の監査

依存関係の脆弱性を、定期的に検査します。

対象:

* Swift パッケージ
* npm
* Composer
* Gradle / Maven

GitHub Dependabot を利用可能とします。

依存関係の更新は、下記の流れで処理します。

* 更新→ CI →テスト→マージ

## Secret スキャン

GitHub Secret スキャン/プッシュ保護が利用可能な場合は、有効化します。

対象の種類は [`security_spec.md`](./security_spec.md) を正本とします。
本仕様は、「リポジトリにクレデンシャル (資格情報) がコミットされていないことを、継続的に検証する」ことのみを定めます。

## セキュリティ・ワークフロー

セキュリティ・ワークフローは、通常の CI と独立して実行可能とします。

対象は、下記とします。

* 依存関係の監査
* Secret スキャン
* 静的解析
* システム設定 (Configuration) チェック

セキュリティ失敗は、深刻度に応じて、マージゲートとします。

## ビルド成果物

CI で生成したビルド成果物は、必要に応じて、GitHub アクション成果物として保存します。

例:

* `S2JPackageDashboard.xcarchive`
* `S2JPackageDashboard.ipa`
* テストの結果
* カバレッジ・レポート

原則として、デバッグ・ビルド成果物は、長期保存しません。

リリース成果物は、リリース・ワークフローで正式に管理します。

## 成果物の命名規則

成果物名は、下記の情報を識別可能にします。

`<Product>-<Platform>-<Configuration>-<Version>-<Build>`

例:

`S2JPackageDashboard-iOS-Release-1.0.0-100`

## テストの結果

CI は、テストの結果を、GitHub アクション UI から確認可能にします。必要に応じて、JUnit/XCTest 結果を標準化します。

対象:

* ユニットテストの結果
* UI テストの結果
* 失敗ログ
* コード・カバレッジ

## コード・カバレッジ

コード・カバレッジは、品質指標として計測します。

初期段階では、カバレッジ割合を、絶対的なマージゲートとしません。

まず、カバレッジの傾向とリグレッション検出を重視します。カバレッジを品質の唯一の指標としないことは [`testing_spec.md`](./testing_spec.md) を正本とします。

十分なテスト・スイートが確立した段階で、カバレッジの最小閾値を設定します。

## PR チェック

必須チェックは [PR 品質ゲート](#pr-品質ゲート) を正本とします。

Android 導入後は、下記を追加します。

* Android / Lint
* Android / テスト
* Android / ビルド

## ブランチ保護

`main` ブランチに、ブランチ保護を設定します。

必須条件:

* PR 必須
* 必須ステータス・チェック
* 会話による解決
* ダイレクト・プッシュなし

必要に応じて、下記を追加します。

* 必須レビュー
* CODEOWNERS レビュー
* 署名付きコミット

## CODEOWNERS

重要な仕様/ワークフロー/セキュリティ・システム設定 (Configuration) について、CODEOWNERS を利用可能とします。変更時に、適切なレビューを要求します。

例:

* `.github/`
* `docs/`
* `docs_mod/`
* `project.yml`
* `Package.swift`

## CI でのリリース

リリース条件 (バージョン番号、品質ゲート、TestFlight/Play、ロールバック) の正本は [`release.md`](./release.md) とします。
本仕様は、「CI 上でいつどのジョブが走り、成果物をどう扱うか」のみを定義します。

### リリース・トリガー

リリース・ワークフローは、Git タグ (例: `v1.0.0`) を基準とします。`main` へのプッシュだけで、本番リリースしません。

### リリース・パイプライン

基本パイプラインは、下記とします。

* Git タグ→検証バージョン→ビルド・リリース→ユニットテスト→ UI テスト/スモーク・テスト→アーカイブ→成果物の検証→リリースの作成→配布

本番配布の可否、リリース候補 (RC)、ストア提出、ロールバックは [`release.md`](./release.md) に従います。

### 署名 / 環境

署名クレデンシャル (資格情報) は、CI リポジトリに直接保存しません。本番署名および本番配布は、リリース環境に限定します。

```yaml
environment:
  name: production
```

必要に応じて、環境承認を設定します。GitHub の環境 Secret は、対象環境のジョブに限定でき、必須レビュアーを設定した場合は、承認されるまで Secret を利用できません。

(参考: [Deployments and environments · github/docs · GitHub](https://github.com/github/docs/blob/main/content/actions/reference/workflows-and-actions/deployments-and-environments.md))

### 成果物

リリース成果物は、作成後に変更しません。成果物には、バージョン/ビルド番号/Git コミット SHA を関連付けます。同じバージョンに対して、異なる成果物を無秩序に再生成しません。

GitHub アクションの `attestations` 権限は、成果物認証の生成に利用できるため、リリース・パイプラインのセキュリティ強化として、将来導入を検討します。

(参考: [Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

リリースノート / CHANGELOG の内容は [`release.md`](./release.md) を正とします。CI は、生成と添付のみを担当します。

配布失敗が発生した場合、`ビルド成功`、`配布失敗` と `ビルド失敗` を区別します。成果物が正常に生成済みの場合、再ビルドではなく、配布のみリトライ可能とします。

CI が自動ロールバックを実行することは、実用最小限の製品 (MVP) では要求しません。

## スケジュール済み CI

定期的に、下記を実行可能とします。通常の PR CI と、ナイトリー CI の目的を分離します。

* `Nightly`
* `Weekly`

用途:

* 依存関係の監査
* セキュリティ・スキャン
* 拡張テスト
* UI テスト
* ドキュメントのリンク・チェック

## CI 最適化

CI 実行時間を短縮するため、必要に応じて、下記を利用します。ただし、キャッシュに、クレデンシャル (資格情報) や Secret を含めません。

* 依存関係のキャッシュ
* ビルドのキャッシュ
* ジョブの並列化
* パス・フィルター
* 条件付きジョブ
* 成果物の再利用

## ジョブの依存関係

ジョブ間の依存関係を明示します。独立ジョブは、並列実行します。

例: `lint`、`unit-test`、`security`、`docs` を並列の検証とし、その後 `build` → `integration` → `release` とする

## 失敗処理

下記は、CI 失敗を分類したものです。ソースの失敗は、修正が必須です。基盤の失敗 / 外部サービスの失敗は、リトライを可能とします。

* ソースの失敗
* 環境の失敗
* 依存関係の失敗
* 基盤の失敗
* 外部サービスの失敗

## リトライの方針

自動リトライは、冪等 (べきとう) な処理に限定します。

対象例:

* 依存関係のダウンロード
* 外部 API アクセス
* 成果物のアップロード

下記を無条件にリトライしません。

* テスト失敗
* Lint 失敗
* コンパイル・エラー
* セキュリティ失敗

## ログ記録

CI ログは、デバッグに必要な情報を含めます。

ただし、下記を出力しません。デバッグ時にも Secret を直接 `echo` しません。

* Secret
* Token
* 非公開キー
* パスワード
* 証明書コンテンツ
* 認可ヘッダー

## サードパーティ製アクションのセキュリティ

サードパーティ GitHub アクションの利用を最小限にします。

利用する場合:

1. メンテナーを確認
2. リポジトリを確認
3. 権限を確認
4. バージョンを固定
5. リリース / SHA を検証
6. 不要な Secret を渡さない

GitHub もアクションのバージョン/SHA の明示を推奨しています。

(参考: [Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

## ワークフロー権限

デフォルト:

```yaml
permissions: {}
```

CI:

```yaml
permissions:
  contents: read
```

リリースなどで書き込みが必要な場合:

```yaml
permissions:
  contents: write
```

ただし、必要なジョブに限定します。

## 環境変数

非 secret なシステム設定 (Configuration) は、環境変数/リポジトリ変数を利用可能とします。Secret は、変数ではなく Secrets を使用します。

例:

* `IOS_DEPLOYMENT_TARGET`
* `ANDROID_MIN_SDK`
* `XCODE_VERSION`
* `SWIFT_VERSION`

## ローカル / CI の一貫性

CI で使用するビルド・コマンド/テスト・コマンドは、可能な限り、ローカル開発環境でも実行可能にします。CI ワークフローに、すべてのビルド・ロジックを直接記述しません。

例:

* `./scripts/test.sh`
* `./scripts/lint.sh`
* `./scripts/build.sh`

## スクリプト境界

リポジトリ内のスクリプトを、CI とローカルで共有します。`scripts/` に推奨スクリプトを置きます。GitHub アクションは、これらのスクリプトを呼び出す、薄いオーケストレーション層とします。

推奨スクリプト: 

* `bootstrap.sh`
* `lint.sh`
* `test.sh`
* `build.sh`
* `docs-lint.sh`
* `release.sh` を 

## コードとしての CI システム設定 (Configuration)

CI/CD システム設定は、Git 管理します。本番環境 Secret は、Git 管理しません。

対象:

* `.github/workflows/`
* `scripts/`
* `project.yml`
* `Package.swift`

## CI のドキュメント

CI/CD の変更が、アプリケーション挙動、ビルド、配布またはリリース・プロセスに影響する場合、関連するドキュメントも更新します。

CI/CD に関する仕様は、`./docs/` 配下で管理します。

[`cicd.md`](./cicd.md) は、CI/CD パイプライン全体を定義し、[`release.md`](./release.md) は、リリース・プロセスの詳細を定義します。両者で重複する内容については、リリース・プロセスの詳細は [`release.md`](./release.md) を正とし、[`cicd.md`](./cicd.md) では概要のみを記載します。

特に下記を、必要に応じて、同期します。

* [`cicd.md`](./cicd.md)
* [`release.md`](./release.md)
* [`CHANGELOG.md`](../CHANGELOG.md)
* [`README.md`](../README.md)

## CI/CD 受け入れ条件

### PR

* [ ] PR で CI が実行される
* [ ] コンパイルが、成功する
* [ ] ユニットテストが、成功する
* [ ] Lint が、成功する
* [ ] ドキュメント Lint が、成功する
* [ ] セキュリティ・チェックが、成功する

### Main

* [ ] `main` が、ビルド可能である
* [ ] テストが、成功する
* [ ] リリース候補 (RC) を、生成可能である

### リリース

* [ ] バージョンが、検証される
* [ ] リリース・ビルドが、成功する
* [ ] 成果物が、生成される
* [ ] Git コミットと成果物を、追跡できる
* [ ] 本番環境が、分離されている
* [ ] 配布が、明示的に実行される

### セキュリティ

* [ ] Secret が、ソースに存在しない
* [ ] フォーク PR が、Secret を利用できない
* [ ] `GITHUB_TOKEN` が、最小権限の原則である
* [ ] サードパーティ製アクションのバージョンが、固定されている
* [ ] リリース Secret が、PR CI に公開されない

### 再現性

* [ ] 依存関係バージョンが、再現可能である
* [ ] Xcode バージョンが、識別可能である
* [ ] ビルド番号が、識別可能である
* [ ] Git コミット SHA が、成果物と紐付く

## 実用最小限の製品 (MVP) CI/CD

対象機能は [`use_cases.md`](./use_cases.md) の MVP ユースケースを正本とします。
本節は、「初期版の必須ジョブ」だけを定めます。機能一覧は再掲しません。

* PR → Lint →ユニットテスト→ビルド→セキュリティ・チェック/依存関係チェック→ドキュメント Lint
* `main`: フル CI → リリース候補 (RC) ビルド

リリースのタグ / TestFlight / App Store は [`release.md`](./release.md) を正本とします。
本仕様は、「Git タグからリリース・ビルドを起動する」ことのみを定めます。

## 将来 CI/CD

将来的に、下記を導入可能とします。

* Android CI
* Kotlin Multiplatform (KMP) commonTest
* Android エミュレータ UI テスト
* Google Play 内部のテスト
* TestFlight 自動配信
* App Store 自動配信
* 依存関係の自動更新
* SBOM
* 成果物の認証
* ビルドの来歴
* 自動リリースノート
* ナイトリー拡張 UI テスト
* パフォーマンスのリグレッション・テスト
* クラッシュレポート・アップロード / シンボル・アップロード
* 自動ロールバック支援

## CI/CD アーキテクチャー

PR/マージの順序は [CI パイプライン](#ci-パイプライン)、リリースゲートは [`release.md`](./release.md) を正本とします。
本仕様は、「`main` から、リリース候補 (RC) を切り、Git タグで iOS/Android のリリース・ワークフローを起動する」ことのみを定めます。

## 最終原則

S2J Package Dashboard の CI/CD は、下記を最終原則とします。

1. PR は、自動検証する
2. `main` は、常にビルド可能にする
3. リリースは、Git タグを基準にする
4. 本番配布は、明示的なリリースゲートの後に行う
5. Secret は、CI ソースに保存しない
6. `GITHUB_TOKEN` は、最小権限の原則とする
7. サードパーティ製アクションのバージョンを、固定する
8. 依存関係の解決を、再現可能にする
9. ビルド成果物と Git コミットを、追跡可能にする
10. ローカルと CI のビルド・スクリプトを、可能な限り、共通化する
11. iOS / Android / Kotlin Multiplatform (KMP) の CI を、同一の品質基準で扱う
12. CI/CD 自体を、アプリケーション・アーキテクチャーと同様に、コード/仕様として管理する
