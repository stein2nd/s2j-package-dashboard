# S2J Package Dashboard - CHANGELOG

## unreleased

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
