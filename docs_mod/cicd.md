# S2J Package Dashboard - CI/CD 仕様

## 概要

本ドキュメントは、S2J Package Dashboard の初期設計における、CI/CD 方針を定義します。GitHub Actions を使用する。

## 目的

本仕様は、CI/CD の方針、Workflow、品質ゲート、Build、Test、Artifact および Security を定義する。GitHub Actions を使用する。

## 非目的

本仕様は、アプリケーションのドメイン挙動、Store 提出の可否判断、版番号の意味を再定義しない。

## 責務

いつどの Job が走るか、成果物、パイプライン上のゲート評価、Signing / Environment、Artifact の扱いを定義する。

## 非責務

Release 条件、バージョニング、TestFlight / Play、Rollback は [`release.md`](./release.md) を正本とする。アプリケーション本体の仕様は各専門仕様を正本とする。

## CI/CD Principles

下記を基本原則とする。

### 1. Every Change Must Be Verifiable

Pull Request に含まれる変更は、Merge 前に自動検証が可能であること。流れは Pull Request → CI → Quality Gate → Merge とする。

### 2. Main Must Remain Buildable

`main` branch は常に Release Candidate を生成可能な状態を維持する。流れは `main` → Build → Test → Release Candidate とする。

### 3. Build Reproducibility

同一 Commit から生成される Artifact は、可能な限り同一の Source / Dependency / Build Configuration にもとづくものとする。

### 4. Fail Fast

安価で高速な検証を先に実行する。順序は Lint → Static Analysis → Unit Test → Integration Test → Build → UI Test → Distribution とする。

### 5. No Secret in Source

Credential / Certificate / Token / API Key 等を Repository に Commit しない。

GitHub Actions では Secret を必要な Job に限定して利用する。

## CI/CD Platform

CI/CD Platform: `GitHub Actions`

Workflow は: `.github/workflows/`

に配置する。

推奨 Workflow ファイル:

* `ci.yml`
* `docs.yml`
* `security.yml`
* `dependency.yml`
* `ios.yml`
* `android.yml`
* `release.yml`

実際の Workflow 数は実装上の保守性を考慮して統合してよい。

## Workflow Naming

Workflow 名は目的を明確にする。

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

Job 名も GitHub Actions UI 上で意味が明確になるようにする。

## Trigger Policy

### 1. Pull Request

基本的に下記を対象とする。

`pull_request`

対象 branch: `main`

必要に応じてパス filter を利用する。

### 2. Push

`main` への Push を対象とする。

```yml
push:
  branches:
    - main
```

Pull Request Merge 後の状態を検証する。

### 3. Manual

必要に応じて `workflow_dispatch` を利用する。

用途:

* 再 Build
* Release Candidate
* Emergency Release
* Distribution Retry
* Maintenance

### 4. Release

Git Tag または GitHub Release を Release Trigger とする。

推奨:

`vMAJOR.MINOR.PATCH`

例:

* `v1.0.0`
* `v1.1.0`
* `v1.1.1`

## Branch Strategy

* 基本 branch: `main`
* Feature Branch: `feature/*`
* Fix Branch: `fix/*`
* Release Branch が必要となった場合: `release/*`

を利用可能とする。

ただし、不要な長期間 Branch を作成しない。

## Pull Request Quality Gate

Pull Request は下記を満たさなければ Merge できない。各 Check で何をテストするかは [`testing_spec.md`](./testing_spec.md) を正本とする。

* Build
* Test
* Lint
* Documentation
* Security

最低限、Compile / Unit Test / Static Analysis / Format Check、Documentation Lint、Dependency / Secret Check を満たす。順序は `### 4. Fail Fast` を正本とする。

## CI Pipeline

標準 CI Pipeline の順序は `### 4. Fail Fast` を正本とする。本節は、Pull Request で Lint / Test / Security を並列し、Build 後に Quality Gate を経て Merge することだけを定める。

## Source Checkout

Workflow では Repository を Checkout する。

Action Version は明示的に固定する。

