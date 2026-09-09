# S2J Package Dashboard - リリース仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、リリース方針を定義します。Release 条件の正本である。

## 目的

本仕様は、リリースに関する基本方針、バージョニング、Release Candidate、検証、配布、リリース後の確認および Rollback 方針を定義する。Release 条件の正本である。

## 非目的

本仕様は、CI Job の詳細手順、日常の PR 検証、アプリケーション機能そのものを定義しない。

## 責務

何をもって Release とするか、版番号、品質ゲート、配布、Hotfix / Rollback を定義する。

## 非責務

CI/CD パイプラインは [`cicd.md`](./cicd.md) を正本とする。

## Release Principles

S2J Package Dashboard の Release は、下記の原則に従う。

1. `main` は常に Release 可能な状態を維持する。
2. Release される Version は Git tag によって一意に識別する。
3. Release 前に CI Quality Gate を通過する。
4. Release Artifact は、検証済みの Commit から生成する。
5. Release Version と Source Commit の対応関係を追跡可能にする。
6. Credentials、Signing Key、API Token 等の Secret を Git repository に保存しない。
7. Platform-specific な配布処理は、共通 Release Policy と分離する。
8. Release 後に最低限の Smoke Test を実施する。
9. 問題が発生した場合に、影響範囲を限定して Rollback または Hotfix を実施できる状態を維持する。

## Release Scope

本仕様で扱う Release の対象は下記とする。

| Category | Target |
| --- | --- |
| Source | Git repository |
| Version | Application Version |
| Git Tag | `vX.Y.Z` |
| GitHub | GitHub Release |
| iOS | App Store Connect / TestFlight / App Store |
| iPadOS | App Store Connect / TestFlight / App Store |
| Android | Google Play Console |
| Documentation | [`CHANGELOG.md`](../CHANGELOG.md), [`README.md`](../README.md), `./docs/`, `./docs_mod/` |
| CI/CD | GitHub Actions |

Android は将来対応する。

## Versioning

### 1. Versioning Policy

Application Version は Semantic Versioning を基本とする。

`MAJOR.MINOR.PATCH`

例:

* `1.0.0`
* `1.1.0`
* `1.1.1`
* `2.0.0`

Git tag は下記の形式とする。

`vMAJOR.MINOR.PATCH`

例:

* `v1.0.0`
* `v1.1.0`
* `v1.1.1`

