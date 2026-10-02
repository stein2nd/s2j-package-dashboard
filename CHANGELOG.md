# S2J Package Dashboard - CHANGELOG

## unreleased

## 0.0.4 - 2026-10-02

### Changed

* 廃止された `npm.enableScriptExplorer` を `.vscode/settings.json` から外し、`json.schemaDownload.enable` を有効にする

## 0.0.4 - 2026-09-29

### Changed

* `docs/specs.md` の入口節をですます調にそろえる
* `*.code-workspace` を `.gitignore` に追加し、ローカルのワークスペースファイルを Git の追跡対象外にする

## 0.0.4 - 2026-09-28

### Added

* 進行中 initiative の実装管理を `docs_mod/` に追加
    * `implementation.md`: 優先順位ごとのタスク
    * `status.md`: 進捗

### Changed

* `docs_mod/` の専門仕様を `preset-wp-docs-ja` に合わせて表記を統一
    * 英語混在の見出し・用語を日本語化 (Storage → ストレージ、Architecture → アーキテクチャー、Cross-* → 横断型、Package → パッケージ、Favorite → お気に入り、Credential → クレデンシャル など)
    * 正本参照の長文を分割し、本仕様の範囲を引用で明示。参考リンクを `(参考: …)` に切り出し
    * 見出し先頭の通し番号を外し、本文をですます調にそろえる
    * 本文に残っていた英語用語も日本語化 (Authentication → 認証、Chart → チャート、Historical → 履歴、Native → ネイティブ など)。略語は初出で和訳を併記 (DTO: データ転送オブジェクト、TTL: 有効期限)
    * 見出しに残っていた英語も日本語化 (Pull to Refresh → 引っ張って更新、Dark Mode → ダークモード、Safe Area → セーフエリア、Build → ビルド、Phase → フェーズ、MVP → 実用最小限の製品 など)
    * 本文の用語をそろえる (応答 → レスポンス、視覚 → ビジュアル、回帰 → リグレッション、定着率 → 継続率)。キャッシュの鮮度を表す「期限切れ」は Stale に統一
    * 残っていた常体をですます調にし、読点と中黒を補う。長い一文は箇条書きに分割
    * `api-github.md` / `api-packagist.md` の節構成と相互参照を整理
        * 節の並びを「目的 → エンドポイント」にそろえ、長い変換フローは箇条書きに分割
        * 本文中の見出し名を Markdown リンクにする
        * テスト種別を「連携テスト」から「結合テスト」に統一 (`spec_structure.md` も同様)。セレクション → 選択、意味論 → セマンティクス、Organization → 組織、コミット履歴 → コミット活動
    * `models_spec.md` の型名と層の書き方を整理
        * 見出しに型名を併記 (マイ・パッケージ `MyPackage`、お気に入り `Favorite`、統計のスナップショット `StatisticsSnapshot` など)
        * モデル層を具体例つきの箇条書きにし、UI モデルをプレゼンテーション・モデルに改称
        * `PackageType` の節をパッケージ名の前へ移し、統計仕様への参照を見出しリンクにする
    * 実装時期をユースケースの優先順位にそろえる
        * 優先順位-1: ダッシュボード、Packagist 認証 (クレデンシャル節とそこへの経路)、管理対象の取得、一覧、検索、詳細、統計、ローカルデータ、オフライン、エラー復旧
        * 優先順位-2: お気に入り、パッケージ更新、GitHub 認証、クレデンシャルの更新・削除、認証ステータス、ナビゲーション復元、ディープリンク、設定の残り、About。初期バージョンの最優先ではなく、v1.1または v1.2で可能な限り早く実装する。将来予定ではない
        * 将来予定: エクスポート、インポート、同期
    * About は設定からのみ開く。表示できることの確認は UC-31、表示内容は UC-32
    * パッケージ詳細に README と依存関係を含める。呼び方と並びは画面仕様を正本とする
    * README 本文は公開リポジトリの README API を匿名で取得し、Markup HTML とする。サブディレクトリと非公開リポジトリは初期バージョンの対象外。健全性はコミュニティ・プロフィールのまま、本文とは分ける
    * GitHub トラフィックは初期バージョンに含め、認証成功後に取得する。認証の設定は UC-17 (優先順位-2)
    * セキュリティ告知の有無と件数を、初期バージョンのパッケージ詳細に出す
    * リポジトリを特定できないときは短い理由のあと Packagist のデータを出し、Packagist も失敗したときは短い理由と端末内の最新キャッシュを出す。認証エラーと権限エラーも短い人間可読な文とし、HTTP ステータスコードは出さない
    * 初期対象は iOS/iPadOS の SwiftUI。Android は今後のターゲット。Room は Android 永続化の利用の第一候補
    * 保持の用語を「継続率」から「保持」に改める。キャッシュの Stale と認証の有効期限切れは分けたまま
* `@s2j/docs-linter` を ^1.0.25に更新

* 確定した仕様を `docs_mod/` から `docs/` に移す。実装管理 (`implementation.md`、`status.md`、`test-results.md`) は `docs_mod/` に残す

## 0.0.3 - 2026-09-10

### Changed

* GitHub Actions のプレースホルダーを実装に置き換え
    * `docs-lint.yml`: Node.js v20で `npm run lint:docs` を実行
    * `swift-test.yml`: macOS / iOS テスト、リリース・ビルド、Codecov。Xcode v26.5 (Swift v6.3+) を使用

## 0.0.2 - 2026-09-10

### Added

* `docs_mod/` に層別の専門仕様を追加し、`specs.md` を入口として整理
    * ドメイン / 外部連携: `domain_rules.md`、`api-packagist.md`、`api-github.md`
    * アプリケーション: `use_cases.md`、`application_state.md`、`state_machine.md`
    * プレゼンテーション: `navigation_spec.md`、`screen_spec.md`、`component_spec.md`、`ui.md`、`ui-viewport.md`
    * 永続化 / 統計: `storage_spec.md`、`cache_spec.md`、`ios_spec.md`、`android_spec.md`、`statistics_spec.md`
    * 認証 / プラットフォーム / テスト / 運用: `authentication_spec.md`、`kmp_spec.md`、`testing_spec.md`、`test-results.md`、`release.md`

### Changed

* 既存仕様 (`overview` / `architecture` / `models_spec` / `ux_flows_spec` / `design_spec` / `security_spec` / `cicd` / `spec` / `spec_structure` / `specs`) を責務分割と正本参照に合わせて拡充
* `@s2j/docs-linter` を ^1.0.24に更新し、textlint を base プリセット + `preset-wp-docs-ja` に切り替え

## 0.0.1 - 2026-08-17

### Added

* プロジェクト基盤を追加 (`package.json`、`Package.swift`、`.gitignore`、`.npmrc`)
    * `@s2j/docs-linter` ^1.0.22と `lint:docs` / `test:local` スクリプト
    * Swift tools v6.3、macOS v14、`swift-docc-plugin`
    * npm v12+ 向け `legacy-peer-deps=true` / `allow-git=all`、`allowScripts`
* textlint 設定 (`.textlintrc.json`、`.vscode`) と Cursor allowlist を追加
* macOS アプリケーションの骨格 (`S2JPackageDashboardApp/`) を追加
* 仕様草案 `docs_mod/` を追加 (`specs.md` を起点に overview / architecture / cicd 等)
* GitHub Actions ワークフローのプレースホルダー (`docs-lint.yml`、`swift-test.yml`) を追加