GitHub は Action を Branch 名だけで参照するより、Version Tag または Commit SHA を指定することを推奨している。特に Security / Reproducibility を重視する Workflow では SHA 固定を優先する。([Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

例:

```yaml
- uses: actions/checkout@<pinned-version>
```

実際の Version / SHA は Workflow 実装時点で決定する。

## GitHub Token Permissions

Workflow の `GITHUB_TOKEN` は最小権限とする。

基本:

```yaml
permissions: {}
```

Read-only が必要な CI:

```yaml
permissions:
  contents: read
```

Release 等で Write が必要な Job は、その Job にのみ必要な権限を付与する。

GitHub Actions では `permissions` により `GITHUB_TOKEN` の権限を `read` / `write` / `none` で明示できる。明示した場合、未指定の権限は `none` になるため、Least Privilege を実現しやすい。([Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

## Secret Management

Secret は GitHub Actions Secret / Environment Secret を使用する。

例:

* APP_STORE_CONNECT_API_KEY
* APP_STORE_CONNECT_KEY_ID
* APP_STORE_CONNECT_ISSUER_ID

* MATCH_PASSWORD
* SIGNING_PASSWORD

* GOOGLE_PLAY_SERVICE_ACCOUNT

実際の Secret 名は実装時に決定する。

Secret を下記に記述してはならない。

* Source Code
* `project.yml`
* `Package.swift`
* `.env` committed to Git
* Documentation
* Workflow Log
* Test Fixture
* Screenshot
* Artifact

Environment Secret を使用する場合、Release Job のような必要な Job にのみ Environment を関連付ける。

GitHub の Environment Secret は、その Environment を参照する Job にのみ提供でき、Approval が設定されている場合は承認後に利用可能となる。([Deployments and environments · github/docs · GitHub](https://github.com/github/docs/blob/main/content/actions/reference/workflows-and-actions/deployments-and-environments.md))

## Fork Pull Request Security

Fork からの Pull Request では Secret を利用する Workflow を実行しない。

特に Fork PR から Secret Access や Release / Distribution を行わない。Fork PR では通常の Read-only CI のみを実行する。

GitHub Actions では Fork / Dependabot 起点の Workflow は Secret を利用できない制約があるため、この前提を CI 設計に組み込む。([Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

## Dependency Installation

Dependency Installation は Lock File を正とする。

対象:

* Swift Package Manager
* npm
* Composer
* 将来の Gradle / Kotlin

Dependency Version を CI 実行ごとに意図せず変化させない。

## Swift Package Manager

Swift Package Manager を利用する場合、下記を基本とする。

* Package.swift
* Package.resolved

CI では Lock / Resolution 情報を尊重する。

Dependency 更新は通常の CI と分離し、専用の Dependency Update Workflow で検証する。

## Xcode Project Generation

本プロジェクトでは `project.yml` を XcodeGen の入力として扱う場合、CI でも `project.yml` → XcodeGen → Xcode Project → Build / Test の同じ生成手順を使用する。

生成された Xcode Project を Source of Truth としない場合は、Repository に Commit しない。

Source of Truth: `project.yml`

## Xcode Version

CI では Xcode Version を明示する。

例:

`Xcode v26.x`

実際の Version は対象 SDK / Deployment Target / CI Runner の対応状況に応じて固定する。

GitHub-hosted macOS runner では複数の Xcode Version が提供されるため、`xcode-select` 等を用いて CI が意図した Xcode を使用していることを検証する。GitHub の runner image には Xcode Version / macOS Version が明示されている。([runner-images/images/macos/xcode-27-Readme.md at main · actions/runner-images · GitHub](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-Readme.md))

## Swift Build

基本 Build:

* `Debug`
* `Release`

CI では少なくとも `Debug` Build を検証する。

`Release` Build は `Release` Workflow または main CI で検証する。

## Swift Unit Test

Unit Test は Pull Request CI で必須とする。

対象:

* Domain
* Application
* State Machine
* Reducer
* Use Case
* Repository Mock
* Validation
* Statistics

State Machine は外部 I/O なしでテスト可能でなければならない。

## SwiftUI Test

UI Test は下記を対象とする。

* Launch
* Dashboard
* Package List
* Package Detail
* Search
* Favorite
* Statistics
* Refresh
* Error
* Offline
* Navigation
* State Restoration

UI Test は PR CI と Nightly / Main CI で実行頻度を分けてもよい。

## Device Test Matrix

対象デバイスは [`ui-viewport.md`](./ui-viewport.md) の Reference Devices を正本とする。本仕様は、CI 上で Simulator の安定 OS を使い、実機固有の問題は Manual Device Test で確認することだけを定める。

## Platform Compatibility

CI で最低限確認する対象:

* iOS
* iPadOS

Android 対応後: Android

を追加する。

KMP Shared Logic は Platform ごとに同じ Test Suite を共有できる構造を目指す。

## Android CI

Android 実装開始後は下記を追加する。

* `./gradlew lint`
* `./gradlew test`
* `./gradlew assemble`

必要に応じて: `./gradlew connectedCheck` を使用する。

Android UI Test は Emulator を利用する。

## KMP CI

KMP Shared Logic 導入後は `commonMain` を独立して Test 可能とする。

HOW は [`kmp_spec.md`](./kmp_spec.md) を正本とする。本仕様は、`commonMain` を独立して Unit Test し、その後 iOS / Android で検証することだけを定める。

State Machine / Domain / Use Case の Test は可能な限り common Test に集約する。

## Documentation CI

Documentation も CI の対象とする。

対象:

* `docs_mod/**/*.md`
* `docs/*.md`
* `README.md`
* `CHANGELOG.md`

検証:

* Markdown syntax
* textlint
* Link Check
* Internal Reference Check
* Required Heading Check

既存の `docs-linter` 方針と整合させる。

## Documentation Quality Gate

Documentation CI が失敗した場合、PR を Merge 不可とする。

ただし、下記のような明らかな External Service 障害については CI Retry を可能とする。

* External Link Timeout
* Temporary HTTP Error

## Static Analysis

Static Analysis を CI に含める。

Swift:

* SwiftLint
* SwiftFormat --lint

必要に応じて:

「Xcode Compiler Warnings」を Error / Warning として扱う。

Android:

* `ktlint`
* `detekt`
* `Android Lint`

を導入可能とする。

## Formatting

Formatting は CI で検証する。

基本原則は、Source を Formatter に通し Expected Format と差分がないこととする。

CI では Source を自動修正せず、差分を検出して Failure とする。

開発者は Local で Formatter を実行して修正する。

## Dependency Audit

Dependency の脆弱性を定期的に検査する。

対象:

* Swift Package
* npm
* Composer
* Gradle / Maven

GitHub Dependabot を利用可能とする。

Dependency Update は Update → CI → Test → Merge の流れで処理する。

## Secret Scanning

対象の種類は [`security_spec.md`](./security_spec.md) を正本とする。本仕様は、Repository に Credential が Commit されていないことを継続的に検証することだけを定める。GitHub Secret Scanning / Push Protection が利用可能な場合は有効化する。

## Security Workflow

Security Workflow は通常の CI と独立して実行可能とする。対象は Dependency Audit / Secret Scan / Static Analysis / Configuration Check とする。

Security Failure は Severity に応じて Merge Gate とする。

## Build Artifact

CI で生成した Build Artifact は必要に応じて GitHub Actions Artifact として保存する。

例:

* `S2JPackageDashboard.xcarchive`
* `S2JPackageDashboard.ipa`
* Test Results
* Coverage Report

Debug Build Artifact は原則として長期保存しない。

Release Artifact は Release Workflow で正式に管理する。

## Artifact Naming

Artifact 名は下記の情報を識別可能にする。

`<Product>-<Platform>-<Configuration>-<Version>-<Build>`

例:

`S2JPackageDashboard-iOS-Release-1.0.0-100`

## Test Results

CI は Test Result を GitHub Actions UI から確認可能にする。

対象:

* Unit Test Result
* UI Test Result
* Failure Log
* Code Coverage

必要に応じて JUnit / XCTest Result を標準化する。

## Code Coverage

Code Coverage は品質指標として計測する。

初期段階では Coverage Percentage を絶対的な Merge Gate としない。

まず Coverage の Trend と Regression Detection を重視する。Coverage を品質の唯一の指標としないことは [`testing_spec.md`](./testing_spec.md) を正本とする。

十分な Test Suite が確立した段階で Minimum Coverage Threshold を設定する。

## Pull Request Checks

必須 Check は `## Pull Request Quality Gate` を正本とする。Android 導入後は Android / Test / Lint / Build を追加する。

## Branch Protection

`main` Branch に Branch Protection を設定する。

必須条件:

* Pull Request Required
* Required Status Checks
* Conversation Resolution
* No Direct Push

必要に応じて:

* Required Review
* CODEOWNERS Review
* Signed Commit

を追加する。

## CODEOWNERS

重要な仕様 / Workflow / Security Configuration について CODEOWNERS を利用可能とする。

例:

* `.github/`
* `docs_mod/`
* `project.yml`
* `Package.swift`

変更時に適切な Review を要求する。

## Release in CI

Release 条件 (版番号、品質ゲート、TestFlight / Play、Rollback) の正本は [`release.md`](./release.md) とする。本仕様は、CI 上でいつどの Job が走り、Artifact をどう扱うかだけを定義する。

### Release Trigger

Release Workflow は Git Tag (例: `v1.0.0`) を基準とする。`main` への Push だけで Production Release を行わない。

### Release Pipeline

基本 Pipeline は Git Tag → Validate Version → Build Release → Unit Test → UI / Smoke Test → Archive → Artifact Validation → Create Release → Distribution とする。Production Distribution の可否、RC、Store 提出、Rollback は [`release.md`](./release.md) に従う。

### Signing / Environment

Signing Credential は CI Repository に直接保存しない。Production Signing および Production Distribution は Release Environment に限定する。

```yaml
environment:
  name: production
```

必要に応じて Environment Approval を設定する。GitHub の Environment Secret は対象 Environment の Job に限定でき、Required Reviewers を設定した場合は承認されるまで Secret を利用できない。([Deployments and environments · github/docs · GitHub](https://github.com/github/docs/blob/main/content/actions/reference/workflows-and-actions/deployments-and-environments.md))

### Artifact

Release Artifact は作成後に変更しない。Artifact には Version / Build Number / Git Commit SHA を関連付ける。同じ Version に対して異なる Artifact を無秩序に再生成しない。

GitHub Actions の `attestations` permission は Artifact Attestation の生成に利用できるため、Release Pipeline の Security 強化として将来導入を検討する。([Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

Release Notes / CHANGELOG の内容は [`release.md`](./release.md) を正とする。CI は生成と添付のみを担当する。

Distribution Failure が発生した場合、`Build Success`、`Distribution Failure` と `Build Failure` を区別する。Artifact が正常に生成済みの場合、再 Build ではなく Distribution のみ Retry 可能とする。CI が自動 Rollback を実行することは MVP では要求しない。

## Scheduled CI

定期的に下記を実行可能とする。

* `Nightly`
* `Weekly`

用途:

* Dependency Audit
* Security Scan
* Extended Test
* UI Test
* Documentation Link Check

通常の PR CI と Nightly CI の目的を分離する。

## CI Optimization

CI 実行時間を短縮するため、必要に応じて下記を利用する。

* Dependency キャッシュ
* Build キャッシュ
* Job Parallelization
* パス Filter
* Conditional Job
* Artifact Reuse

ただしキャッシュに Credential や Secret を含めない。

## Job Dependency

Job 間の依存関係を明示する。

例: lint / unit-test / security / docs を並列の Validation とし、その後 build → integration → release とする。独立 Job は並列実行する。

## Failure Handling

CI Failure は下記に分類する。

* `Source Failure`
* `Environment Failure`
* `Dependency Failure`
* `Infrastructure Failure`
* `External Service Failure`

下記を可能とする。

* Source Failure: `Fix Required`
* Infrastructure / External Service Failure: `Retry`

## Retry Policy

自動 Retry は Idempotent な処理に限定する。

対象例:

* Dependency Download
* External API Access
* Artifact Upload

下記を無条件に Retry しない。

* Test Failure
* Lint Failure
* Compile Error
* Security Failure

## Logging

CI Log は Debug に必要な情報を含める。

ただし下記を出力しない。

* Secret
* Token
* Private Key
* Password
* Certificate Content
* Authorization Header

Debug 時にも Secret を直接 `echo` しない。

## Security of Third-party Actions

Third-party GitHub Actions の利用を最小限にする。

利用する場合:

1. Maintainer を確認
2. Repository を確認
3. Permission を確認
4. Version を固定
5. Release / SHA を検証
6. 不要な Secret を渡さない

GitHub も Action の Version / SHA の明示を推奨している。([Workflow syntax for GitHub Actions - GitHub Docs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax))

## Workflow Permissions

Default:

```yaml
permissions: {}
```

CI:

```yaml
permissions:
  contents: read
```

Release などで Write が必要な場合:

```yaml
permissions:
  contents: write
```

ただし、必要な Job に限定する。

## Environment Variables

Non-secret Configuration は Environment Variable / Repository Variable を利用可能とする。

例:

* `IOS_DEPLOYMENT_TARGET`
* `ANDROID_MIN_SDK`
* `XCODE_VERSION`
* `SWIFT_VERSION`

Secret は Variables ではなく Secrets を使用する。

## Local / CI Consistency

CI で使用する Build / Test Command は、可能な限り Local 開発環境でも実行可能にする。

例:

* `./scripts/test.sh`
* `./scripts/lint.sh`
* `./scripts/build.sh`

CI Workflow にすべての Build Logic を直接記述しない。

## Script Boundary

Repository 内の Script を CI と Local で共有する。

推奨 Script: `bootstrap.sh` / `lint.sh` / `test.sh` / `build.sh` / `docs-lint.sh` / `release.sh` を `scripts/` に置く。GitHub Actions はこれらの Script を呼び出す薄い Orchestration Layer とする。

## CI Configuration as Code

CI/CD Configuration は Git 管理する。

対象:

* `.github/workflows/`
* `scripts/`
* `project.yml`
* `Package.swift`

Production Environment Secret は Git 管理しない。

## Documentation of CI

CI/CD の変更が Application Behavior、Build、Distribution または Release Process に影響する場合、関連する Documentation も更新する。

CI/CD に関する仕様は `./docs/` (確定に到達する前は、`./docs_mod/`) 配下で管理する。

[`cicd.md`](./cicd.md) は CI/CD Pipeline 全体を定義し、[`release.md`](./release.md) は Release Process の詳細を定義する。

両者で重複する内容については、Release Process の詳細は [`release.md`](./release.md) を正とし、[`cicd.md`](./cicd.md) では概要のみを記載する。

特に下記を必要に応じて同期する。

* [`cicd.md`](./cicd.md)
* [`release.md`](./release.md)
* [`CHANGELOG.md`](../CHANGELOG.md)
* [`README.md`](../README.md)

## CI/CD Acceptance Criteria

### Pull Request

* [ ] Pull Request で CI が実行される
* [ ] Compile が成功する
* [ ] Unit Test が成功する
* [ ] Lint が成功する
* [ ] Documentation Lint が成功する
* [ ] Security Check が成功する

### Main

* [ ] `main` が Build 可能である
* [ ] Test が成功する
* [ ] Release Candidate を生成可能である

### Release

* [ ] Version が検証される
* [ ] Release Build が成功する
* [ ] Artifact が生成される
* [ ] Git Commit と Artifact を追跡できる
* [ ] Production Environment が分離されている
* [ ] Distribution が明示的に実行される

### Security

* [ ] Secret が Source に存在しない
* [ ] Fork PR が Secret を利用できない
* [ ] `GITHUB_TOKEN` が Least Privilege である
* [ ] Third-party Actions の Version が固定されている
* [ ] Release Secret が PR CI に公開されない

### Reproducibility

* [ ] Dependency Version が再現可能である
* [ ] Xcode Version が識別可能である
* [ ] Build Number が識別可能である
* [ ] Git Commit SHA が Artifact と紐付く

## MVP CI/CD

対象機能は [`use_cases.md`](./use_cases.md) の MVP ユースケースを正本とする。本節は、初期版の必須 Job だけを定める。機能一覧は再掲しない。

* Pull Request: Lint → Unit Test → Build → Security / Dependency Check → Documentation Lint
* `main`: Full CI → Release Candidate Build
* Release の Tag / TestFlight / App Store は [`release.md`](./release.md) を正本とする。本仕様は Git Tag から Release Build を起動することだけを定める。

## Future CI/CD

将来的に下記を導入可能とする。

* Android CI
* KMP commonTest
* Android Emulator UI Test
* Google Play Internal Testing
* Automatic TestFlight Distribution
* Automatic App Store Distribution
* Dependency Auto Update
* SBOM
* Artifact Attestation
* Build Provenance
* Automatic Release Notes
* Nightly Extended UI Test
* Performance Regression Test
* Crash / Symbol Upload
* Automated Rollback Assistance

## CI/CD Architecture

PR / Merge の順序は `## CI Pipeline`、出荷ゲートは [`release.md`](./release.md) を正本とする。本仕様は、`main` から Release Candidate を切り、Git Tag で iOS / Android の Release Workflow を起動することだけを定める。

## Final Principles

S2J Package Dashboard の CI/CD は、下記を最終原則とする。

1. **Pull Request は自動検証する**
2. **`main` は常に Build 可能にする**
3. **Release は Git Tag を基準にする**
4. **Production Distribution は明示的な Release Gate の後に行う**
5. **Secret は CI Source に保存しない**
6. **`GITHUB_TOKEN` は Least Privilege とする**
7. **Third-party Actions の Version を固定する**
8. **Dependency Resolution を再現可能にする**
9. **Build Artifact と Git Commit を追跡可能にする**
10. **Local と CI の Build Script を可能な限り共通化する**
11. **iOS / Android / KMP の CI を同一の品質基準で扱う**
12. **CI/CD 自体を Application Architecture と同様に Code / Specification として管理する**
