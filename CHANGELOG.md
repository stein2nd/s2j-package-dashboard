# S2J Package Dashboard - CHANGELOG

## unreleased

## 0.0.1 - 2026-08-17

### Added

* プロジェクト基盤を追加 (`package.json`、`Package.swift`、`.gitignore`、`.npmrc`)
    * `@s2j/docs-linter` ^1.0.22 と `lint:docs` / `test:local` スクリプト
    * Swift tools v6.3、macOS v14、`swift-docc-plugin`
    * npm 12+ 向け `legacy-peer-deps=true` / `allow-git=all`、`allowScripts`
* textlint 設定 (`.textlintrc.json`、`.vscode`) と Cursor allowlist を追加
* macOS アプリの骨格 (`S2JPackageDashboardApp/`) を追加
* 仕様草案 `docs_mod/` を追加 (`specs.md` を起点に overview / architecture / cicd 等)
* GitHub Actions ワークフローのプレースホルダー (`docs-lint.yml`、`swift-test.yml`) を追加