GitHub でも Semantic Versioning にもとづく release tag が推奨されている。([Releasing and maintaining actions - GitHub Docs](https://docs.github.com/en/actions/how-tos/create-and-publish-actions/release-and-maintain-actions))

### 2. MAJOR Version

下記の場合に MAJOR Version を increment する。

* 既存ユーザーに影響する重大な仕様変更
* 既存設定・データとの互換性を維持できない変更
* 公開 API / Data Model / Persistence Model の破壊的変更
* Migration が必要となる重大な変更

例:

`1.5.3 → 2.0.0`

### 3. MINOR Version

下記の場合に MINOR Version を increment する。

* 後方互換性を維持した新機能
* 新しい Screen
* 新しい Statistics
* 新しい Package Management 機能
* 新しい Platform Support

例:

`1.2.3 → 1.3.0`

### 4. PATCH Version

下記の場合に PATCH Version を increment する。

* Bug Fix
* Security Fix
* UI/UX の軽微な修正
* Performance Improvement
* Documentation の修正のみではなく、Application Behavior に影響する軽微な変更

例:

`1.2.3 → 1.2.4`

## Pre-release Version

Release Candidate 等の事前公開版には Pre-release Identifier を使用できる。

例:

* `1.0.0-alpha.1`
* `1.0.0-beta.1`
* `1.0.0-rc.1`

Git tag:

* `v1.0.0-alpha.1`
* `v1.0.0-beta.1`
* `v1.0.0-rc.1`

Pre-release は Production Release と区別する。

## Release Channels

Release は下記の Channel に分類する。

| Channel | Purpose |
| --- | --- |
| Development | 開発中の検証 |
| Internal | 開発者・関係者による検証 |
| Beta | 外部を含む事前検証 |
| Release Candidate | Production Release 候補 |
| Production | 一般ユーザー向け正式版 |

## Release Candidate

### 1. Purpose

Release Candidate (RC) は、Production Release 候補として十分な検証を完了した Build とする。

RC は単なる Beta Build ではなく、原則として下記を満たす。

* Feature Complete
* Version 確定
* Documentation 更新済み
* CHANGELOG 更新済み
* Known Issue の確認済み

必須の Test Suite は [`testing_spec.md`](./testing_spec.md) の Release Candidate Tests を正本とする。RC Build は Production Build と同じ Configuration を使用する。

### 2. RC Tag

RC には下記の形式を使用する。

`v1.0.0-rc.1`

RC に重大な問題が発見された場合は、修正版を新しい RC とする。

* `v1.0.0-rc.1`
* `v1.0.0-rc.2`
* `v1.0.0-rc.3`

既存の RC tag を書き換えない。

## Release Preconditions

Release を開始する前に、下記を確認する。

### 1. Source

* [ ] Release 対象 Commit が `main` に存在する
* [ ] Working Tree が意図した状態である
* [ ] Release に不要な変更が含まれていない
* [ ] Pull Request が必要な範囲で Merge 済みである

### 2. CI

* [ ] CI が成功している
* [ ] Unit Test が成功している
* [ ] Integration Test が成功している
* [ ] Static Analysis が成功している
* [ ] Documentation Check が成功している
* [ ] Security Check が成功している

### 3. Documentation

* [ ] [`CHANGELOG.md`](../CHANGELOG.md) が更新されている
* [ ] [`README.md`](../README.md) の Version-dependent information が更新されている
* [ ] `./docs_mod/` の関連仕様が更新されている
* [ ] `./docs/` の関連ドキュメントが必要に応じて更新されている
* [ ] Release Notes を作成できる状態である

### 4. Version

* [ ] Application Version が確定している
* [ ] Git tag が未使用である
* [ ] iOS/iPadOS の Version / Build Number が整合している
* [ ] Android の Version Code / Version Name が必要に応じて更新されている

## Release Preparation

Release Preparation は下記の順序で実施する。

1. development
2. feature complete
3. main
4. CI
5. release preparation
6. version update
7. CHANGELOG update
8. Release Candidate
9. platform testing
10. Release approval
11. production release

## Version Update

Release Version を確定した後、Application の Version 情報を更新する。

Version 情報を複数の箇所で管理する場合、それぞれが同一 Release Version を指すことを確認する。

例:

`MARKETING_VERSION = 1.0.0`

Build Number は Application Version とは独立して管理する。

* Version: 1.0.0
* Build: 100

Build Number は同一 Platform 内で重複させない。

## Documentation Responsibility

Documentation は下記の役割に分類する。

| Location | Role |
| --- | --- |
| `./docs_mod/` | Development / Design Specification |
| `./docs/` | Published / User-facing Documentation |
| [`README.md`](../README.md) | Repository Overview |
| [`CHANGELOG.md`](../CHANGELOG.md) | Release History |

## CHANGELOG

Release 前に [`CHANGELOG.md`](../CHANGELOG.md) を更新する。

Release Notes には少なくとも下記を含める。

* Added
* Changed
* Fixed
* Security
* Known Issues

例:

```markdown
## [1.0.0] - YYYY-MM-DD

### Added

- Package Dashboard
- Packagist package statistics
- GitHub repository statistics

### Changed

- Initial production release

### Fixed

- N/A

### Security

- Credential data is stored using platform secure storage

### Known Issues

- None
```

CHANGELOG の内容は GitHub Release Notes および Platform Store Release Notes の基礎情報として利用する。

## Git Tag

Release Version を確定したら、対応する Git tag を作成する。

`v1.0.0`

Tag は Release 対象 Commit に直接対応させる。`main` 上の release commit に `v1.0.0` を付ける。

Release tag 作成後、その tag が指す Commit を変更しない。

Release に対応する GitHub Release は、可能な限り immutable な Release Artifact として扱う。

## GitHub Release

GitHub Release は Release の主要な記録として使用する。

GitHub Release には下記を含める。

* Version
* Release Date
* Summary
* Added
* Changed
* Fixed
* Security
* Known Issues
* Supported Platforms
* Build information
* Source Commit

Release Artifact が存在する場合は、該当する Artifact を添付する。

## iOS / iPadOS Release

### 1. Build

iOS / iPadOS Build は CI/CD により再現可能な形で生成する。

基本的な流れ: Git tag を起点に CI で Build / Test / Archive / Validate し、Upload 先を App Store Connect とする。CI Job の順序は [`cicd.md`](./cicd.md) の `### Release Pipeline` を正本とする。本節は、iOS / iPadOS Artifact の提出先が App Store Connect であることだけを定める。

### 2. TestFlight

Production Release 前に必要に応じて TestFlight を利用する。

TestFlight では Internal Tester / External Tester を使い分ける。

Apple の App Store Connect では、TestFlight に Build を Upload し、Tester に配布して検証できる。External Tester に対しては Beta App Review が必要となる場合がある。([TestFlight overview - Test a beta version - App Store Connect - Help - Apple Developer](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview))

TestFlight 検証項目:

* [ ] App Launch
* [ ] Package List
* [ ] Package Detail
* [ ] Search
* [ ] Refresh
* [ ] Statistics
* [ ] GitHub Integration
* [ ] Authentication
* [ ] Offline / キャッシュ
* [ ] Navigation
* [ ] iPhone
* [ ] iPad
* [ ] Rotation
* [ ] Accessibility

## App Store Release

Production Release の iOS / iPadOS Build は App Store Connect から App Review に提出する。

基本的な流れ: TestFlight → Release Candidate validation → App Store Connect → App Review → Approved → Release → Production verification。

Apple の公式 Release Flow でも、TestFlight による Beta 検証後、最終 Build を App Review に提出して App Store で公開する流れが基本となる。([Distributing your app for beta testing and releases | Apple Developer Documentation](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases))

## Android Release

Android Support が実装された場合、Google Play Console を利用する。

基本的な流れ: Git tag を起点に CI で Build / Test し、成果物を Android App Bundle として Internal / Closed / Open testing を経て Production へ進める。CI Job の順序は [`cicd.md`](./cicd.md) の `### Release Pipeline` を正本とする。本節は、Google Play の提出形式と Testing Track だけを定める。

Google Play では Android App Bundle (AAB) を基本的な公開形式として使用する。([Inspect app versions on the Latest releases and bundles page - Play Console Help](https://support.google.com/googleplay/android-developer/answer/9844279?hl=en))

Testing Track は必要に応じて下記を使用する。

* Internal testing
* Closed testing
* Open testing
* Production

Google Play Console はこれらの Testing Track と Production を Release 単位で管理できる。([Prepare and roll out a release - Play Console Help](https://support.google.com/googleplay/android-developer/answer/9859348/prepare-and-roll-out-a-release?hl=en-GB))

## Platform Release Independence

iOS / iPadOS と Android の Release は、必ずしも同一タイミングで公開する必要はない。

たとえば:

* S2J Package Dashboard v1.2.0
    * iOS: Released
    * iPadOS: Released
    * Android: Testing

という状態を許容する。

ただし、Platform ごとに Application Version の意味が異なる状態を長期間維持しない。

Platform-specific な未実装機能がある場合は、Release Notes に明記する。

## Release Quality Gate

Production Release には Quality Gate を設ける。各 Gate で何をテストするかは [`testing_spec.md`](./testing_spec.md)、いつどの Job が走るかは [`cicd.md`](./cicd.md) を正本とする。本節は、必須 Gate が失敗した場合に Production Release を停止することだけを定める。

## Device Validation

実機検証を Production Release の必須条件とする。対象デバイスは [`ui-viewport.md`](./ui-viewport.md) の Reference Devices、確認項目は [`testing_spec.md`](./testing_spec.md) / [`ui-viewport.md`](./ui-viewport.md) を正本とする。

Android Support 開始後に、代表的な Android Device / Window Size を追加する。

## Release Smoke Test

Production Release 後、Smoke Test を必須とする。確認する操作内容は [`testing_spec.md`](./testing_spec.md) の Post-release Smoke Test を正本とする。

Authentication を利用する機能については、Authentication 状態も確認する。

## Post-release Verification

Release 後、下記を確認する。

## Application

アプリケーション動作の確認内容は [`testing_spec.md`](./testing_spec.md) の Post-release Smoke Test を正本とする。

## Distribution

* [ ] App Store / Google Play で Version が確認できる
* [ ] 正しい Build が配布されている
* [ ] Release Notes が正しい
* [ ] Store Metadata が正しい

## Monitoring

* [ ] Crash / Error が異常増加していない
* [ ] API Error が異常増加していない
* [ ] Authentication Error が異常増加していない
* [ ] Critical Bug Report が発生していない

## Release Incident

Production Release 後に重大な問題が確認された場合、Issue の Severity を判定する。

| Severity | Description | Action |
| --- | --- | --- |
| Critical | 起動不能・重大なデータ破壊・重大な Security Issue | Release Stop / Hotfix |
| High | 主要機能が利用不能 | Hotfix 検討 |
| Medium | 一部機能に問題 | 次回 Release または Hotfix |
| Low | 軽微な UI / UX Issue | 次回 Release |

Critical / High の問題については、通常の Release Cycle を待たずに Hotfix Release を検討する。

## Hotfix

Hotfix は Production Version に対する緊急修正版とする。

例: `1.2.0` に対する Hotfix は `1.2.1` とする。

Hotfix でも通常の CI Quality Gate を省略しない。

ただし、Critical Incident の場合は必要最小限の検証に絞った Emergency Release Process を使用できる。

Emergency Release 後は、通常の CI / Test / Documentation を追補して状態を正規化する。

## Rollback

Rollback は下記の場合に検討する。

* Critical Crash
* Application Launch Failure
* Critical Security Issue
* Major Data Corruption
* Major API Compatibility Failure

Mobile App の Store Release は Web Service のように即時に全ユーザーを旧 Version に戻せるとは限らない。

そのため、基本戦略は Incident → Release Stop → 可能な範囲でサーバー側挙動を Disable → Hotfix → Emergency Release とする。

サーバー側 Feature Flag 等で制御可能な機能については、Release Rollback よりも Feature Disable を優先できる。

## Release Artifact

Release Artifact は、Release Version と Source Commit を追跡可能な状態で保存する。

最低限、下記を記録する。

* Application Version
* Build Number
* Git Tag
* Git Commit SHA
* Build Date
* Platform
* CI Workflow Run

例:

* Version: 1.0.0
* Build: 100
* Tag: v1.0.0
* Commit: <SHA>
* Platform: iOS

Artifact の生成元を後から特定できない Build を Production Release に使用しない。

## Reproducibility

可能な限り同一 Source Commit から同一 Release Artifact を再生成できる状態を維持する。

そのために下記を管理する。

* Xcode Version
* Swift Version
* Swift Package dependency versions
* Android SDK Version
* Kotlin Version
* Gradle Version
* Gradle dependency versions
* Build configuration
* CI Runner image

CI では `latest` に依存しすぎず、Production Release に使用する Toolchain を明示的に管理する。

## Secrets and Signing

Release に必要な Credentials / Signing Material は Repository に保存しない。

対象:

* Apple signing certificate
* Apple provisioning information
* App Store Connect credentials
* App Store Connect API Key
* Google Play service account credentials
* Android signing key
* Packagist API Token
* GitHub Token

Secrets は GitHub Actions Secrets / Environment Secrets 等の安全な Secret Store を利用する。

Production Release では、可能な限り専用 Environment を使用し、Release Approval を必要とする。

## Release Approval

Production Release は自動 Build と自動 Release を必ずしも同一処理としない。

推奨フロー: Tag → CI → Build → Test → Artifact → Release Candidate → Manual Approval → Production Distribution。CI Job の順序は [`cicd.md`](./cicd.md) を正本とする。本節は、CI 成功だけで Production Release を自動実行しないことだけを定める。

## Release Checklist

## Preparation

* [ ] Feature Complete
* [ ] Issue / PR review complete
* [ ] CI successful
* [ ] Version determined
* [ ] CHANGELOG updated
* [ ] Documentation updated
* [ ] Release Notes prepared

## Candidate

* [ ] Release Candidate tag created
* [ ] Build successful
* [ ] Unit Test successful
* [ ] Integration Test successful
* [ ] Device Test successful
* [ ] TestFlight / Android testing completed

## Production

* [ ] Production tag created
* [ ] GitHub Release created
* [ ] iOS / iPadOS submitted
* [ ] Android submitted when applicable
* [ ] Store metadata verified
* [ ] Release Notes verified

## Post-release

* [ ] Production Smoke Test completed
* [ ] Crash / Error checked
* [ ] API health checked
* [ ] Authentication checked
* [ ] Known Issues reviewed
* [ ] Release completed

## Release Flow

Release 全体は `## Release Preparation` を正本とする。本節は、RC 後に iOS/iPad TestFlight と Android Testing を並列し、Approval → Production → Smoke Test → Monitor とすることだけを定める。

## Relationship with CI/CD

[`cicd.md`](./cicd.md) はいつどの Job が走るか、本仕様は何をもって Release としどの条件で Production に配布するかを正本とする。検証内容は [`testing_spec.md`](./testing_spec.md) を正本とする。

## Source of Truth

Release に関する情報は下記の優先順位で管理する。

1. [`release.md`](./release.md)
2. [`CHANGELOG.md`](../CHANGELOG.md)
3. GitHub Release
4. Platform Store Release Notes
5. [`README.md`](../README.md)

実際の Release 作業で仕様と実装が矛盾した場合は、Release 前に本仕様を更新する。

## Future Extensions

下記は将来必要になった場合に追加する。

* Automated Release Notes
* App Store Connect API integration
* Google Play Developer API integration
* Automatic TestFlight distribution
* Automatic Google Play testing-track distribution
* Release approval workflow
* Release dashboard
* Crash analytics integration
* Feature Flag
* Remote Configuration
* Automated rollback support
* Artifact attestation
* SBOM generation
* Release provenance

## MVP Release Policy

対象機能は [`use_cases.md`](./use_cases.md) の MVP ユースケースを正本とする。本節は、出荷に必要な成果物とゲートを定義する。機能一覧は再掲しない。

### Required

* Semantic Versioning
* Git tag
* GitHub Release
* CI Quality Gate
* CHANGELOG
* iOS/iPadOS TestFlight
* iOS/iPadOS Production Release
* Device Smoke Test
* Release Checklist
* Production Post-check

### Future

* Android Production Release
* Automated Store submission
* Automated Release Notes
* Automated Rollback
* Feature Flag
* SBOM
* Artifact Attestation

MVP では Release Automation を過度に複雑化せず、`## Release Approval` の Manual Approval を基本形とする。

## Final Release Policy

S2J Package Dashboard の Release は、**「検証済みの Source Commit を、明確な Version として固定し、再現可能な Artifact を生成し、Platform-specific な配布経路を経て Production に公開する」** ことを基本とする。

Release の成功条件は、単に Build が成功することではなく、Source / Version / CI / Test / Artifact が Release Ready として追跡可能であり、その後 Distribution と Post-release Verification までたどれることとする。
